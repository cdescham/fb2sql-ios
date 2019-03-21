#
# Be sure to run `pod lib lint fb2sql-ios.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SQLDatabase'
  s.version          = '1.0.2'
  s.summary          = 'Firebase api-like Wrapper for api-platform.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
	Firebase like Wrapper for api-platform for FB to SQL Migration.
	DESC

  s.homepage         = 'https://github.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Christophe Deschamps' => 'christophe.deschamps.work@gmail.com' }
  s.source           = { :git => 'https://github.com/cdescham/fb2sql-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'fb2sql-ios-src/Classes/*.{h,m}'
  s.exclude_files = 'fb2sql-ios-src/Classes/Info.plist'
  
  # s.resource_bundles = {
  #   'fb2sql-ios' => ['fb2sql-ios/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 2.7'

end
