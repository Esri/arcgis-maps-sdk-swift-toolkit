# Feature Editor

The feature editor component allows users to edit existing features and add new
features from shared templates to a `MapView`'s map.

## Usage

To use the feature editor:
- Add ``ArcGIS/MapView/featureEditor(_:)`` to a `MapView` and provide a binding 
to an optional `ArcGISFeature` to edit. 
- Add ``FeatureEditorContainer`` above the `featureEditor(_:)` modifier in
the view hierarchy. If the hierarchy that contains this view has a navigation
view, such as a `NavigationStack` or `NavigationSplitView`, the
`FeatureEditorContainer` must be placed above it to support the feature editor's
navigation.
- To edit a feature, set the `feature` binding passed to the `featureEditor(_:)` 
modifier.
- To add features from shared templates, press the add button that is displayed 
on the `MapView`. The button is shown when the `feature` binding is `nil`, and 
there are shared templates in the `MapView`'s map.

```swift
FeatureEditorContainer {
    NavigationStack {
        MapView(map: map)
            .featureEditor($feature)
    }
}
```

## Features

- Attribute, attachment, and utility network association editing via a 
``FeatureFormView``.
- `Point`, `Multipoint`, `Polyline`, and `Polygon` geometry editing via a 
`GeometryEditor` that is set on the `MapView` automatically.
- Performing common geometry editing operations via UI controls in a toolbar 
shown on the `MapView`, including:
    - Changing the editing tool.
    - Deleting the selected element.
    - Undoing the last action on the geometry.
    - Redoing the last undone action.
    - Configuring snap settings.
- Snap source syncing with support for rule-based snapping when available.
- `MapView` viewpoint centering when applicable.

### Editing Features

Supports editing existing and new features, with the following capabilities:
- Editing the feature's geometry with support for the following 
`GeometryEditorTool`s:
    - `VertexTool`
    - `ReticleVertexTool`
    - `FreehandTool`
    - `ShapeTool`
        - `arrow`
        - `ellipse`
        - `rectangle`
        - `triangle`
- Spatial and non-spatial features.

### Adding Features

Supports creating and adding features from shared templates:
- Selecting feature, group, and preset templates queried from the operational 
layers and feature tables on the map displayed in the `MapView`.
- Creating a geometry for the selected template using the following 
`GeometryConstructionTool.Kind`s:
    - `circle`
    - `ellipse`
    - `line`
    - `multipoint`
    - `point`
    - `polygon`
    - `rectangle`
    - `streamingPolygon`
    - `streamingPolyline`
- Spatial and non-spatial shared templates.

## Behavior

The feature editor displays its ``FeatureFormView`` and shared template picker 
in an inspector. The add button and toolbar are shown in the 
`Alignment.topTrailing` position on the `MapView`. The toolbar is displayed 
vertically by default, but adapts its orientation based on available space.
