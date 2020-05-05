//
//  ViewController.swift
//  iOSSoapManager
//
//  Created by ChristianNF on 05/04/2020.
//  Copyright (c) 2020 ChristianNF. All rights reserved.
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

import UIKit
/// import the Library
import iOSSoapManager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Uncomment to test it, but be sure you get a functioning soap server url, and its requirements.
        /// doTest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Function to test your soap request
    private func doTest(){
               
        /// SOAP REQUEST TEST.
        
        let namespace = "Here the Soap Server Namespace"
        let methodName = "Here the Soap Message Method Name"
        
        /// CREATING the Soap Message.
        let soapMessage = SoapMessage(withNamespace: namespace, withSoapAction: methodName)
         
        /// Adding some Http Headers to the `HTTP` Request
        /// - Note: The basics HTTP headers are handled by the 'iOSSoapManger', so you don´t need to add next HTTP Headers
        /// Content-Type: text/xml; charset="utf-8"
        /// Content-Length: n
        /// More details about HTTP headers, next link:
        /// https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
        soapMessage.addHTTPHeader(withName: "Accept-Encoding", withValue: "Encoding")
        soapMessage.addHTTPHeader(withName: "Connection", withValue: "close")
        soapMessage.addHTTPHeader(withName: "Accept-Language", withValue: "es, en-gb")
        
        
        /// Adding some prefixes to different elements of the message
        /// More details abut perfixes and attributes, next link:
        /// https://www.w3.org/TR/2000/NOTE-SOAP-20000508/#_Toc478383486
        soapMessage.setEnvelopePrefix(withPrefix: "Your Prefix")
        soapMessage.setXsiPrefix(withPrefix: "Your Prefix")
        soapMessage.setXsdPrefix(withPrefix: "Your Prefix")
        soapMessage.setEncPrefix(withPrefix: "Your Prefix")
        soapMessage.setEnvPrefix(withPrefix: "Your Prefix")
        soapMessage.setEnvelopeHeaderPrefix(withPrefix: "Your Prefix")
        soapMessage.setEnvelopeBodyPrefix(withPrefix: "Your Prefix")
        soapMessage.setEnvelopeMethodPrefix(withPrefix: "Your Prefix")
        soapMessage.setEnvelopeMethodAttribute(withAttributes: "id=\"1\" c:root=\"0\"")
        soapMessage.setNamespacePrefix(withPrefix: "Your Prefix")
        
        /// Adding come element to the ENVELOPE header
        /// - Note: Here you have to enter the entire tag with it´s prefixes and atributes, exactly as you see in the example
        /// More details about Envelope Headers, next link:
        /// https://www.w3.org/TR/2000/NOTE-SOAP-20000508/#_Toc478383497
        soapMessage.addElementToEnvelopeHeader(withFullElementString: "<t:Transaction xmlns:t=\"some-URI\" v:mustUnderstand=\"1\"> 5 </t:Transaction>")
         
        /// Some parameters to use on functions
        let paramOne = "Param one value"
        let paramTwo = "Param two value"
        let paramThree = "Param Three value"
         
        /// Constructin the Soap Message Body, adding some parameters.
        soapMessage.addParameterToSoapMethod(withParameterName: "param1", withAttributes: nil, withValue: paramOne)
        soapMessage.addParameterToSoapMethod(withParameterName: "param2", withAttributes: nil, withValue: paramTwo)
        
        
        /// You can add some attributes to the parameter, you are sending inside the method, may the server needs to know the value type of the parameter
        /// - Note: You need to add the slash when you need a double cuote, as in this example \"d:string\",
        ///         it will be sent as "d:string", or use literal strings.
        soapMessage.addParameterToSoapMethod(withParameterName: "param3", withAttributes: "i:type=\"d:string\"", withValue: paramThree)
         
        /// If you get some error from the server you are triying to comunicate, you can see the
        /// ENTIRE SOAP MESSAGE That you are sending to it by using the next function.
         soapMessage.enableMessageDebugging()
        
        let soapServerUrl = "http://soapserverurl.com"
        
        /// Once you have the entire message configured, do the request to the server.
        SB.makeRequest(withSoapObjet: soapMessage, withUrl: soapServerUrl, completion: { data, response, error in
            /// Raw data sent by the server
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print(dataString)
            }
            /// HTTP response
            else if let response = response {
                print(response)
            }
            /// HTTP error
            else if let error = error {
                print(error)
            }
        })
    }
}

