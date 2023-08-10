

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
    ///   - selection: The selected site, facility, or level.
    public init(
        floorManager: FloorManager,
        alignment: Alignment,
        automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
        viewpoint: Binding<Viewpoint?> = .constant(nil),
        isNavigating: Binding<Bool>,
        selection: Binding<FloorFilterSelection?>? = nil
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

///  A selected site, facility, or level.
public enum FloorFilterSelection: Hashable {
    /// A selected site.
    case site(FloorSite)
    /// A selected facility.
    case facility(FloorFacility)
    /// A selected level.
    case level(FloorLevel)
}
```

`FloorFilter` has the following modifier:

- `func levelSelectorWidth(_ width: CGFloat)` - The width of the level selector.

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
