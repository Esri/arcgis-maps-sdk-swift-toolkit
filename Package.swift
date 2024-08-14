// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Copyright 2021 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import PackageDescription

let package = Package(
    name: "arcgis-maps-sdk-swift-toolkit",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .macCatalyst(.v16)
    ],
    products: [
        .library(
            name: "ArcGISToolkit",
            targets: ["ArcGISToolkit"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/Esri/arcgis-maps-sdk-swift", .upToNextMinor(from: "200.5.0"))
    ],
    targets: [
        .target(
            name: "ArcGISToolkit",
            dependencies: [
                .product(name: "ArcGIS", package: "arcgis-maps-sdk-swift")
            ],
            resources: [
                .copy("PrivacyInfo.xcprivacy")
            ]
        ),
        .testTarget(
            name: "ArcGISToolkitTests",
            dependencies: ["ArcGISToolkit"]
        )
    ]
)

for target in package.targets {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        // Experimental Features.
        .enableExperimentalFeature("AccessLevelOnImport"),
        .enableExperimentalFeature("StrictConcurrency"),
        // Upcoming Features.
        .enableUpcomingFeature("DisableOutwardActorInference")
    ]
}
