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

***REMOVED***
import Combine
***REMOVED***
import UniformTypeIdentifiers

***REMOVED***/ An object that provides the business logic for the workflow of prompting the user for a
***REMOVED***/ certificate and a password.
@MainActor final class CertificatePickerViewModel: ObservableObject {
***REMOVED******REMOVED***/ The types of certificate error.
***REMOVED***enum CertificateError: Error {
***REMOVED******REMOVED******REMOVED***/ Could not access the certificate file.
***REMOVED******REMOVED***case couldNotAccessCertificateFile
***REMOVED******REMOVED******REMOVED***/ The certificate import error.
***REMOVED******REMOVED***case importError(CertificateImportError)
***REMOVED******REMOVED******REMOVED*** The other error.
***REMOVED******REMOVED***case other(Error)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The challenge that requires a certificate to proceed.
***REMOVED***let challenge: NetworkChallengeContinuation
***REMOVED***
***REMOVED******REMOVED***/ The URL of the certificate that the user chose.
***REMOVED***var certificateURL: URL?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether to show the prompt.
***REMOVED***@Published var showPrompt = false
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
***REMOVED***func proceedToPicker() {
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED*** If we don't delay this, then the picker does not animate in.
***REMOVED******REMOVED******REMOVED******REMOVED*** Delay for 0.25 seconds.
***REMOVED******REMOVED******REMOVED***try await Task.sleep(nanoseconds: 250_000_000)
***REMOVED******REMOVED******REMOVED***self.showPicker = true
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Proceeds to show the user the password form. This should be called after the user selects
***REMOVED******REMOVED***/ a certificate.
***REMOVED******REMOVED***/ - Parameter url: The URL of the certificate that the user chose.
***REMOVED***func proceedToPasswordEntry(forCertificateWithURL url: URL) {
***REMOVED******REMOVED***certificateURL = url
***REMOVED******REMOVED***showPassword = true
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Attempts to use the certificate and password to respond to the challenge.
***REMOVED******REMOVED***/ - Parameter password: The password for the certificate.
***REMOVED***func proceedToUseCertificate(withPassword password: String) {
***REMOVED******REMOVED***guard let certificateURL = certificateURL else {
***REMOVED******REMOVED******REMOVED***preconditionFailure()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***Task.detached {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***if certificateURL.startAccessingSecurityScopedResource() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***defer { certificateURL.stopAccessingSecurityScopedResource() ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let credential = try NetworkCredential.certificate(at: certificateURL, password: password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await self.challenge.resume(with: .continueWithCredential(credential))
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await self.showCertificateError(.couldNotAccessCertificateFile)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** catch(let certificateImportError as CertificateImportError) {
***REMOVED******REMOVED******REMOVED******REMOVED***await self.showCertificateError(.importError(certificateImportError))
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***await self.showCertificateError(.other(error))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels the challenge.
***REMOVED***func cancel() {
***REMOVED******REMOVED***challenge.resume(with: .cancel)
***REMOVED***
***REMOVED***
***REMOVED***private func showCertificateError(_ error: CertificateError) {
***REMOVED******REMOVED***certificateError = error
***REMOVED******REMOVED***showCertificateError = true
***REMOVED***
***REMOVED***

extension CertificateImportError: LocalizedError {
***REMOVED***public var errorDescription: String? {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .invalidData:
***REMOVED******REMOVED******REMOVED***return String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "The certificate file was invalid.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating the chosen file was invalid."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .invalidPassword:
***REMOVED******REMOVED******REMOVED***return String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "The password was invalid.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating the given password was invalid."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return SecCopyErrorMessageString(rawValue, nil) as String? ?? String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "The certificate file or password was invalid.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating the chosen file or given password was invalid."
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

extension CertificatePickerViewModel.CertificateError: LocalizedError {
***REMOVED***var errorDescription: String? {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .couldNotAccessCertificateFile:
***REMOVED******REMOVED******REMOVED***return String(
***REMOVED******REMOVED******REMOVED******REMOVED***localized: "Could not access the certificate file.",
***REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating a certificate file was inaccessible."
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***case .importError(let error):
***REMOVED******REMOVED******REMOVED***return error.localizedDescription
***REMOVED******REMOVED***case .other(let error):
***REMOVED******REMOVED******REMOVED***return error.localizedDescription
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view modifier that presents a certificate picker workflow.
@MainActor
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
***REMOVED******REMOVED******REMOVED***.delayedOnAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Present the prompt right away.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Setting it after initialization allows it to animate.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** However, this needs to happen after a slight delay or
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** it doesn't show.
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.showPrompt = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.promptBrowseCertificate(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showPrompt,
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel: viewModel
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.certificateFilePicker(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showPicker,
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel: viewModel
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.credentialInput(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showPassword,
***REMOVED******REMOVED******REMOVED******REMOVED***fields: .password,
***REMOVED******REMOVED******REMOVED******REMOVED***message: String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "Please enter a password for the chosen certificate.",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label requesting the password associated with the chosen certificate."
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***title: String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "Password Required",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating that a password is required to proceed with an operation."
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: String.cancel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "OK",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for button to proceed with an operation."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { _, password in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceedToUseCertificate(withPassword: password)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.certificateErrorSheet(
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
***REMOVED******REMOVED***sheet(isPresented: isPresented) {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Certificate Required",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating that a certificate is required to proceed."
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical)
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"A certificate is required to access content on \(viewModel.challengingHost).",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** An alert message indicating that a certificate is required to access
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** content on a remote host. The variable is the host that prompted the challenge.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.cancel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceedToPicker()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Browse",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button to open the system file browser."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED******REMOVED******REMOVED***.padding()
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
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceedToPasswordEntry(forCertificateWithURL: $0)
***REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED******REMOVED***/ Displays a sheet to notify that there was an error importing the certificate.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED******REMOVED***/   - viewModel: The view model associated with the view.
***REMOVED***@MainActor @ViewBuilder func certificateErrorSheet(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***viewModel: CertificatePickerViewModel
***REMOVED***) -> some View {
***REMOVED******REMOVED***sheet(isPresented: isPresented) {
***REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Error importing certificate",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** A message indicating that some error occurred while importing a chosen
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** network certificate.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** """
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.certificateError?.localizedDescription ?? String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "The certificate file or password was invalid.",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating the chosen file or given password was invalid."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.cancel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented.wrappedValue = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceedToPicker()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Try Again",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button allowing the user to retry an operation."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***
