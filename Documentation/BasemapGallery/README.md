# BasemapGallery

The `BasemapGallery` displays a collection of basemaps from ArcGIS Online, a user-defined portal, or an array of `BasemapGalleryItem`s. When a new basemap is selected from the `BasemapGallery` and the optional `BasemapGalleryViewModel.geoModel` property is set, the basemap of the `geoModel` is replaced with the basemap in the gallery.

|iPhone|iPad|
|:--:|:--:|
|![image](https://user-images.githubusercontent.com/3998072/205385086-cb9bc0a0-3c46-484d-aefa-8878c7112a3e.png)|![image](https://user-images.githubusercontent.com/3998072/205384854-79f25efe-25f4-4330-a487-b64b528a9daf.png)|

> **NOTE**: BasemapGallery uses metered ArcGIS basemaps by default, so you will need to configure an API key. See [Security and authentication documentation](https://developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys) for more information.

## Features

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
    public init(portal: Portal, geoModel: GeoModel? = nil)
```

`BasemapGallery` has the following instance method:

- `style(_ newStyle: Style)` - The `Style` of the `BasemapGallery`, used to specify how the list of basemaps is displayed (list, grid, or automatic depending on display width).

`BasemapGallery` has the following helper class and initializer:

```swift
///  The `BasemapGalleryItem` encompasses an element in a `BasemapGallery`.
public class BasemapGalleryItem : ObservableObject

/// Creates a `BasemapGalleryItem`.
/// - Parameters:
///   - basemap: The `Basemap` represented by the item.
///   - name: The item name. If `nil`, `Basemap.name` is used, if available.
///   - description: The item description. If `nil`, `Basemap.Item.description`
///   is used, if available.
///   - thumbnail: The thumbnail used to represent the item. If `nil`,
///   `Basemap.Item.thumbnail` is used, if available.
public init(
    basemap: Basemap,
    name: String? = nil,
    description: String? = nil,
    thumbnail: UIImage? = nil
)

```

## Behavior:

Selecting a basemap with a spatial reference that does not match that of the geo model will display an error. It will also display an error if a provided base map cannot be loaded. If a `GeoModel` is provided to the `BasemapGallery`, selecting an item in the gallery will set that basemap on the geo model.

## Usage

### Basic usage for displaying a `BasemapGallery`.

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
