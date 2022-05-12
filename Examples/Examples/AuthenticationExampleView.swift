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
***REMOVED***
***REMOVED***Toolkit

struct AuthenticationExampleView: View {
***REMOVED***@StateObject var authenticator = Authenticator()
***REMOVED***@State var previousApiKey: APIKey?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***List(AuthenticationItem.all, id: \.title) { item in
***REMOVED******REMOVED******REMOVED***AuthenticationItemView(item: item)
***REMOVED***
***REMOVED******REMOVED***.navigationBarTitle(Text("Authentication"), displayMode: .inline)
***REMOVED******REMOVED***.sheet(item: $authenticator.continuation) {
***REMOVED******REMOVED******REMOVED***AuthenticationView(continuation: $0)
***REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED***ArcGISURLSession.challengeHandler = authenticator
***REMOVED***
***REMOVED******REMOVED******REMOVED*** Save and restore the API Key.
***REMOVED******REMOVED******REMOVED*** Note: This is only necessary in this example. Other examples make use of the global
***REMOVED******REMOVED******REMOVED*** api key that is set when the app starts up. Using an api key will prevent an
***REMOVED******REMOVED******REMOVED*** authentication challenge prompt for certain services. Since this example highlights
***REMOVED******REMOVED******REMOVED*** the usage of authentication challenge prompts, we want to set the api key to `nil`
***REMOVED******REMOVED******REMOVED*** when this example appears and restore it when this example disappears.
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED*** Save off the api key
***REMOVED******REMOVED******REMOVED***previousApiKey = ArcGISRuntimeEnvironment.apiKey
***REMOVED******REMOVED******REMOVED******REMOVED*** Set the api key to nil so that the authenticated services will prompt.
***REMOVED******REMOVED******REMOVED***ArcGISRuntimeEnvironment.apiKey = nil
***REMOVED***
***REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED*** Restore api key when exiting this example.
***REMOVED******REMOVED******REMOVED***ArcGISRuntimeEnvironment.apiKey = previousApiKey
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func errorString(for error: Error) -> String {
***REMOVED******REMOVED***switch error {
***REMOVED******REMOVED***case is ArcGISAuthenticationChallenge.Error:
***REMOVED******REMOVED******REMOVED***return "Authentication error"
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return error.localizedDescription
***REMOVED***
***REMOVED***
***REMOVED***

private struct AuthenticationItemView: View {
***REMOVED***let loadable: Loadable
***REMOVED***let title: String
***REMOVED***@State var status = LoadStatus.notLoaded
***REMOVED***
***REMOVED***init(item: AuthenticationItem) {
***REMOVED******REMOVED***self.loadable = item.loadable
***REMOVED******REMOVED***self.title = item.title
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***status = .loading
***REMOVED******REMOVED******REMOVED******REMOVED***try? await loadable.load()
***REMOVED******REMOVED******REMOVED******REMOVED***status = loadable.loadStatus
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***buttonContent
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var buttonContent: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***switch status {
***REMOVED******REMOVED******REMOVED***case .loading:
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED***case .loaded:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Loaded")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.green)
***REMOVED******REMOVED******REMOVED***case .notLoaded:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Tap to load")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***case .failed:
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Failed to laod")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.red)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED***static let worldImageryMapServer = URL(string: "https:***REMOVED***ibasemaps-api.arcgis.com/arcgis/rest/services/World_Imagery/MapServer")!
***REMOVED***

private struct AuthenticationItem {
***REMOVED***let title: String
***REMOVED***let loadable: Loadable
***REMOVED***

extension AuthenticationItem {
***REMOVED***static let token = AuthenticationItem(
***REMOVED******REMOVED***title: "Token secured resource",
***REMOVED******REMOVED***loadable: ArcGISTiledLayer(url: .worldImageryMapServer)
***REMOVED***)
***REMOVED***
***REMOVED***static let all: [AuthenticationItem] = [
***REMOVED******REMOVED***.token
***REMOVED***]
***REMOVED***
