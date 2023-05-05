# Compass

The Compass (alias North arrow) displays the current viewpoint rotation of a MapView or SceneView. The Compass supports resetting the rotation to zero/north.

The ArcGIS Maps SDK for Swift currently supports rotating MapViews and SceneViews interactively with a 2-finger gesture and while the map/scene will snap to north when rotating using gestures, the Compass provides an easier way. The Compass Toolkit component will appear when the map is rotated and, when tapped, re-orientates the map back to north and hides the compass icon (note that the MapView auto-snaps back to north when it's within a threshold of north, and in that case the compass also auto hides).

![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202810369-a0b82778-77d4-404e-bebf-1a84841fbb1b.png)

## Features

Compass:

- Automatically hides when the rotation is zero.
- Can be configured to be always visible.
- Will reset the map/scene rotation to North when tapped on.

## Key properties

`Compass` has the following initializers:

```swift
***REMOVED******REMOVED***/ Creates a compass with a rotation (0° indicates a direction toward true North, 90° indicates
***REMOVED******REMOVED***/ a direction toward true West, etc.).
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - rotation: The rotation whose value determines the heading of the compass.
***REMOVED******REMOVED***/   - mapViewProxy: The proxy to provide access to map view operations.
***REMOVED***public init(rotation: Double?, mapViewProxy: MapViewProxy)
***REMOVED***
***REMOVED******REMOVED***/ Creates a compass with a rotation (0° indicates a direction toward true North, 90° indicates
***REMOVED******REMOVED***/ a direction toward true West, etc.).
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - rotation: The rotation whose value determines the heading of the compass.
***REMOVED******REMOVED***/   - action: The action to perform when the compass is tapped.
***REMOVED***public init(rotation: Double?, action: @escaping () -> Void)
```

`Compass` has the following modifiers:

- `func compassSize(size: CGFloat)` - The size of the `Compass`, specifying both the width and height of the compass.
- `func autoHideDisabled(_:)` - Specifies whether the ``Compass`` should automatically hide when the heading is 0.

## Behavior:

Whenever the map is not orientated North (non-zero bearing) the compass appears. When reset to north, it disappears. The `autoHideDisabled` view modifier allows you to disable the auto-hide feature so that it is always displayed.

When the compass is tapped, the map orients back to north (zero bearing). 

## Usage

### Basic usage for displaying a `Compass`.

```swift
@State private var map = Map(basemapStyle: .arcGISImagery)

@State private var viewpoint: Viewpoint?

var body: some View {
***REMOVED***MapViewReader { proxy in
***REMOVED******REMOVED***MapView(map: map, viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***Compass(rotation: viewpoint?.rotation, mapViewProxy: proxy)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
```

To add a `Compass` to a SceneView, use the initializer which takes an `action` argument to perform a custom action when the compass is tapped on.

```swift
@State private var scene = Scene(basemapStyle: .arcGISImagery)

@State private var viewpoint: Viewpoint?

var body: some View {
***REMOVED***SceneViewReader { proxy in
***REMOVED******REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED******REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED***Compass(rotation: viewpoint?.rotation) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let viewpoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***await proxy.setViewpoint(viewpoint.withRotation(.zero))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
```



To see it in action, try out the [Examples](../../Examples/Examples) and refer to [CompassExampleView.swift](../../Examples/Examples/CompassExampleView.swift) in the project.
