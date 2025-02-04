***REMOVED***
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

struct Examples: View {
***REMOVED******REMOVED***/ The categories to display.
***REMOVED***let categories = makeCategories()
***REMOVED***
***REMOVED******REMOVED***/ The category selected by the user.
***REMOVED***@State private var selectedCategory: Category?
***REMOVED******REMOVED***/ The example selected by the user.
***REMOVED***@State private var selectedExample: Example?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationSplitView {
***REMOVED******REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED***List(categories, id: \.name, selection: $selectedCategory) { category in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(category.name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List(category.examples, id: \.name, selection: $selectedExample) { example in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(example.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tag(example)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.sidebar)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle(category.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.isDetailLink(false)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle("Toolkit Examples")
***REMOVED******REMOVED***
***REMOVED*** detail: {
***REMOVED******REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if let example = selectedExample {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***example.view
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle(example.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED*** else if selectedCategory != nil {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Select an example")
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Select a category")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***static func makeCategories() -> [Category] {
***REMOVED******REMOVED***let common: [Category] = [
***REMOVED******REMOVED******REMOVED***.geoview,
***REMOVED******REMOVED******REMOVED***.views
***REMOVED******REMOVED***]
#if os(iOS) && !targetEnvironment(macCatalyst)
***REMOVED******REMOVED***return [.augmentedReality] + common
#else
***REMOVED******REMOVED***return common
#endif
***REMOVED***
***REMOVED***

@MainActor
extension Category {
#if os(iOS) && !targetEnvironment(macCatalyst)
***REMOVED***static var augmentedReality: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***name: "Augmented Reality",
***REMOVED******REMOVED******REMOVED***examples: [
***REMOVED******REMOVED******REMOVED******REMOVED***Example("Flyover", content: FlyoverExampleView()),
***REMOVED******REMOVED******REMOVED******REMOVED***Example("Tabletop", content: TableTopExampleView()),
***REMOVED******REMOVED******REMOVED******REMOVED***Example("World Scale", content: WorldScaleExampleView())
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
***REMOVED***
#endif
***REMOVED***
***REMOVED***static var geoview: Self {
***REMOVED******REMOVED***var examples: [Example] = [
***REMOVED******REMOVED******REMOVED***Example("Basemap Gallery", content: BasemapGalleryExampleView()),
***REMOVED******REMOVED******REMOVED***Example("Bookmarks", content: BookmarksExampleView()),
***REMOVED******REMOVED******REMOVED***Example("Compass", content: CompassExampleView()),
***REMOVED******REMOVED******REMOVED***Example("Floor Filter", content: FloorFilterExampleView()),
***REMOVED******REMOVED******REMOVED***Example("Overview Map", content: OverviewMapExampleView()),
***REMOVED******REMOVED******REMOVED***Example("Popup", content: PopupExampleView()),
***REMOVED******REMOVED******REMOVED***Example("Scalebar", content: ScalebarExampleView()),
***REMOVED******REMOVED******REMOVED***Example("Search", content: SearchExampleView()),
***REMOVED******REMOVED******REMOVED***Example("Utility Network Trace", content: UtilityNetworkTraceExampleView())
***REMOVED******REMOVED***]
#if !os(visionOS)
***REMOVED******REMOVED***examples.append(
***REMOVED******REMOVED******REMOVED***contentsOf: [
***REMOVED******REMOVED******REMOVED******REMOVED***Example("Feature Form", content: FeatureFormExampleView())
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
#endif
***REMOVED******REMOVED***return .init(
***REMOVED******REMOVED******REMOVED***name: "GeoView",
***REMOVED******REMOVED******REMOVED***examples: examples.sorted(by: { $0.name < $1.name ***REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var views: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***name: "Views",
***REMOVED******REMOVED******REMOVED***examples: [
***REMOVED******REMOVED******REMOVED******REMOVED***Example("Floating Panel", content: FloatingPanelExampleView())
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
