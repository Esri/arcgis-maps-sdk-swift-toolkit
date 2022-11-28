# Compass

The Compass (alias North arrow) displays the current viewpoint rotation of a MapView or SceneView. The Compass supports resetting the rotation to zero/north.

The ArcGIS Maps SDK for Swift currently supports rotating MapViews and SceneViews interactively with a 2-finger gesture and while the map/scene will snap to north when rotating using gestures, the Compass provides an easier way. The Compass Toolkit component will appear when the map is rotated and, when tapped, re-orientates the map back to north and hides the compass icon (note that the MapView auto-snaps back to north when it's within a threshold of north, and in that case the compass also auto hides).

![image](https://user-images.githubusercontent.com/3998072/202810369-a0b82778-77d4-404e-bebf-1a84841fbb1b.png)

## Features

Compass:

- Can be configured to automatically hide when the rotation is zero.
- Will reset the map/scene rotation to North when tapped on.

## Key properties

`Compass` has the following initializers:

```swift
    /// Creates a compass with a binding to a heading based on compass
    /// directions (0° indicates a direction toward true North, 90° indicates a
    /// direction toward true East, etc.).
    /// - Parameters:
    ///   - heading: The heading of the compass.
    ///   - autoHide: A Boolean value that determines whether the compass
    ///   automatically hides itself when the heading is `0`.
    public init(heading: Binding<Double>, autoHide: Bool = true)
```

```swift
    /// Creates a compass with a binding to a viewpoint rotation (0° indicates
    /// a direction toward true North, 90° indicates a direction toward true
    /// West, etc.).
    /// - Parameters:
    ///   - viewpointRotation: The viewpoint rotation whose value determines the
    ///   heading of the compass.
    ///   - autoHide: A Boolean value that determines whether the compass
    ///   automatically hides itself when the viewpoint rotation is 0 degrees.
    public init(viewpointRotation: Binding<Double>, autoHide: Bool = true)
```

```swift
    /// Creates a compass with a binding to an optional viewpoint.
    /// - Parameters:
    ///   - viewpoint: The viewpoint whose rotation determines the heading of the compass.
    ///   - autoHide: A Boolean value that determines whether the compass automatically hides itself
    ///   when the viewpoint's rotation is 0 degrees.
    public init(viewpoint: Binding<Viewpoint?>, autoHide: Bool = true)
```

`Compass` has the following modifier:

- `func compassSize(size: CGFloat)` - The size of the `Compass`, specifying both the width and height of the compass.

## Behavior:

Whenever the map is not orientated North (non-zero bearing) the compass appears. When reset to north, it disappears. An initializer argument allows you to disable the auto-hide feature so that it always appears.

When the compass is tapped, the map orients back to north (zero bearing).

## Usage

### Basic usage for displaying a `Compass`.

```swift
@StateObject var map = Map(basemapStyle: .arcGISImagery)

/// Allows for communication between the Compass and MapView or SceneView.
@State private var viewpoint: Viewpoint? = Viewpoint(
    center: Point(x: -117.19494, y: 34.05723, spatialReference: .wgs84),
    scale: 10_000,
    rotation: -45
)

var body: some View {
    MapView(map: map, viewpoint: viewpoint)
        .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
        .overlay(alignment: .topTrailing) {
            Compass(viewpoint: $viewpoint)
                .padding()
        }
}
```

To see it in action, try out the [Examples](../../Examples/Examples) and refer to [CompassExampleView.swift](../../Examples/Examples/CompassExampleView.swift) in the project.
