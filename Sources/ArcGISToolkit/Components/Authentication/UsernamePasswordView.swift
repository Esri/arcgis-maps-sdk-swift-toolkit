***REMOVED***
***REMOVED*** COPYRIGHT 1995-2022 ESRI
***REMOVED***
***REMOVED*** TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
***REMOVED*** Unpublished material - all rights reserved under the
***REMOVED*** Copyright Laws of the United States and applicable international
***REMOVED*** laws, treaties, and conventions.
***REMOVED***
***REMOVED*** For additional information, contact:
***REMOVED*** Environmental Systems Research Institute, Inc.
***REMOVED*** Attn: Contracts and Legal Services Department
***REMOVED*** 380 New York Street
***REMOVED*** Redlands, California, 92373
***REMOVED*** USA
***REMOVED***
***REMOVED*** email: contracts@esri.com
***REMOVED***

***REMOVED***
***REMOVED***

@MainActor
class UsernamePasswordViewModel: ObservableObject {
***REMOVED***init(challengingHost: String) {
***REMOVED******REMOVED***self.challengingHost = challengingHost
***REMOVED******REMOVED***continuation = nil
***REMOVED***
***REMOVED***
***REMOVED***private let continuation: ChallengeContinuation?
***REMOVED***
***REMOVED***init(continuation: ChallengeContinuation) {
***REMOVED******REMOVED***self.continuation = continuation
***REMOVED******REMOVED***self.challengingHost = continuation.challenge.request.url!.host!
***REMOVED***
***REMOVED***
***REMOVED***@Published var username = "" {
***REMOVED******REMOVED***didSet { updateSigninButtonEnabled() ***REMOVED***
***REMOVED***
***REMOVED***@Published var password = "" {
***REMOVED******REMOVED***didSet { updateSigninButtonEnabled() ***REMOVED***
***REMOVED***
***REMOVED***@Published var signinButtonEnabled = false
***REMOVED***
***REMOVED***private func updateSigninButtonEnabled() {
***REMOVED******REMOVED***signinButtonEnabled = !username.isEmpty && !password.isEmpty
***REMOVED***
***REMOVED***
***REMOVED***let challengingHost: String
***REMOVED***
***REMOVED***func signIn() {
***REMOVED******REMOVED***if let continuation = continuation {
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***let disposition: Task<ArcGISAuthenticationChallenge.Disposition, Error> = Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.useCredential(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try await .token(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge: continuation.challenge,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***username: username,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***password: password
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***continuation.resume(with: await disposition.result)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***if let continuation = continuation {
***REMOVED******REMOVED******REMOVED***continuation.cancel()
***REMOVED***
***REMOVED***
***REMOVED***

struct UsernamePasswordView: View {
***REMOVED***init(viewModel: UsernamePasswordViewModel) {
***REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED***
***REMOVED***
***REMOVED***var viewModel: UsernamePasswordViewModel
***REMOVED***
***REMOVED******REMOVED***/ The focused field.
***REMOVED***@FocusState private var focusedField: Field?

***REMOVED******REMOVED***/ The username to be entered by the user.
***REMOVED***@State private var username = ""

***REMOVED******REMOVED***/ The password to be entered by the user.
***REMOVED***@State private var password = ""

***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "person.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 150, height: 150)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.shadow(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .gray.opacity(0.4),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***radius: 3,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: 1,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: 2
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("You need to sign in to access '\(viewModel.challengingHost)'")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fixedSize(horizontal: false, vertical: true)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(Color.clear)
***REMOVED******REMOVED******REMOVED***

***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField("Username", text: $username)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.focused($focusedField, equals: .username)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.textContentType(.username)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.next)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { focusedField = .password ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SecureField("Password", text: $password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.focused($focusedField, equals: .password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.textContentType(.password)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.submitLabel(.go)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { viewModel.signIn() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.autocapitalization(.none)
***REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)

***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(action: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.signIn()
***REMOVED******REMOVED******REMOVED******REMOVED***, label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Sign In")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.white)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.disabled(!viewModel.signinButtonEnabled)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(viewModel.signinButtonEnabled ? Color.accentColor : Color.gray)
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

struct UsernamePasswordView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***UsernamePasswordView(viewModel: UsernamePasswordViewModel(challengingHost: "arcgis.com"))
***REMOVED***
***REMOVED***

private extension UsernamePasswordView {
***REMOVED******REMOVED***/ The field to set the focus.
***REMOVED***enum Field: Hashable {
***REMOVED******REMOVED***case username
***REMOVED******REMOVED***case password
***REMOVED***
***REMOVED***
