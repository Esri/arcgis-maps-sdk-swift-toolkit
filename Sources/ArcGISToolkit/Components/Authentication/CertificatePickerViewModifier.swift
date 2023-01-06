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
import UniformTypeIdentifiers
***REMOVED***

***REMOVED***/ An object that provides the business logic for the workflow of prompting the user for a
***REMOVED***/ certificate and a password.
@MainActor final class CertificatePickerViewModel: ObservableObject {
***REMOVED******REMOVED***/ The types of certificate error.
***REMOVED***enum CertificateError: Error {
***REMOVED******REMOVED******REMOVED***/ Could not access the certificate file.
***REMOVED******REMOVED***case couldNotAccessCertificateFile
***REMOVED******REMOVED******REMOVED***/ The certificate import error.
***REMOVED******REMOVED***case importError(CertificateImportError)
***REMOVED******REMOVED******REMOVED*** The failure error.
***REMOVED******REMOVED***case failure(Error)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The challenge that requires a certificate to proceed.
***REMOVED***let challenge: NetworkChallengeContinuation
***REMOVED***
***REMOVED******REMOVED***/ The URL of the certificate that the user chose.
***REMOVED***var certificateURL: URL?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to show the prompt.
***REMOVED***@Published var showPrompt = true
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to show the certificate file picker.
***REMOVED***@Published var showPicker = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to show the password field view.
***REMOVED***@Published var showPassword = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to display the error.
***REMOVED***@Published var showCertificateError = false
***REMOVED***
***REMOVED******REMOVED***/ The certificate error that occurred.
***REMOVED***var certificateError: CertificateError?
***REMOVED***
***REMOVED******REMOVED***/ The host that prompted the challenge.
***REMOVED***var challengingHost: String {
***REMOVED******REMOVED***challenge.host
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a certificate picker view model.
***REMOVED******REMOVED***/ - Parameter challenge: The challenge that requires a certificate.
***REMOVED***init(challenge: NetworkChallengeContinuation) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Proceeds to show the file picker. This should be called after the prompt that notifies the
***REMOVED******REMOVED***/ user that a certificate must be selected.
***REMOVED***func proceedFromPrompt() {
***REMOVED******REMOVED***showPicker = true
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Proceeds to show the user the password form. This should be called after the user selects
***REMOVED******REMOVED***/ a certificate.
***REMOVED******REMOVED***/ - Parameter url: The URL of the certificate that the user chose.
***REMOVED***func proceed(withCertificateURL url: URL) {
***REMOVED******REMOVED***certificateURL = url
***REMOVED******REMOVED***showPassword = true
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Attempts to use the certificate and password to respond to the challenge.
***REMOVED******REMOVED***/ - Parameter password: The password for the certificate.
***REMOVED***func proceed(withPassword password: String) {
***REMOVED******REMOVED***guard let certificateURL = certificateURL else {
***REMOVED******REMOVED******REMOVED***preconditionFailure()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***guard certificateURL.startAccessingSecurityScopedResource() else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await self.showCertificateError(CertificateError.couldNotAccessCertificateFile)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***defer { certificateURL.stopAccessingSecurityScopedResource() ***REMOVED***

***REMOVED******REMOVED******REMOVED******REMOVED***await self.challenge.resume(with: .continueWithCredential(try .certificate(at: certificateURL, password: password)))
***REMOVED******REMOVED*** catch(let certificateImportError as CertificateImportError) {
***REMOVED******REMOVED******REMOVED******REMOVED***await self.showCertificateError(CertificateError.importError(certificateImportError))
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***await self.showCertificateError(CertificateError.failure(error))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels the challenge.
***REMOVED***func cancel() {
***REMOVED******REMOVED***challenge.resume(with: .cancel)
***REMOVED***

***REMOVED***private func showCertificateError(_ error: CertificateError) async {
***REMOVED******REMOVED******REMOVED*** This is required to prevent an "already presenting" error.
***REMOVED******REMOVED***try? await Task.sleep(nanoseconds: 100_000)
***REMOVED******REMOVED***certificateError = error
***REMOVED******REMOVED***showCertificateError = true
***REMOVED***
***REMOVED***

extension CertificatePickerViewModel.CertificateError {
***REMOVED***var message: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .couldNotAccessCertificateFile:
***REMOVED******REMOVED******REMOVED***return "Could not access the certificate file."
***REMOVED******REMOVED***case .importError(let certificateImportError):
***REMOVED******REMOVED******REMOVED***switch certificateImportError {
***REMOVED******REMOVED******REMOVED***case .invalidData:
***REMOVED******REMOVED******REMOVED******REMOVED***return "The certificate file was invalid."
***REMOVED******REMOVED******REMOVED***case .invalidPassword:
***REMOVED******REMOVED******REMOVED******REMOVED***return "The password was invalid."
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***return "The certificate file or password was invalid."
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED***return error.localizedDescription
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view modifier that presents a certificate picker workflow.
struct CertificatePickerViewModifier: ViewModifier {
***REMOVED******REMOVED***/ Creates a certificate picker view modifier.
***REMOVED******REMOVED***/ - Parameter challenge: The challenge that requires a certificate.
***REMOVED***init(challenge: NetworkChallengeContinuation) {
***REMOVED******REMOVED***viewModel = CertificatePickerViewModel(challenge: challenge)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model.
***REMOVED***@ObservedObject private var viewModel: CertificatePickerViewModel
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.promptBrowseCertificate(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showPrompt,
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel: viewModel
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.certificateFilePicker(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showPicker,
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel: viewModel
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.credentialInput(
***REMOVED******REMOVED******REMOVED******REMOVED***fields: .password,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showPassword,
***REMOVED******REMOVED******REMOVED******REMOVED***message: "Please enter a password for the chosen certificate.",
***REMOVED******REMOVED******REMOVED******REMOVED***title: "Password Required",
***REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: "Cancel",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: "OK",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { _, password in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceed(withPassword: password)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.alertCertificateError(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showCertificateError,
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel: viewModel
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension UTType {
***REMOVED******REMOVED***/ A `UTType` that represents a pfx file.
***REMOVED***static let pfx = UTType(filenameExtension: "pfx")!
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Displays a prompt to the user to let them know that picking a certificate is required.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED******REMOVED***/   - viewModel: The view model associated with the view.
***REMOVED***@MainActor @ViewBuilder func promptBrowseCertificate(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***viewModel: CertificatePickerViewModel
***REMOVED***) -> some View {
***REMOVED******REMOVED***alert("Certificate Required", isPresented: isPresented, presenting: viewModel.challengingHost) { _ in
***REMOVED******REMOVED******REMOVED***Button("Browse For Certificate") {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceedFromPrompt()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED***
***REMOVED*** message: { _ in
***REMOVED******REMOVED******REMOVED***Text("A certificate is required to access content on \(viewModel.challengingHost).")
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Displays a sheet that allows the user to select a certificate file.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED******REMOVED***/   - viewModel: The view model associated with the view.
***REMOVED***@MainActor @ViewBuilder func certificateFilePicker(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***viewModel: CertificatePickerViewModel
***REMOVED***) -> some View {
***REMOVED******REMOVED***sheet(isPresented: isPresented) {
***REMOVED******REMOVED******REMOVED***DocumentPickerView(contentTypes: [.pfx]) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceed(withCertificateURL: $0)
***REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Displays an alert to notify that there was an error importing the certificate.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED******REMOVED***/   - viewModel: The view model associated with the view.
***REMOVED***@MainActor @ViewBuilder func alertCertificateError(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***viewModel: CertificatePickerViewModel
***REMOVED***) -> some View {
***REMOVED******REMOVED***
***REMOVED******REMOVED***alert("Error importing certificate", isPresented: isPresented) {
***REMOVED******REMOVED******REMOVED***Button("Try Again") {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceedFromPrompt()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED***
***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text(viewModel.certificateError?.message ?? "The certificate file or password was invalid.")
***REMOVED***
***REMOVED***
***REMOVED***
