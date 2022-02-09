// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI
import XCTest
@testable import ArcGISToolkit

@MainActor
class CompassViewModelTests: XCTestCase {
    func testInitWithViewpoint() {
        var viewpoint = viewpoint(0.0)
        let _viewpoint = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(viewpoint: _viewpoint)
        XCTAssertTrue(viewModel.viewpoint.rotation.isZero)
    }

    func testInitWithViewpointAndSize() {
        let initialRotationValue = 90.0
        let initialSizeValue = 90.0
        var viewpoint = viewpoint(initialRotationValue)
        let _viewpoint = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(
            viewpoint: _viewpoint,
            size: initialSizeValue
        )
        XCTAssertTrue(viewModel.width.isEqual(to: initialSizeValue))
        XCTAssertTrue(viewModel.height.isEqual(to: initialSizeValue))
    }

    func testInitWithViewpointAndAutoHide() {
        let rotationValue = 90.0
        let sizeValue = 90.0
        let autoHide = false
        var viewpoint = viewpoint(rotationValue)
        let _viewpoint = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(
            viewpoint: _viewpoint,
            size: sizeValue,
            autoHide: autoHide
        )
        XCTAssertTrue(viewModel.autoHide == autoHide)
    }

    func testResetHeading() {
        let initialValue = 0.5
        let finalValue = 0.0
        var viewpoint = viewpoint(initialValue)
        let binding = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(viewpoint: binding)
        XCTAssertTrue(viewModel.viewpoint.rotation.isEqual(to: initialValue))
        viewModel.resetHeading()
        XCTAssertTrue(viewModel.viewpoint.rotation.isEqual(to: finalValue))
    }
}

extension CompassViewModelTests {
    var point: Point {
        Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84)
    }

    var scale: Double {
        10_000.00
    }

    func viewpoint(_ rotation: Double) -> Viewpoint {
        return Viewpoint(center: point, scale: scale, rotation: rotation)
    }
}
