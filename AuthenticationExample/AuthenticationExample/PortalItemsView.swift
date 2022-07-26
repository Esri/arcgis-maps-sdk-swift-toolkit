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

***REMOVED***/ A view that displays portal items.
struct FeaturedMapsView: View {
***REMOVED***var portal: Portal
***REMOVED***@State var isLoading = true
***REMOVED***@State var featuredItems = [PortalItem]()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if isLoading {
***REMOVED******REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***List(featuredItems) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***MapItemView(map: Map(item: item))
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ItemView(item: item)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***guard featuredItems.isEmpty else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED***featuredItems = try await portal.homePageFeaturedContent
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.filter { $0.kind == .webMap ***REMOVED***
***REMOVED******REMOVED*** catch {***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***isLoading = false
***REMOVED***
***REMOVED******REMOVED***.navigationTitle("Featured Maps")
***REMOVED***
***REMOVED***

struct ItemView: View {
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
