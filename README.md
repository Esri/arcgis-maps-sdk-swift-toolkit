# ArcGIS Runtime Toolkit for Swift

[![doc](https://img.shields.io/badge/Doc-purple)](Documentation)  [![SPM](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager/)

The ArcGIS Runtime SDK for Swift Toolkit contains components that will simplify your iOS app development.  It is built off of the new Swift ArcGIS Runtime SDK.

To use Toolkit in your project:

* **[Install with Swift Package Manager](#swift-package-manager)** - Add `https://github.com/ArcGIS/arcgis-runtime-toolkit-swift` as the package repository URL.

## Toolkit Components

* [Compass](./Documentation/Compass/README.md)

* [OverviewMap](./Documentation/OverviewMap/README.md)

## Requirements
* ArcGIS Runtime SDK for Swift
* Xcode 13.0 (or higher)

The *ArcGIS Runtime Toolkit for Swift* has a *Target SDK* version of *15.0*, meaning that it can run on devices with *iOS 15.0* or newer.

## Instructions

### Swift Package Manager

 1. Open your project in Xcode
 2. Go to *File* > *Swift Packages* > *Add Package Dependency* option 
 3. Enter `https://github.com/ArcGIS/arcgis-runtime-toolkit-swift` as the package repository URL
 4. ~Choose version 100.12.0 or a later version. Click Next. Only version 100.12.0 or newer supports Swift Package Manager.~
 
 Note: The Toolkit Swift Package adds the ArcGIS SDK Swift Package as a dependency so there's no need to add both separately. If you already have the ArcGIS SDK Swift Package, delete it and just add the Toolkit Swift Package. 

 New to Swift Package Manager? Visit [swift.org/package-manager/](https://swift.org/package-manager/).

## Additional Resources

* [Developers guide documentation](https://developers.arcgis.com/ios)
* [Runtime API Reference](https://developers.arcgis.com/ios/api-reference)
* [Samples](https://github.com/Esri/arcgis-runtime-samples-ios)
* Got a question? Ask the community on our [forum](http://geonet.esri.com/community/developers/native-app-developers/arcgis-runtime-sdk-for-ios)

## Issues

Find a bug or want to request a new feature?  Please let us know by [submitting an issue](https://github.com/Esri/arcgis-runtime-toolkit-ios/issues/new).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing
Copyright 2017 - 2021 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [LICENSE]( /LICENSE) file.
