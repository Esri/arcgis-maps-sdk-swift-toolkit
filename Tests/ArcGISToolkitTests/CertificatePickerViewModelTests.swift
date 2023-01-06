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

@MainActor final class CertificatePickerViewModelTests: XCTestCase {
***REMOVED***func testViewModel() async throws {
***REMOVED******REMOVED***let challenge = NetworkChallengeContinuation(host: "host.com", kind: .certificate)
***REMOVED******REMOVED***let model = CertificatePickerViewModel(challenge: challenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.certificateURL)
***REMOVED******REMOVED***XCTAssertTrue(model.showPrompt)
***REMOVED******REMOVED***XCTAssertFalse(model.showPicker)
***REMOVED******REMOVED***XCTAssertFalse(model.showPassword)
***REMOVED******REMOVED***XCTAssertFalse(model.showCertificateError)
***REMOVED******REMOVED***XCTAssertEqual(model.challengingHost, "host.com")
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.proceedFromPrompt()
***REMOVED******REMOVED***XCTAssertTrue(model.showPicker)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let url = URL(fileURLWithPath: "/does-not-exist.pfx")
***REMOVED******REMOVED***model.proceed(withCertificateURL: url)
***REMOVED******REMOVED***XCTAssertEqual(model.certificateURL, url)
***REMOVED******REMOVED***XCTAssertTrue(model.showPassword)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.proceed(withPassword: "1234")
***REMOVED******REMOVED******REMOVED*** Have to yield here because the proceed function kicks off a task.
***REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED******REMOVED*** Have to wait here because the proceed function waits to avoid a bug.
***REMOVED******REMOVED***try? await Task.sleep(nanoseconds: 300_000)
***REMOVED******REMOVED******REMOVED*** Another yield seems to be required to deal with timing when running the test
***REMOVED******REMOVED******REMOVED*** repeatedly.
***REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED***XCTAssertTrue(model.showCertificateError)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.cancel()
***REMOVED******REMOVED***let disposition = await challenge.value
***REMOVED******REMOVED***XCTAssertEqual(disposition, .cancel)
***REMOVED***
***REMOVED***
