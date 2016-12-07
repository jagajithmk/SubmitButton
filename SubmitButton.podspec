#
# Be sure to run `pod lib lint SubmitButton.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SubmitButton'
  s.version          = '0.1.0'
  s.summary          = 'Submitbutton library provides a better user interation for a submit button.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'Submitbutton library provide a new catching user interface for a submit button. This library is written in Swift 3. From now on, anytime the user clicks on the button that involves addressing to the server, they will see the animation that informs them of the progress and completion. '

  s.homepage         = 'https://github.com/jagajithmk/SubmitButton'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jagajith M Kalarickal' => 'jagajithmk@gmail.com' }
  s.source           = { :git => 'https://github.com/jagajithmk/SubmitButton.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'SubmitButton/Classes/**/*'
  
  # s.resource_bundles = {
  #   'SubmitButton' => ['SubmitButton/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
