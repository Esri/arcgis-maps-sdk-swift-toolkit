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
import Combine
import SwiftUI
import XCTest
@testable import ArcGISToolkit

@MainActor
class ScalebarTests: XCTestCase {
    /// Asserts that the scalebar view model correctly changes `isVisible`.
    func testAutohide() {
        var subscriptions = Set<AnyCancellable>()
        let expectation1 = expectation(description: "Went visible")
        let expectation2 = expectation(description: "Went hidden")
        var changedToVisible = false
        let viewpoint1 = Viewpoint(
            center: esriRedlands,
            scale: 1
        )
        let viewpoint2 = Viewpoint(
            center: esriRedlands,
            scale: 2
        )
        let unitsPerPoint = unitsPerPointBinding(1)
        let viewModel = scalebarViewModel(
            autoHide: true,
            unitsPerPoint: unitsPerPoint,
            viewpoint: viewpoint1
        )
        viewModel.$isVisible.sink { isVisible in
            if isVisible && !changedToVisible {
                changedToVisible = true
                expectation1.fulfill()
            } else if !isVisible && changedToVisible {
                expectation2.fulfill()
            }
        }
        .store(in: &subscriptions)
        viewModel.viewpointSubject.send(viewpoint2)
        waitForExpectations(timeout: 5.0)
    }
    
    struct ScalebarTestCase {
        let x: Double
        let y: Double
        let sR: SpatialReference = .webMercator
        let style: ScalebarStyle
        let targetWidth: Double
        let units: ScalebarUnits
        let scale: Double
        let upp: Double
        let uGC: Bool
        let dL: Double
        let labels: [String]
    }
    
    var testCases: [ScalebarTestCase] {[
        // Test metric vs imperial units
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric,   scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 137, labels: ["0", "100", "200", "300 km"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .imperial, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 147, labels: ["0", "50", "100", "150", "200 mi"]),
        
        // Disable geodetic calculations
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric,   scale: 10_000_000, upp: 2645.833333330476, uGC: false, dL: 151, labels: ["0", "100", "200", "300", "400 km"]),
        
        // Test all styles
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .bar,           targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 171, labels: ["375 km"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .dualUnitLine,  targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 137, labels: ["0", "100", "200", "300 km"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .graduatedLine, targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 137, labels: ["0", "100", "200", "300 km"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .line,          targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 171, labels: ["375 km"]),
        
        // Test alternate widths
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 100, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 80,  labels: ["0", "87.5", "175 km"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 300, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 273, labels: ["0", "200", "400", "600 km"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 500, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 456, labels: ["0", "250", "500", "750", "1,000 km"]),
        
        // Test alternate points
        ScalebarTestCase(x: -24752697, y: 15406913,  style: .alternatingBar, targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 128, labels: ["0", "20", "40", "60 km"]), // Artic ocean
        ScalebarTestCase(x: -35729271, y: -13943757, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 153, labels: ["0", "30", "60", "90 km"]), // Near Antartica
        
        // Test different scales
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 100,        upp: 0.02645833333330476, uGC: true, dL: 137, labels: ["0", "1", "2", "3 m"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 1_000,      upp: 0.26458333333304757, uGC: true, dL: 137, labels: ["0", "10", "20", "30 m"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 10_000,     upp: 2.6458333333304758,  uGC: true, dL: 137, labels: ["0", "100", "200", "300 m"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 100_000,    upp: 26.458333333304758,  uGC: true, dL: 137, labels: ["0", "1", "2", "3 km"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 1_000_000,  upp: 264.58333333304756,  uGC: true, dL: 137, labels: ["0", "10", "20", "30 km"]),
        ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 80_000_000, upp: 21166.666666643807,  uGC: true, dL: 143, labels: ["0", "1,250", "2,500 km"])
    ]}
    
    func testAllCases() {
        for test in testCases {
            let viewpoint = Viewpoint(
                center: Point(x: test.x, y: test.y, spatialReference: test.sR),
                scale: test.scale
            )
            let unitsPerPoint = unitsPerPointBinding(test.upp)
            let viewModel = ScalebarViewModel(
                false,
                0,
                test.sR,
                test.style,
                test.targetWidth,
                test.units,
                unitsPerPoint,
                test.uGC,
                viewpoint
            )
            XCTAssertEqual(viewModel.displayLength.rounded(), test.dL)
            XCTAssertEqual(viewModel.labels.count, test.labels.count)
            for i in 0..<test.labels.count {
                XCTAssertEqual(viewModel.labels[i].text, test.labels[i])
            }
        }
    }
}

extension ScalebarTests {
    /// Web mercator coordinates for Esri's Redlands campus
    var esriRedlands: Point {
        return Point(
            x: -13046081.04434825,
            y: 4036489.208008117,
            spatialReference: .webMercator
        )
    }
    
    /// Generates a binding to a provided units per point value.
    func unitsPerPointBinding(_ value: Double) -> Binding<Double?> {
        var _value = value
        return Binding(
            get: { _value },
            set: { _value = $0 ?? .zero }
        )
    }
    
    /// Generates a new scalebar view model.
    func scalebarViewModel(
        autoHide: Bool = false,
        unitsPerPoint: Binding<Double?>,
        viewpoint: Viewpoint?
    ) -> ScalebarViewModel {
        return ScalebarViewModel(
            autoHide,
            0,
            .webMercator,
            .alternatingBar,
            175,
            .imperial,
            unitsPerPoint,
            true,
            viewpoint
        )
    }
}
