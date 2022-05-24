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

public extension View {
***REMOVED***@ViewBuilder
***REMOVED***func authentication(authenticator: Authenticator) -> some View {
***REMOVED******REMOVED***modifier(InvisibleOverlayModifier(authenticator: authenticator))
***REMOVED***
***REMOVED***

***REMOVED***/ This is an intermediate modifier that overlays an always present invisible view.
***REMOVED***/ This view is necessary because of SwiftUI behavior that prevent the UI from functioning
***REMOVED***/ properly when showing and hiding sheets. The sheets need to be off of a view that is always
***REMOVED***/ present.
private struct InvisibleOverlayModifier: ViewModifier {
***REMOVED***@ObservedObject var authenticator: Authenticator
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 0, height: 0)
***REMOVED******REMOVED******REMOVED******REMOVED***.modifier(AuthenticationModifier(authenticator: authenticator))
***REMOVED***
***REMOVED***
***REMOVED***

private struct AuthenticationModifier: ViewModifier {
***REMOVED***@ObservedObject var authenticator: Authenticator
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***if let challenge = authenticator.currentChallenge {
***REMOVED******REMOVED******REMOVED***authenticationView(for: challenge, content: content)
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***content
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func authenticationView(for challenge: QueuedChallenge, content: Content) -> some View {
***REMOVED******REMOVED***switch challenge {
***REMOVED******REMOVED***case let challenge as QueuedArcGISChallenge:
***REMOVED******REMOVED******REMOVED***content.modifier(UsernamePasswordViewModifier(challenge: challenge))
***REMOVED******REMOVED***case let challenge as QueuedURLChallenge:
***REMOVED******REMOVED******REMOVED***switch challenge.urlChallenge.protectionSpace.authenticationMethod {
***REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodServerTrust:
***REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(TrustHostViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodClientCertificate:
***REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(CertificatePickerViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodDefault,
***REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodNTLM,
***REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTMLForm,
***REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPBasic,
***REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPDigest:
***REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(UsernamePasswordViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***
