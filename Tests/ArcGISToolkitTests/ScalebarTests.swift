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
    
    /// Asserts that the scalebar view model provides the correct label at a scale of 10,000,000.
    func testScale_10000000() {
        let correctImperialLabel = "200 mi"
        let correctMetricLabel = "300 km"
        let viewpoint = Viewpoint(
            center: esriRedlands,
            scale: 10_000_000.00
        )
        let unitsPerPoint = unitsPerPointBinding(2645.833333330476)
        let viewModel = scalebarViewModel(
            unitsPerPoint: unitsPerPoint,
            viewpoint: viewpoint
        )
        let calculatedMetricLabel = viewModel.alternateUnit.label
        if let calculatedImperialLabel = viewModel.labels.last?.text {
            XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
            XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
        } else {
            XCTFail()
        }
    }
    
    /// Asserts that the scalebar view model provides the correct label at a scale of 1,000,000.
    func testScale_1000000() {
        let correctImperialLabel = "20 mi"
        let correctMetricLabel = "30 km"
        let viewpoint = Viewpoint(
            center: esriRedlands,
            scale: 1_000_000.00
        )
        let unitsPerPoint = unitsPerPointBinding(264.58333333304756)
        let viewModel = scalebarViewModel(
            unitsPerPoint: unitsPerPoint,
            viewpoint: viewpoint
        )
        let calculatedMetricLabel = viewModel.alternateUnit.label
        if let calculatedImperialLabel = viewModel.labels.last?.text {
            XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
            XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
        } else {
            XCTFail()
        }
    }
    
    /// Asserts that the scalebar view model provides the correct label at a scale of 100,000.
    func testScale_100000() {
        let correctImperialLabel = "2 mi"
        let correctMetricLabel = "3 km"
        let viewpoint = Viewpoint(
            center: esriRedlands,
            scale: 100_000.00
        )
        let unitsPerPoint = unitsPerPointBinding(26.458333333304758)
        let viewModel = scalebarViewModel(
            unitsPerPoint: unitsPerPoint,
            viewpoint: viewpoint
        )
        let calculatedMetricLabel = viewModel.alternateUnit.label
        if let calculatedImperialLabel = viewModel.labels.last?.text {
            XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
            XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
        } else {
            XCTFail()
        }
    }
    
    /// Asserts that the scalebar view model provides the correct label at a scale of 10,000.
    func testScale_10000() {
        let correctImperialLabel = "1,000 ft"
        let correctMetricLabel = "300 m"
        let viewpoint = Viewpoint(
            center: esriRedlands,
            scale: 10_000.00
        )
        let unitsPerPoint = unitsPerPointBinding(2.6458333333304758)
        let viewModel = scalebarViewModel(
            unitsPerPoint: unitsPerPoint,
            viewpoint: viewpoint
        )
        let calculatedMetricLabel = viewModel.alternateUnit.label
        if let calculatedImperialLabel = viewModel.labels.last?.text {
            XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
            XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
        } else {
            XCTFail()
        }
    }
    
    /// Asserts that the scalebar view model provides the correct label at a scale of 100.
    func testScale_100() {
        let correctImperialLabel = "10 ft"
        let correctMetricLabel = "3 m"
        let viewpoint = Viewpoint(
            center: esriRedlands,
            scale: 100.00
        )
        let unitsPerPoint = unitsPerPointBinding(0.02645833333330476)
        let viewModel = scalebarViewModel(
            unitsPerPoint: unitsPerPoint,
            viewpoint: viewpoint
        )
        let calculatedMetricLabel = viewModel.alternateUnit.label
        if let calculatedImperialLabel = viewModel.labels.last?.text {
            XCTAssertEqual(calculatedImperialLabel, correctImperialLabel)
            XCTAssertEqual(calculatedMetricLabel, correctMetricLabel)
        } else {
            XCTFail()
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
