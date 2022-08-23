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
***REMOVED******REMOVED******REMOVED***.credentialInput(
***REMOVED******REMOVED******REMOVED******REMOVED***fields: .usernamePassword,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***message: "You must sign in to access '\(viewModel.challengingHost)'",
***REMOVED******REMOVED******REMOVED******REMOVED***title: "Authentication Required",
***REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: "Cancel",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: "Continue",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { username, password in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.username = username
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.password = password
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.signIn()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .cancel)
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
