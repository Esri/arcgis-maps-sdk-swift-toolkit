***REMOVED***.

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

struct Examples: View {
***REMOVED******REMOVED***/ The list of example lists.  Allows for a hierarchical navigation model for examples.
***REMOVED***let lists: [ExampleList] = [
***REMOVED******REMOVED***.augmentedReality,
***REMOVED******REMOVED***.geoview,
***REMOVED******REMOVED***.views
***REMOVED***]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***NavigationView {
***REMOVED******REMOVED******REMOVED***List(lists) { (list) in
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(list.name, destination: list)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.navigationBarTitle(Text("Toolkit Examples"), displayMode: .inline)
***REMOVED***
***REMOVED******REMOVED***.navigationViewStyle(StackNavigationViewStyle())
***REMOVED***
***REMOVED***

extension ExampleList {
***REMOVED***static let augmentedReality = Self(
***REMOVED******REMOVED***name: "Augmented Reality",
***REMOVED******REMOVED***examples: [
***REMOVED******REMOVED******REMOVED***AnyExample("Flyover", content: FlyoverExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Tabletop", content: TableTopExampleView())
***REMOVED******REMOVED***]
***REMOVED***)
***REMOVED***
***REMOVED***static let geoview = Self(
***REMOVED******REMOVED***name: "GeoView",
***REMOVED******REMOVED***examples: [
***REMOVED******REMOVED******REMOVED***AnyExample("Basemap Gallery", content: BasemapGalleryExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Bookmarks", content: BookmarksExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Compass", content: CompassExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Floor Filter", content: FloorFilterExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Overview Map", content: OverviewMapExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Popup", content: PopupExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Scalebar", content: ScalebarExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Search", content: SearchExampleView()),
***REMOVED******REMOVED******REMOVED***AnyExample("Utility Network Trace", content: UtilityNetworkTraceExampleView())
***REMOVED******REMOVED***]
***REMOVED***)
***REMOVED***
***REMOVED***static let views = Self(
***REMOVED******REMOVED***name: "Views",
***REMOVED******REMOVED***examples: [
***REMOVED******REMOVED******REMOVED***AnyExample("Floating Panel", content: FloatingPanelExampleView())
***REMOVED******REMOVED***]
***REMOVED***)
***REMOVED***
