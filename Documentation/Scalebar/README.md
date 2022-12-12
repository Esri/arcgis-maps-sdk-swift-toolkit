# Scalebar

A scalebar displays the representation of an accurate linear measurement on the map. It provides a visual indication through which users can determine the size of features or the distance between features on a map. A scale bar is a line or bar divided into parts. It is labeled with its ground length, usually in multiples of map units, such as tens of kilometers or hundreds of miles. 

![image](https://user-images.githubusercontent.com/3998072/203605457-df6f845c-9245-4608-a61e-6d1e2e63a81b.png)

## Features

Scalebar:

- Can be configured to display as either a bar or line, with different styles for each.
- Can be configured with custom colors for fills, lines, shadows, and text.
- Can be configured to automatically hide after a pan or zoom operation.
- Displays both metric and imperial units.

## Key properties

`Scalebar` has the following initializer:

```swift
    /// A scalebar displays the current map scale.
    /// - Parameters:
    ///   - maxWidth: The maximum screen width allotted to the scalebar.
    ///   - minScale: Set a minScale if you only want the scalebar to appear when you reach a large
    ///     enough scale maybe something like 10_000_000. This could be useful because the scalebar is
    ///     really only accurate for the center of the map on smaller scales (when zoomed way out). A
    ///     minScale of 0 means it will always be visible.
    ///   - settings: Appearance settings.
    ///   - spatialReference: The map's spatial reference.
    ///   - style: The visual appearance of the scalebar.
    ///   - units: The units to be displayed in the scalebar.
    ///   - unitsPerPoint: The current number of device independent pixels to map display units.
    ///   - useGeodeticCalculations: Set `false` to compute scale without a geodesic curve.
    ///   - viewpoint: The map's current viewpoint.
    public init(
        maxWidth: Double,
        minScale: Double = .zero,
        settings: ScalebarSettings = ScalebarSettings(),
        spatialReference: Binding<SpatialReference?>,
        style: ScalebarStyle = .alternatingBar,
        units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
        unitsPerPoint: Binding<Double?>,
        useGeodeticCalculations: Bool = true,
        viewpoint: Binding<Viewpoint?>
    )
```

`Scalebar` has an associated `ScalebarSettings` struct to aid in configuration:

```swift
public struct ScalebarSettings {
    /// - Parameters:
    ///   - autoHide: Determines if the scalebar should automatically hide/show itself.
    ///   - autoHideDelay: The time to wait in seconds before the scalebar hides itself.
    ///   - barCornerRadius: The corner radius used by bar style scalebar renders.
    ///   - fillColor1: The darker fill color used by the alternating bar style render.
    ///   - fillColor2: The lighter fill color used by the bar style renders.
    ///   - lineColor: The color of the prominent scalebar line.
    ///   - shadowColor: The shadow color used by all scalebar style renders.
    ///   - shadowRadius: The shadow radius used by all scalebar style renders.
    ///   - textColor: The text color used by all scalebar style renders.
    ///   - textShadowColor: The text shadow color used by all scalebar style renders.
    public init(
        autoHide: Bool = false,
        autoHideDelay: TimeInterval = 1.75,
        barCornerRadius: Double = 2.5,
        fillColor1: Color = .black,
        fillColor2: Color = Color(uiColor: .lightGray).opacity(0.5),
        lineColor: Color = .white,
        shadowColor: Color = Color(uiColor: .black).opacity(0.65),
        shadowRadius: Double = 1.0,
        textColor: Color = .primary,
        textShadowColor: Color = .white
    )
}
```

## Behavior:

The scalebar uses geodetic calculations to provide accurate measurements for maps of any spatial reference. The measurement is accurate for the center of the map extent being displayed. This means at smaller scales (zoomed way out) you might find it somewhat inaccurate at the extremes of the visible extent. As the map is panned and zoomed, the scalebar automatically grows and shrinks and updates its measurement based on the new map extent.

## Usage

### Basic usage for displaying a `Scalebar`.

```swift
MapView(map: map)
    .onSpatialReferenceChanged { spatialReference = $0 }
    .onUnitsPerPointChanged { unitsPerPoint = $0 }
    .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
    .overlay(alignment: alignment) {
        Scalebar(
            maxWidth: maxWidth,
            spatialReference: $spatialReference,
            unitsPerPoint: $unitsPerPoint,
            viewpoint: $viewpoint
        )
    }
```

To see it in action, try out the [Examples](../../Examples) and refer to [ScalebarExampleView.swift](../../Examples/Examples/ScalebarExampleView.swift) in the project.
