# Compass

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
