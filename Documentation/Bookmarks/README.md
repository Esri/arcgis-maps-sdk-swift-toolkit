# Bookmarks

The `Bookmarks` component will display a list of bookmarks and allow the user to select a bookmark and perform some action. You can create the component with either an array of `Bookmarks`, or with a `Map` or `Scene` containing the bookmarks to display.

`Bookmarks` can be configured to handle automated bookmark selection (zooming the map/scene to the bookmark’s viewpoint) by passing in a `Viewpoint` binding or the client can handle bookmark selection changes manually using the `.onSelectionChanged(perform:)` modifier.

|iPhone|iPad|
|:--:|:--:|
|![image](https://user-images.githubusercontent.com/3998072/202765630-894bee44-a0c2-4435-86f4-c80c4cc4a0b9.png)|![image](https://user-images.githubusercontent.com/3998072/202765729-91c52555-4677-4c2b-b62b-215e6c3790a6.png)|

## Features

Bookmarks:

- Can be configured to display bookmarks from a map or scene, or from an array of user-defined bookmarks.
- Can be configured to automatically zoom the map or scene to a bookmark selection.
- Can be configured to perform a user-defined action when a bookmark is selected.
- Will automatically hide the `Bookmark` view when a bookmark is selected.

## Key properties

`Bookmarks` has the following initializers:

```swift
    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - bookmarks: An array of bookmarks. Use this when displaying bookmarks defined at runtime.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
    ///   Alternately, you can use the `onSelectionChanged(perform:)` modifier to handle
    ///   bookmark selection.
    public init(isPresented: Binding<Bool>, bookmarks: [Bookmark], viewpoint: Binding<Viewpoint?>? = nil)
```

```swift
    /// Creates a `Bookmarks` component.
    /// - Parameters:
    ///   - isPresented: Determines if the bookmarks list is presented.
    ///   - mapOrScene: A `GeoModel` authored with pre-existing bookmarks.
    ///   - viewpoint: A viewpoint binding that will be updated when a bookmark is selected.
    ///   Alternately, you can use the `onSelectionChanged(perform:)` modifier to handle
    ///   bookmark selection.
    public init(isPresented: Binding<Bool>, mapOrScene: GeoModel, viewpoint: Binding<Viewpoint?>? = nil)
```

`Bookmarks` has the following instance method:

```swift
    /// Sets an action to perform when the bookmark selection changes.
    /// - Parameter action: The action to perform when the bookmark selection has changed.
    public func onSelectionChanged(perform action: @escaping (Bookmark) -> Void) -> Bookmarks
```

## Behavior:

If a `Viewpoint` binding is provided to the `Bookmarks` view, selecting a bookmark will set that viewpoint binding to the viewpoint of the bookmark. Selecting a bookmark will dismiss the `Bookmarks` view. If a `GeoModel` is provided, that geo model's bookmarks will be displayed to the user.

## Usage

### Basic usage for displaying a `Bookmarks` view.
The view is displayed in a `popover` in response to a toolbar button tap.

```swift
/// A web map with predefined bookmarks.
@StateObject private var map = Map(url: URL(string: "https://www.arcgis.com/home/item.html?id=16f1b8ba37b44dc3884afc8d5f454dd2")!)!

/// Indicates if the `Bookmarks` component is shown or not.
/// - Remark: This allows a developer to control when the `Bookmarks` component is
/// shown/hidden, whether that be in a group of options or a standalone button.
@State var showingBookmarks = false

/// Allows for communication between the `Bookmarks` component and a `MapView` or
/// `SceneView`.
@State var viewpoint: Viewpoint? = nil

var body: some View {
    MapView(map: map, viewpoint: viewpoint)
        .onViewpointChanged(kind: .centerAndScale) {
            viewpoint = $0
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingBookmarks.toggle()
                } label: {
                    Label(
                        "Show Bookmarks",
                        systemImage: "bookmark"
                    )
                }
                .popover(isPresented: $showingBookmarks) {
                    // Display the `Bookmarks` components with a pre-defined
                    // list of bookmarks. Passing in a `Viewpoint` binding
                    // will allow the `Bookmarks` component to handle
                    // bookmark selection.
                    Bookmarks(
                        isPresented: $showingBookmarks,
                        mapOrScene: map,
                        viewpoint: $viewpoint
                    )
                }
            }
        }
}
```

To see it in action, try out the [Examples](../../Examples) and refer to [BookmarksExampleView.swift](../../Examples/Examples/BookmarksExampleView.swift) in the project.
