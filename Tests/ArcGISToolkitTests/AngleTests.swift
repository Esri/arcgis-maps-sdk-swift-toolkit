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

import SwiftUI
import XCTest
@testable import ArcGISToolkit

class AngleTests: XCTestCase {
    /// Tests the behvaior of `Angle`'s normalized member.
    func testNormalizedAngle() {
        XCTAssertEqual(Angle(degrees: -361.0).normalizedDegrees, 359)
        XCTAssertEqual(Angle(degrees: -360.0).normalizedDegrees, 0)
        XCTAssertEqual(Angle(degrees: -180.0).normalizedDegrees, 180)
        XCTAssertEqual(Angle(degrees: -0).normalizedDegrees, 0)
        XCTAssertEqual(Angle(degrees: 0).normalizedDegrees, 0)
        XCTAssertEqual(Angle(degrees: 45).normalizedDegrees, 45)
        XCTAssertEqual(Angle(degrees: 180).normalizedDegrees, 180)
        XCTAssertEqual(Angle(degrees: 360).normalizedDegrees, 0)
        XCTAssertEqual(Angle(degrees: 405).normalizedDegrees, 45)
    }
}
