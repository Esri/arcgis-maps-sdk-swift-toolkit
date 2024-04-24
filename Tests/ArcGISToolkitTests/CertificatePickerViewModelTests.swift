// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import XCTest
import ArcGIS
@testable import ArcGISToolkit

final class CertificatePickerViewModelTests: XCTestCase {
    @MainActor func testViewModel() async throws {
        let challenge = NetworkChallengeContinuation(host: "host.com", kind: .certificate)
        let model = CertificatePickerViewModel(challenge: challenge)
        
        XCTAssertNil(model.certificateURL)
        XCTAssertFalse(model.showPrompt)
        XCTAssertFalse(model.showPicker)
        XCTAssertFalse(model.showPassword)
        XCTAssertFalse(model.showCertificateError)
        XCTAssertEqual(model.challengingHost, "host.com")
        
        model.proceedToPicker()
        
        // Have to wait here because the proceed function is delayed to avoid a bug.
        XCTExpectFailure(
            "fulfillment(of:timeout:enforceOrder:) doesn't work properly with Xcode 15.0 CLI tools. Ref Toolkit #699",
            options: .nonStrict()
        )
        await fulfillment(
            of: [
                expectation(
                    for: NSPredicate(value: true),
                    evaluatedWith: model.showPicker
                )
            ],
            timeout: 10.0
        )
        
        let url = URL(fileURLWithPath: "/does-not-exist.pfx")
        model.proceedToPasswordEntry(forCertificateWithURL: url)
        XCTAssertEqual(model.certificateURL, url)
        XCTAssertTrue(model.showPassword)
        
        model.proceedToUseCertificate(withPassword: "1234")
        
        XCTExpectFailure(
            "fulfillment(of:timeout:enforceOrder:) doesn't work properly with Xcode 15.0 CLI tools. Ref Toolkit #699",
            options: .nonStrict()
        )
        await fulfillment(
            of: [
                expectation(
                    for: NSPredicate(value: true),
                    evaluatedWith: model.showCertificateError
                )
            ],
            timeout: 10.0
        )
        
        model.cancel()
        let disposition = await challenge.value
        XCTAssertEqual(disposition, .cancel)
    }
    
    func testCertificateErrorLocalizedDescription() {
        let couldNotAccessCertificateFileError = CertificatePickerViewModel.CertificateError.couldNotAccessCertificateFile
        XCTAssertEqual(couldNotAccessCertificateFileError.localizedDescription, "Could not access the certificate file.")
        
        let importErrorInvalidData = CertificatePickerViewModel.CertificateError.importError(.invalidData)
        XCTAssertEqual(importErrorInvalidData.localizedDescription, "The certificate file was invalid.")
        
        let importErrorInvalidPassword = CertificatePickerViewModel.CertificateError.importError(.invalidPassword)
        XCTAssertEqual(importErrorInvalidPassword.localizedDescription, "The password was invalid.")
        
        let importErrorInternalError = CertificatePickerViewModel.CertificateError.importError(CertificateImportError(rawValue: errSecInternalError)!)
        XCTAssertEqual(importErrorInternalError.localizedDescription, "An internal error has occurred.")
        
        let otherError = CertificatePickerViewModel.CertificateError.other(NSError(domain: NSOSStatusErrorDomain, code: Int(errSecInvalidCertAuthority)))
        XCTAssertEqual(otherError.localizedDescription, "The operation couldn’t be completed. (OSStatus error -67826.)")
    }
}
