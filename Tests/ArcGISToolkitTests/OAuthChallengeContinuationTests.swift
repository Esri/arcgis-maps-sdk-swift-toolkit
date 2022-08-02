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

import SwiftUI
import XCTest
@testable import ArcGISToolkit
import ArcGIS

@MainActor final class OAuthChallengeContinuationTests: XCTestCase {
    func testInit() {
        let portalURL = URL(string: "www.test-portal.com")!
        let clientID = "client id"
        let redirectURL = URL(string: "test-app://redirect")!
        
        let config = OAuthConfiguration(
            portalURL: portalURL,
            clientID: clientID,
            redirectURL: redirectURL
        )
        
        let challenge = OAuthChallengeContinuation(configuration: config)
        XCTAssertEqual(challenge.configuration, config)
    }
}
