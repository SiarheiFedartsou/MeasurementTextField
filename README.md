# MeasurementTextField

[![CI Status](http://img.shields.io/travis/SiarheiFedartsou/MeasurementTextField.svg?style=flat)](https://travis-ci.org/SiarheiFedartsou/MeasurementTextField)
[![Version](https://img.shields.io/cocoapods/v/MeasurementTextField.svg?style=flat)](http://cocoapods.org/pods/MeasurementTextField)
[![License](https://img.shields.io/cocoapods/l/MeasurementTextField.svg?style=flat)](http://cocoapods.org/pods/MeasurementTextField)
[![Platform](https://img.shields.io/cocoapods/p/MeasurementTextField.svg?style=flat)](http://cocoapods.org/pods/MeasurementTextField)

UITextField-based control for (NS)Measurement values input. Provides type-safe keyboard and picker based input of different measurements(such as length, mass, speed etc). See example app for API details.

## Screenshots

<img src="/images/screenshot1.png" alt="Screenshot 1" width="50%" /><img src="/images/screenshot2.png" alt="Screenshot 2"  width="50%" />

## Example Usage

First of all you need to import `MeasurementTextField`:
```swift
import MeasurementTextField
```

Need text field for angle input? Just write:
```swift
let angleTextField = MeasurementTextField<UnitAngle>(inputType: .keyboard(.degrees))
```
Instead of `UnitAngle` you can use [any `Dimension` type defined in Foundation](https://developer.apple.com/documentation/foundation/dimension) or implement own `Dimension` subclass if you need something special.
Then to obtain [Measurement](https://developer.apple.com/documentation/foundation/measurement) value inputted by user just use `value` property:
```swift
if let value = angleTextField.value {
    let formatter = MeasurementFormatter()
    print("Your input is \(formatter.string(from: value))!")
} else {
    print("You cleared the field!")
}
```
Degrees input is not enough? Need also arc minutes and arc seconds? Just use another input type:
```swift
let angleTextField = MeasurementTextField<UnitAngle>(inputType: .picker([
    PickerColumn(unit: UnitAngle.degrees, range: 0...360, step: 1.0), // `step` is optional here, 1.0 by default
    PickerColumn(unit: UnitAngle.arcMinutes, range: 0...60),
    PickerColumn(unit: UnitAngle.arcSeconds, range: 0...60),
]))
```
Need to be notified when value is changed? Just subscribe on `UIControlEvents.valueChanged`:
```swift
@objc private func onAngleValueChanged() {
    print("Angle value was changed!")
}
angleTextField.addTarget(self, action: #selector(onAngleValueChanged), for: .valueChanged)
```

### Customization

To change text color of measurement unit label for `.keyboard` input type just change `tintColor`:
```swift
angleTextField.tintColor = .red
```
Want to remove it completely? Just pass `showMeasureUnit: false` in input type configuration:
```swift
let angleTextField = MeasurementTextField<UnitAngle>(inputType: .keyboard(.degrees, showMeasureUnit: false))
```
Also be aware that `MeasurementTextField` is an usual `UITextField`, so you can use all APIs provided by it, except of `textField(_:shouldChangeCharactersIn:replacementString:)` delegate method.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Requirements

- Swift 4

## Issues

If you need some feature or you found a bug feel free to [open an issue](https://github.com/SiarheiFedartsou/MeasurementTextField/issues/new).

## Installation

MeasurementTextField is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MeasurementTextField'
```

## Author

SiarheiFedartsou, siarhei.fedartsou@gmail.com

## License

MeasurementTextField is available under the MIT license. See the LICENSE file for more info.
