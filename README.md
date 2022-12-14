# ArcGIS Maps SDK for Swift Toolkit

[![doc](https://img.shields.io/badge/Doc-purple)](Documentation)  [![SPM](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager/)

The ArcGIS Maps SDK for Swift Toolkit contains components that will simplify your iOS app development. It is built off of the new ArcGIS Maps SDK for Swift.

To use Toolkit in your project:

* **[Install with Swift Package Manager](#swift-package-manager)** - Add `https://github.com/Esri/arcgis-maps-sdk-swift-toolkit` as the package repository URL.

## Toolkit Components

* **[Authenticator](Documentation/Authenticator)** - Displays a user interface when network and ArcGIS authentication challenges occur.
* **[BasemapGallery](Documentation/BasemapGallery)** - Displays a collection of basemaps.
* **[Bookmarks](Documentation/Bookmarks)** - Shows bookmarks, from a map, scene, or a list.
* **[Compass](Documentation/Compass)** - Shows a compass direction when the map is rotated. Auto-hides when the map points north.
* **[FloatingPanel](Documentation/FloatingPanel)** - Allows display of view-related content in a "bottom sheet". 
* **[FloorFilter](Documentation/FloorFilter)** - Allows filtering of floor plan data in a geo view by a site, a building in the site, or a floor in the building. 
* **[OverviewMap](Documentation/OverviewMap)** - Displays the visible extent of a geo view in a small "inset" map.
* **[Popup](Documentation/Popup)** - Displays details, media, and attachments of features and graphics.
* **[Scalebar](Documentation/Scalebar)** - Displays current scale reference.
* **[Search](Documentation/Search)** - Displays a search experience for geo views.
* **[UtilityNetworkTrace](Documentation/UtilityNetworkTrace)** - Runs traces on a web map published with a utility network and trace configurations.

## Requirements
* ArcGIS Maps SDK for Swift
* Xcode 14.0 (or newer)

The *ArcGIS Maps SDK for Swift Toolkit* has a *Target SDK* version of *15.0*, meaning that it can run on devices with *iOS 15.0* or newer.

## Instructions

### Swift Package Manager

1. Open your Xcode project. In the menu bar, select **File** > **Add Packages...** 
1. In the search bar, enter `https://github.com/Esri/arcgis-maps-sdk-swift-toolkit` as the package repository URL. 
1. Optionally, select an option for the **Dependency Rule** if you want to specify an exact version or a range of versions to use.   
1. Click **Add Package**.
1. Add `import ArcGIS` and `import ArcGISToolkit` in your source code and start using the toolkit components.

 Note: The Toolkit Swift Package adds the ArcGIS Maps SDK for Swift Package as a dependency so there's no need to add both separately. If you already have the ArcGIS Maps SDK for Swift Package, delete it and just add the Toolkit Swift Package. 

 New to Swift Package Manager? Visit [swift.org/package-manager/](https://swift.org/package-manager/).

## Configure API Key

Some of the toolkit components and examples utilize a set of ready-to-use ArcGIS Platform services, including basemaps, and therefore require an API Key to be set in `ExamplesApp.swift`. Please see the [setup guide](https://developers.arcgis.com/swift/get-started/#3-access-services-and-content-with-an-api-key/) for more information.

## Additional Resources

* [Developers guide documentation](https://developers.arcgis.com/swift)
* [Maps SDK API Reference](https://developers.arcgis.com/swift/api-reference/documentation/arcgis)
* [Samples](https://github.com/Esri/arcgis-maps-sdk-swift-samples)
* Got a question? Ask the community on our [forum](https://community.esri.com/t5/swift-maps-sdk-questions/bd-p/swift-maps-sdk-questions)

## Issues

Find a bug or want to request a new feature?  Please let us know by [submitting an issue](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/issues/new).

## Contributing

Esri welcomes contributions from anyone and everyone. Please see our [guidelines for contributing](https://github.com/esri/contributing).

## Licensing
Copyright 2017 - 2022 Esri

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

A copy of the license is available in the repository's [LICENSE](/LICENSE?raw=1) file.
