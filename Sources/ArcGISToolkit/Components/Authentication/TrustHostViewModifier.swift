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

***REMOVED***/ Prompts the user when encountering an untrusted host.
struct TrustHostViewModifier: ViewModifier {
***REMOVED******REMOVED***/ Creates a `TrustHostViewModifier`.
***REMOVED******REMOVED***/ - Parameter challenge: The network authentication challenge for the untrusted host.
***REMOVED******REMOVED***/ - Precondition: `challenge.kind` is equal to `serverTrust`.
***REMOVED***init(challenge: NetworkChallengeContinuation) {
***REMOVED******REMOVED***precondition(challenge.kind == .serverTrust)
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The network authentication challenge for the untrusted host.
***REMOVED***let challenge: NetworkChallengeContinuation
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether or not the prompt is displayed.
***REMOVED***@State var isPresented: Bool = false
***REMOVED***
***REMOVED***var title: some View {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Certificate Trust Warning",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating that the remote host's certificate is not trusted."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED***
***REMOVED***
***REMOVED***var message: some View {
***REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED***"Dangerous: The certificate provided by '\(challenge.host)' is not signed by a trusted authority.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A warning that the host service (challenge.host) is providing a potentially unsafe certificate."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED***
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
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $isPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .center) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***title
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.vertical)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***message
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.bottom)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .cancel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.cancel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .continueWithCredential(.serverTrust))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Allow",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A button indicating the user accepts a potentially dangerous action."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED******REMOVED***.presentationDetents([.medium])
***REMOVED******REMOVED******REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
