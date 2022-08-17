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
***REMOVED***

***REMOVED***/ A value that contains a username and password pair.
struct LoginCredential: Hashable {
***REMOVED******REMOVED***/ The username.
***REMOVED***let username: String
***REMOVED***
***REMOVED******REMOVED***/ The password.
***REMOVED***let password: String
***REMOVED***

***REMOVED***/ A type that provides the business logic for a view that prompts the user to login with a
***REMOVED***/ username and password.
@MainActor
final class LoginViewModel: ObservableObject {
***REMOVED******REMOVED***/ The username.
***REMOVED***@Published var username = "" {
***REMOVED******REMOVED***didSet { updateSignInButtonEnabled() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The password.
***REMOVED***@Published var password = "" {
***REMOVED******REMOVED***didSet { updateSignInButtonEnabled() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the sign-in button is enabled.
***REMOVED***@Published var signInButtonEnabled = false
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the user signs in. This is a closure that takes a username
***REMOVED******REMOVED***/ and password, respectively.
***REMOVED***var signInAction: (LoginCredential) -> Void
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the user cancels.
***REMOVED***var cancelAction: () -> Void
***REMOVED***
***REMOVED******REMOVED***/ Creates a `UsernamePasswordViewModel`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - challengingHost: The host that prompted the challenge.
***REMOVED******REMOVED***/   - signInAction: The action to perform when the user signs in. This is a closure that takes
***REMOVED******REMOVED***/***REMOVED***a username and password, respectively.
***REMOVED******REMOVED***/   - cancelAction: The action to perform when the user cancels.
***REMOVED***init(
***REMOVED******REMOVED***challengingHost: String,
***REMOVED******REMOVED***onSignIn signInAction: @escaping (LoginCredential) -> Void,
***REMOVED******REMOVED***onCancel cancelAction: @escaping () -> Void
***REMOVED***) {
***REMOVED******REMOVED***self.challengingHost = challengingHost
***REMOVED******REMOVED***self.signInAction = signInAction
***REMOVED******REMOVED***self.cancelAction = cancelAction
***REMOVED***
***REMOVED***
***REMOVED***private func updateSignInButtonEnabled() {
***REMOVED******REMOVED***signInButtonEnabled = !username.isEmpty && !password.isEmpty
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The host that initiated the challenge.
***REMOVED***var challengingHost: String
***REMOVED***
***REMOVED******REMOVED***/ Attempts to log in with a username and password.
***REMOVED***func signIn() {
***REMOVED******REMOVED***signInAction(LoginCredential(username: username, password: password))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels the challenge.
***REMOVED***func cancel() {
***REMOVED******REMOVED***cancelAction()
***REMOVED***
***REMOVED***

***REMOVED***/ A view modifier that prompts a user to login with a username and password.
struct LoginViewModifier: ViewModifier {
***REMOVED******REMOVED***/ The view model.
***REMOVED***let viewModel: LoginViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the prompt to login is displayed.
***REMOVED***@State var isPresented = false
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.task { isPresented = true ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay {
***REMOVED******REMOVED******REMOVED******REMOVED***LoginView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel: viewModel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

extension LoginViewModifier {
***REMOVED******REMOVED***/ Creates a `LoginViewModifier` with a network challenge continuation.
***REMOVED***@MainActor init(challenge: NetworkChallengeContinuation) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***viewModel: LoginViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***challengingHost: challenge.host,
***REMOVED******REMOVED******REMOVED******REMOVED***onSignIn: { loginCredential in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: .useCredential(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.password(username: loginCredential.username, password: loginCredential.password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .cancelAuthenticationChallenge)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates a `LoginViewModifier` with an ArcGIS challenge continuation.
***REMOVED***@MainActor init(challenge: TokenChallengeContinuation) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***viewModel: LoginViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***challengingHost: challenge.host,
***REMOVED******REMOVED******REMOVED******REMOVED***onSignIn: { loginCredential in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: loginCredential)
***REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

***REMOVED***/ A view that prompts a user to login with a username and password.
***REMOVED***/
***REMOVED***/ Implemented in UIKit because as of iOS 16, SwiftUI alerts don't support visible but disabled buttons.
private struct LoginView: UIViewControllerRepresentable {
***REMOVED******REMOVED***/ The view model.
***REMOVED***@ObservedObject var viewModel: LoginViewModel
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the view is displayed.
***REMOVED***@Binding var isPresented: Bool
***REMOVED***
***REMOVED******REMOVED***/ The cancel action for the `UIAlertController`.
***REMOVED***let cancelAction: UIAlertAction
***REMOVED***
***REMOVED******REMOVED***/ The sign in action for the `UIAlertController`.
***REMOVED***let signInAction: UIAlertAction
***REMOVED***
***REMOVED******REMOVED***/ Creates the view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewModel: The view model.
***REMOVED******REMOVED***/   - isPresented: A Boolean value indicating whether or not the view is displayed.
***REMOVED***init(viewModel: LoginViewModel, isPresented: Binding<Bool>) {
***REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED***_isPresented = isPresented
***REMOVED******REMOVED***
***REMOVED******REMOVED***cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED***
***REMOVED******REMOVED***signInAction = UIAlertAction(title: "Sign In", style: .default) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.signIn()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***cancelAction.isEnabled = true
***REMOVED******REMOVED***signInAction.isEnabled = false
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
***REMOVED******REMOVED******REMOVED***title: "You must sign in to access '\(viewModel.challengingHost)'",
***REMOVED******REMOVED******REMOVED***message: nil,
***REMOVED******REMOVED******REMOVED***preferredStyle: .alert
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***uiAlertController.addTextField { textField in
***REMOVED******REMOVED******REMOVED***textField.autocapitalizationType = .none
***REMOVED******REMOVED******REMOVED***textField.autocorrectionType = .no
***REMOVED******REMOVED******REMOVED***textField.delegate = context.coordinator
***REMOVED******REMOVED******REMOVED***textField.placeholder = "Username"
***REMOVED******REMOVED******REMOVED***textField.returnKeyType = .next
***REMOVED******REMOVED******REMOVED***textField.textContentType = .username
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***uiAlertController.addTextField { textField in
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
***REMOVED******REMOVED***uiAlertController.addAction(signInAction)
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
***REMOVED******REMOVED***if isPresented {
***REMOVED******REMOVED******REMOVED***let alertController = makeAlertController(context: context)
***REMOVED******REMOVED******REMOVED***DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
***REMOVED******REMOVED******REMOVED******REMOVED***uiViewController.present(alertController, animated: true) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension LoginView {
***REMOVED******REMOVED***/ The coordinator for the login view that acts as a delegate to the underlying
***REMOVED******REMOVED***/ `UIAlertViewController`.
***REMOVED***final class Coordinator: NSObject, UITextFieldDelegate {
***REMOVED******REMOVED******REMOVED***/ The view that owns this coordinator.
***REMOVED******REMOVED***let parent: LoginView
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Creates the coordinator.
***REMOVED******REMOVED******REMOVED***/ - Parameter parent: The view that owns this coordinator.
***REMOVED******REMOVED***init(_ parent: LoginView) {
***REMOVED******REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textField(
***REMOVED******REMOVED******REMOVED***_ textField: UITextField,
***REMOVED******REMOVED******REMOVED***shouldChangeCharactersIn range: NSRange,
***REMOVED******REMOVED******REMOVED***replacementString string: String
***REMOVED******REMOVED***) -> Bool {
***REMOVED******REMOVED******REMOVED***DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
***REMOVED******REMOVED******REMOVED******REMOVED***self?.updateValues(with: textField)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func textFieldShouldReturn(_ textField: UITextField) -> Bool {
***REMOVED******REMOVED******REMOVED***if textField.textContentType == .password &&
***REMOVED******REMOVED******REMOVED******REMOVED***parent.viewModel.signInButtonEnabled {
***REMOVED******REMOVED******REMOVED******REMOVED***parent.viewModel.signIn()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return true
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ Updates the view model with the latest text field values and the enabled state of the sign in
***REMOVED******REMOVED******REMOVED***/ button.
***REMOVED******REMOVED******REMOVED***/ - Parameter textField: The text field who's value recently changed.
***REMOVED******REMOVED***func updateValues(with textField: UITextField) {
***REMOVED******REMOVED******REMOVED***if textField.textContentType == .username {
***REMOVED******REMOVED******REMOVED******REMOVED***parent.viewModel.username = textField.text ?? ""
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***parent.viewModel.password = textField.text ?? ""
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***parent.signInAction.isEnabled = parent.viewModel.signInButtonEnabled
***REMOVED***
***REMOVED***
***REMOVED***
