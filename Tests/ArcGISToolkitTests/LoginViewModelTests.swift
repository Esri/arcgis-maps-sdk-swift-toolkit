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

@MainActor final class LoginViewModelTests: XCTestCase {
    func testViewModel() {
        var signInCalled = false
        func signIn(username: String, password: String) {
            signInCalled = true
        }
        
        var cancelCalled = false
        func cancel() {
            cancelCalled = true
        }
        
        let model = LoginViewModel(
            challengingHost: "host.com",
            onSignIn: { _ in
                signInCalled = true
            },
            onCancel: {
                cancelCalled = true
            }
        )
        
        XCTAssertEqual(model.challengingHost, "host.com")
        XCTAssertNotNil(model.signInAction)
        XCTAssertNotNil(model.cancelAction)
        XCTAssertFalse(model.signInButtonEnabled)
        XCTAssertTrue(model.username.isEmpty)
        XCTAssertTrue(model.password.isEmpty)
        XCTAssertFalse(signInCalled)
        XCTAssertFalse(cancelCalled)
        
        model.username = "abc"
        XCTAssertFalse(model.signInButtonEnabled)
        
        model.password = "123"
        XCTAssertTrue(model.signInButtonEnabled)
        
        model.password = ""
        XCTAssertFalse(model.signInButtonEnabled)
        
        model.password = "123"
        XCTAssertTrue(model.signInButtonEnabled)
        
        model.signIn()
        XCTAssertTrue(signInCalled)
        XCTAssertFalse(cancelCalled)
        
        model.cancel()
        XCTAssertTrue(cancelCalled)
    }
}
