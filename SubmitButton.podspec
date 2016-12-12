Pod::Spec.new do |s|
  s.name             = 'SubmitButton'
  s.version          = '0.2.1'
  s.summary          = 'SubmitButton library provides a better user interation for a submit button.'

  s.description      = 'Submitbutton library provide a new catching user interface for a submit button. This library is written in Swift 3. From now on, anytime the user clicks on the button that involves addressing to the server, they will see the animation that informs them of the progress and completion.'

  s.homepage         = 'https://github.com/jagajithmk/SubmitButton'
  s.screenshots     = 'http://i.imgur.com/m8zkLWE.png', 'http://i.imgur.com/X1ou1Xm.png', 'http://i.imgur.com/faZcJV9.png', 'http://i.imgur.com/ndFeaBa.png', 'http://i.imgur.com/CyaPeiY.png', 'http://i.imgur.com/RIMpcsW.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jagajith M Kalarickal' => 'jagajithmk@gmail.com' }
  s.source           = { :git => 'https://github.com/jagajithmk/SubmitButton.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.resources = "SubmitButton/Assets/*.imageset"

  s.source_files = 'SubmitButton/Classes/**/*'
  s.frameworks = 'UIKit'
end
