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
***REMOVED***name: "arcgis-runtime-toolkit-swift",
***REMOVED***platforms: [
***REMOVED******REMOVED***.iOS(.v14)
***REMOVED***],
***REMOVED***products: [
***REMOVED******REMOVED******REMOVED*** Products define the executables and libraries a package produces, and make them visible to other packages.
***REMOVED******REMOVED***.library(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkitSwift",
***REMOVED******REMOVED******REMOVED***targets: ["ArcGISToolkitSwift"]),
***REMOVED***],
***REMOVED***dependencies: [
***REMOVED******REMOVED******REMOVED*** Dependencies declare other packages that this package depends on.
***REMOVED******REMOVED******REMOVED*** .package(url: /* package url */, from: "1.0.0"),
***REMOVED******REMOVED***.package(name: "ArcGIS", path: "../swift")

***REMOVED***],
***REMOVED***targets: [
***REMOVED******REMOVED******REMOVED*** Targets are the basic building blocks of a package. A target can define a module or a test suite.
***REMOVED******REMOVED******REMOVED*** Targets can depend on other targets in this package, and on products in packages this package depends on.
***REMOVED******REMOVED***.target(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkitSwift",
***REMOVED******REMOVED******REMOVED***dependencies: ["ArcGIS"]),
***REMOVED******REMOVED***.testTarget(
***REMOVED******REMOVED******REMOVED***name: "ArcGISToolkitSwiftTests",
***REMOVED******REMOVED******REMOVED***dependencies: ["ArcGISToolkitSwift"]),
***REMOVED***]
)
