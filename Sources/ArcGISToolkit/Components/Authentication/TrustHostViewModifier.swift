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
***REMOVED******REMOVED*** Even though we will present it right away we need to use a state variable for this.
***REMOVED******REMOVED*** Using a constant has 2 issues. One, it won't animate. Two, when challenging for multiple
***REMOVED******REMOVED*** endpoints at a time, and the challenges stack up, you can end up with a "already presenting"
***REMOVED******REMOVED*** error.
***REMOVED***@State var isPresented: Bool = false
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Present the alert right away. This makes it animated.
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.alert("Certificate Trust Warning", isPresented: $isPresented, presenting: challenge) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Dangerous: Allow Connection", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .continueWithCredential(.serverTrust))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .cancel)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** message: { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***Text("The certificate provided by '\(challenge.host)' is not signed by a trusted authority.")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
