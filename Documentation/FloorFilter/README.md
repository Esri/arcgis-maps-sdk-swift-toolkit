#  FloorFilter

The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a building in your application. It allows you to filter down the floor plan data displayed in your geo view to a site, a building in the site, or a floor in the building. 

The ArcGIS Maps SDK currently supports filtering a 2D floor aware map based on the sites, buildings, or levels in the map.

|iPhone|iPad|
|:--:|:--:|
|![image](https://user-images.githubusercontent.com/3998072/202811733-dcd640e9-3b27-43a8-8bec-fd9aeb6798c7.png)|![image](https://user-images.githubusercontent.com/3998072/202811772-bf6009e7-82ec-459f-86ae-6651f519b2ef.png)|

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

Selecting a basemap with a spatial reference that does not match that of the geo model will display an error. It will also display an error if a provided base map cannot be loaded. If a `GeoModel` is provided to the `BasemapGallery`, selecting an item in the gallery will set that basemap on the geo model.

## Usage

### Basic usage for displaying a `FloorFilter`.

```swift
@StateObject var map = Map(basemapStyle: .arcGISImagery)

var body: some View {
    MapView(map: map)
        .overlay(alignment: .topTrailing) {
            BasemapGallery(geoModel: map)
                .style(.automatic())
                .padding()
        }
}
```




### Behavior:

When the Site button is tapped, a prompt opens so the user can select a site and then a facility. After selecting a site and facility, a list of levels is displayed either above or below the site button.

### Usage

```swift
```

To see it in action, try out the [Examples](../../Examples) and refer to [FloorFilterExampleView.swift](../../Examples/Examples/FloorFilterExampleView.swift) in the project.
