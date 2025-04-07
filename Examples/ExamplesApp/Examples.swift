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
***REMOVED******REMOVED***/ The menu items to display.
***REMOVED***let menuItems = makeMenuItems()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationSplitView {
***REMOVED******REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED******REMOVED***List(menuItems, id: \.name) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let category = item as? Category {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(category.name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***List(category.examples, id: \.name) { example in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeExampleLink(example)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listStyle(.sidebar)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle(category.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.isDetailLink(false)
***REMOVED******REMOVED******REMOVED******REMOVED*** else if let example = item as? Example {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeExampleLink(example)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED*** detail: {
***REMOVED******REMOVED******REMOVED***Text("Select a example")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makeExampleLink(_ example: Example) -> some View {
***REMOVED******REMOVED***NavigationLink(
***REMOVED******REMOVED******REMOVED***example.name,
***REMOVED******REMOVED******REMOVED***destination: example.view
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle(example.name)
***REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***.isDetailLink(true)
***REMOVED***
***REMOVED***
***REMOVED***static func makeCategories() -> [Category] {
#if os(iOS) && !targetEnvironment(macCatalyst)
***REMOVED******REMOVED***return [.augmentedReality]
#else
***REMOVED******REMOVED***return []
#endif
***REMOVED***
***REMOVED***
***REMOVED***static func makeMenuItems() -> [any MenuItem] {
***REMOVED******REMOVED***(makeCategories() + makeUncategorizedExamples())
***REMOVED******REMOVED******REMOVED***.sorted(by: { $0.name < $1.name ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static func makeUncategorizedExamples() -> [Example] { [
***REMOVED******REMOVED***Example("Basemap Gallery", content: BasemapGalleryExampleView()),
***REMOVED******REMOVED***Example("Bookmarks", content: BookmarksExampleView()),
***REMOVED******REMOVED***Example("Compass", content: CompassExampleView()),
***REMOVED******REMOVED***Example("Feature Form", content: FeatureFormExampleView()),
***REMOVED******REMOVED***Example("Floating Panel", content: FloatingPanelExampleView()),
***REMOVED******REMOVED***Example("Floor Filter", content: FloorFilterExampleView()),
***REMOVED******REMOVED***Example("Overview Map", content: OverviewMapExampleView()),
***REMOVED******REMOVED***Example("Popup", content: PopupExampleView()),
***REMOVED******REMOVED***Example("Scalebar", content: ScalebarExampleView()),
***REMOVED******REMOVED***Example("Search", content: SearchExampleView()),
***REMOVED******REMOVED***Example("Utility Network Trace", content: UtilityNetworkTraceExampleView())
***REMOVED***] ***REMOVED***
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
