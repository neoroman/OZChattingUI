#
# Be sure to run `pod lib lint OZChattingUI.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OZChattingUI'
  s.version          = '0.7.8'
  s.summary          = 'OZChattingUI.framework is chatting UI with CollectionKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'OZChattingUI is a library designed to simplify the development of UI for such a trivial task as chat. It has flexible possibilities for styling, customizing. It is also contains example for fully customizable UI.'

  s.homepage         = 'https://github.com/neoroman/OZChattingUI'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Henry Kim' => 'neoroman@gmail.com' }
  s.source           = { :git => 'https://github.com/neoroman/OZChattingUI.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/neoroman'

  s.ios.deployment_target = '10.0'
  s.swift_versions = '5.0'

  s.pod_target_xcconfig = {
     "SWIFT_VERSION" => "5.0"
  }

  s.source_files = 'OZChattingUI/Sources/**/*'
  s.vendored_libraries = 'OZChattingUI/Sources/OZHelpers/LibAMRNB/libopencore-amrnb.a'

  # s.resource_bundles = {
  #   'OZChattingUI' => ['OZChattingUI/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Sources/**/*.h'
  s.weak_frameworks = 'UIKit', 'AVFoundation'
  s.dependency 'CollectionKit', '~> 2.4.0'
  s.dependency 'NVActivityIndicatorView', '~> 4.8.0'
  s.dependency 'YetAnotherAnimationLibrary', '~> 1.4.0'
end
