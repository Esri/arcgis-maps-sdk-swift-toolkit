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
***REMOVED***@Published var showCertificateImportError = false
***REMOVED***
***REMOVED******REMOVED***/ The certificate import error that occurred.
***REMOVED***var certificateImportError: CertificateImportError?
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
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .useCredential(try .certificate(at: certificateURL, password: password)))
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** This is required to prevent an "already presenting" error.
***REMOVED******REMOVED******REMOVED******REMOVED***try? await Task.sleep(nanoseconds: 100_000)
***REMOVED******REMOVED******REMOVED******REMOVED***certificateImportError = error as? CertificateImportError
***REMOVED******REMOVED******REMOVED******REMOVED***showCertificateImportError = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels the challenge.
***REMOVED***func cancel() {
***REMOVED******REMOVED***challenge.resume(with: .cancel)
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
***REMOVED******REMOVED******REMOVED***.alertCertificateImportError(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showCertificateImportError,
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
***REMOVED***@MainActor @ViewBuilder func alertCertificateImportError(
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
***REMOVED******REMOVED******REMOVED***Text(message(for: viewModel.certificateImportError))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func message(for error: CertificateImportError?) -> String {
***REMOVED******REMOVED***let defaultMessage = "The certificate file or password was invalid."
***REMOVED******REMOVED***guard let error = error else {
***REMOVED******REMOVED******REMOVED***return defaultMessage
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch error {
***REMOVED******REMOVED***case .invalidData:
***REMOVED******REMOVED******REMOVED***return "The certificate file was invalid."
***REMOVED******REMOVED***case .invalidPassword:
***REMOVED******REMOVED******REMOVED***return "The password was invalid."
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return defaultMessage
***REMOVED***
***REMOVED***
***REMOVED***
