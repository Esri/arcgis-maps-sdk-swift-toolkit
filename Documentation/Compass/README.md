# Compass

## Usage

### Basic usage for displaying a `Compass`.

```swift
@State private var map = Map(basemapStyle: .arcGISImagery)

@State private var viewpoint: Viewpoint?

var body: some View {
    MapViewReader { proxy in
        MapView(map: map, viewpoint: viewpoint)
            .onViewpointChanged(kind: .centerAndScale) { viewpoint = $0 }
            .overlay(alignment: .topTrailing) {
                Compass(rotation: viewpoint?.rotation, mapViewProxy: proxy)
                    .padding()
            }
    }
}
```
