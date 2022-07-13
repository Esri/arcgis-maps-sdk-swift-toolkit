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

import XCTest
@testable import ArcGISToolkit

@MainActor
class UsernamePasswordViewModelTests: XCTestCase {
    func testViewModel() {
        var signInCalled = false
        func signIn(username: String, password: String) {
            signInCalled = true
        }
        
        var cancelCalled = false
        func cancel() {
            cancelCalled = true
        }
        
        let model = UsernamePasswordViewModel(
            challengingHost: "host.com",
            onSignIn: { _, _ in
                signInCalled = true
            },
            onCancel: {
                cancelCalled = true
            }
        )
        
        XCTAssertEqual(model.challengingHost, "host.com")
        XCTAssertNotNil(model.signInAction)
        XCTAssertNotNil(model.cancelAction)
        XCTAssertFalse(model.signinButtonEnabled)
        XCTAssertTrue(model.formEnabled)
        XCTAssertTrue(model.username.isEmpty)
        XCTAssertTrue(model.password.isEmpty)
        XCTAssertFalse(signInCalled)
        XCTAssertFalse(cancelCalled)
        
        model.username = "abc"
        XCTAssertFalse(model.signinButtonEnabled)
        
        model.password = "123"
        XCTAssertTrue(model.signinButtonEnabled)
        
        model.password = ""
        XCTAssertFalse(model.signinButtonEnabled)
        
        model.password = "123"
        XCTAssertTrue(model.signinButtonEnabled)
        
        model.signIn()
        XCTAssertFalse(model.formEnabled)
        XCTAssertTrue(signInCalled)
        XCTAssertFalse(cancelCalled)
        
        model.cancel()
        XCTAssertTrue(cancelCalled)
    }
}
