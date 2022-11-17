# FloatingPanel

A floating panel is a view that overlays a view and supplies view-related content. For a map view, for instance, it could display a legend, bookmarks, search results, etc.. Apple Maps, Google Maps, Windows 10, and Collector have floating panel implementations, sometimes referred to as a "bottom sheet".

Floating panels are non-modal and primarily simple containers that clients will fill with their own content. They can be transient where they only display information for a short period of time, like identify results. Or they can be persistent, where the information is always displayed. A dedicated search panel, for example.

The floating panel allows for interaction with background content, unlike native sheets or popovers.

### Behavior:

Content in a floating panel can be resized using a “handle” on the bottom (for regular-width environments) or on the top (compact-width environments).

The height of the floating panel is determined by a selected “detent”.  There are pre-defined detents for full screen height, half screen height, and a “summary” height, along with the ability to set custom detent heights. Dragging and releasing the handle will snap the floating panel height to the neartest detent.

The floating panel is displayed via a view modifier that allows you to set the content of the floating panel along with a number of other properties, including:

- `backgroundColor`: The background color of the floating panel.
- `selectedDetent`: A binding to the currently selected detent.
- `horizontalAlignment`: The horizontal alignment of the floating panel.
- `maxWidth`: The maximum width of the floating panel.

### Usage

```swift
MapView(
***REMOVED***map: map
)
.floatingPanel() {
***REMOVED***List(1..<21) { Text("\($0)") ***REMOVED***
***REMOVED******REMOVED***.listStyle(.plain)
***REMOVED***
```

To see it in action, try out the [Examples](../../Examples) and refer to [FloatingPanelExampleView.swift](../../Examples/Examples/FloatingPanelExampleView.swift) in the project.
