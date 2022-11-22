#  FloorFilter

The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a building in your application. It allows you to filter the floor plan data displayed in your geo view to view a site, a building in the site, or a floor in the building. 

The ArcGIS Maps SDK currently supports filtering a 2D floor aware map based on the sites, buildings, or levels in the map.

|iPhone|iPad|
|:--:|:--:|
|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202811733-dcd640e9-3b27-43a8-8bec-fd9aeb6798c7.png)|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202811772-bf6009e7-82ec-459f-86ae-6651f519b2ef.png)|

## Features:

- Automatically hides the floor browsing view when the associated map or scene is not floor-aware.
- Selects the facility in view automatically (can be configured through the `AutomaticSelectionMode`).
- Shows the selected facility's levels in proper vertical order.
- Filters the map/scene content to show the selected level.
- Allows browsing the full floor-aware hierarchy of sites, facilities, and levels.
- Shows the ground floor of all facilities when there is no active selection.
- Updates the visibility of floor levels across all facilities (e.g. if you are looking at floor 3 in building A, floor 3 will be shown in neighboring buildings).
- Adjusts layout and presentation to work well regardless of positioning - left/right and top/bottom.
- Keeps the selected facility visible in the list while the selection is changing in response to map navigation.

## Key properties

`FloorFilter` has the following initializer:

```swift
***REMOVED******REMOVED***/ Creates a `FloorFilter`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - floorManager: The floor manager used by the `FloorFilter`.
***REMOVED******REMOVED***/   - alignment: Determines the display configuration of Floor Filter elements.
***REMOVED******REMOVED***/   - automaticSelectionMode: The selection behavior of the floor filter.
***REMOVED******REMOVED***/   - viewpoint: Viewpoint updated when the selected site or facility changes.
***REMOVED******REMOVED***/   - isNavigating: A Boolean value indicating whether the map is currently being navigated.
***REMOVED***public init(
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***alignment: Alignment,
***REMOVED******REMOVED***automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?> = .constant(nil),
***REMOVED******REMOVED***isNavigating: Binding<Bool>
***REMOVED***)
```

`FloorFilter` has the associated enum:

```swift
***REMOVED***/ Defines automatic selection behavior.
public enum FloorFilterAutomaticSelectionMode {
***REMOVED******REMOVED***/ Always update selection based on the current viewpoint; clear the selection when the user
***REMOVED******REMOVED***/ navigates away.
***REMOVED***case always
***REMOVED******REMOVED***/ Only update the selection when there is a new site or facility in the current viewpoint; don't clear
***REMOVED******REMOVED***/ selection when the user navigates away.
***REMOVED***case alwaysNotClearing
***REMOVED******REMOVED***/ Never update selection based on the map or scene view's current viewpoint.
***REMOVED***case never
***REMOVED***
```

## Behavior:

|Site Button|
|:--:|
|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203417956-5161103d-5d29-42fa-8564-de254159efe2.png)|

When the Site button is tapped, a prompt opens so the user can select a site and then a facility. After selecting a site and facility, a list of levels is displayed. The list of sites and facilities can be dynamically filtered using the search bar.

## Usage

### Basic usage for displaying a `FloorFilter`.

```swift
***REMOVED***/ Make a map from a portal item.
static func makeMap() -> Map {
***REMOVED***Map(item: PortalItem(
***REMOVED******REMOVED***portal: .arcGISOnline(connection: .anonymous),
***REMOVED******REMOVED***id: Item.ID("b4b599a43a474d33946cf0df526426f5")!
***REMOVED***))
***REMOVED***

***REMOVED***/ Determines the appropriate time to initialize the `FloorFilter`.
@State private var isMapLoaded = false

***REMOVED***/ A Boolean value indicating whether the map is currently being navigated.
@State private var isNavigating = false

***REMOVED***/ The initial viewpoint of the map.
@State private var viewpoint: Viewpoint? = Viewpoint(
***REMOVED***center: Point(
***REMOVED******REMOVED***x: -117.19496,
***REMOVED******REMOVED***y: 34.05713,
***REMOVED******REMOVED***spatialReference: .wgs84
***REMOVED***),
***REMOVED***scale: 100_000
)

@StateObject private var map = makeMap()

var body: some View {
***REMOVED***MapView(
***REMOVED******REMOVED***map: map,
***REMOVED******REMOVED***viewpoint: viewpoint
***REMOVED***)
***REMOVED***.onNavigatingChanged {
***REMOVED******REMOVED***isNavigating = $0
***REMOVED***
***REMOVED***.onViewpointChanged(kind: .centerAndScale) {
***REMOVED******REMOVED***viewpoint = $0
***REMOVED***
***REMOVED******REMOVED***/ Preserve the current viewpoint when a keyboard is presented in landscape.
***REMOVED***.ignoresSafeArea(.keyboard, edges: .bottom)
***REMOVED***.overlay(alignment: .bottomLeading) {
***REMOVED******REMOVED***if isMapLoaded,
***REMOVED******REMOVED***   let floorManager = map.floorManager {
***REMOVED******REMOVED******REMOVED***FloorFilter(
***REMOVED******REMOVED******REMOVED******REMOVED***floorManager: floorManager,
***REMOVED******REMOVED******REMOVED******REMOVED***alignment: .bottomLeading,
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED***isNavigating: $isNavigating
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.frame(
***REMOVED******REMOVED******REMOVED******REMOVED***maxWidth: 400,
***REMOVED******REMOVED******REMOVED******REMOVED***maxHeight: 400
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.padding(36)
***REMOVED***
***REMOVED***
***REMOVED***.task {
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try await map.load()
***REMOVED******REMOVED******REMOVED***isMapLoaded = true
***REMOVED*** catch { ***REMOVED***
***REMOVED***
***REMOVED***
```

To see it in action, try out the [Examples](../../Examples) and refer to [FloorFilterExampleView.swift](../../Examples/Examples/FloorFilterExampleView.swift) in the project.
