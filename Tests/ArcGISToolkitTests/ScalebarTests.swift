***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import Combine
***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit

@MainActor
class ScalebarTests: XCTestCase {
***REMOVED******REMOVED***/ Asserts that the scalebar view model correctly changes `isVisible`.
***REMOVED***func testAutohide() {
***REMOVED******REMOVED***var subscriptions = Set<AnyCancellable>()
***REMOVED******REMOVED***let expectation1 = expectation(description: "Went visible")
***REMOVED******REMOVED***let expectation2 = expectation(description: "Went hidden")
***REMOVED******REMOVED***var changedToVisible = false
***REMOVED******REMOVED***let viewpoint1 = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: esriRedlands,
***REMOVED******REMOVED******REMOVED***scale: 1
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let viewpoint2 = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: esriRedlands,
***REMOVED******REMOVED******REMOVED***scale: 2
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let unitsPerPoint = unitsPerPointBinding(1)
***REMOVED******REMOVED***let viewModel = scalebarViewModel(
***REMOVED******REMOVED******REMOVED***autoHide: true,
***REMOVED******REMOVED******REMOVED***unitsPerPoint: unitsPerPoint,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint1
***REMOVED******REMOVED***)
***REMOVED******REMOVED***viewModel.$isVisible.sink { isVisible in
***REMOVED******REMOVED******REMOVED***if isVisible && !changedToVisible {
***REMOVED******REMOVED******REMOVED******REMOVED***changedToVisible = true
***REMOVED******REMOVED******REMOVED******REMOVED***expectation1.fulfill()
***REMOVED******REMOVED*** else if !isVisible && changedToVisible {
***REMOVED******REMOVED******REMOVED******REMOVED***expectation2.fulfill()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.store(in: &subscriptions)
***REMOVED******REMOVED***viewModel.viewpointSubject.send(viewpoint2)
***REMOVED******REMOVED***waitForExpectations(timeout: 5.0)
***REMOVED***
***REMOVED***
***REMOVED***struct ScalebarTestCase {
***REMOVED******REMOVED***let x: Double
***REMOVED******REMOVED***let y: Double
***REMOVED******REMOVED***let sR: SpatialReference = .webMercator
***REMOVED******REMOVED***let style: ScalebarStyle
***REMOVED******REMOVED***let targetWidth: Double
***REMOVED******REMOVED***let units: ScalebarUnits
***REMOVED******REMOVED***let scale: Double
***REMOVED******REMOVED***let upp: Double
***REMOVED******REMOVED***let uGC: Bool
***REMOVED******REMOVED***let dL: Double
***REMOVED******REMOVED***let labels: [String]
***REMOVED***
***REMOVED***
***REMOVED***var testCases: [ScalebarTestCase] {[
***REMOVED******REMOVED******REMOVED*** Test metric vs imperial units
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric,   scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 137, labels: ["0", "100", "200", "300 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .imperial, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 147, labels: ["0", "50", "100", "150", "200 mi"]),
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Disable geodetic calculations
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric,   scale: 10_000_000, upp: 2645.833333330476, uGC: false, dL: 151, labels: ["0", "100", "200", "300", "400 km"]),
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test all styles
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .bar,***REMOVED******REMOVED***   targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 171, labels: ["375 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .dualUnitLine,  targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 137, labels: ["0", "100", "200", "300 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .graduatedLine, targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 137, labels: ["0", "100", "200", "300 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .line,***REMOVED******REMOVED***  targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 171, labels: ["375 km"]),
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test alternate widths
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 100, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 80,  labels: ["0", "87.5", "175 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 300, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 273, labels: ["0", "200", "400", "600 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 500, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 456, labels: ["0", "250", "500", "750", "1,000 km"]),
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test alternate points
***REMOVED******REMOVED***ScalebarTestCase(x: -24752697, y: 15406913,  style: .alternatingBar, targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 128, labels: ["0", "20", "40", "60 km"]), ***REMOVED*** Artic ocean
***REMOVED******REMOVED***ScalebarTestCase(x: -35729271, y: -13943757, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 10_000_000, upp: 2645.833333330476, uGC: true, dL: 153, labels: ["0", "30", "60", "90 km"]), ***REMOVED*** Near Antartica
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Test different scales
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 100,***REMOVED******REMOVED***upp: 0.02645833333330476, uGC: true, dL: 137, labels: ["0", "1", "2", "3 m"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 1_000,***REMOVED***  upp: 0.26458333333304757, uGC: true, dL: 137, labels: ["0", "10", "20", "30 m"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 10_000,***REMOVED*** upp: 2.6458333333304758,  uGC: true, dL: 137, labels: ["0", "100", "200", "300 m"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 100_000,***REMOVED***upp: 26.458333333304758,  uGC: true, dL: 137, labels: ["0", "1", "2", "3 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 1_000_000,  upp: 264.58333333304756,  uGC: true, dL: 137, labels: ["0", "10", "20", "30 km"]),
***REMOVED******REMOVED***ScalebarTestCase(x: esriRedlands.x, y: esriRedlands.y, style: .alternatingBar, targetWidth: 175, units: .metric, scale: 80_000_000, upp: 21166.666666643807,  uGC: true, dL: 143, labels: ["0", "1,250", "2,500 km"])
***REMOVED***]***REMOVED***
***REMOVED***
***REMOVED***func testAllCases() {
***REMOVED******REMOVED***for test in testCases {
***REMOVED******REMOVED******REMOVED***let viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED******REMOVED***center: Point(x: test.x, y: test.y, spatialReference: test.sR),
***REMOVED******REMOVED******REMOVED******REMOVED***scale: test.scale
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***let unitsPerPoint = unitsPerPointBinding(test.upp)
***REMOVED******REMOVED******REMOVED***let viewModel = ScalebarViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***false,
***REMOVED******REMOVED******REMOVED******REMOVED***0,
***REMOVED******REMOVED******REMOVED******REMOVED***test.sR,
***REMOVED******REMOVED******REMOVED******REMOVED***test.style,
***REMOVED******REMOVED******REMOVED******REMOVED***test.targetWidth,
***REMOVED******REMOVED******REMOVED******REMOVED***test.units,
***REMOVED******REMOVED******REMOVED******REMOVED***unitsPerPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***test.uGC,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(viewModel.displayLength.rounded(), test.dL)
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
***REMOVED******REMOVED***/ Generates a binding to a provided units per point value.
***REMOVED***func unitsPerPointBinding(_ value: Double) -> Binding<Double?> {
***REMOVED******REMOVED***var _value = value
***REMOVED******REMOVED***return Binding(
***REMOVED******REMOVED******REMOVED***get: { _value ***REMOVED***,
***REMOVED******REMOVED******REMOVED***set: { _value = $0 ?? .zero ***REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Generates a new scalebar view model.
***REMOVED***func scalebarViewModel(
***REMOVED******REMOVED***autoHide: Bool = false,
***REMOVED******REMOVED***unitsPerPoint: Binding<Double?>,
***REMOVED******REMOVED***viewpoint: Viewpoint?
***REMOVED***) -> ScalebarViewModel {
***REMOVED******REMOVED***return ScalebarViewModel(
***REMOVED******REMOVED******REMOVED***autoHide,
***REMOVED******REMOVED******REMOVED***0,
***REMOVED******REMOVED******REMOVED***.webMercator,
***REMOVED******REMOVED******REMOVED***.alternatingBar,
***REMOVED******REMOVED******REMOVED***175,
***REMOVED******REMOVED******REMOVED***.imperial,
***REMOVED******REMOVED******REMOVED***unitsPerPoint,
***REMOVED******REMOVED******REMOVED***true,
***REMOVED******REMOVED******REMOVED***viewpoint
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
