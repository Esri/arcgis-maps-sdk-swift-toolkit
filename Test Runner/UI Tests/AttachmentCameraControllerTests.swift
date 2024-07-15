***REMOVED*** Copyright 2024 Esri
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

import XCTest

final class AttachmentCameraControllerTests: XCTestCase {
***REMOVED***override func setUpWithError() throws {
***REMOVED******REMOVED***continueAfterFailure = true
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Test `AttachmentCameraController.onCameraCaptureModeChanged(perform:)`
***REMOVED***func testOnCameraCaptureModeChanged() throws {
***REMOVED******REMOVED***let isUnsupportedEnvironment: Bool
#if targetEnvironment(simulator) || targetEnvironment(macCatalyst)
***REMOVED******REMOVED***isUnsupportedEnvironment = true
#else
***REMOVED******REMOVED***isUnsupportedEnvironment = false
#endif
***REMOVED******REMOVED***try XCTSkipIf(isUnsupportedEnvironment, "This test intended for iOS devices only.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let app = XCUIApplication()
***REMOVED******REMOVED***let cameraModeController = app.otherElements["CameraMode"]
***REMOVED******REMOVED***let cameraModeLabel = app.staticTexts["Camera Capture Mode"]
***REMOVED******REMOVED***let device = UIDevice.current.userInterfaceIdiom
***REMOVED******REMOVED***let orientation = app.staticTexts["Device Orientation"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***app.launch()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let attachmentCameraControllerTestsButton = app.buttons["AttachmentCameraController Tests"]
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***attachmentCameraControllerTestsButton.exists,
***REMOVED******REMOVED******REMOVED***"The AttachmentCameraController Tests button wasn't found."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***attachmentCameraControllerTestsButton.tap()
***REMOVED******REMOVED***
***REMOVED******REMOVED***addUIInterruptionMonitor(withDescription: "Camera access alert") { (alert) -> Bool in
***REMOVED******REMOVED******REMOVED***alert.buttons["Allow"].tap()
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED******REMOVED***addUIInterruptionMonitor(withDescription: "Microphone access alert") { (alert) -> Bool in
***REMOVED******REMOVED******REMOVED***alert.buttons["Allow"].tap()
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertTrue(
***REMOVED******REMOVED******REMOVED***cameraModeController.waitForExistence(timeout: 5)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if device == .pad || (device == .phone && orientation.label == "Landscape Right") {
***REMOVED******REMOVED******REMOVED***cameraModeController.swipeDown()
***REMOVED*** else if orientation.label == "Landscape Left" {
***REMOVED******REMOVED******REMOVED***cameraModeController.swipeUp()
***REMOVED*** else /* iPhone - portrait */ {
***REMOVED******REMOVED******REMOVED***cameraModeController.swipeRight()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(cameraModeLabel.label, "Video")
***REMOVED******REMOVED***
***REMOVED******REMOVED***if device == .pad || (device == .phone && orientation.label == "Landscape Right") {
***REMOVED******REMOVED******REMOVED***cameraModeController.swipeUp()
***REMOVED*** else if orientation.label == "Landscape Left" {
***REMOVED******REMOVED******REMOVED***cameraModeController.swipeDown()
***REMOVED*** else /* iPhone - portrait */ {
***REMOVED******REMOVED******REMOVED***cameraModeController.swipeLeft()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(cameraModeLabel.label, "Photo")
***REMOVED***
***REMOVED***
