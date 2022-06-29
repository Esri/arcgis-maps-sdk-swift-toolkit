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
***REMOVED******REMOVED***/ Presents user experiences for collecting network authentication credentials from the
***REMOVED******REMOVED***/ user.
***REMOVED******REMOVED***/ - Parameter authenticator: The authenticator for which credentials will be prompted.
***REMOVED***@ViewBuilder
***REMOVED***func authenticator(_ authenticator: Authenticator) -> some View {
***REMOVED******REMOVED***modifier(AuthenticatorOverlayModifier(authenticator: authenticator))
***REMOVED***
***REMOVED***

***REMOVED***/ A view modifier that overlays an always present invisible view for which the
***REMOVED***/ authenticator view modifiers can modify.
***REMOVED***/ This view is necessary because of SwiftUI behavior that prevent the UI from functioning
***REMOVED***/ properly when showing and hiding sheets. The sheets need to be off of a view that is always
***REMOVED***/ present.
***REMOVED***/ The problem that I was seeing without this is content in lists not updating properly
***REMOVED***/ after a sheet was dismissed.
private struct AuthenticatorOverlayModifier: ViewModifier {
***REMOVED***@ObservedObject var authenticator: Authenticator
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***ZStack {
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 0, height: 0)
***REMOVED******REMOVED******REMOVED******REMOVED***.modifier(AuthenticatorModifier(authenticator: authenticator))
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view modifier that prompts for credentials.
private struct AuthenticatorModifier: ViewModifier {
***REMOVED***@ObservedObject var authenticator: Authenticator
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***switch authenticator.currentChallenge {
***REMOVED******REMOVED***case let challenge as QueuedArcGISChallenge:
***REMOVED******REMOVED******REMOVED***content.modifier(UsernamePasswordViewModifier(challenge: challenge))
***REMOVED******REMOVED***case let challenge as QueuedNetworkChallenge:
***REMOVED******REMOVED******REMOVED***switch challenge.kind {
***REMOVED******REMOVED******REMOVED***case .serverTrust:
***REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(TrustHostViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***case .certificate:
***REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(CertificatePickerViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***case .login:
***REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(UsernamePasswordViewModifier(challenge: challenge))
***REMOVED******REMOVED***
***REMOVED******REMOVED***case .none:
***REMOVED******REMOVED******REMOVED***content
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***
