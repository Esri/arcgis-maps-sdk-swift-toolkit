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
    /// Asserts that accessibility labels are properly generated.
    func testCardinalAndIntercardinals() {
        var viewpoint = getViewpoint(0.0)
        let _viewpoint = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(viewpoint: _viewpoint)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 0 degrees north"
        )
        viewpoint = getViewpoint(23)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 337 degrees northwest"
        )
        viewpoint = getViewpoint(68)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 292 degrees west"
        )
        viewpoint = getViewpoint(113)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 247 degrees southwest"
        )
        viewpoint = getViewpoint(158)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 202 degrees south"
        )
        viewpoint = getViewpoint(203)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 157 degrees southeast"
        )
        viewpoint = getViewpoint(248)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 112 degrees east"
        )
        viewpoint = getViewpoint(293)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 67 degrees northeast"
        )
        viewpoint = getViewpoint(293)
        XCTAssertEqual(
            viewModel.viewpoint.heading,
            "Compass, heading 67 degrees northeast"
        )
    }

    /// Asserts that the model accurately indicates when the compass should be hidden when autoHide is
    /// disabled.
    func testHiddenWithAutoHideOff() {
        let initialValue = 0.0
        let finalValue = 90.0
        var viewpoint = getViewpoint(initialValue)
        let binding = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(viewpoint: binding, autoHide: false)
        XCTAssertFalse(viewModel.hidden)
        viewpoint = getViewpoint(finalValue)
        XCTAssertFalse(viewModel.hidden)
    }

    /// Asserts that the model accurately indicates when the compass should be hidden when autoHide is
    /// enabled.
    func testHiddenWithAutoHideOn() {
        let initialValue = 0.0
        let finalValue = 90.0
        var viewpoint = getViewpoint(initialValue)
        let binding = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(viewpoint: binding)
        XCTAssertTrue(viewModel.hidden)
        viewpoint = getViewpoint(finalValue)
        XCTAssertFalse(viewModel.hidden)
    }

    /// Asserts that the model correctly initializes when given only a viewpoint.
    func testInitWithViewpoint() {
        var viewpoint = getViewpoint(0.0)
        let _viewpoint = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(viewpoint: _viewpoint)
        XCTAssertTrue(viewModel.viewpoint.rotation.isZero)
        XCTAssertEqual(viewModel.height, 30.0)
        XCTAssertEqual(viewModel.width, 30.0)
        XCTAssertEqual(viewModel.autoHide, true)
    }

    /// Asserts that the model correctly initializes when given a viewpoint and size.
    func testInitWithViewpointAndSize() {
        let initialRotationValue = 0.0
        let initialSizeValue = 90.0
        var viewpoint = getViewpoint(initialRotationValue)
        let _viewpoint = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(
            viewpoint: _viewpoint,
            size: initialSizeValue
        )
        XCTAssertTrue(viewModel.viewpoint.rotation.isZero)
        XCTAssertEqual(viewModel.width, initialSizeValue)
        XCTAssertEqual(viewModel.height, initialSizeValue)
        XCTAssertEqual(viewModel.autoHide, true)
    }

    /// Asserts that the model correctly initializes when given only a viewpoint.
    func testInitWithViewpointAndSizeAndAutoHide() {
        let rotationValue = 0.0
        let sizeValue = 90.0
        let autoHide = false
        var viewpoint = getViewpoint(rotationValue)
        let _viewpoint = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(
            viewpoint: _viewpoint,
            size: sizeValue,
            autoHide: autoHide
        )
        XCTAssertTrue(viewModel.viewpoint.rotation.isZero)
        XCTAssertEqual(viewModel.width, sizeValue)
        XCTAssertEqual(viewModel.height, sizeValue)
        XCTAssertEqual(viewModel.autoHide, autoHide)
    }

    func testResetHeading() {
        let initialValue = 0.5
        let finalValue = 0.0
        var viewpoint = getViewpoint(initialValue)
        let binding = Binding(get: { viewpoint }, set: { viewpoint = $0 })
        let viewModel = CompassViewModel(viewpoint: binding)
        XCTAssertEqual(viewModel.viewpoint.rotation, initialValue)
        viewModel.resetHeading()
        XCTAssertEqual(viewModel.viewpoint.rotation, finalValue)
    }
}

extension CompassViewModelTests {
    /// An arbitrary point to use for testing.
    var point: Point {
        Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84)
    }

    /// An arbitrary scale to use for testing.
    var scale: Double {
        10_000.00
    }

    /// Builds viewpoints to use for tests.
    /// - Parameter rotation: The rotation to use for the resulting viewpoint.
    /// - Returns: A viewpoint object for tests.
    func getViewpoint(_ rotation: Double) -> Viewpoint {
        return Viewpoint(center: point, scale: scale, rotation: rotation)
    }
}
