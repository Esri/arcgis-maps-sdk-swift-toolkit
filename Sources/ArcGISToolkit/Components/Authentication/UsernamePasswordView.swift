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

@MainActor protocol UsernamePasswordViewModel: ObservableObject {
***REMOVED***var username: String { get set ***REMOVED***
***REMOVED***var password: String { get set ***REMOVED***
***REMOVED***var signinButtonEnabled: Bool { get ***REMOVED***
***REMOVED***var isDismissed: Bool { get ***REMOVED***
***REMOVED***var challengingHost: String { get ***REMOVED***
***REMOVED***
***REMOVED***func signIn()
***REMOVED***func cancel()
***REMOVED***

@MainActor class TokenCredentialViewModel: UsernamePasswordViewModel {
***REMOVED***private let challenge: QueuedArcGISChallenge
***REMOVED***
***REMOVED***init(challenge: QueuedArcGISChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED***
***REMOVED***
***REMOVED***@Published var username = "" {
***REMOVED******REMOVED***didSet { updateSigninButtonEnabled() ***REMOVED***
***REMOVED***
***REMOVED***@Published var password = "" {
***REMOVED******REMOVED***didSet { updateSigninButtonEnabled() ***REMOVED***
***REMOVED***
***REMOVED***@Published var signinButtonEnabled = false
***REMOVED***@Published var isDismissed = false
***REMOVED***
***REMOVED***private func updateSigninButtonEnabled() {
***REMOVED******REMOVED***signinButtonEnabled = !username.isEmpty && !password.isEmpty
***REMOVED***
***REMOVED***
***REMOVED***var challengingHost: String {
***REMOVED******REMOVED***challenge.arcGISChallenge.request.url!.host!
***REMOVED***
***REMOVED***
***REMOVED***func signIn() {
***REMOVED******REMOVED***isDismissed = true
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***challenge.resume(with: await Result {
***REMOVED******REMOVED******REMOVED******REMOVED***.useCredential(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await .token(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge: challenge.arcGISChallenge,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***username: username,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***password: password
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***isDismissed = true
***REMOVED******REMOVED***challenge.cancel()
***REMOVED***
***REMOVED***

@MainActor class URLCredentialUsernamePasswordViewModel: UsernamePasswordViewModel {
***REMOVED***private let challenge: QueuedURLChallenge
***REMOVED***
***REMOVED***init(challenge: QueuedURLChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED***
***REMOVED***
***REMOVED***@Published var username = "" {
***REMOVED******REMOVED***didSet { updateSigninButtonEnabled() ***REMOVED***
***REMOVED***
***REMOVED***@Published var password = "" {
***REMOVED******REMOVED***didSet { updateSigninButtonEnabled() ***REMOVED***
***REMOVED***
***REMOVED***@Published var signinButtonEnabled = false
***REMOVED***@Published var isDismissed = false
***REMOVED***
***REMOVED***private func updateSigninButtonEnabled() {
***REMOVED******REMOVED***signinButtonEnabled = !username.isEmpty && !password.isEmpty
***REMOVED***
***REMOVED***
***REMOVED***var challengingHost: String {
***REMOVED******REMOVED***challenge.urlChallenge.protectionSpace.host
***REMOVED***
***REMOVED***
***REMOVED***func signIn() {
***REMOVED******REMOVED***isDismissed = true
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***challenge.resume(with: Result {
***REMOVED******REMOVED******REMOVED******REMOVED***(.useCredential, URLCredential(user: username, password: password, persistence: .forSession))
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***isDismissed = true
***REMOVED******REMOVED***challenge.cancel()
***REMOVED***
***REMOVED***

@MainActor struct UsernamePasswordView<ViewModel: UsernamePasswordViewModel>: View {
***REMOVED***init(viewModel: ViewModel) {
***REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED***
***REMOVED***
***REMOVED***@ObservedObject private var viewModel: ViewModel
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("You need to sign in to access '\(viewModel.challengingHost)'")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fixedSize(horizontal: false, vertical: true)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(Color.clear)
***REMOVED******REMOVED******REMOVED***

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

***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***signinButton
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Sign In")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .cancellationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel") { viewModel.cancel() ***REMOVED***
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
***REMOVED***private var signinButton: some View {
***REMOVED******REMOVED***Button(action: {
***REMOVED******REMOVED******REMOVED***viewModel.signIn()
***REMOVED***, label: {
***REMOVED******REMOVED******REMOVED***Text("Sign In")
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.white)
***REMOVED***)
***REMOVED******REMOVED******REMOVED***.disabled(!viewModel.signinButtonEnabled)
***REMOVED******REMOVED******REMOVED***.listRowBackground(viewModel.signinButtonEnabled ? Color.accentColor : Color.gray)
***REMOVED***
***REMOVED***

***REMOVED***struct UsernamePasswordView_Previews: PreviewProvider {
***REMOVED******REMOVED***static var previews: some View {
***REMOVED******REMOVED******REMOVED***UsernamePasswordView(viewModel: UsernamePasswordViewModel(challengingHost: "arcgis.com"))
***REMOVED******REMOVED***
***REMOVED******REMOVED***

private extension UsernamePasswordView {
***REMOVED******REMOVED***/ A type that represents the fields in the user name and password sign-in form.
***REMOVED***enum Field: Hashable {
***REMOVED******REMOVED***case username
***REMOVED******REMOVED***case password
***REMOVED***
***REMOVED***
