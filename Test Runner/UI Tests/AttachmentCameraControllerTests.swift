// Copyright 2024 Esri
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
final class AttachmentCameraControllerTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = true
    }
    
    /// Test `AttachmentCameraController.onCameraCaptureModeChanged(perform:)`
    func testOnCameraCaptureModeChanged() throws {
        let isUnsupportedEnvironment: Bool
#if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
        isUnsupportedEnvironment = true
#else
        isUnsupportedEnvironment = false
#endif
        try XCTSkipIf(isUnsupportedEnvironment, "This test intended for iOS devices only.")
        
        let app = XCUIApplication()
        let cameraModeController = app.otherElements["CameraMode"]
        let cameraModeLabel = app.staticTexts["Camera Capture Mode"]
        let device = UIDevice.current.userInterfaceIdiom
        let orientation = app.staticTexts["Device Orientation"]
        
        app.launch()
        
        let attachmentCameraControllerTestsButton = app.buttons["AttachmentCameraController Tests"]
        
        XCTAssertTrue(
            attachmentCameraControllerTestsButton.exists,
            "The AttachmentCameraController Tests button wasn't found."
        )
        attachmentCameraControllerTestsButton.tap()
        
        // Wait for camera access alert's allow button.
        XCTAssertTrue(allowButton.waitForExistence(timeout: 5))
        allowButton.tap()
        
        XCTAssertTrue(
            cameraModeController.waitForExistence(timeout: 5)
        )
        
        if device == .pad || (device == .phone && orientation.label == "Landscape Right") {
            cameraModeController.swipeDown()
        } else if orientation.label == "Landscape Left" {
            cameraModeController.swipeUp()
        } else /* iPhone - portrait */ {
            cameraModeController.swipeRight()
        }
        
        // Wait for microphone access alert's allow button.
        XCTAssertTrue(allowButton.waitForExistence(timeout: 5))
        allowButton.tap()
        
        XCTAssertEqual(cameraModeLabel.label, "Video")
        
        if device == .pad || (device == .phone && orientation.label == "Landscape Right") {
            cameraModeController.swipeUp()
        } else if orientation.label == "Landscape Left" {
            cameraModeController.swipeDown()
        } else /* iPhone - portrait */ {
            cameraModeController.swipeLeft()
        }
        
        XCTAssertEqual(cameraModeLabel.label, "Photo")
    }
}

private extension AttachmentCameraControllerTests {
    var allowButton: XCUIElement {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let key = if #available(iOS 18.0, *) {
            "Allow"
        } else {
            "OK"
        }
        return springboard.buttons[key]
    }
}
