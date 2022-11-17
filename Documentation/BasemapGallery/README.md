# BasemapGallery

The `BasemapGallery` displays a collection of basemaps from ArcGIS Online, a user-defined portal, or an array of `BasemapGalleryItem`s. When a new basemap is selected from the `BasemapGallery` and the optional `BasemapGalleryViewModel.geoModel` property is set, the basemap of the `geoModel` is replaced with the basemap in the gallery.

> **NOTE**: BasemapGallery uses metered ArcGIS basemaps by default, so you will need to configure an API key. See [Security and authentication documentation](https://developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys) for more information.

## Features:

BasemapGallery:

- Can be configured to use a list, grid, or automatic layout. When using an automatic layout, list or grid presentation is chosen based on the horizontal size class of the display.
- Displays basemaps from a portal or a custom collection. If neither a custom portal or array of basemaps is provided, the list of basemaps will be loaded from ArcGIS Online.
- Displays a representation of the map or scene's current basemap if that basemap exists in the gallery.
- Displays a name and thumbnail for each basemap.
- Can be configured to automatically change the basemap of a geo model based on user selection.

## Key properties

`BasemapGallery` has the following initializers:

```swift
    /// Creates a `BasemapGallery` with the given geo model and array of basemap gallery items.
    /// - Remark: If `items` is empty, ArcGIS Online's developer basemaps will
    /// be loaded and added to `items`.
    /// - Parameters:
    ///   - items: A list of pre-defined base maps to display.
    ///   - geoModel: A geo model.
    public init(items: [BasemapGalleryItem] = [], geoModel: GeoModel? = nil)
```

```swift
    /// Creates a `BasemapGallery` with the given geo model and portal.
    /// The portal will be used to retrieve basemaps.
    /// - Parameters:
    ///   - portal: The portal to use to load basemaps.
    ///   - geoModel: A geo model.
    internal init(portal: Portal, geoModel: GeoModel? = nil)
```

`BasemapGallery` has the following modifer:

- `style(_ newStyle: Style)` - The `Style` of the `BasemapGallery`, used to specify how the list of basemaps is displayed (list, grid, or automatic depending on display width).

## Behavior:

Selecting a basemap with a spatial reference that does not match that of the geo model will display an error. It will also display an error if a provided base map cannot be loaded.

## Usage

### Basic usage for overlaying a `BasemapGallery` with a geo model.

```swift
@StateObject var map = Map(basemapStyle: .arcGISImagery)

var body: some View {
    MapView(map: map)
        .overlay(alignment: .topTrailing) {
            BasemapGallery(geoModel: map)
                .style(.automatic())
                .padding()
        }
}
```

To see it in action, try out the [Examples](../../Examples) and refer to [BasemapGalleryExampleView.swift](../../Examples/Examples/BasemapGalleryExampleView.swift) in the project.
