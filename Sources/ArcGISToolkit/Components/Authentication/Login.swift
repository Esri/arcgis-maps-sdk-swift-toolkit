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
***REMOVED******REMOVED***/ A Boolean value indicating if the form is enabled.
***REMOVED***@Published var formEnabled: Bool = true
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
***REMOVED******REMOVED***formEnabled = false
***REMOVED******REMOVED***signInAction(LoginCredential(username: username, password: password))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Cancels the challenge.
***REMOVED***func cancel() {
***REMOVED******REMOVED***formEnabled = false
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
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***LoginView(viewModel: viewModel)
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

***REMOVED***/ A view that prompts a user to login with a username and password.
private struct LoginView: View {
***REMOVED******REMOVED***/ Creates the view.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - viewModel: The view model.
***REMOVED***init(viewModel: LoginViewModel) {
***REMOVED******REMOVED***_viewModel = ObservedObject(initialValue: viewModel)
***REMOVED***
***REMOVED***
***REMOVED***@Environment(\.dismiss) var dismissAction
***REMOVED***
***REMOVED******REMOVED***/ The view model.
***REMOVED***@ObservedObject private var viewModel: LoginViewModel
***REMOVED***
***REMOVED******REMOVED***/ The focused field.
***REMOVED***@FocusState private var focusedField: Field?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***person
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("You must sign in to access '\(viewModel.challengingHost)'")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fixedSize(horizontal: false, vertical: true)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(Color.clear)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField("Username", text: $viewModel.username)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.focused($focusedField, equals: .username)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.textContentType(.username)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.next)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { focusedField = .password ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SecureField("Password", text: $viewModel.password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.focused($focusedField, equals: .password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.textContentType(.password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.go)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { viewModel.signIn() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.autocapitalization(.none)
***REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***signInButton
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.disabled(!viewModel.formEnabled)
***REMOVED******REMOVED******REMOVED***.navigationTitle("Sign In")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .cancellationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***focusedField = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismissAction()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Workaround for Apple bug - FB9676178.
***REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***focusedField = .username
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An image used in the form.
***REMOVED***private var person: some View {
***REMOVED******REMOVED***Image(systemName: "person.circle")
***REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED***.frame(width: 150, height: 150)
***REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED***color: .gray.opacity(0.4),
***REMOVED******REMOVED******REMOVED******REMOVED***radius: 3,
***REMOVED******REMOVED******REMOVED******REMOVED***x: 1,
***REMOVED******REMOVED******REMOVED******REMOVED***y: 2
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The sign-in button.
***REMOVED***private var signInButton: some View {
***REMOVED******REMOVED***Button(action: {
***REMOVED******REMOVED******REMOVED***dismissAction()
***REMOVED******REMOVED******REMOVED***viewModel.signIn()
***REMOVED***, label: {
***REMOVED******REMOVED******REMOVED***if viewModel.formEnabled {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Sign In")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.white)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tint(.white)
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED******REMOVED***.disabled(!viewModel.signInButtonEnabled)
***REMOVED******REMOVED***.listRowBackground(viewModel.signInButtonEnabled ? Color.accentColor : Color.gray)
***REMOVED***
***REMOVED***

private extension LoginView {
***REMOVED******REMOVED***/ A type that represents the fields in the user name and password sign-in form.
***REMOVED***enum Field: Hashable {
***REMOVED******REMOVED******REMOVED***/ The username field.
***REMOVED******REMOVED***case username
***REMOVED******REMOVED******REMOVED***/ The password field.
***REMOVED******REMOVED***case password
***REMOVED***
***REMOVED***
