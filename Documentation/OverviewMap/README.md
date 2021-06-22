### OverviewMap Behavior:

For an OverviewMap on a `MapView`, the `MapView`'s `visibleArea` property will be represented in the overview map as a polygon, which will rotate as the `MapView` rotates. 

For a `SceneView`...



# OverviewMap

`OverviewMap` is a small, secondary `MapView` (sometimes called an inset map), that can be superimposed on an existing `MapView`/`SceneView`. OverviewMap shows shows the visible extent of the `GeoView` it is connected to.

![OverviewMap](https:***REMOVED***user-images.githubusercontent.com/29742178/121975740-34f07000-cd37-11eb-9162-462925cb3fe7.png)

> **NOTE**: OverviewMap uses metered ArcGIS basemaps by default, so you will need to configure an API key. See [Security and authentication documentation](https:***REMOVED***developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys) for more information.

## Features

OverviewMap:

- Displays a representation of the current `Viewpoint` for a connected `GeoView`
- Supports a configurable scaling factor for setting the overview map's zoom level relative to the connected view.
- Supports a configurable symbol for visualizing the current `Viewpoint` representation.

## Key properties

`OverviewMap` has the following customizable properties:

- `geoView` - References the connected `MapView` or `SceneView`
- `symbol` - Defines the symbol used to visualize the current `Viewpoint` . This is a red rectangle by default for `MapView`s; For `SceneView`s, this is a red cross.
- `scaleFactor` - Defines the scale of the `OverviewMap` relative to the scale of the connected `GeoView`. The default is 25.
- `map` - the `Map` displayed in the `OverviewMap`.  For example, you can use `map` to change the base map displayed by the `OverviewMap`.

## Usage

```swift
***REMOVED*** Waiting on final implementation details
```

To see it in action, try out the [Examples](../../Examples) and refer to [OverviewMap.swift](../../Examples/ArcGISToolkitExamples/OverviewMap.swift) in the project.

