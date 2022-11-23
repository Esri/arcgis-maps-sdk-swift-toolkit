# Scalebar

A scalebar displays the representation of an accurate linear measurement on the map. It provides a visual indication through which users can determine the size of features or the distance between features on a map. A scale bar is a line or bar divided into parts. It is labeled with its ground length, usually in multiples of map units, such as tens of kilometers or hundreds of miles. 

![image](https:***REMOVED***user-images.githubusercontent.com/3998072/203605457-df6f845c-9245-4608-a61e-6d1e2e63a81b.png)

## Features:

Scalebar:

- Can be configured to display as either a bar or line, with different styles for each.
- Can be configured with custom colors for fills, lines, shadows, and text.
- Can be configured to automatically hide after a pan zoom operation.
- Displays both metric and imperial units.

## Key properties

`Scalebar` has the following initializer:

```swift
***REMOVED******REMOVED***/ A scalebar displays the current map scale.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - maxWidth: The maximum screen width allotted to the scalebar.
***REMOVED******REMOVED***/   - minScale: Set a minScale if you only want the scalebar to appear when you reach a large
***REMOVED******REMOVED***/***REMOVED*** enough scale maybe something like 10_000_000. This could be useful because the scalebar is
***REMOVED******REMOVED***/***REMOVED*** really only accurate for the center of the map on smaller scales (when zoomed way out). A
***REMOVED******REMOVED***/***REMOVED*** minScale of 0 means it will always be visible.
***REMOVED******REMOVED***/   - settings: Appearance settings.
***REMOVED******REMOVED***/   - spatialReference: The map's spatial reference.
***REMOVED******REMOVED***/   - style: The visual appearance of the scalebar.
***REMOVED******REMOVED***/   - units: The units to be displayed in the scalebar.
***REMOVED******REMOVED***/   - unitsPerPoint: The current number of device independent pixels to map display units.
***REMOVED******REMOVED***/   - useGeodeticCalculations: Set `false` to compute scale without a geodesic curve.
***REMOVED******REMOVED***/   - viewpoint: The map's current viewpoint.
***REMOVED***public init(
***REMOVED******REMOVED***maxWidth: Double,
***REMOVED******REMOVED***minScale: Double = .zero,
***REMOVED******REMOVED***settings: ScalebarSettings = ScalebarSettings(),
***REMOVED******REMOVED***spatialReference: Binding<SpatialReference?>,
***REMOVED******REMOVED***style: ScalebarStyle = .alternatingBar,
***REMOVED******REMOVED***units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
***REMOVED******REMOVED***unitsPerPoint: Binding<Double?>,
***REMOVED******REMOVED***useGeodeticCalculations: Bool = true,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>
***REMOVED***)
```

`Scalebar` has an associated `ScalebarSettings` struct to aid in configuration:

```swift
public struct ScalebarSettings {
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - autoHide: Determines if the scalebar should automatically hide/show itself.
***REMOVED******REMOVED***/   - autoHideDelay: The time to wait in seconds before the scalebar hides itself.
***REMOVED******REMOVED***/   - barCornerRadius: The corner radius used by bar style scalebar renders.
***REMOVED******REMOVED***/   - fillColor1: The darker fill color used by the alternating bar style render.
***REMOVED******REMOVED***/   - fillColor2: The lighter fill color used by the bar style renders.
***REMOVED******REMOVED***/   - lineColor: The color of the prominent scalebar line.
***REMOVED******REMOVED***/   - shadowColor: The shadow color used by all scalebar style renders.
***REMOVED******REMOVED***/   - shadowRadius: The shadow radius used by all scalebar style renders.
***REMOVED******REMOVED***/   - textColor: The text color used by all scalebar style renders.
***REMOVED******REMOVED***/   - textShadowColor: The text shadow color used by all scalebar style renders.
***REMOVED***public init(
***REMOVED******REMOVED***autoHide: Bool = false,
***REMOVED******REMOVED***autoHideDelay: TimeInterval = 1.75,
***REMOVED******REMOVED***barCornerRadius: Double = 2.5,
***REMOVED******REMOVED***fillColor1: Color = .black,
***REMOVED******REMOVED***fillColor2: Color = Color(uiColor: .lightGray).opacity(0.5),
***REMOVED******REMOVED***lineColor: Color = .white,
***REMOVED******REMOVED***shadowColor: Color = Color(uiColor: .black).opacity(0.65),
***REMOVED******REMOVED***shadowRadius: Double = 1.0,
***REMOVED******REMOVED***textColor: Color = .primary,
***REMOVED******REMOVED***textShadowColor: Color = .white
***REMOVED***)
***REMOVED***
```

## Behavior:

The scalebar uses geodetic calculations to provide accurate measurements for maps of any spatial reference. The measurement is accurate for the center of the map extent being displayed. This means at smaller scales (zoomed way out) you might find it somewhat inaccurate at the extremes of the visible extent. As the map is panned and zoomed, the scalebar automatically grows and shrinks and updates its measurement based on the new map extent.

## Usage

### Basic usage for displaying a `Scalebar`.

```swift
MapView(map: map)
***REMOVED***.onSpatialReferenceChanged { spatialReference = $0 ***REMOVED***
***REMOVED***.onUnitsPerPointChanged { unitsPerPoint = $0 ***REMOVED***
***REMOVED***.onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 ***REMOVED***
***REMOVED***.overlay(alignment: alignment) {
***REMOVED******REMOVED***Scalebar(
***REMOVED******REMOVED******REMOVED***maxWidth: maxWidth,
***REMOVED******REMOVED******REMOVED***spatialReference: $spatialReference,
***REMOVED******REMOVED******REMOVED***unitsPerPoint: $unitsPerPoint,
***REMOVED******REMOVED******REMOVED***viewpoint: $viewpoint
***REMOVED******REMOVED***)
***REMOVED***
```

To see it in action, try out the [Examples](../../Examples) and refer to [ScalebarExampleView.swift](../../Examples/Examples/ScalebarExampleView.swift) in the project.
