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

class CompassTests: XCTestCase {
    /// Asserts that the compass accurately indicates when the compass should be hidden when autoHide
    /// is disabled.
    func testHiddenWithAutoHideOff() {
        let initialValue = 0.0
        let finalValue = 90.0
        var _viewpoint: Viewpoint? = makeViewpoint(initialValue)
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let compass = Compass(viewpoint: viewpoint, autoHide: false)
        XCTAssertFalse(compass.shouldHide)
        _viewpoint = makeViewpoint(finalValue)
        XCTAssertFalse(compass.shouldHide)
    }
    
    /// Asserts that the compass accurately indicates when the compass should be hidden when autoHide
    /// is enabled.
    func testHiddenWithAutoHideOn() {
        let initialValue = 0.0
        let finalValue = 90.0
        var _viewpoint: Viewpoint? = makeViewpoint(initialValue)
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let compass = Compass(viewpoint: viewpoint)
        XCTAssertTrue(compass.shouldHide)
        _viewpoint = makeViewpoint(finalValue)
        XCTAssertFalse(compass.shouldHide)
    }
    
    /// Asserts that the compass correctly initializes when given a nil viewpoint
    func testInit() {
        var _viewpoint: Viewpoint? = nil
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let compass = Compass(viewpoint: viewpoint)
        XCTAssertEqual(compass.shouldHide, true)
    }
    
    /// Asserts that the compass correctly initializes when given a nil viewpoint, and autoHide is disabled.
    func testInitNoAutoHide() {
        var _viewpoint: Viewpoint? = nil
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let compass = Compass(viewpoint: viewpoint, autoHide: false)
        XCTAssertEqual(compass.shouldHide, false)
    }
    
    /// Asserts that the compass correctly initializes when given only a viewpoint.
    func testInitWithViewpoint() {
        var _viewpoint: Viewpoint? = makeViewpoint(0.0)
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let compass = Compass(viewpoint: viewpoint)
        XCTAssertEqual(compass.shouldHide, true)
    }
    
    /// Asserts that the compass correctly initializes when given only a viewpoint.
    func testInitWithViewpointAndAutoHide() {
        let autoHide = false
        var _viewpoint: Viewpoint? = makeViewpoint(0)
        let viewpoint = Binding(get: { _viewpoint }, set: { _viewpoint = $0 })
        let compass = Compass(viewpoint: viewpoint, autoHide: autoHide)
        XCTAssertEqual(compass.shouldHide, false)
    }
}

extension CompassTests {
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
    func makeViewpoint(_ rotation: Double) -> Viewpoint {
        return Viewpoint(center: point, scale: scale, rotation: rotation)
    }
}
