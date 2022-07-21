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

***REMOVED***
import XCTest
@testable ***REMOVED***Toolkit
***REMOVED***

@MainActor
final class QueuedOAuthChallengeTests: XCTestCase {
***REMOVED***func testInit() {
***REMOVED******REMOVED***let portalURL = URL(string: "www.test-portal.com")!
***REMOVED******REMOVED***let clientID = "client id"
***REMOVED******REMOVED***let redirectURL = URL(string: "test-app:***REMOVED***redirect")!
***REMOVED******REMOVED***
***REMOVED******REMOVED***let config = OAuthConfiguration(
***REMOVED******REMOVED******REMOVED***portalURL: portalURL,
***REMOVED******REMOVED******REMOVED***clientID: clientID,
***REMOVED******REMOVED******REMOVED***redirectURL: redirectURL
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let challenge = QueuedOAuthChallenge(configuration: config)
***REMOVED******REMOVED***XCTAssertEqual(challenge.configuration, config)
***REMOVED***
***REMOVED***
