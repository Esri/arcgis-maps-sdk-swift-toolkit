// Copyright 2025 Esri
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

import XCTest

@MainActor
final class UtilityNetworkTraceTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Adds launch arguments specifying the feature to use as a trace starting point and opens the trace view.
    /// - Parameters:
    ///   - objectID: The object ID of the feature that will be used as a trace starting point.
    ///   - layerName: The name of the `FeatureLayer` containing the feature.
    func openTraceToolWithStartingPoint(_ objectID: Int, on layerName: String) {
        let app = XCUIApplication()
        let utilityNetworkTraceTestsButton = app.buttons["Utility Network Trace Tests"]
        
        // Adds the launch arguments that will be read in the test view.
        let arguments = ["-objectID", "\(objectID)", "-layerName", "\(layerName)"]
        app.launchArguments.append(contentsOf: arguments)
        
        // Opens the utility network trace test view.
        app.launch()
        utilityNetworkTraceTestsButton.tap()
    }
    
    // MARK: - UtilityNetworkTrace Tests
    
    /// Verifies that the correct default titles are shown for an associations element with no titles specified.
    func testTracingProgressIndicator() {
        let app = XCUIApplication()
        let selectTraceConfiguration = app.staticTexts["Select Trace Configuration"]
        let connected = app.buttons["Connected"]
        let traceButton = app.buttons["Trace"]
        let progressIndicator = app.activityIndicators["Tracing…"]
        
        openTraceToolWithStartingPoint(3321, on: .electricDistributionDevice)
        
        // Expectation: The default title is "Associations".
        XCTAssertTrue(
            selectTraceConfiguration.waitForExistence(timeout: 10),
            "The trace configuration option doesn't exist."
        )
        
        selectTraceConfiguration.tap()
        
        // Expectation: The default title is "Associations".
        XCTAssertTrue(
            connected.waitForExistence(timeout: 10),
            "The element \"Associations\" doesn't exist."
        )
        
        connected.tap()
        
        traceButton.tap()
        
        XCTAssertTrue(
            progressIndicator.waitForNonExistence(timeout: 10),
            "The tracing progress indicator was still visible after 10 seconds."
        )
    }
}

private extension String {
    static let electricDistributionDevice = "Electric Distribution Device"
}
