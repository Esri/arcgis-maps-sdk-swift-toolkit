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

import XCTest
@testable ***REMOVED***Toolkit

@MainActor
class LoginViewModelTests: XCTestCase {
***REMOVED***func testViewModel() {
***REMOVED******REMOVED***var signInCalled = false
***REMOVED******REMOVED***func signIn(username: String, password: String) {
***REMOVED******REMOVED******REMOVED***signInCalled = true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var cancelCalled = false
***REMOVED******REMOVED***func cancel() {
***REMOVED******REMOVED******REMOVED***cancelCalled = true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let model = LoginViewModel(
***REMOVED******REMOVED******REMOVED***challengingHost: "host.com",
***REMOVED******REMOVED******REMOVED***onSignIn: { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***signInCalled = true
***REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED***onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED***cancelCalled = true
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(model.challengingHost, "host.com")
***REMOVED******REMOVED***XCTAssertNotNil(model.signInAction)
***REMOVED******REMOVED***XCTAssertNotNil(model.cancelAction)
***REMOVED******REMOVED***XCTAssertFalse(model.signinButtonEnabled)
***REMOVED******REMOVED***XCTAssertTrue(model.formEnabled)
***REMOVED******REMOVED***XCTAssertTrue(model.username.isEmpty)
***REMOVED******REMOVED***XCTAssertTrue(model.password.isEmpty)
***REMOVED******REMOVED***XCTAssertFalse(signInCalled)
***REMOVED******REMOVED***XCTAssertFalse(cancelCalled)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.username = "abc"
***REMOVED******REMOVED***XCTAssertFalse(model.signinButtonEnabled)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.password = "123"
***REMOVED******REMOVED***XCTAssertTrue(model.signinButtonEnabled)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.password = ""
***REMOVED******REMOVED***XCTAssertFalse(model.signinButtonEnabled)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.password = "123"
***REMOVED******REMOVED***XCTAssertTrue(model.signinButtonEnabled)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.signIn()
***REMOVED******REMOVED***XCTAssertFalse(model.formEnabled)
***REMOVED******REMOVED***XCTAssertTrue(signInCalled)
***REMOVED******REMOVED***XCTAssertFalse(cancelCalled)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.cancel()
***REMOVED******REMOVED***XCTAssertTrue(cancelCalled)
***REMOVED***
***REMOVED***
