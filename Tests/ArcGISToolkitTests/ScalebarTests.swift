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
***REMOVED******REMOVED***/ Asserts that the scalebar view model provides the correct label at a scale of 10,000,000.
***REMOVED***func testScale_10000000() {
***REMOVED******REMOVED***let correctImperialLabel = "200 mi"
***REMOVED******REMOVED***let correctMetricLabel = "300 km"
***REMOVED******REMOVED***let viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: esriRedlands,
***REMOVED******REMOVED******REMOVED***scale: 10_000_000.00
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let unitsPerPoint = unitsPerPointBinding(2645.833333330476)
***REMOVED******REMOVED***let viewModel = scalebarViewModel(
***REMOVED******REMOVED******REMOVED***unitsPerPoint: unitsPerPoint,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let calculatedMetricLabel = viewModel.alternateUnit.label
***REMOVED******REMOVED***if let calculatedImperialLabel = viewModel.labels.last?.text {
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***XCTFail()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Asserts that the scalebar view model provides the correct label at a scale of 1,000,000.
***REMOVED***func testScale_1000000() {
***REMOVED******REMOVED***let correctImperialLabel = "20 mi"
***REMOVED******REMOVED***let correctMetricLabel = "30 km"
***REMOVED******REMOVED***let viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: esriRedlands,
***REMOVED******REMOVED******REMOVED***scale: 1_000_000.00
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let unitsPerPoint = unitsPerPointBinding(264.58333333304756)
***REMOVED******REMOVED***let viewModel = scalebarViewModel(
***REMOVED******REMOVED******REMOVED***unitsPerPoint: unitsPerPoint,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let calculatedMetricLabel = viewModel.alternateUnit.label
***REMOVED******REMOVED***if let calculatedImperialLabel = viewModel.labels.last?.text {
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***XCTFail()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Asserts that the scalebar view model provides the correct label at a scale of 100,000.
***REMOVED***func testScale_100000() {
***REMOVED******REMOVED***let correctImperialLabel = "2 mi"
***REMOVED******REMOVED***let correctMetricLabel = "3 km"
***REMOVED******REMOVED***let viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: esriRedlands,
***REMOVED******REMOVED******REMOVED***scale: 100_000.00
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let unitsPerPoint = unitsPerPointBinding(26.458333333304758)
***REMOVED******REMOVED***let viewModel = scalebarViewModel(
***REMOVED******REMOVED******REMOVED***unitsPerPoint: unitsPerPoint,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let calculatedMetricLabel = viewModel.alternateUnit.label
***REMOVED******REMOVED***if let calculatedImperialLabel = viewModel.labels.last?.text {
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***XCTFail()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Asserts that the scalebar view model provides the correct label at a scale of 10,000.
***REMOVED***func testScale_10000() {
***REMOVED******REMOVED***let correctImperialLabel = "1,000 ft"
***REMOVED******REMOVED***let correctMetricLabel = "300 m"
***REMOVED******REMOVED***let viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: esriRedlands,
***REMOVED******REMOVED******REMOVED***scale: 10_000.00
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let unitsPerPoint = unitsPerPointBinding(2.6458333333304758)
***REMOVED******REMOVED***let viewModel = scalebarViewModel(
***REMOVED******REMOVED******REMOVED***unitsPerPoint: unitsPerPoint,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let calculatedMetricLabel = viewModel.alternateUnit.label
***REMOVED******REMOVED***if let calculatedImperialLabel = viewModel.labels.last?.text {
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***XCTFail()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Asserts that the scalebar view model provides the correct label at a scale of 100.
***REMOVED***func testScale_100() {
***REMOVED******REMOVED***let correctImperialLabel = "10 ft"
***REMOVED******REMOVED***let correctMetricLabel = "3 m"
***REMOVED******REMOVED***let viewpoint = Viewpoint(
***REMOVED******REMOVED******REMOVED***center: esriRedlands,
***REMOVED******REMOVED******REMOVED***scale: 100.00
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let unitsPerPoint = unitsPerPointBinding(0.02645833333330476)
***REMOVED******REMOVED***let viewModel = scalebarViewModel(
***REMOVED******REMOVED******REMOVED***unitsPerPoint: unitsPerPoint,
***REMOVED******REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED******REMOVED***)
***REMOVED******REMOVED***let calculatedMetricLabel = viewModel.alternateUnit.label
***REMOVED******REMOVED***if let calculatedImperialLabel = viewModel.labels.last?.text {
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
***REMOVED******REMOVED******REMOVED***XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***XCTFail()
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
