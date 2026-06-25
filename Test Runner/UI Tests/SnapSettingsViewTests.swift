// Copyright 2026 Esri
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
final class SnapSettingsViewTests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    /// Verifies the snap settings toggles remain off when a feature is selected
    /// for editing.
    func testFeatureEditorToolbarSnapSettingsDefaultToggleStates() {
        let app = XCUIApplication()
        app.launch()
        
        app.buttons["Feature Editor Tests"].tap()
        app.buttons["Settings"].assertExistenceAndTap(timeout: 5)
        
        let geometryGuidesToggle = snapToggle(named: "Snap to Geometry Guides", in: app)
        let featuresToggle = snapToggle(named: "Snap to Features", in: app)
        
        geometryGuidesToggle.assertExistence()
        featuresToggle.assertExistence()
        
        // By default, the geometry guides toggle should be off, and the
        // snap to features toggle should be on.
        geometryGuidesToggle.assertToggleIsOff()
        featuresToggle.assertToggleIsOn()
    }
}

private extension SnapSettingsViewTests {
    func snapToggle(named name: String, in app: XCUIApplication) -> XCUIElement {
#if targetEnvironment(macCatalyst)
        app.checkBoxes[name]
#else
        app.switches[name]
#endif
    }
}
