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

@MainActor protocol TrustHostViewModel: ObservableObject {
***REMOVED***var challengingHost: String { get ***REMOVED***
***REMOVED***
***REMOVED***func allowConnection()
***REMOVED***func cancel()
***REMOVED***

final class TrustHostChallengeViewModel: TrustHostViewModel {
***REMOVED***init(challenge: QueuedURLChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED***
***REMOVED***
***REMOVED***let challenge: QueuedURLChallenge
***REMOVED***
***REMOVED***var challengingHost: String {
***REMOVED******REMOVED***challenge.urlChallenge.protectionSpace.host
***REMOVED***
***REMOVED***
***REMOVED***func allowConnection() {
***REMOVED******REMOVED***challenge.resume(
***REMOVED******REMOVED******REMOVED***with: (
***REMOVED******REMOVED******REMOVED******REMOVED***.useCredential,
***REMOVED******REMOVED******REMOVED******REMOVED***URLCredential(trust: challenge.urlChallenge.protectionSpace.serverTrust!)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***challenge.resume(with: (.performDefaultHandling, nil))
***REMOVED***
***REMOVED***

final class MockTrustHostViewModel: TrustHostViewModel {
***REMOVED***let challengingHost: String
***REMOVED***init(challengingHost: String) {
***REMOVED******REMOVED***self.challengingHost = challengingHost
***REMOVED***
***REMOVED***func allowConnection() {***REMOVED***
***REMOVED***func cancel() {***REMOVED***
***REMOVED***

struct TrustHostView<ViewModel: TrustHostViewModel>: View {
***REMOVED***init(viewModel: ViewModel) {
***REMOVED******REMOVED***self.viewModel = viewModel
***REMOVED***
***REMOVED***
***REMOVED***@ObservedObject private var viewModel: ViewModel
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Text("Certificate Trust Warning")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom])
***REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.center)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text("The certificate provided by '\(viewModel.challengingHost)' is not signed by a trusted authority.")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.body)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding([.bottom])
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button(role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.cancel()
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Cancel")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED***.controlSize(.large)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.allowConnection()
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Dangerous: Allow Connection")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED***.controlSize(.large)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***.interactiveDismissDisabled()
***REMOVED***
***REMOVED***

struct TrustHostView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***TrustHostView(viewModel: MockTrustHostViewModel(challengingHost: "arcgis.com"))
***REMOVED***
***REMOVED***
