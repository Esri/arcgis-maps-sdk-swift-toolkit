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

@MainActor final class CertificatePickerViewModel: ObservableObject {
***REMOVED***let challengingHost: String
***REMOVED***let challenge: QueuedURLChallenge
***REMOVED***
***REMOVED***@Published var certificateURL: URL?
***REMOVED***@Published var password: String = ""
***REMOVED***
***REMOVED***init(challenge: QueuedURLChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED******REMOVED***challengingHost = challenge.urlChallenge.protectionSpace.host
***REMOVED***
***REMOVED***
***REMOVED***func signIn() {
***REMOVED******REMOVED***guard let certificateURL = certificateURL else {
***REMOVED******REMOVED******REMOVED***preconditionFailure()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***challenge.resume(with: .certificate(url: certificateURL, passsword: password))
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***challenge.cancel()
***REMOVED***
***REMOVED***

struct CertificatePickerView: View {
***REMOVED***@ObservedObject var viewModel: CertificatePickerViewModel
***REMOVED***
***REMOVED***@State var showPrompt: Bool = true
***REMOVED***@State var showPicker: Bool = false
***REMOVED***@State var showPassword: Bool = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***InvisibleView()
***REMOVED******REMOVED******REMOVED***.promptBrowseCertificateView(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $showPrompt,
***REMOVED******REMOVED******REMOVED******REMOVED***host: viewModel.challengingHost,
***REMOVED******REMOVED******REMOVED******REMOVED***onContinue: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showPicker = true
***REMOVED******REMOVED******REMOVED***, onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $showPicker) {
***REMOVED******REMOVED******REMOVED******REMOVED***DocumentPickerView(contentTypes: [.pfx]) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.certificateURL = $0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showPassword = true
***REMOVED******REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $showPassword) {
***REMOVED******REMOVED******REMOVED******REMOVED***EnterPasswordView(password: $viewModel.password) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.signIn()
***REMOVED******REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

private extension UTType {
***REMOVED***static let pfx = UTType(filenameExtension: "pfx")!
***REMOVED***

private extension View {
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***func promptBrowseCertificateView(
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
***REMOVED***@Binding var password: String
***REMOVED***var onContinue: () -> Void
***REMOVED***var onCancel: () -> Void
***REMOVED***@FocusState var isPasswordFocused: Bool
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED***Form {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***person
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit { onContinue() ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.autocapitalization(.none)
***REMOVED******REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)

***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***okButton
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Certificate")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED******REMOVED***.toolbar {
***REMOVED******REMOVED******REMOVED******REMOVED***ToolbarItem(placement: .cancellationAction) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel") { onCancel() ***REMOVED***
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
***REMOVED******REMOVED******REMOVED***onContinue()
***REMOVED***, label: {
***REMOVED******REMOVED******REMOVED***Text("OK")
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.white)
***REMOVED***)
***REMOVED******REMOVED******REMOVED***.disabled(!password.isEmpty)
***REMOVED******REMOVED******REMOVED***.listRowBackground(!password.isEmpty ? Color.accentColor : Color.gray)
***REMOVED***
***REMOVED***
