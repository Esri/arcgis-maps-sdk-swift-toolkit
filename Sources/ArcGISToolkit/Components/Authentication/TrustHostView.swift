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

struct TrustHostViewModifier: ViewModifier {
***REMOVED***init(challenge: QueuedURLChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED***
***REMOVED***
***REMOVED***let challenge: QueuedURLChallenge
***REMOVED***
***REMOVED***var host: String {
***REMOVED******REMOVED***challenge.urlChallenge.protectionSpace.host
***REMOVED***
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.alert("Certificate Trust Warning", isPresented: .constant(true), presenting: challenge) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Dangerous: Allow Connection", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.resume(with: .trustHost)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***challenge.cancel()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** message: { _ in
***REMOVED******REMOVED******REMOVED******REMOVED***Text("The certificate provided by '\(host)' is not signed by a trusted authority.")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
