//
//  SMSession.swift
//  iOSSoapManager
//
//  Created by Christian Noguera on 23/04/2020.
//  Copyright © 2020 Christian Noguera. All rights reserved.
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  MARK: The above copyright notice and this permission notice shall be included in
//  MARK: all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

public class SMSession{
    
    /// Shared Singleton `SMSession` instance to be used  by all "SB.request"
    public static let `default` = SMSession()
    
    ///`URLSesion` to make the HTTP request
    let urlSession = URLSession.shared
    
    
    // MARK: - Request

    /// Make an HTTP request with a POST HTTP method, and a Soap Message as a HTTP Body
    ///
    /// - Note: This method is directly based on the native `URLSession.shared.dataTask()`
    ///         whic is an asynchronous operation.
    ///         For more information please see the Swift Documentation.
    ///
    /// - Parameters:
    ///   - soapObjetc:     `SoapObject` which contains all Soap Message Details.
    ///   - url:            `String` with the url to make the request
    ///   - httpHeaders:    `Dictionary` with the HTTP Headers to be added to the HTTP request.
    ///
    /// - Returns:
    ///   - completion:         The HTTP `Data`, `URLResponse` and `Error` .
    public func makeRequest(
        withSoapObjet soapObject: SoapMessage?,
        withUrl url: String,
        completion:@escaping (Data?, URLResponse?, Error?) -> Void){
        
        if let soapObject = soapObject  {
            let url = URL(string: url)
            var httpRequest = URLRequest(url: url! as URL)
            
            /// Load the HTTP headers contained in the Envelope, into the HTTPRequest
            for (key, value) in soapObject.httpHeaders{
                httpRequest.addValue(value, forHTTPHeaderField: key)
            }
            
            /// This POST HTTP methos is the only one way to embed the soap message into the HTTP request
            httpRequest.httpMethod = "POST"
            
            /// Insert the SoapRequest into the HTTP Resquest body as data with utf8 encoding
            httpRequest.httpBody =  "\(soapObject.getEnvelopeAsString())".data(using: String.Encoding.utf8, allowLossyConversion: false)
            
            let task = urlSession.dataTask(with: httpRequest as URLRequest,
                completionHandler: { data, response, error in
                completion(data, response, error)
                })
            task.resume()
        }
    }
    
}

// MARK: - SoapMessage

/// Class which contains all necesary data to make an Soap HTTP Request
///
/// - Note: `SoapMessage` is based on the 1.1 version described on w3.org
///          This class represents a Soap Message described on the above reference.
///          Inside the `SoapMessage` is considered the HTTP data, which is necesary to carry on an HTTP request succesfully///
///
/// - Description:
///   - Here a very short description extracted from the official documentation on w3.org
///
///   - SOAP  consists of three parts:
///         1- The SOAP envelope construct defines an overall framework for expressing what is in a message;
///         who should deal with it, and whether it is optional or mandatory.
///         2- The SOAP encoding rules defines a serialization mechanism that can be used to exchange instances
///         of application-defined datatypes.
///         3- The SOAP RPC representation defines a convention that can be used to represent remote
///         procedure calls and responses.
///
///   - In this entire `SoapMessage` is considered no just the Soap Envelope and its properties and elements inside
///     but even all HTTP requirements to carry on the  requests successfully. In order to reach that goal, all the
///     HTTP request configuration needed, are included insider this  `SoapMessage`
public class SoapMessage{
    
    /// Namespace Conventions
    static let XSI = "http://www.w3.org/2001/XMLSchema-instance"
    static let XSD = "http://www.w3.org/2001/XMLSchema"
    
    /// Encoding Conventions
    static let ENV = "http://schemas.xmlsoap.org/soap/envelope/"
    static let ENC = "http://schemas.xmlsoap.org/soap/encoding/"
    
    /// `SoapMessage` instance properties
    
    /// Namespace for this message
    private let namespace:String
    
    /// Soap Actionn for tie message
    private let soapAction:String
    
    /// The `Envelope`which is contained in this `SoapMessage`
    private var envelope: Envelope
    
    ///`HTTP headers
    var httpHeaders: [String:String] = [:]
    
    public init(withNamespace namespace:String = "", withSoapAction soapAction:String = "") {
        self.namespace = namespace
        self.soapAction = soapAction
        self.envelope = Envelope(methodName: soapAction, namespace: namespace)
        configureDefaultHTTPHeaders()
    }
    
    /// Configure some default HTTP headers
    private func configureDefaultHTTPHeaders(){
       httpHeaders = [
        "Content-Type":"text/xml; charset=utf-8",
        "Content-Length":"\(getEnvelopeAsString().count)",
        "SOAPAction": "\(getNamespace())/\(getSoapAction())"]
    }
    
    /// Add an HTTP Header to this `SoapMessage`.
    ///
    /// Used to personalize the HTTP header may expected for the the Soap Web Service
    ///
    /// - Parameters:
    ///   - headerName:     `String` with the HTTP Header entity name.
    ///   - value:          `String` with the header value.
    func addHTTPHeader(withName headerName:String, withValue value:String){
        httpHeaders[headerName] = value
    }
    
    /// Returns the namespace.
    /// Used to be inserted in to varios elements, into the Envelope and HTTPHeaders.
    ///
    /// - Returns:
    ///   - namespace:          `String` with this `SoapMessage` namespace.
    func getNamespace() -> String {
        return self.namespace
    }
    
    /// Returns the Soap Action.
    /// Used to be inserted into various elements, in the `Envelope` and HTTP Headers.
    ///
    /// - Returns:
    ///   - soapAction:             `String` with the Soap Action
    func getSoapAction() -> String {
        return self.soapAction
    }
    
    /// Add a parameter into the parameters Dictionary in the Envelope
    ///
    /// Used to insert parameteres into de Envelope, if needed
    ///
    /// - Parameters:
    ///   - parameterName:          `String` with the name of the parameter.
    ///   - attributes:             `String?`with the litteral attributes to set into this particular parameter.
    ///   - value:                  `String` with the value for this parameter.
    func addParameterToSoapMethod(
        withParameterName parameterName:String,
        withAttributes attributes:String?,
        withValue value:String){
        envelope.addParameterToSoapMethod(withParameterName: parameterName, withAttributes: attributes, withValue: value)
    }
    
    /// Add an element to the `Envelope` header.
    ///
    /// Used to insert a totally cutomized element to the `Envelpe` Header
    ///
    /// - Parameters:
    ///   - element:           `String` with the data of the element to insert into this Envelope Header.
    public func addElementToEnvelopeHeader(withFullElementString element: String){
    envelope.envelopeHeaders.append(element)
    }
    
    /// Returns entire Envelope as a String.
    /// Used to be inserted as the Body of the HTTP Request (Soap Message Body)
    ///
    /// - Returns:
    ///   - envelope:          `String`with the entire Envelope
    public func getEnvelopeAsString() -> String{
        return envelope.getFullEnvelopeString()
    }
    
    /// Set the Xsi to this Envelope
    ///
    /// Used to change the default xsi of this Envelope
    ///
    /// - Parameters:
    ///   - xsi:        `String` with the xsi to set
    public func setEnvelopeXsi(withXsi xsi: String){
        envelope.xsi = xsi
    }
    
    /// Set the Xsd to this Envelope
    ///
    /// Used to change the default xsd of this Envelope
    ///
    /// - Parameters:
    ///   - xsd:        `String`with the xsd to set
    public func setEnvelopeXsd(withXsd xsd: String){
        envelope.xsd = xsd
    }
    
    /// Set the Encoding to this Envelope
    ///
    /// Used to change the default encoding of this Envelope
    ///
    /// - Parameters:
    ///   - enc:     `String`with the enc to set
    public func setEnvelopeEnc(withEnc enc: String){
        envelope.enc = enc
    }
    
    /// Set the Env to this Envelope
    ///
    /// Used to change the default env of this Envelope
    ///
    /// - Parameters:
    ///   - env:     `String` with the  env to set
    public func setEnvelopeEnv(withEnv env: String){
        envelope.env = env
    }
    
    /// Set the Envelope prefix
    ///
    /// Used to customize the default Envelope prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String`with the prefix to set
    public func setEnvelopePrefix(withPrefix prefix:String){
        envelope.envPrefixes["Envelope"] = "\(prefix):"
    }
    
    /// Set the Envelope Header prefix
    ///
    /// Used to customize the default Envelope Header prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String` with the prefix to set
    public func setEnvelopeHeaderPrefix(withPrefix prefix:String){
        envelope.envPrefixes["EnvelopeHeader"] = "\(prefix):"
    }
    
    /// Set the Body Envelope prefix
    ///
    /// Used to customize the default Body Envelope prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String`   with the prefix to set
    public func setEnvelopeBodyPrefix(withPrefix prefix:String){
        envelope.envPrefixes["Body"] = "\(prefix):"
    }
    
    
    /// Set the Envelope Method prefix
    ///
    /// Used to customize the default Envelope Method prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String` with the prefix to set
    public func setEnvelopeMethodPrefix(withPrefix prefix:String){
        envelope.envPrefixes["Method"] = "\(prefix):"
        envelope.envPrefixes["MethodEnd"] = "\(prefix):"
    }
    
    /// Set the Envelope Method attribute
    ///
    /// Used to customize the default Envelope Method attribute
    ///
    /// - Parameters:
    ///   - attributes:     `String` with the prefix to set
    public func setEnvelopeMethodAttribute(withAttributes attributes:String){
        envelope.envAttributes["Method"] = "\(attributes)"
    }
    
    /// Set the Namspace prefix
    ///
    /// Used to customize the default namespace prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String` with the prefix to set
    public func setNamespacePrefix(withPrefix prefix:String){
        envelope.envPrefixes["Namespace"] = ":\(prefix)"
    }
    
    /// Set the Xsi prefix
    ///
    /// Used to customize the default Xsi prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String` with the prefix to set
    public func setXsiPrefix(withPrefix prefix:String){
        envelope.envPrefixes["Xsi"] = ":\(prefix)"
    }
    
    /// Set the Xsd prefix
    ///
    /// Used to customize the default Xsd prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String` with the prefix to set
    public func setXsdPrefix(withPrefix prefix:String){
        envelope.envPrefixes["Xsd"] = ":\(prefix)"
    }
    
    /// Set the Enc prefix
    ///
    /// Used to customize the default Enc prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String` with the prefix to set
    public func setEncPrefix(withPrefix prefix:String){
        envelope.envPrefixes["Enc"] = ":\(prefix)"
    }
    
    /// Set the Env prefix
    ///
    /// Used to customize the default Env prefix
    ///
    /// - Parameters:
    ///   - prefix:     `String` with the prefix to set
    public func setEnvPrefix(withPrefix prefix:String){
        envelope.envPrefixes["Env"] = ":\(prefix)"
    }
    
    /// Enablethe Soap Message Debugging
    ///
    /// Used to show the message in the console
    public func enableMessageDebugging(){
        envelope.enableSoapMessageDebugging = true
    }
    
    /// Disable the Soap Message Debugging
    ///
    /// Used to show the message in the console
    public func disableMessageDebugging(){
        envelope.enableSoapMessageDebugging = false
    }
   
    
    // MARK: - Envelope

    /// `SoapMessage` internal class that defines de body of an SOAP Message
    ///
    /// - Note: `Envelope` is a mandatory root element of a SOAP Message
    ///          It contains all data, and define tha way it must be interpreted
    class Envelope {
        
        /// Instance properties
        /// Soap Action
        private var soapMethodName=""
        
        /// Namespace to be insertes into the `Envelope`
        private var namespace=""
        
        /// Empty array to save possibles parametes to the method
        /// Used to insert parameter into the `Evelope` body if needed
        private var methodParameters = [MethodParameter]()
        
        /// Contains `Envelope` prefixes to every mandatory Envelope Element
        var envPrefixes = [String:String]()
        
        /// Contains `Envelope` attributes to every mandatory Envelope Element
        var envAttributes = [String:String]()
        
        /// Contains `Envelope` Settings
        private var envelopeSettings = [String:String]()
        
        /// Contains de `Envelope` headers
        var envelopeHeaders: [String] = []
        
        /// Enable or disable the debugging of the final message `String` tha is about to be sent.
        var enableSoapMessageDebugging = false
        
        
        /// Set default configuration for this `Envelope`
        var xsi = SoapMessage.XSD
        var xsd = SoapMessage.XSI
        var enc = SoapMessage.ENC
        var env = SoapMessage.ENV
                
        init(methodName:String, namespace:String) {
            self.soapMethodName = methodName
            self.namespace =  namespace
            loadSettings()
            setDefaultPrefixes()
            setDefaultAttributes()
        }
        
        /// Load the default necessary settings
        /// Used to insert the Xml version and Xml enconding of this Envelope
        private func loadSettings (){
            envelopeSettings["XmlVersion"]="1.0"
            envelopeSettings["XmlEncoding"]="utf-8"
        }
        
        /// Set the new version of the xml for this SoapMessage
        ///
        /// Used to change de default value of the SoapMessage Xml Version
        ///
        /// - Parameters:
        ///   - version:        `String` with the value of the version to set.
        ///
        func setXmlVersion(withXmlVersion version:String){
            envelopeSettings["XmlVersion"] = version
        }
        
        /// Set the new value for the Xml Encoding of this SoapMessage
        ///
        /// Used to change de default value of the SoapMessage Xml Encoding
        ///
        /// - Parameters:
        ///   - String:     Wtih the value of the encoding to set.
        func setXmlEnconding(withXmlEncoding encoding:String) {
            envelopeSettings["XmlEncoding"] = encoding
        }
        
        /// Load the default prefixes fot the mandatory Envelope Elements
        ///
        /// Used to set the prefixes to these elements
        private func setDefaultPrefixes(){
            envPrefixes["Envelope"] = ""
            envPrefixes["Body"] = ""
            envPrefixes["Method"] = ""
            envPrefixes["MethodEnd"] = ""
            envPrefixes["Xsi"] = ""
            envPrefixes["Xsd"] = ""
            envPrefixes["Enc"] = ""
            envPrefixes["Env"] = ""
            envPrefixes["Namespace"] = ""
            envPrefixes["EnvelopeHeader"] = ""
        }
        
        /// Load the default prefixes fot the mandatory Envelope Elements
        ///
        /// Used to set the prefixes to these elements
        private func setDefaultAttributes(){
            envAttributes["Method"] = ""
        }
              
        /// Add a parameter to the method in Envelope Body
        ///
        /// Used to add a aparameter to the Soap Message Body Method
        ///
        /// - Parameters:
        ///   - parameterName:      `String` with the tag name of this parameter
        ///   - attributes:         `String?` with the atributes for this tag name
        ///   - value:             `String` with the value for this parameter
        func addParameterToSoapMethod(withParameterName parameterName:String, withAttributes attributes:String?, withValue value:String){
            methodParameters.append(MethodParameter(withAttributes: attributes, withParameterName: parameterName, withValue: value))
        }
        
        /// Defines a fix start of the this `Envelope` structure
        ///
        /// Used to conform part of the all `Envelope` string
        ///
        /// - Returns:
        ///   - envelopStart:           `String` with the first part of the entire envelope string
        private func getEnvelopeStart() -> String {
            return """
            <?xml
                version="\(envelopeSettings["XmlVersion"]!)"
                encoding="\(envelopeSettings["XmlEncoding"]!)"?>
            <\(envPrefixes["Envelope"]!)Envelope
                xmlns\(envPrefixes["Xsi"]!)="\(xsi)"
                xmlns\(envPrefixes["Xsd"]!)="\(xsd)"
                xmlns\(envPrefixes["Enc"]!)="\(enc)"
                xmlns\(envPrefixes["Env"]!)="\(env)">
                    <\(envPrefixes["EnvelopeHeader"]!)Header>
                        \(getEnvelopeHeader())
                    </\(envPrefixes["EnvelopeHeader"]!)Header>
                    <\(envPrefixes["Body"]!)Body>
                        <\(envPrefixes["Method"]!)\(soapMethodName)
                            \(envAttributes["Method"]!)
                            xmlns\(envPrefixes["Namespace"]!)="\(namespace)">
            
            """
        }
        
        /// Defines a fix end of the this Envelope structure
        ///
        /// Used to conform part of the all Envelope string
        ///
        /// - Returns:
        ///   - String:           With the last part of the entire envelope string
        ///
        private func getEnvelopeEnd() -> String {
            return """
                        </\(envPrefixes["MethodEnd"]!)\(soapMethodName)>
                    </\(envPrefixes["Body"]!)Body>
            </\(envPrefixes["Envelope"]!)Envelope>
            
            """
        }
        
        /// Joins the three parts of this envelope, the start, the parameters (if were introduced), and the end
        ///
        /// Used to conform all Envelope string
        ///
        /// - Returns:
        ///   - entireEnvelope:          `String` with the entire envelope string
        func getFullEnvelopeString() -> String {
            if enableSoapMessageDebugging {
                print("\n--------Soap Message Debugging--------\n")
                print("\(getEnvelopeStart()) \(getParametersAsString()) \(getEnvelopeEnd())")
                print("\n--------Soap Message Debugging--------\n")
            }
            return "\(getEnvelopeStart()) \(getParametersAsString()) \(getEnvelopeEnd())"
        }
        
        /// If there is any parameter inserted into this `Envelope`, it needs to be serialized to a string in
        /// order to be added to the `Envelope` Body
        ///
        /// Used to conform a string with all inserted parameters
        ///
        /// - Returns:
        ///   - parameters:          `String` with the paratemeteres serialized
        private func getParametersAsString() -> String {
            var toReturn = ""
            for parameter in methodParameters{
                toReturn += "                   "
                toReturn += getXmlTagFromKeyValueAsString( withTagName: parameter.parameterName, withAttributes: parameter.attributes, value: parameter.value)
            }
            return toReturn
        }
        
        /// Insert the added Envelope Header parameters to the `Envelope`
        ///
        ///  - Note: Is necessary to insert the entire tag estructure, tag name, tag prefix, tag atributes, tag value
        ///          and all necesarry data for each tag on this header.
        ///
        /// Used to conform a string with all inserted enveloper header parameters
        ///
        /// - Returns:
        ///   - envelopeHeader:         `String` with the `Envelope` header
        private func getEnvelopeHeader() -> String {
            var toReturn = ""
            for element in envelopeHeaders{
                toReturn += "\(element)\n"
            }
            return toReturn
        }
    
        /// Convert a Key Value Dictionary to a Key Value Xml Element to be added to the Envelope Body
        ///
        /// Used to change all method parameter into the Enveloper body
        ///
        /// - Parameters:
        ///   - tagName:        `String` with the tagName.
        ///   - attributes:     `String?` with the Attributes if given.
        ///   - value:          `String` with the value for this tag
        ///
        /// - Returns:
        ///   - xmlTag:           `String` with Xml tag serilzed
        private func getXmlTagFromKeyValueAsString(withTagName tagName: String , withAttributes attributes:String?, value: String) -> String {
            var tagAsString=""
            if let attribute = attributes{
                tagAsString = "<\(tagName) \(attribute)>\(value)</\(tagName)>\n"
            }else{
                tagAsString = "<\(tagName)>\(value)</\(tagName)>\n"
            }
            
            return tagAsString
        }
    }
    
    
    
    //MARK: - MethodParameter
    
    /// Auxiliar class defined as an internal one because it doen´t make sense outside a SoapMessege Object
    /// Used to be inserted as the Body of the HTTP Request (Soap Message Body)
    struct MethodParameter {
        var attributes:String?
        var parameterName:String
        var value:String
        
        init(withAttributes attributes:String?, withParameterName parameterName:String, withValue value:String) {
            self.attributes = attributes
            self.parameterName = parameterName
            self.value = value
        }
    }
    
}

