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
***REMOVED******REMOVED***/ The list of example lists.  Allows for a hierarchical navigation model for examples.
***REMOVED***let lists = makeExamples()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationStack {
***REMOVED******REMOVED******REMOVED***List(lists) { (list) in
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(list.name, destination: list)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationTitle("Toolkit Examples")
***REMOVED******REMOVED******REMOVED***.navigationBarTitleDisplayMode(.inline)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***static func makeExamples() -> [ExampleList] {
***REMOVED******REMOVED***let common: [ExampleList] = [
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

extension ExampleList {
#if os(iOS) && !targetEnvironment(macCatalyst)
***REMOVED***static var augmentedReality: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***name: "Augmented Reality",
***REMOVED******REMOVED******REMOVED***examples: [
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("Flyover", content: FlyoverExampleView()),
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("Tabletop", content: TableTopExampleView()),
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("World Scale", content: WorldScaleExampleView())
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
***REMOVED***
#endif
***REMOVED***
***REMOVED***static var geoview: Self {
***REMOVED******REMOVED***var examples: [any Example] = [
***REMOVED******REMOVED******REMOVED***AnyExample("Basemap Gallery", content: BasemapGalleryExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Bookmarks", content: BookmarksExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Overview Map", content: OverviewMapExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Popup", content: PopupExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Scalebar", content: ScalebarExampleView())
***REMOVED******REMOVED***]
#if !os(visionOS)
***REMOVED******REMOVED***examples.append(
***REMOVED******REMOVED******REMOVED***contentsOf: [
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("Compass", content: CompassExampleView()),
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("Feature Form", content: FeatureFormExampleView()),
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("Floor Filter", content: FloorFilterExampleView()),
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("Search", content: SearchExampleView()),
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("Utility Network Trace", content: UtilityNetworkTraceExampleView())
***REMOVED******REMOVED******REMOVED***] as [any Example]
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
***REMOVED******REMOVED******REMOVED******REMOVED***AnyExample("Floating Panel", content: FloatingPanelExampleView())
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
