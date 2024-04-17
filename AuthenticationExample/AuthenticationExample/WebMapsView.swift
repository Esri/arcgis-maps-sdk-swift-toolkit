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
***REMOVED***

***REMOVED***/ A view that displays the web maps of a portal.
struct WebMapsView: View {
***REMOVED******REMOVED***/ The portal from which the web maps can be fetched.
***REMOVED***var portal: Portal
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the featured content is being loaded.
***REMOVED***@State private var isLoading = true
***REMOVED***
***REMOVED******REMOVED***/ The web map portal items.
***REMOVED***@State private var webMapItems = [PortalItem]()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if isLoading {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***List(webMapItems, id: \.id) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***MapItemView(map: Map(item: item))
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***PortalItemView(item: item)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***guard webMapItems.isEmpty else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Try to fetch the featured items but if none available then find webmap items.
***REMOVED******REMOVED******REMOVED******REMOVED***var items = try await portal.featuredItems
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.filter { $0.kind == .webMap ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if items.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***items = try await portal.findItems(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***queryParameters: .items(ofKinds: [.webMap])
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.results
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***webMapItems = items
***REMOVED******REMOVED*** catch {***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isLoading = false
***REMOVED***
***REMOVED******REMOVED***.navigationTitle("Web Maps")
***REMOVED***
***REMOVED***

***REMOVED***/ A view that displays information about a portal item for viewing that information within a list.
struct PortalItemView: View {
***REMOVED******REMOVED***/ The portal item to display information about.
***REMOVED***var item: PortalItem
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***if let thumbnail = item.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***LoadableImageView(loadableImage: thumbnail)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 64, height: 44)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***VStack(alignment: .leading, spacing: 2) {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(item.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.headline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Owner: \(item.owner), Views: \(item.viewCount)")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED***Text(item.snippet)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
