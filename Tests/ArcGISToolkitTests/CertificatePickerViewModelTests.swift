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
***REMOVED***
@testable ***REMOVED***Toolkit

final class CertificatePickerViewModelTests: XCTestCase {
***REMOVED***@MainActor func testViewModel() async throws {
***REMOVED******REMOVED***let challenge = NetworkChallengeContinuation(host: "host.com", kind: .certificate)
***REMOVED******REMOVED***let model = CertificatePickerViewModel(challenge: challenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED***XCTAssertNil(model.certificateURL)
***REMOVED******REMOVED***XCTAssertFalse(model.showPrompt)
***REMOVED******REMOVED***XCTAssertFalse(model.showPicker)
***REMOVED******REMOVED***XCTAssertFalse(model.showPassword)
***REMOVED******REMOVED***XCTAssertFalse(model.showCertificateError)
***REMOVED******REMOVED***XCTAssertEqual(model.challengingHost, "host.com")
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.proceedToPicker()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Have to wait here because the proceed function is delayed to avoid a bug.
***REMOVED******REMOVED***await fulfillment(
***REMOVED******REMOVED******REMOVED***of: [
***REMOVED******REMOVED******REMOVED******REMOVED***expectation(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: NSPredicate(value: true),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***evaluatedWith: model.showPicker
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***],
***REMOVED******REMOVED******REMOVED***timeout: 10.0
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***let url = URL(fileURLWithPath: "/does-not-exist.pfx")
***REMOVED******REMOVED***model.proceedToPasswordEntry(forCertificateWithURL: url)
***REMOVED******REMOVED***XCTAssertEqual(model.certificateURL, url)
***REMOVED******REMOVED***XCTAssertTrue(model.showPassword)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.proceedToUseCertificate(withPassword: "1234")
***REMOVED******REMOVED***
***REMOVED******REMOVED***await fulfillment(
***REMOVED******REMOVED******REMOVED***of: [
***REMOVED******REMOVED******REMOVED******REMOVED***expectation(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for: NSPredicate(value: true),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***evaluatedWith: model.showCertificateError
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***],
***REMOVED******REMOVED******REMOVED***timeout: 10.0
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***model.cancel()
***REMOVED******REMOVED***let disposition = await challenge.value
***REMOVED******REMOVED***XCTAssertEqual(disposition, .cancel)
***REMOVED***
***REMOVED***
***REMOVED***func testCertificateErrorLocalizedDescription() {
***REMOVED******REMOVED***let couldNotAccessCertificateFileError = CertificatePickerViewModel.CertificateError.couldNotAccessCertificateFile
***REMOVED******REMOVED***XCTAssertEqual(couldNotAccessCertificateFileError.localizedDescription, "Could not access the certificate file.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let importErrorInvalidData = CertificatePickerViewModel.CertificateError.importError(.invalidData)
***REMOVED******REMOVED***XCTAssertEqual(importErrorInvalidData.localizedDescription, "The certificate file was invalid.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let importErrorInvalidPassword = CertificatePickerViewModel.CertificateError.importError(.invalidPassword)
***REMOVED******REMOVED***XCTAssertEqual(importErrorInvalidPassword.localizedDescription, "The password was invalid.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let importErrorInternalError = CertificatePickerViewModel.CertificateError.importError(CertificateImportError(rawValue: errSecInternalError)!)
***REMOVED******REMOVED***XCTAssertEqual(importErrorInternalError.localizedDescription, "An internal error has occurred.")
***REMOVED******REMOVED***
***REMOVED******REMOVED***let otherError = CertificatePickerViewModel.CertificateError.other(NSError(domain: NSOSStatusErrorDomain, code: Int(errSecInvalidCertAuthority)))
***REMOVED******REMOVED***XCTAssertEqual(otherError.localizedDescription, "The operation couldn’t be completed. (OSStatus error -67826.)")
***REMOVED***
***REMOVED***
