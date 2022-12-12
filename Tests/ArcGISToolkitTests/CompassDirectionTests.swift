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

import XCTest
@testable import ArcGISToolkit

final class CompassDirectionTests: XCTestCase {
    /// Tests the behavior of `CompassDirection.init(_ : Double)`
    func testInitCompassDirection() {
        XCTAssertEqual(CompassDirection(-405), .northwest)
        XCTAssertEqual(CompassDirection(-360), .north)
        XCTAssertEqual(CompassDirection(0), .north)
        XCTAssertEqual(CompassDirection(22.4), .north)
        XCTAssertEqual(CompassDirection(22.5), .northeast)
        XCTAssertEqual(CompassDirection(45), .northeast)
        XCTAssertEqual(CompassDirection(90), .east)
        XCTAssertEqual(CompassDirection(135), .southeast)
        XCTAssertEqual(CompassDirection(180), .south)
        XCTAssertEqual(CompassDirection(225), .southwest)
        XCTAssertEqual(CompassDirection(270), .west)
        XCTAssertEqual(CompassDirection(315), .northwest)
        XCTAssertEqual(CompassDirection(359), .north)
        XCTAssertEqual(CompassDirection(450), .east)
    }
}
