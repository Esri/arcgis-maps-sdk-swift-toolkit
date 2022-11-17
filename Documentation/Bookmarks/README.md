# Bookmarks

The Bookmarks component will display a list of bookmarks and allows the user to select a bookmark and perform some action. You can create the component with either an array of `Bookmarks`, or with a `Map` or `Scene` containing the bookmarks to display.

The component can be configured to handle automated bookmark selection (zooming the map/scene to the bookmark’s viewpoint) by passing in a `Viewpoint` binding or the client can handle bookmark selection changes manually using the `.onSelectionChanged(perform:)` modifier.

## Bookmarks Behavior:

## Usage

```swift
***REMOVED*** Display bookmarks in a map, passing in a viewpoint binding to allow
***REMOVED*** automated bookmark selection.
Bookmarks(
***REMOVED***isPresented: $showingBookmarks,
***REMOVED***mapOrScene: map,
***REMOVED***viewpoint: $viewpoint
)
```

```swift
***REMOVED*** Handle bookmark selection changes manually using `.onSelectionChanged(perform:)`.
Bookmarks(
***REMOVED***isPresented: $showingBookmarks,
***REMOVED***mapOrScene: map,
***REMOVED***viewpoint: $viewpoint
)
.onSelectionChanged {
***REMOVED***print("New bookmark: \($0.name)")
***REMOVED***

```



To see it in action, try out the [Examples](../../Examples) and refer to [BookmarksExampleView.swift](../../Examples/Examples/BookmarksExampleView.swift) in the project.
