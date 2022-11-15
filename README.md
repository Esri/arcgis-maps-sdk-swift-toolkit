# ArcGIS Maps SDK Toolkit for Swift

[![doc](https:***REMOVED***img.shields.io/badge/Doc-purple)](Documentation)  [![SPM](https:***REMOVED***img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https:***REMOVED***github.com/apple/swift-package-manager/)

The ArcGIS Maps SDK Toolkit for Swift contains components that will simplify your iOS app development.  It is built off of the new ArcGIS Maps SDK for Swift.

To use Toolkit in your project:

* **[Install with Swift Package Manager](#swift-package-manager)** - Add `https:***REMOVED***github.com/ArcGIS/arcgis-maps-sdk-toolkit-swift` as the package repository URL.

## Toolkit Components

* **[BasemapGallery](Documentation/BasemapGallery)** - Displays a collection of basemaps.
* **[Bookmarks](Documentation/Bookmarks)** - Shows bookmarks, from a map, scene, or a list.
* **[Compass](Documentation/Compass)** - Shows a compass direction when the map is rotated. Auto-hides when the map
  points north up.
* **[FloatingPanel](Documentation/FloatingPanel)** - Allows display of view-related content in a "bottom sheet". 
* **[FloorFilter](Documentation/FloorFilter)** - Allows to filter floor plan data in a geo view by a site, a building in the site, or a floor in the building. 
* **[OverviewMap](Documentation/OverviewMap)** - Displays the visible extent of a geo view in a small "inset" map.
* **[Scalebar](Documentation/Scalebar)** - Displays current scale reference.
* **[Search](Documentation/Search)** - Displays a search experience for geo views.
* **[UtilityNetworkTrace](Documentation/UtilityNetworkTrace)** - Runs traces on a web map published with a utility network and trace configurations.
* **[Authenticator](Documentation/Authenticator)** - Displays a user interface when network and ArcGIS authentication challenges occur.


## Requirements
* ArcGIS Maps SDK for Swift
* Xcode 13.0 (or higher)

The *ArcGIS Maps SDK Toolkit for Swift* has a *Target SDK* version of *15.0*, meaning that it can run on devices with *iOS 15.0* or newer.

## Instructions

### Swift Package Manager

 1. Open your project in Xcode
 2. Go to *File* > *Swift Packages* > *Add Package Dependency* option 
 3. Enter `https:***REMOVED***github.com/ArcGIS/arcgis-maps-sdk-toolkit-swift` as the package repository URL
 4. ~Choose version 100.12.0 or a later version. Click Next. Only version 100.12.0 or newer supports Swift Package Manager.~
 
 Note: The Toolkit Swift Package adds the ArcGIS SDK Swift Package as a dependency so there's no need to add both separately. If you already have the ArcGIS SDK Swift Package, delete it and just add the Toolkit Swift Package. 

 New to Swift Package Manager? Visit [swift.org/package-manager/](https:***REMOVED***swift.org/package-manager/).

## Configure API Key

Some of the toolkit components and examples utilize a set of ready-to-use ArcGIS Platform services, including basemaps, and therefore require an API Key to be set in `ExamplesApp.swift`. Please see the [setup guide](https:***REMOVED***developers.arcgis.com/documentation/) for more information.

## Additional Resources

* [Developers guide documentation](https:***REMOVED***developers.arcgis.com/ios)
* [Maps SDK API Reference](https:***REMOVED***developers.arcgis.com/ios/api-reference)
* [Samples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-samples)
* Got a question? Ask the community on our [forum](http:***REMOVED***geonet.esri.com/community/developers/native-app-developers/arcgis-maps-sdk-for-swift)

## Issues

Find a bug or want to request a new feature?  Please let us know by [submitting an issue](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-toolkit-swift/issues/new).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https:***REMOVED***github.com/esri/contributing).

## Licensing
Copyright 2017 - 2022 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [LICENSE]( /LICENSE) file.
