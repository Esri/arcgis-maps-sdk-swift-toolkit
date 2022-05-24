# Scalebar

A scalebar displays the representation of an accurate linear measurement on the map. It provides a visual indication through which users can determine the size of features or the distance between features on a map. A scale bar is a line or bar divided into parts. It is labeled with its ground length, usually in multiples of map units, such as tens of kilometers or hundreds of miles. 

The scalebar uses geodetic calculations to provide accurate measurements for maps of any spatial reference. The measurement is accurate for the center of the map extent being displayed. This means at smaller scales (zoomed way out) you might find it somewhat inaccurate at the extremes of the visible extent. As the map is panned and zoomed, the scalebar automatically grows and shrinks and updates its measurement based on the new map extent.

### Usage

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
