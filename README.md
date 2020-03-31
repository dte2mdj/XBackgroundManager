# XBackgroundManager
[![Platform](https://img.shields.io/badge/platform-iOS-green)](https://cocoapods.org/pods/XBackgroundManager)
[![License](https://img.shields.io/badge/license-MIT-9cf)](https://cocoapods.org/pods/XBackgroundManager)

## 描述
利用 CLLocation 定位实现 App 在进入后台后长久存活

## 必要配置
```
******************* XBackgroundManager *******************
                     请检查 info 中配置

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>AlwaysAndWhenInUseUsage描述</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>InUseUsage描述</string>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>location</string>
</array>

**********************************************************
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

XBackgroundManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XBackgroundManager'
```

## Author

dte2mdj, awen365@qq.com

## License

XBackgroundManager is available under the MIT license. See the LICENSE file for more info.
