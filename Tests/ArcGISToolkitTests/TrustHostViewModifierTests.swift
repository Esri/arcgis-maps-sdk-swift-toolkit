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

final class TrustHostViewModifierTests: XCTestCase {
***REMOVED***@MainActor
***REMOVED***func testInit() {
***REMOVED******REMOVED***let challenge = NetworkChallengeContinuation(host: "host.com", kind: .serverTrust)
***REMOVED******REMOVED******REMOVED*** Tests the initial state.
***REMOVED******REMOVED***let modifier = TrustHostViewModifier(challenge: challenge)
***REMOVED******REMOVED***XCTAssertIdentical(modifier.challenge, challenge)
***REMOVED******REMOVED***XCTAssertFalse(modifier.isPresented)
***REMOVED***
***REMOVED***
