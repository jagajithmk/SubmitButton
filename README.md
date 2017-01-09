# SubmitButton

[![Version](https://img.shields.io/cocoapods/v/SubmitButton.svg?style=flat)](http://cocoapods.org/pods/SubmitButton)
[![License](https://img.shields.io/cocoapods/l/SubmitButton.svg?style=flat)](http://cocoapods.org/pods/SubmitButton)
[![Platform](https://img.shields.io/cocoapods/p/SubmitButton.svg?style=flat)](http://cocoapods.org/pods/SubmitButton)

## Overview

SubmitButton is a subclass of UIButton, written in Swift 3. SubmitButton library provide a new catching user interface for a submit button. From now on, anytime the user clicks on the button that involves addressing to the server, they will see the animation that informs them of the progress and completion.

<p align="center">
<img src="http://i.imgur.com/IwiJgfZ.gif" alt="SubmitButton" />
</p>

## Highlights

- [x] Custom button color.
- [x] Shows loading indicator.
- [x] Support success, failed and cancelled status.
- [x] Support storyboard customization. 

## Installation

### CocoaPods:

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `SubmitButton` into your Xcode project using CocoaPods, specify it in your Podfile:
```ruby

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod "SubmitButton"
end
```

Then, run the following command:

```bash
$ pod install
```

### Manually:

* Download SubmitButton.
* Drag and drop SubmitButton directory to your project


## Example Project

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
* Xcode 7.3+
* iOS 8.0+
* Swift 2.3+

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Usage

Here is how you can use `SubmitButton`. 

Import SubmitButton to your viewcontroller,

```swift
import SubmitButton
```

* Select button type as 'Custom' in Attributes inspector 
* Use loadingType property to select the button loading type.
* Use Cancel Enable in Attributes inspector or cancelEnabled property to show cancel while loading.

```swift

submitButton.taskCompletion { (_) in
    self.submitButton.completeAnimation(status: .success)
}

```

## Author

Jagajith M Kalarickal, jagajithmk@gmail.com

## License

SubmitButton is available under the MIT license. See the LICENSE file for more info.
