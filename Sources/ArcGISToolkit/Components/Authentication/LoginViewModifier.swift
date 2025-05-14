***REMOVED*** Copyright 2023 Esri
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
***REMOVED***

***REMOVED***/ A view modifier that prompts a user to login with a username and password.
struct LoginViewModifier: ViewModifier {
***REMOVED******REMOVED***/ The host that initiated the challenge.
***REMOVED***let challengingHost: String
***REMOVED******REMOVED***/ The action to perform when the user signs in. This is a closure that
***REMOVED******REMOVED***/ takes a login credential.
***REMOVED***let onSignIn: (LoginCredential) -> Void
***REMOVED******REMOVED***/ The action to perform when the user cancels.
***REMOVED***let onCancel: () -> Void
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the prompt to login is displayed.
***REMOVED***@State private var isPresented = false
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.delayedOnAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Present the sheet right away.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Setting it after initialization allows it to animate.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** However, this needs to happen after a slight delay or
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** it doesn't show.
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.credentialInput(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***fields: .usernamePassword,
***REMOVED******REMOVED******REMOVED******REMOVED***message: String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "You must sign in to access '\(challengingHost)'",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***A label explaining that credentials are required to authenticate with specified host.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***The host is indicated in the variable.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***title: String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "Authentication Required",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label indicating authentication is required to proceed."
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***cancelAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: .cancel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { _, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onCancel()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED***continueAction: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title: .init(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Continue",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkit,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label for a button used to continue the authentication operation."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***handler: { username, password in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let loginCredential = LoginCredential(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***username: username, password: password
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***onSignIn(loginCredential)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

@MainActor
extension LoginViewModifier {
***REMOVED******REMOVED***/ Creates an instance from a network challenge continuation.
***REMOVED***init(challenge: NetworkChallengeContinuation) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***challengingHost: challenge.host,
***REMOVED******REMOVED******REMOVED***onSignIn: { loginCredential in
***REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: .continueWithCredential(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.password(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***username: loginCredential.username,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***password: loginCredential.password
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED***onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .cancel)
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Creates an instance from an ArcGIS challenge continuation.
***REMOVED***init(challenge: TokenChallengeContinuation) {
***REMOVED******REMOVED***self.init(
***REMOVED******REMOVED******REMOVED***challengingHost: challenge.host,
***REMOVED******REMOVED******REMOVED***onSignIn: { loginCredential in
***REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: loginCredential)
***REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED***onCancel: {
***REMOVED******REMOVED******REMOVED******REMOVED***challenge.cancel()
***REMOVED******REMOVED***
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
