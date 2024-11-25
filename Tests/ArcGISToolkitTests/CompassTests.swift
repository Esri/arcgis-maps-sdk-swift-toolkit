// Copyright 2022 Esri
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

#if !os(visionOS)
import ArcGIS
import SwiftUI
import XCTest
@testable import ArcGISToolkit

final class CompassTests: XCTestCase {
    /// Verifies that the compass accurately indicates it shouldn't be hidden when `autoHideDisabled`
    /// is applied.
    @MainActor
    func testHiddenWithAutoHideOff() {
        let compass1Heading = Double.zero
        let compass1 = Compass(rotation: compass1Heading, mapViewProxy: nil, action: nil)
            .autoHideDisabled()
        XCTAssertFalse(compass1.shouldHide(forHeading: compass1Heading))
        
        let compass2Heading = 45.0
        let compass2 = Compass(rotation: compass2Heading, mapViewProxy: nil, action: nil)
            .autoHideDisabled()
        XCTAssertFalse(compass2.shouldHide(forHeading: compass2Heading))
        
        let compass3Heading = Double.nan
        let compass3 = Compass(rotation: compass3Heading, mapViewProxy: nil, action: nil)
            .autoHideDisabled()
        XCTAssertFalse(compass3.shouldHide(forHeading: compass3Heading))
    }
    
    /// Verifies that the compass accurately indicates when it should be hidden.
    @MainActor
    func testHiddenWithAutoHideOn() {
        let compass1Heading: Double = .zero
        let compass1 = Compass(rotation: compass1Heading, mapViewProxy: nil, action: nil)
        XCTAssertTrue(compass1.shouldHide(forHeading: compass1Heading))
        
        let compass2Heading = 45.0
        let compass2 = Compass(rotation: compass2Heading, mapViewProxy: nil, action: nil)
        XCTAssertFalse(compass2.shouldHide(forHeading: compass2Heading))
        
        let compass3Heading = Double.nan
        let compass3 = Compass(rotation: compass3Heading, mapViewProxy: nil, action: nil)
        XCTAssertTrue(compass3.shouldHide(forHeading: compass3Heading))
    }
}
#endif
