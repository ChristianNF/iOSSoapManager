#
# Be sure to run `pod lib lint iOSSoapManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iOSSoapManager'
  s.version          = '0.1.0'
  s.summary          = 'iOSSoapManager is a very easy to handle library to manage soap messages and soap request.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  You will be able to cutomize the entire soap message, even the elements and it´s attributes or prefixes.
  iOSSoapManager allows you also to make a request to the soap server with your already customized soap message.
                       DESC

  s.homepage         = 'https://github.com/ChristianNF/iOSSoapManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ChristianNF' => 'christiannogueraalc@gmail.com' }
  s.source           = { :git => 'https://github.com/ChristianNF/iOSSoapManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'

  s.source_files = 'Source/**/*'
  
  # s.resource_bundles = {
  #   'iOSSoapManager' => ['iOSSoapManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
