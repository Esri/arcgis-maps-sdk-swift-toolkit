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

@MainActor final class CertificatePickerViewModelTests: XCTestCase {
    func testViewModel() async throws {
        let challenge = NetworkChallengeContinuation(host: "host.com", kind: .certificate)
        let model = CertificatePickerViewModel(challenge: challenge)
        
        XCTAssertNil(model.certificateURL)
        XCTAssertTrue(model.showPrompt)
        XCTAssertFalse(model.showPicker)
        XCTAssertFalse(model.showPassword)
        XCTAssertFalse(model.showCertificateImportError)
        XCTAssertEqual(model.challengingHost, "host.com")
        
        model.proceedFromPrompt()
        XCTAssertTrue(model.showPicker)
        
        let url = URL(fileURLWithPath: "/does-not-exist.pfx")
        model.proceed(withCertificateURL: url)
        XCTAssertEqual(model.certificateURL, url)
        XCTAssertTrue(model.showPassword)
        
        model.proceed(withPassword: "1234")
        // Have to yield here because the proceed function kicks off a task.
        await Task.yield()
        // Have to wait here because the proceed function waits to avoid a bug.
        try? await Task.sleep(nanoseconds: 300_000)
        // Another yield seems to be required to deal with timing when running the test
        // repeatedly.
        await Task.yield()
        XCTAssertTrue(model.showCertificateImportError)
        
        model.cancel()
        let disposition = await challenge.value
        XCTAssertEqual(disposition, .cancelAuthenticationChallenge)
    }
}
