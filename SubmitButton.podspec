Pod::Spec.new do |s|
  s.name             = 'SubmitButton'
  s.version          = '0.2.1'
  s.summary          = 'SubmitButton library provides a better user interation for a submit button.'

  s.description      = 'Submitbutton library provide a new catching user interface for a submit button. This library is written in Swift 3. From now on, anytime the user clicks on the button that involves addressing to the server, they will see the animation that informs them of the progress and completion.'

  s.homepage         = 'https://github.com/jagajithmk/SubmitButton'
  s.screenshots     = 'https://github.com/jagajithmk/SubmitButton/blob/master/Images/success%20state.png', 'https://github.com/jagajithmk/SubmitButton/blob/master/Images/time%20limited%20loading%20state.png', 'https://github.com/jagajithmk/SubmitButton/blob/master/Images/error%20state.png', 'https://github.com/jagajithmk/SubmitButton/blob/master/Images/loading%20with%20cancel.png', 'https://github.com/jagajithmk/SubmitButton/blob/master/Images/cancelled%20state.png', 'https://github.com/jagajithmk/SubmitButton/blob/master/Images/infinite%20loading%20state.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jagajith M Kalarickal' => 'jagajithmk@gmail.com' }
  s.source           = { :git => 'https://github.com/jagajithmk/SubmitButton.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.resource_bundles = {
   'SubmitButton' => ['SubmitButton/Assets/*.xcassets']
    }

  s.source_files = 'SubmitButton/Classes/**/*'
  s.frameworks = 'UIKit'
end
