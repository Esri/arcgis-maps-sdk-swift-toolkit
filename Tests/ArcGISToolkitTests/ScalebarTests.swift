***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

#if !os(visionOS)
***REMOVED***
import Combine
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

class ScalebarTests: XCTestCase {
***REMOVED***struct ScalebarTestCase {
***REMOVED******REMOVED***let x: Double
***REMOVED******REMOVED***let y: Double
***REMOVED******REMOVED***let spatialReference: SpatialReference = .webMercator
***REMOVED******REMOVED***let style: ScalebarStyle
***REMOVED******REMOVED***let maxWidth: Double
***REMOVED******REMOVED***let units: ScalebarUnits
***REMOVED******REMOVED***let scale: Double
***REMOVED******REMOVED***let unitsPerPoint: Double
***REMOVED******REMOVED***var useGeodeticCalculations: Bool = true
***REMOVED******REMOVED***let displayLength: Double
***REMOVED******REMOVED***let labels: [String]
***REMOVED***
***REMOVED***
***REMOVED***var testCases: [ScalebarTestCase] {[
***REMOVED******REMOVED******REMOVED*** Test metric vs imperial units
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .metric,   scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 137, labels: ["0", "100", "200", "300 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .imperial, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 147, labels: ["0", "50", "100", "150", "200 mi"]),
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Disable geodetic calculations
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .metric,   scale: 10_000_000, unitsPerPoint: 2645.833333330476, useGeodeticCalculations: false, displayLength: 151, labels: ["0", "100", "200", "300", "400 km"]),
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test all styles
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .bar,***REMOVED******REMOVED***   maxWidth: 175, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 171, labels: ["375 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .dualUnitLine,  maxWidth: 175, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 137, labels: ["0", "100", "200", "300 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .graduatedLine, maxWidth: 175, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 137, labels: ["0", "100", "200", "300 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .line,***REMOVED******REMOVED***  maxWidth: 175, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 171, labels: ["375 km"]),
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test alternate widths
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 100, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 80,  labels: ["0", "87.5", "175 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 300, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 273, labels: ["0", "200", "400", "600 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 500, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 456, labels: ["0", "250", "500", "750", "1,000 km"]),
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test alternate points
***REMOVED******REMOVED***ScalebarTestCase(x: -24752697, y: 15406913,  style: .alternatingBar, maxWidth: 175, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 128, labels: ["0", "20", "40", "60 km"]), ***REMOVED*** Arctic ocean
***REMOVED******REMOVED***ScalebarTestCase(x: -35729271, y: -13943757, style: .alternatingBar, maxWidth: 175, units: .metric, scale: 10_000_000, unitsPerPoint: 2645.833333330476, displayLength: 153, labels: ["0", "30", "60", "90 km"]), ***REMOVED*** Near Antartica
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test different scales
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .metric, scale: 100,***REMOVED******REMOVED***unitsPerPoint: 0.02645833333330476, displayLength: 137, labels: ["0", "1", "2", "3 m"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .metric, scale: 1_000,***REMOVED***  unitsPerPoint: 0.26458333333304757, displayLength: 137, labels: ["0", "10", "20", "30 m"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .metric, scale: 10_000,***REMOVED*** unitsPerPoint: 2.6458333333304758,  displayLength: 137, labels: ["0", "100", "200", "300 m"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .metric, scale: 100_000,***REMOVED***unitsPerPoint: 26.458333333304758,  displayLength: 137, labels: ["0", "1", "2", "3 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .metric, scale: 1_000_000,  unitsPerPoint: 264.58333333304756,  displayLength: 137, labels: ["0", "10", "20", "30 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, maxWidth: 175, units: .metric, scale: 80_000_000, unitsPerPoint: 21166.666666643807,  displayLength: 143, labels: ["0", "1,250", "2,500 km"])
***REMOVED***]***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***func testAllCases() {
***REMOVED******REMOVED***for test in testCases {
***REMOVED******REMOVED******REMOVED***let viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: Point(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: test.x,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: test.y,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***spatialReference: test.spatialReference
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***scale: test.scale
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let viewModel = ScalebarViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***test.maxWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***0,
***REMOVED******REMOVED******REMOVED******REMOVED***test.style,
***REMOVED******REMOVED******REMOVED******REMOVED***test.units,
***REMOVED******REMOVED******REMOVED******REMOVED***test.useGeodeticCalculations
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***viewModel.update(test.spatialReference)
***REMOVED******REMOVED******REMOVED***viewModel.update(test.unitsPerPoint)
***REMOVED******REMOVED******REMOVED***viewModel.update(viewpoint)
***REMOVED******REMOVED******REMOVED***viewModel.updateScale()
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(viewModel.displayLength.rounded(), test.displayLength)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(viewModel.labels.count, test.labels.count)
***REMOVED******REMOVED******REMOVED***for i in 0..<test.labels.count {
***REMOVED******REMOVED******REMOVED******REMOVED***XCTAssertEqual(viewModel.labels[i].text, test.labels[i])
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension ScalebarTests {
***REMOVED******REMOVED***/ Web mercator coordinates for Esri's Redlands campus
***REMOVED***var esriRedlands: Point {
***REMOVED******REMOVED***return Point(
***REMOVED******REMOVED******REMOVED***x: -13046081.04434825,
***REMOVED******REMOVED******REMOVED***y: 4036489.208008117,
***REMOVED******REMOVED******REMOVED***spatialReference: .webMercator
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
#endif
