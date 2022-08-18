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
***REMOVED******REMOVED***/ The password.
***REMOVED***@Published var password = ""
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
***REMOVED***func proceedWithPassword() {
***REMOVED******REMOVED***guard let certificateURL = certificateURL, !password.isEmpty else {
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
***REMOVED******REMOVED***overlay {
***REMOVED******REMOVED******REMOVED***EnterPasswordView(
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel: viewModel,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: isPresented
***REMOVED******REMOVED******REMOVED***)
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

***REMOVED***/ A view that allows the user to enter a password.
***REMOVED***/
***REMOVED***/ Implemented in UIKit because as of iOS 16, SwiftUI alerts don't support visible but disabled buttons.
struct EnterPasswordView: UIViewControllerRepresentable {
***REMOVED******REMOVED***/ The view model.
***REMOVED***@ObservedObject var viewModel: CertificatePickerViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the view is displayed.
***REMOVED***@Binding var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ The cancel action for the `UIAlertController`.
***REMOVED***@State var cancelAction: UIAlertAction
***REMOVED***
***REMOVED******REMOVED***/ The continue action for the `UIAlertController`.
***REMOVED***@State var continueAction: UIAlertAction
***REMOVED***
***REMOVED******REMOVED***/ Creates the view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewModel: The view model.
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating whether or not the view is displayed.
***REMOVED***init(
***REMOVED******REMOVED***viewModel: CertificatePickerViewModel,
***REMOVED******REMOVED***isPresented: Binding<Bool>
***REMOVED***) {
***REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED******REMOVED***
***REMOVED******REMOVED***cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED***
***REMOVED******REMOVED***continueAction = UIAlertAction(title: "OK", style: .default) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.proceedWithPassword()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***cancelAction.isEnabled = true
***REMOVED******REMOVED***continueAction.isEnabled = false
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(self)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates the alert controller object and configures its initial state.
***REMOVED******REMOVED***/ - Parameter context: A context structure containing information about the current state of the
***REMOVED******REMOVED***/ system.
***REMOVED******REMOVED***/ - Returns: A configured alert controller.
***REMOVED***func makeAlertController(context: Context) -> UIAlertController {
***REMOVED******REMOVED***let uiAlertController = UIAlertController(
***REMOVED******REMOVED******REMOVED***title: "Password Required",
***REMOVED******REMOVED******REMOVED***message: "Please enter a password for the chosen certificate.",
***REMOVED******REMOVED******REMOVED***preferredStyle: .alert
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***uiAlertController.addTextField { textField in
***REMOVED******REMOVED******REMOVED***textField.addAction(
***REMOVED******REMOVED******REMOVED******REMOVED***UIAction { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.password = textField.text ?? ""
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***continueAction.isEnabled = !viewModel.password.isEmpty
***REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***for: .editingChanged
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***textField.autocapitalizationType = .none
***REMOVED******REMOVED******REMOVED***textField.autocorrectionType = .no
***REMOVED******REMOVED******REMOVED***textField.delegate = context.coordinator
***REMOVED******REMOVED******REMOVED***textField.isSecureTextEntry = true
***REMOVED******REMOVED******REMOVED***textField.placeholder = "Password"
***REMOVED******REMOVED******REMOVED***textField.returnKeyType = .go
***REMOVED******REMOVED******REMOVED***textField.textContentType = .password
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***uiAlertController.addAction(cancelAction)
***REMOVED******REMOVED***uiAlertController.addAction(continueAction)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return uiAlertController
***REMOVED***
***REMOVED***
***REMOVED***func makeUIViewController(context: Context) -> UIViewController {
***REMOVED******REMOVED***return UIViewController()
***REMOVED***
***REMOVED***
***REMOVED***func updateUIViewController(
***REMOVED******REMOVED***_ uiViewController: UIViewControllerType,
***REMOVED******REMOVED***context: Context
***REMOVED***) {
***REMOVED******REMOVED***guard isPresented else { return ***REMOVED***
***REMOVED******REMOVED***let alertController = makeAlertController(context: context)
***REMOVED******REMOVED***DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
***REMOVED******REMOVED******REMOVED***uiViewController.present(alertController, animated: true) {
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension EnterPasswordView {
***REMOVED******REMOVED***/ The coordinator for the password view that acts as a delegate to the underlying
***REMOVED******REMOVED***/ `UIAlertViewController`.
***REMOVED***final class Coordinator: NSObject, UITextFieldDelegate {
***REMOVED******REMOVED******REMOVED***/ The view that owns this coordinator.
***REMOVED******REMOVED***let parent: EnterPasswordView
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates the coordinator.
***REMOVED******REMOVED******REMOVED***/ - Parameter parent: The view that owns this coordinator.
***REMOVED******REMOVED***init(_ parent: EnterPasswordView) {
***REMOVED******REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textFieldShouldReturn(_ textField: UITextField) -> Bool {
***REMOVED******REMOVED******REMOVED***guard !parent.viewModel.password.isEmpty else {
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***parent.viewModel.proceedWithPassword()
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED***
***REMOVED***
