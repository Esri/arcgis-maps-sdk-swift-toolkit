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
***REMOVED******REMOVED***/ The list items to display.
***REMOVED***let listItems = makeListItems()
***REMOVED***
***REMOVED******REMOVED***/ The visibility of the navigation split view's column.
***REMOVED***@State private var columnVisibility: NavigationSplitViewVisibility = .all
***REMOVED******REMOVED***/ The example selected by the user.
***REMOVED***@State private var selectedExample: Example?
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationSplitView(columnVisibility: $columnVisibility) {
***REMOVED******REMOVED******REMOVED***List(listItems, selection: $selectedExample) { item in
***REMOVED******REMOVED******REMOVED******REMOVED***switch item {
***REMOVED******REMOVED******REMOVED******REMOVED***case .category(let category):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(category.name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(category.examples) { example in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(example.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tag(example)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***case .example(let example):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(example.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.tag(example)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Toolkit Examples")
***REMOVED*** detail: {
***REMOVED******REMOVED******REMOVED***if let selectedExample {
***REMOVED******REMOVED******REMOVED******REMOVED***selectedExample.view
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationTitle(selectedExample.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Select an example")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED*** visionOS doesn't provide the column visibility toggle like
***REMOVED******REMOVED******REMOVED*** iPadOS and Mac Catalyst so conditionally hide the column.
#if !os(visionOS)
***REMOVED******REMOVED***.onChange(selectedExample) { _ in
***REMOVED******REMOVED******REMOVED***columnVisibility = .detailOnly
***REMOVED***
#endif
***REMOVED***
***REMOVED***
***REMOVED***static func makeCategories() -> [ListItem] {
#if os(iOS) && !targetEnvironment(macCatalyst)
***REMOVED******REMOVED***return [.category(.augmentedReality)]
#else
***REMOVED******REMOVED***return []
#endif
***REMOVED***
***REMOVED***
***REMOVED***static func makeListItems() -> [ListItem] {
***REMOVED******REMOVED***(makeCategories() + makeUncategorizedExamples())
***REMOVED******REMOVED******REMOVED***.sorted(by: { $0.id < $1.id ***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static func makeUncategorizedExamples() -> [ListItem] {
***REMOVED******REMOVED***return [
***REMOVED******REMOVED******REMOVED***.example(.init("Basemap Gallery", content: BasemapGalleryExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Bookmarks", content: BookmarksExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Compass", content: CompassExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Feature Form", content: FeatureFormExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Floating Panel", content: FloatingPanelExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Floor Filter", content: FloorFilterExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Overview Map", content: OverviewMapExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Popup", content: PopupExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Scalebar", content: ScalebarExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Search", content: SearchExampleView())),
***REMOVED******REMOVED******REMOVED***.example(.init("Utility Network Trace", content: UtilityNetworkTraceExampleView()))
***REMOVED******REMOVED***]
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
