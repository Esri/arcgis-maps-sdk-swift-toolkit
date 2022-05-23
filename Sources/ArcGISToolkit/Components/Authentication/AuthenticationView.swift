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

struct AuthenticationView: View {
***REMOVED***init(challenge: QueuedChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED***

***REMOVED***let challenge: QueuedChallenge
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***switch challenge {
***REMOVED******REMOVED******REMOVED***case let challenge as QueuedArcGISChallenge:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Sheet {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UsernamePasswordView(challenge: challenge)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case let challenge as QueuedURLChallenge:
***REMOVED******REMOVED******REMOVED******REMOVED***switch challenge.urlChallenge.protectionSpace.authenticationMethod {
***REMOVED******REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodServerTrust:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TrustHostView(challenge: challenge)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodClientCertificate:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CertificatePickerView(challenge: challenge)
***REMOVED******REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodDefault,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodNTLM,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTMLForm,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPBasic,
***REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPDigest:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UsernamePasswordView(challenge: challenge)
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***switch challenge {
***REMOVED******REMOVED***case let challenge as QueuedArcGISChallenge:
***REMOVED******REMOVED******REMOVED***modifier(UsernamePasswordViewModifier(challenge: challenge))
***REMOVED******REMOVED***case let challenge as QueuedURLChallenge:
***REMOVED******REMOVED******REMOVED***switch challenge.urlChallenge.protectionSpace.authenticationMethod {
***REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodServerTrust:
***REMOVED******REMOVED******REMOVED******REMOVED***modifier(TrustHostViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodClientCertificate:
***REMOVED******REMOVED******REMOVED******REMOVED***modifier(CertificatePickerViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodDefault,
***REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodNTLM,
***REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTMLForm,
***REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPBasic,
***REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPDigest:
***REMOVED******REMOVED******REMOVED******REMOVED***modifier(UsernamePasswordViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***

public extension View {
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***func authentication(authenticator: Authenticator) -> some View {
***REMOVED******REMOVED***modifier(AuthenticationModifier(authenticator: authenticator))
***REMOVED***
***REMOVED***

struct AuthenticationModifier: ViewModifier {
***REMOVED***@ObservedObject var authenticator: Authenticator
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***if let challenge = authenticator.currentChallenge {
***REMOVED******REMOVED******REMOVED***switch challenge {
***REMOVED******REMOVED******REMOVED***case let challenge as QueuedArcGISChallenge:
***REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(UsernamePasswordViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED***case let challenge as QueuedURLChallenge:
***REMOVED******REMOVED******REMOVED******REMOVED***switch challenge.urlChallenge.protectionSpace.authenticationMethod {
***REMOVED******REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodServerTrust:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(TrustHostViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodClientCertificate:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(CertificatePickerViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED******REMOVED***case NSURLAuthenticationMethodDefault,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodNTLM,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTMLForm,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPBasic,
***REMOVED******REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPDigest:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***content.modifier(UsernamePasswordViewModifier(challenge: challenge))
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***else {
***REMOVED******REMOVED******REMOVED***content
***REMOVED***
***REMOVED***
***REMOVED***
