# OverviewMap

`OverviewMap` is a small, secondary `MapView` (sometimes called an inset map), that can be overlayed on an existing `GeoView` (`MapView` or `SceneView`). `OverviewMap` shows shows a representation of the current `visibleArea` (for a `MapView`) or `viewpoint` (for a `SceneView`) of the `GeoView` it is connected to.

Map View
![OverviewMap - MapView](./OverviewMap_MapView.png)

SceneView
![OverviewMap - SceneView](./OverviewMap_SceneView.png.png)


> **NOTE**: OverviewMap uses metered ArcGIS basemaps by default, so you will need to configure an API key. See [Security and authentication documentation](https:***REMOVED***developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys) for more information.

## Features

OverviewMap:

- Displays a representation of the current `VisibleArea`/`Viewpoint` for a connected `GeoView`.
- Supports a configurable scaling factor for setting the overview map's zoom level relative to the connected view.
- Supports a configurable symbol for visualizing the current `VisibleArea`/`Viewpoint` representation (a `FillSymbol` for a connected `MapView`; a `MarkerSymbol` for a connected `SceneView`).

## Key properties

`OverviewMap` has the following customizable properties:

- `map` - the `Map` displayed in the `OverviewMap`.  For example, you can use `map` to change the base map displayed by the `OverviewMap`.
- `scaleFactor` - Defines the scale of the `OverviewMap` relative to the scale of the connected `GeoView`. The default is 25.
- `symbol` - Defines the symbol used to visualize the current `Viewpoint` . This is a red rectangle by default for a `MapView`; for a `SceneView`, this is a red cross.

## Behavior:

For an `OverviewMap` on a `MapView`, the `MapView`'s `visibleArea` property will be represented in the `OverviewMap` as a polygon, which will rotate as the `MapView` rotates. 

For an `OverviewMap` on a `SceneView`, the center point of the `SceneView`'s `currentViewpoint` property will be represented in the `OverviewMap` by a point. 

## Usage

### Basic usage for overlaying a `MapView`

Note that for `MapView`'s, you need to provide the `OverviewMap` both a viewpoint and visibleArea, as well as providing a `FillSymbol` if you want to customize the display of the visible area.

```swift
let map = Map(basemap: .imageryWithLabels())
***REMOVED***
@State
private var viewpoint: Viewpoint?

@State
private var visibleArea: ArcGIS.Polygon?

var body: some View {
***REMOVED***MapView(map: map)
***REMOVED******REMOVED***.onViewpointChanged(type: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0 ***REMOVED***
***REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleArea: visibleArea
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   )
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED***)
***REMOVED***
```

### Displaying a custom fill symbol and scale factor for a `MapView`'s visible area

```swift
let map = Map(basemap: .imageryWithLabels())
***REMOVED***
@State
private var viewpoint: Viewpoint?

@State
private var visibleArea: ArcGIS.Polygon?

var body: some View {
***REMOVED***MapView(map: map)
***REMOVED******REMOVED***.onViewpointChanged(type: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED***.onVisibleAreaChanged { visibleArea = $0 ***REMOVED***
***REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***visibleArea: visibleArea,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleFillSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .clear,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***outline: SimpleLineSymbol(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***style: .solid,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***color: .blue,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***width: 2.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scaleFactor: 32.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   )
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED***)
***REMOVED***
```

### Basic usage for overlaying a `SceneView`

Note that for `SceneView`'s, you need to provide the `OverviewMap` only a viewpoint, as well as providing a `MarkerSymbol` if you want to customize the display of the viewpoint.

```swift
let scene = Scene(basemap: .imageryWithLabels())
***REMOVED***
@State
private var viewpoint: Viewpoint?

var body: some View {
***REMOVED***SceneView(scene: scene)
***REMOVED******REMOVED***.onViewpointChanged(type: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED******REMOVED***.overlay(
***REMOVED******REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED******REMOVED***alignment: .topTrailing
***REMOVED******REMOVED***)
***REMOVED***
```

### Displaying a custom marker symbol and scale factor for a `SceneView`'s viewpoint

```swift
SceneView(scene: scene)
***REMOVED***.onViewpointChanged(type: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED***.overlay(
***REMOVED******REMOVED***OverviewMap(viewpoint: viewpoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***symbol: SimpleMarkerSymbol(style: .x,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   color: .blue,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   size: 24.0
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  ),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scaleFactor: 32.0
***REMOVED******REMOVED******REMOVED******REMOVED***   )
***REMOVED******REMOVED******REMOVED***.frame(width: 200, height: 132)
***REMOVED******REMOVED******REMOVED***.padding(),
***REMOVED******REMOVED***alignment: .topTrailing
***REMOVED***)
```

### Changing the map used by the `OverviewMap`

To change the `OverviewMap`'s `map`, you use the `.map()` modifier on `OverviewMap`.

```swift
OverviewMap(viewpoint: viewpoint)
***REMOVED***.map(Map(basemap: .darkGrayCanvasVector()))
```

To see the `OverviewMap` in action, try out the [Examples](../../Examples) and refer to [OverviewMapExampleView.swift](../../Examples/Examples/OverviewMapExampleView.swift) in the project.

