***REMOVED*** swift-tools-version:5.9
***REMOVED*** The swift-tools-version declares the minimum version of Swift required to build this package.
***REMOVED***
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import PackageDescription

let package = Package(
***REMOVED***name: "arcgis-maps-sdk-swift-toolkit",
***REMOVED***defaultLocalization: "en",
***REMOVED***platforms: [
***REMOVED******REMOVED***.iOS(.v16),
***REMOVED******REMOVED***.macCatalyst(.v16)
***REMOVED***],
***REMOVED***products: [
***REMOVED******REMOVED***.library(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkit",
***REMOVED******REMOVED******REMOVED***targets: ["ArcGISToolkit"]
***REMOVED******REMOVED***),
***REMOVED***],
***REMOVED***dependencies: [
***REMOVED******REMOVED***.package(url: "https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift", .upToNextMinor(from: "200.5.0")),
***REMOVED******REMOVED***.package(url: "https:***REMOVED***github.com/swiftlang/swift-markdown.git", .upToNextMinor(from: "0.4.0"))
***REMOVED***],
***REMOVED***targets: [
***REMOVED******REMOVED***.target(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkit",
***REMOVED******REMOVED******REMOVED***dependencies: [
***REMOVED******REMOVED******REMOVED******REMOVED***.product(name: "ArcGIS", package: "arcgis-maps-sdk-swift"),
***REMOVED******REMOVED******REMOVED******REMOVED***.product(name: "Markdown", package: "swift-markdown")
***REMOVED******REMOVED******REMOVED***],
***REMOVED******REMOVED******REMOVED***resources: [
***REMOVED******REMOVED******REMOVED******REMOVED***.copy("PrivacyInfo.xcprivacy")
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***),
***REMOVED******REMOVED***.testTarget(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkitTests",
***REMOVED******REMOVED******REMOVED***dependencies: ["ArcGISToolkit"]
***REMOVED******REMOVED***)
***REMOVED***]
)

for target in package.targets {
***REMOVED***target.swiftSettings = (target.swiftSettings ?? []) + [
***REMOVED******REMOVED******REMOVED*** Experimental Features.
***REMOVED******REMOVED***.enableExperimentalFeature("AccessLevelOnImport"),
***REMOVED******REMOVED***.enableExperimentalFeature("StrictConcurrency"),
***REMOVED******REMOVED******REMOVED*** Upcoming Features.
***REMOVED******REMOVED***.enableUpcomingFeature("DisableOutwardActorInference")
***REMOVED***]
***REMOVED***
