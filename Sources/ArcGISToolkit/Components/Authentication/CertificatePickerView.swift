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
***REMOVED***@State var showPrompt: Bool = false
***REMOVED***@State var showPicker: Bool = true
***REMOVED***@State var showPassword: Bool = false
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***InvisibleView()
***REMOVED******REMOVED******REMOVED******REMOVED***PromptBrowseCertificateView(host: viewModel.challengingHost) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***step = .documentPicker
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***showPicker = true
***REMOVED******REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $showPicker) {
***REMOVED******REMOVED******REMOVED***DocumentPickerView(contentTypes: [.pfx]) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.certificateURL = $0
***REMOVED******REMOVED******REMOVED******REMOVED***showPassword = true
***REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $showPassword) {
***REMOVED******REMOVED******REMOVED***EnterPasswordView(password: $viewModel.password) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.signIn()
***REMOVED******REMOVED*** onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED***
***REMOVED***
***REMOVED***

private extension UTType {
***REMOVED***static let pfx = UTType(filenameExtension: "pfx")!
***REMOVED***

struct PromptBrowseCertificateView: View {
***REMOVED***var host: String
***REMOVED***var onContinue: () -> Void
***REMOVED***var onCancel: () -> Void
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***InvisibleView()
***REMOVED******REMOVED******REMOVED***.alert("Certificate Required", isPresented: .constant(true), presenting: host) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Browse for a certificate") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onContinue()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** message: { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***Text("A certificate is required to access content on \(host)")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

struct EnterPasswordView: View {
***REMOVED***@Binding var password: String
***REMOVED***var onContinue: () -> Void
***REMOVED***var onCancel: () -> Void
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Text("Please enter a password for the chosen certificate.")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom])
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***SecureField(text: $password, prompt: Text("Password")) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("label")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.textInputAutocapitalization(.never)
***REMOVED******REMOVED******REMOVED***.disableAutocorrection(true)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onContinue()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("OK")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED***.controlSize(.large)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCancel()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Cancel")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED***.controlSize(.large)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***.navigationTitle("Certificate Required")
***REMOVED***
***REMOVED***
