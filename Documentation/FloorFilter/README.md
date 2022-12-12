#  FloorFilter

The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a building in your application. It allows you to filter the floor plan data displayed in your geo view to view a site, a building in the site, or a floor in the building. 

The ArcGIS Maps SDK currently supports filtering a 2D floor aware map based on the sites, buildings, or levels in the map.

|iPhone|iPad|
|:--:|:--:|
|![image](https://user-images.githubusercontent.com/3998072/202811733-dcd640e9-3b27-43a8-8bec-fd9aeb6798c7.png)|![image](https://user-images.githubusercontent.com/3998072/202811772-bf6009e7-82ec-459f-86ae-6651f519b2ef.png)|

## Features

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
    /// Creates a `FloorFilter`.
    /// - Parameters:
    ///   - floorManager: The floor manager used by the `FloorFilter`.
    ///   - alignment: Determines the display configuration of Floor Filter elements.
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    ///   - isNavigating: A Boolean value indicating whether the map is currently being navigated.
    public init(
        floorManager: FloorManager,
        alignment: Alignment,
        automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
        viewpoint: Binding<Viewpoint?> = .constant(nil),
        isNavigating: Binding<Bool>
    )
```

`FloorFilter` has the associated enum:

```swift
/// Defines automatic selection behavior.
public enum FloorFilterAutomaticSelectionMode {
    /// Always update selection based on the current viewpoint; clear the selection when the user
    /// navigates away.
    case always
    /// Only update the selection when there is a new site or facility in the current viewpoint; don't clear
    /// selection when the user navigates away.
    case alwaysNotClearing
    /// Never update selection based on the map or scene view's current viewpoint.
    case never
}
```

## Behavior:

|Site Button|
|:--:|
|![image](https://user-images.githubusercontent.com/3998072/203417956-5161103d-5d29-42fa-8564-de254159efe2.png)|

When the Site button is tapped, a prompt opens so the user can select a site and then a facility. After selecting a site and facility, a list of levels is displayed. The list of sites and facilities can be dynamically filtered using the search bar.

## Usage

### Basic usage for displaying a `FloorFilter`.

```swift
/// Make a map from a portal item.
static func makeMap() -> Map {
    Map(item: PortalItem(
        portal: .arcGISOnline(connection: .anonymous),
        id: Item.ID("b4b599a43a474d33946cf0df526426f5")!
    ))
}

/// Determines the appropriate time to initialize the `FloorFilter`.
@State private var isMapLoaded = false

/// A Boolean value indicating whether the map is currently being navigated.
@State private var isNavigating = false

/// The initial viewpoint of the map.
@State private var viewpoint: Viewpoint? = Viewpoint(
    center: Point(
        x: -117.19496,
        y: 34.05713,
        spatialReference: .wgs84
    ),
    scale: 100_000
)

@StateObject private var map = makeMap()

var body: some View {
    MapView(
        map: map,
        viewpoint: viewpoint
    )
    .onNavigatingChanged {
        isNavigating = $0
    }
    .onViewpointChanged(kind: .centerAndScale) {
        viewpoint = $0
    }
    /// Preserve the current viewpoint when a keyboard is presented in landscape.
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .overlay(alignment: .bottomLeading) {
        if isMapLoaded,
           let floorManager = map.floorManager {
            FloorFilter(
                floorManager: floorManager,
                alignment: .bottomLeading,
                viewpoint: $viewpoint,
                isNavigating: $isNavigating
            )
            .frame(
                maxWidth: 400,
                maxHeight: 400
            )
            .padding(36)
        }
    }
    .task {
        do {
            try await map.load()
            isMapLoaded = true
        } catch { }
    }
}
```

To see it in action, try out the [Examples](../../Examples) and refer to [FloorFilterExampleView.swift](../../Examples/Examples/FloorFilterExampleView.swift) in the project.
