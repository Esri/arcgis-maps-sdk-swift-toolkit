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

@MainActor final class QueuedArcGISChallengeTests: XCTestCase {
***REMOVED***func testInit() {
***REMOVED******REMOVED***let challenge = QueuedArcGISChallenge(host: "host.com") { _ in
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertEqual(challenge.host, "host.com")
***REMOVED******REMOVED***XCTAssertNotNil(challenge.tokenCredentialProvider)
***REMOVED***
***REMOVED***
***REMOVED***func testResumeWithLogin() async {
***REMOVED******REMOVED***struct MockError: Error {***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let challenge = QueuedArcGISChallenge(host: "host.com") { _ in
***REMOVED******REMOVED******REMOVED***throw MockError()
***REMOVED***
***REMOVED******REMOVED***challenge.resume(with: .init(username: "user1", password: "1234"))
***REMOVED******REMOVED***
***REMOVED******REMOVED***let result = await challenge.result
***REMOVED******REMOVED***XCTAssertTrue(result.error is MockError)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Make sure multiple simultaneous listeners can await the completion.
***REMOVED******REMOVED***let t1 = Task { await challenge.complete() ***REMOVED***
***REMOVED******REMOVED***let t2 = Task { await challenge.complete() ***REMOVED***
***REMOVED******REMOVED***await t1.value
***REMOVED******REMOVED***await t2.value
***REMOVED***
***REMOVED***
***REMOVED***func testCancel() async {
***REMOVED******REMOVED***let challenge = QueuedArcGISChallenge(host: "host.com") { _ in
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED******REMOVED***challenge.cancel()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let result = await challenge.result
***REMOVED******REMOVED***XCTAssertEqual(result.value, .cancelAuthenticationChallenge)
***REMOVED***
***REMOVED***

private extension Result {
***REMOVED******REMOVED***/ The error that is encapsulated in the failure case when this result is a failure.
***REMOVED***var error: Error? {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***return error
***REMOVED******REMOVED***case .success:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The success value that is encapsulated in the success case when this result is a success.
***REMOVED***var value: Success? {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .failure:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***case .success(let value):
***REMOVED******REMOVED******REMOVED***return value
***REMOVED***
***REMOVED***
***REMOVED***
