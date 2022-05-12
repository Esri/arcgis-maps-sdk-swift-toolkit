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

private extension URL {
***REMOVED***static let worldImageryMapServer = URL(string: "https:***REMOVED***ibasemaps-api.arcgis.com/arcgis/rest/services/World_Imagery/MapServer")!
***REMOVED***

struct AuthenticationExampleView: View {
***REMOVED***@State private var mapLoadResult: Result<Map, Error>?
***REMOVED******REMOVED***@StateObject private var authenticator = Authenticator()
***REMOVED***
***REMOVED***static func makeMap() -> Map {
***REMOVED******REMOVED***let basemap = Basemap(baseLayer: ArcGISTiledLayer(url: .worldImageryMapServer))
***REMOVED******REMOVED***return Map(basemap: basemap)
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if let mapLoadResult = mapLoadResult {
***REMOVED******REMOVED******REMOVED******REMOVED***switch mapLoadResult {
***REMOVED******REMOVED******REMOVED******REMOVED***case .success(let value):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***MapView(map: value)
***REMOVED******REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Error loading map: \(errorString(for: error))")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***let map = Self.makeMap()
***REMOVED******REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED******REMOVED***mapLoadResult = .success(map)
***REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED***mapLoadResult = .failure(error)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: authenticator) {
***REMOVED******REMOVED******REMOVED******REMOVED***SignInSheet(model: signInModel)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***ArcGISURLSession.challengeHandler = signInModel
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.onDisappear {
***REMOVED******REMOVED******REMOVED******REMOVED***ArcGISURLSession.challengeHandler = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func errorString(for error: Error) -> String {
***REMOVED******REMOVED***switch error {
***REMOVED******REMOVED***case let authenticationError as ArcGISAuthenticationChallenge.Error:
***REMOVED******REMOVED******REMOVED***switch authenticationError {
***REMOVED******REMOVED******REMOVED***case .userCancelled(_):
***REMOVED******REMOVED******REMOVED******REMOVED***return "User cancelled error"
***REMOVED******REMOVED******REMOVED***case .credentialCannotBeShared:
***REMOVED******REMOVED******REMOVED******REMOVED***return "Provided credential cannot be shared"
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return error.localizedDescription
***REMOVED***
***REMOVED***
***REMOVED***

struct AuthenticationExampleView_Previews: PreviewProvider {
***REMOVED***static var previews: some View {
***REMOVED******REMOVED***AuthenticationExampleView()
***REMOVED***
***REMOVED***
