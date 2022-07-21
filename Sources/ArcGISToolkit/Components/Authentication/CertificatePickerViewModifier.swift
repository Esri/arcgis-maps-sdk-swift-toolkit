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
***REMOVED***let challenge: QueuedNetworkChallenge
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
***REMOVED***init(challenge: QueuedNetworkChallenge) {
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
***REMOVED******REMOVED***challenge.resume(with: .cancelAuthenticationChallenge)
***REMOVED***
***REMOVED***

***REMOVED***/ A view modifier that presents a certificate picker workflow.
struct CertificatePickerViewModifier: ViewModifier {
***REMOVED******REMOVED***/ Creates a certificate picker view modifier.
***REMOVED******REMOVED***/ - Parameter challenge: The challenge that requires a certificate.
***REMOVED***init(challenge: QueuedNetworkChallenge) {
***REMOVED******REMOVED***viewModel = CertificatePickerViewModel(challenge: challenge)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The view model.
***REMOVED***@ObservedObject private var viewModel: CertificatePickerViewModel

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
***REMOVED******REMOVED******REMOVED***.passwordSheet(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showPassword,
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel: viewModel
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
***REMOVED******REMOVED***/ Displays a sheet that allows the user to enter a password.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating if the view is presented.
***REMOVED******REMOVED***/   - viewModel: The view model associated with the view.
***REMOVED***@MainActor @ViewBuilder func passwordSheet(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***viewModel: CertificatePickerViewModel
***REMOVED***) -> some View {
***REMOVED******REMOVED***sheet(isPresented: isPresented) {
***REMOVED******REMOVED******REMOVED***EnterPasswordView() { password in
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceed(withPassword: password)
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

***REMOVED***/ A view that allows the user to enter a password.
struct EnterPasswordView: View {
***REMOVED***@Environment(\.dismiss) var dismissAction
***REMOVED***
***REMOVED******REMOVED***/ The password that the user entered.
***REMOVED***@State var password: String = ""
***REMOVED***
***REMOVED******REMOVED***/ The action to call once the user has completed entering the password.
***REMOVED***var onContinue: (String) -> Void
***REMOVED***
***REMOVED******REMOVED***/ The action to call if the user cancels.
***REMOVED***var onCancel: () -> Void
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the password field has focus.
***REMOVED***@FocusState var isPasswordFocused: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Please enter a password for the chosen certificate.")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fixedSize(horizontal: false, vertical: true)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(Color.clear)
***REMOVED******REMOVED******REMOVED***

***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SecureField("Password", text: $password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.focused($isPasswordFocused)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.textContentType(.password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.go)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismissAction()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onContinue(password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.autocapitalization(.none)
***REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)

***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***okButton
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Certificate")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .cancellationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismissAction()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCancel()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Workaround for Apple bug - FB9676178.
***REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPasswordFocused = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The "OK" button.
***REMOVED***private var okButton: some View {
***REMOVED******REMOVED***Button(action: {
***REMOVED******REMOVED******REMOVED***dismissAction()
***REMOVED******REMOVED******REMOVED***onContinue(password)
***REMOVED***, label: {
***REMOVED******REMOVED******REMOVED***Text("OK")
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.white)
***REMOVED***)
***REMOVED******REMOVED***.disabled(password.isEmpty)
***REMOVED******REMOVED***.listRowBackground(!password.isEmpty ? Color.accentColor : Color.gray)
***REMOVED***
***REMOVED***
