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

@MainActor
final private class CertificatePickerViewModel: ObservableObject {
***REMOVED***let challengingHost: String
***REMOVED***let challenge: QueuedNetworkChallenge
***REMOVED***
***REMOVED***@Published private(set) var certificateURL: URL?
***REMOVED***@Published var showPrompt = true
***REMOVED***@Published var showPicker = false
***REMOVED***@Published var showPassword = false
***REMOVED***@Published var showCertificateImportError = false
***REMOVED***
***REMOVED***init(challenge: QueuedNetworkChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED******REMOVED***challengingHost = challenge.networkChallenge.host
***REMOVED***
***REMOVED***
***REMOVED***func proceedFromPrompt() {
***REMOVED******REMOVED***showPicker = true
***REMOVED***
***REMOVED***
***REMOVED***func proceed(withCertificateURL url: URL) {
***REMOVED******REMOVED***certificateURL = url
***REMOVED******REMOVED***showPassword = true
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED******REMOVED******REMOVED***showCertificateImportError = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***challenge.resume(with: .cancelAuthenticationChallenge)
***REMOVED***
***REMOVED***

struct CertificatePickerViewModifier: ViewModifier {
***REMOVED***init(challenge: QueuedNetworkChallenge) {
***REMOVED******REMOVED***viewModel = CertificatePickerViewModel(challenge: challenge)
***REMOVED***
***REMOVED***
***REMOVED***@ObservedObject private var viewModel: CertificatePickerViewModel

***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.promptBrowseCertificate(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $viewModel.showPrompt,
***REMOVED******REMOVED******REMOVED******REMOVED***host: viewModel.challengingHost,
***REMOVED******REMOVED******REMOVED******REMOVED***onContinue: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceedFromPrompt()
***REMOVED******REMOVED******REMOVED***, onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $viewModel.showPicker) {
***REMOVED******REMOVED******REMOVED******REMOVED***DocumentPickerView(contentTypes: [.pfx]) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceed(withCertificateURL: $0)
***REMOVED******REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $viewModel.showPassword) {
***REMOVED******REMOVED******REMOVED******REMOVED***EnterPasswordView() { password in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceed(withPassword: password)
***REMOVED******REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.alert("Error importing certificate", isPresented: $viewModel.showCertificateImportError) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Try Again") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.proceedFromPrompt()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("The certificate file or password was invalid.")
***REMOVED******REMOVED***

***REMOVED***
***REMOVED***

private extension UTType {
***REMOVED***static let pfx = UTType(filenameExtension: "pfx")!
***REMOVED***

private extension View {
***REMOVED***@ViewBuilder
***REMOVED***func promptBrowseCertificate(
***REMOVED******REMOVED***isPresented: Binding<Bool>,
***REMOVED******REMOVED***host: String,
***REMOVED******REMOVED***onContinue: @escaping () -> Void,
***REMOVED******REMOVED***onCancel: @escaping () -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***alert("Certificate Required", isPresented: isPresented, presenting: host) { _ in
***REMOVED******REMOVED******REMOVED***Button("Browse For Certificate") {
***REMOVED******REMOVED******REMOVED******REMOVED***onContinue()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED***onCancel()
***REMOVED******REMOVED***
***REMOVED*** message: { _ in
***REMOVED******REMOVED******REMOVED***Text("A certificate is required to access content on \(host).")
***REMOVED***
***REMOVED***
***REMOVED***

struct EnterPasswordView: View {
***REMOVED***@Environment(\.dismiss) var dismiss
***REMOVED***@State var password: String = ""
***REMOVED***var onContinue: (String) -> Void
***REMOVED***var onCancel: () -> Void
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***dismiss()
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
***REMOVED***private var okButton: some View {
***REMOVED******REMOVED***Button(action: {
***REMOVED******REMOVED******REMOVED***dismiss()
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
