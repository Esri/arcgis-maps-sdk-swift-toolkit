

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
***REMOVED******REMOVED***/   - selection: The selected site, facility, or level.
***REMOVED***public init(
***REMOVED******REMOVED***floorManager: FloorManager,
***REMOVED******REMOVED***alignment: Alignment,
***REMOVED******REMOVED***automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?> = .constant(nil),
***REMOVED******REMOVED***isNavigating: Binding<Bool>,
***REMOVED******REMOVED***selection: Binding<FloorFilterSelection?>? = nil
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

***REMOVED***/  A selected site, facility, or level.
public enum FloorFilterSelection: Hashable {
***REMOVED******REMOVED***/ A selected site.
***REMOVED***case site(FloorSite)
***REMOVED******REMOVED***/ A selected facility.
***REMOVED***case facility(FloorFacility)
***REMOVED******REMOVED***/ A selected level.
***REMOVED***case level(FloorLevel)
***REMOVED***
```

`FloorFilter` has the following modifier:

- `func levelSelectorWidth(_ width: CGFloat)` - The width of the level selector.

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
