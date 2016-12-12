# SubmitButton

[![Version](https://img.shields.io/cocoapods/v/SubmitButton.svg?style=flat)](http://cocoapods.org/pods/SubmitButton)
[![License](https://img.shields.io/cocoapods/l/SubmitButton.svg?style=flat)](http://cocoapods.org/pods/SubmitButton)
[![Platform](https://img.shields.io/cocoapods/p/SubmitButton.svg?style=flat)](http://cocoapods.org/pods/SubmitButton)

## Overview

SubmitButton is a subclass of UIButton, written in Swift 3. SubmitButton library provide a new catching user interface for a submit button. From now on, anytime the user clicks on the button that involves addressing to the server, they will see the animation that informs them of the progress and completion.

<p align="center">
<img src="http://i.imgur.com/IwiJgfZ.gif" alt="SubmitButton" />
</p>

![ScreenShot](http://i.imgur.com/m8zkLWE.png =320×569)
![ScreenShot](http://i.imgur.com/X1ou1Xm.png =320×569)
![ScreenShot](http://i.imgur.com/faZcJV9.png =320×569)
![ScreenShot](http://i.imgur.com/ndFeaBa.png =320×569)
![ScreenShot](http://i.imgur.com/CyaPeiY.png =320×569)
![ScreenShot](http://i.imgur.com/RIMpcsW.png =320×569)

## Requirements
* iOS8.0

## Installation with CocoaPods

SubmitButton is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SubmitButton"
```

Select button type as 'Custom' in Attributes inspector 

## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

* Use loadingType property to select the button loading type.
* Use showCancel property to show cancel while loading.
* Use didFinishedTask delegate method to handle button response.


## Release Notes

Version 0.2.1
* Added functionality to cancel loading
* Added error completion mode
* Added deleagtes for button response handling

Version 0.1.1
* Initial release

## Author

Jagajith M Kalarickal, jagajithmk@gmail.com

## License

SubmitButton is available under the MIT license. See the LICENSE file for more info.
