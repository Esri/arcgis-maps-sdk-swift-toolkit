***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***Toolkit
import CryptoKit
***REMOVED***

***REMOVED***/ A view that allows the user to sign in to a portal.
struct SignInView: View {
***REMOVED******REMOVED***/ The error that occurred during an attempt to sign in.
***REMOVED***@State private var error: Error?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the user is currently signing in.
***REMOVED***@State private var isSigningIn = false
***REMOVED***
***REMOVED******REMOVED***/ The portal that the user successfully signed in to.
***REMOVED***@Binding var portal: Portal?
***REMOVED***
***REMOVED******REMOVED***/ The last signed in user name.
***REMOVED******REMOVED***/ - If the property is `nil` then there was no previous effective credential.
***REMOVED******REMOVED***/ - If the property is non-nil and empty, then the previously persisted and effective
***REMOVED******REMOVED***/ credential did not have a username.
***REMOVED******REMOVED***/ - If the property is non-nil and non-empty, then it contains the previously used and
***REMOVED******REMOVED***/ persisted username.
***REMOVED***@State private var lastSignedInUser: String?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if isSigningIn {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(URL.portal.host!)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***signInButton
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if let error = error, !error.isChallengeCancellationError {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(error.localizedDescription)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***guard lastSignedInUser == nil else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let arcGISCredential = ArcGISEnvironment.authenticationManager.arcGISCredentialStore.credential(for: .portal) {
***REMOVED******REMOVED******REMOVED******REMOVED***lastSignedInUser = arcGISCredential.username
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***let networkCredentials = await ArcGISEnvironment.authenticationManager.networkCredentialStore.credentials(forHost: URL.portal.host!)
***REMOVED******REMOVED******REMOVED******REMOVED***if !networkCredentials.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***lastSignedInUser = networkCredentials.compactMap { credential in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch credential {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .password(let passwordCredential):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return passwordCredential.username
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .certificate(let certificateCredential):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return certificateCredential.identityName
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .serverTrust:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .smartCard(let smartCardCredential):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return smartCardCredential.identityName
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fatalError("Unknown NetworkCredential")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.first
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED***var signInButtonText: String {
***REMOVED******REMOVED***if let lastSignedInUser = lastSignedInUser {
***REMOVED******REMOVED******REMOVED***if lastSignedInUser.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Non-nil but empty, can't offer the username.
***REMOVED******REMOVED******REMOVED******REMOVED***return "Sign in again"
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Non-nil and non-empty, show the username in the button text.
***REMOVED******REMOVED******REMOVED******REMOVED***return "Sign in with \(lastSignedInUser)"
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED*** For nil username, then just use default text that implies there was no previous
***REMOVED******REMOVED******REMOVED******REMOVED*** used credential persisted.
***REMOVED******REMOVED******REMOVED***return "Sign in"
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var signInButton: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***signIn()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(signInButtonText)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED***.controlSize(.large)
***REMOVED******REMOVED***.disabled(isSigningIn || portal != nil)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Attempts to sign into a portal.
***REMOVED***func signIn() {
***REMOVED******REMOVED***isSigningIn = true
***REMOVED******REMOVED***error = nil
***REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let portal = Portal(url: .portal, connection: .authenticated)
***REMOVED******REMOVED******REMOVED******REMOVED***try await portal.load()
***REMOVED******REMOVED******REMOVED******REMOVED***self.portal = portal
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***self.error = error
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isSigningIn = false
***REMOVED***
***REMOVED***
***REMOVED***

private extension Error {
***REMOVED******REMOVED***/ Returns a Boolean value indicating whether the error is the result of cancelling an
***REMOVED******REMOVED***/ authentication challenge.
***REMOVED***var isChallengeCancellationError: Bool {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case is ArcGISChallengeCancellationError:
***REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED***case let error as NSError:
***REMOVED******REMOVED******REMOVED***return error.domain == NSURLErrorDomain && error.code == -999
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED***
