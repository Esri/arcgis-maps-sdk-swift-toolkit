***REMOVED*** swift-tools-version:5.3
***REMOVED*** The swift-tools-version declares the minimum version of Swift required to build this package.
***REMOVED***.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import PackageDescription

let package = Package(
***REMOVED***name: "arcgis-maps-sdk-toolkit-swift",
***REMOVED***platforms: [
***REMOVED******REMOVED***.macOS("12"), .iOS("15")
***REMOVED***],
***REMOVED***products: [
***REMOVED******REMOVED***.library(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkit",
***REMOVED******REMOVED******REMOVED***targets: ["ArcGISToolkit"]
***REMOVED******REMOVED***),
***REMOVED***],
***REMOVED***dependencies: [
***REMOVED******REMOVED******REMOVED*** To use a daily build of the Swift API, change the path below to point to the daily build's `output` folder.
***REMOVED******REMOVED***.package(name: "arcgis-runtime-swift", path: "../swift/ArcGIS")
***REMOVED***],
***REMOVED***targets: [
***REMOVED******REMOVED***.target(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkit",
***REMOVED******REMOVED******REMOVED***dependencies: [
***REMOVED******REMOVED******REMOVED******REMOVED***.product(name: "ArcGIS", package: "arcgis-runtime-swift")
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***),
***REMOVED******REMOVED***.testTarget(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkitTests",
***REMOVED******REMOVED******REMOVED***dependencies: ["ArcGISToolkit"]
***REMOVED******REMOVED***)
***REMOVED***]
)
