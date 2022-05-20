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

public struct AuthenticationView: View {
***REMOVED***public init(challenge: IdentifiableQueuedChallenge) {
***REMOVED******REMOVED***self.challenge = challenge.queuedChallenge
***REMOVED***

***REMOVED***let challenge: QueuedChallenge
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***switch challenge {
***REMOVED******REMOVED***case let challenge as QueuedArcGISChallenge:
***REMOVED******REMOVED******REMOVED***UsernamePasswordView(viewModel: TokenCredentialViewModel(challenge: challenge))
***REMOVED******REMOVED***case let challenge as QueuedURLChallenge:
***REMOVED******REMOVED******REMOVED***view(forURLChallenge: challenge)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@MainActor
***REMOVED***@ViewBuilder
***REMOVED***func view(forURLChallenge challenge: QueuedURLChallenge) -> some View {
***REMOVED******REMOVED***switch challenge.urlChallenge.protectionSpace.authenticationMethod {
***REMOVED******REMOVED***case NSURLAuthenticationMethodServerTrust:
***REMOVED******REMOVED******REMOVED***TrustHostView(viewModel: TrustHostChallengeViewModel(challenge: challenge))
***REMOVED******REMOVED***case NSURLAuthenticationMethodClientCertificate:
***REMOVED******REMOVED******REMOVED***CertificatePickerView()
***REMOVED******REMOVED***case NSURLAuthenticationMethodDefault,
***REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodNTLM,
***REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTMLForm,
***REMOVED******REMOVED******REMOVED***NSURLAuthenticationMethodHTTPBasic,
***REMOVED******REMOVED***NSURLAuthenticationMethodHTTPDigest:
***REMOVED******REMOVED******REMOVED***UsernamePasswordView(viewModel: URLCredentialUsernamePasswordViewModel(challenge: challenge))
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***fatalError()
***REMOVED***
***REMOVED***
***REMOVED***
