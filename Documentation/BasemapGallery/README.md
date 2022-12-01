# BasemapGallery

The `BasemapGallery` displays a collection of basemaps from ArcGIS Online, a user-defined portal, or an array of `BasemapGalleryItem`s. When a new basemap is selected from the `BasemapGallery` and the optional `BasemapGalleryViewModel.geoModel` property is set, the basemap of the `geoModel` is replaced with the basemap in the gallery.

|iPhone|iPad|
|:--:|:--:|
|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202764289-9fce4772-b75b-4726-8020-cd2757bf8c8b.png)|![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202764359-07fc6265-723f-490b-a412-25350e7b3c76.png)|

> **NOTE**: BasemapGallery uses metered ArcGIS basemaps by default, so you will need to configure an API key. See [Security and authentication documentation](https:***REMOVED***developers.arcgis.com/documentation/mapping-apis-and-services/security/#api-keys) for more information.

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
***REMOVED******REMOVED***/ Creates a `BasemapGallery` with the given geo model and array of basemap gallery items.
***REMOVED******REMOVED***/ - Remark: If `items` is empty, ArcGIS Online's developer basemaps will
***REMOVED******REMOVED***/ be loaded and added to `items`.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - items: A list of pre-defined base maps to display.
***REMOVED******REMOVED***/   - geoModel: A geo model.
***REMOVED***public init(items: [BasemapGalleryItem] = [], geoModel: GeoModel? = nil)
```

```swift
***REMOVED******REMOVED***/ Creates a `BasemapGallery` with the given geo model and portal.
***REMOVED******REMOVED***/ The portal will be used to retrieve basemaps.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - portal: The portal to use to load basemaps.
***REMOVED******REMOVED***/   - geoModel: A geo model.
***REMOVED***public init(portal: Portal, geoModel: GeoModel? = nil)
```

`BasemapGallery` has the following instance method:

- `style(_ newStyle: Style)` - The `Style` of the `BasemapGallery`, used to specify how the list of basemaps is displayed (list, grid, or automatic depending on display width).

`BasemapGallery` has the following helper class and initializer:

```swift
***REMOVED***/  The `BasemapGalleryItem` encompasses an element in a `BasemapGallery`.
public class BasemapGalleryItem : ObservableObject

***REMOVED***/ Creates a `BasemapGalleryItem`.
***REMOVED***/ - Parameters:
***REMOVED***/   - basemap: The `Basemap` represented by the item.
***REMOVED***/   - name: The item name. If `nil`, `Basemap.name` is used, if available.
***REMOVED***/   - description: The item description. If `nil`, `Basemap.Item.description`
***REMOVED***/   is used, if available.
***REMOVED***/   - thumbnail: The thumbnail used to represent the item. If `nil`,
***REMOVED***/   `Basemap.Item.thumbnail` is used, if available.
public init(
***REMOVED***basemap: Basemap,
***REMOVED***name: String? = nil,
***REMOVED***description: String? = nil,
***REMOVED***thumbnail: UIImage? = nil
)

```

## Behavior:

Selecting a basemap with a spatial reference that does not match that of the geo model will display an error. It will also display an error if a provided base map cannot be loaded. If a `GeoModel` is provided to the `BasemapGallery`, selecting an item in the gallery will set that basemap on the geo model.

## Usage

### Basic usage for displaying a `BasemapGallery`.

```swift
@StateObject var map = Map(basemapStyle: .arcGISImagery)

var body: some View {
***REMOVED***MapView(map: map)
***REMOVED******REMOVED***.overlay(alignment: .topTrailing) {
***REMOVED******REMOVED******REMOVED***BasemapGallery(geoModel: map)
***REMOVED******REMOVED******REMOVED******REMOVED***.style(.automatic())
***REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
```

To see it in action, try out the [Examples](../../Examples) and refer to [BasemapGalleryExampleView.swift](../../Examples/Examples/BasemapGalleryExampleView.swift) in the project.
