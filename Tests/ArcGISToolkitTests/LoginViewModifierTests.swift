***REMOVED*** Copyright 2022 Esri
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
@testable ***REMOVED***Toolkit

@MainActor
final class LoginViewModifierTests: XCTestCase {
***REMOVED***func testMemberwiseInit() {
***REMOVED******REMOVED***var signInCalled = false
***REMOVED******REMOVED***var cancelCalled = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***let modifier = LoginViewModifier(
***REMOVED******REMOVED******REMOVED***challengingHost: "host.com",
***REMOVED******REMOVED******REMOVED***onSignIn: { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***signInCalled = true
***REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED***onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED***cancelCalled = true
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(modifier.challengingHost, "host.com")
***REMOVED******REMOVED***XCTAssertNotNil(modifier.onSignIn)
***REMOVED******REMOVED***XCTAssertNotNil(modifier.onCancel)
***REMOVED******REMOVED***XCTAssertFalse(signInCalled)
***REMOVED******REMOVED***XCTAssertFalse(cancelCalled)
***REMOVED******REMOVED***
***REMOVED******REMOVED***modifier.onSignIn(LoginCredential(username: "", password: ""))
***REMOVED******REMOVED***XCTAssertTrue(signInCalled)
***REMOVED******REMOVED***XCTAssertFalse(cancelCalled)
***REMOVED******REMOVED***
***REMOVED******REMOVED***modifier.onCancel()
***REMOVED******REMOVED***XCTAssertTrue(cancelCalled)
***REMOVED***
***REMOVED***
