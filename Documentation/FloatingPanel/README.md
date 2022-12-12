# FloatingPanel

A floating panel is a view that overlays a view and supplies view-related content. For a map view, for instance, it could display a legend, bookmarks, search results, etc.. Apple Maps, Google Maps, Windows 10, and Collector have floating panel implementations, sometimes referred to as a "bottom sheet".

Floating panels are non-modal and primarily simple containers that clients will fill with their own content. They can be transient where they only display information for a short period of time, like identify results. Or they can be persistent, where the information is always displayed, such as a dedicated search panel.

The floating panel allows for interaction with background content, unlike native sheets or popovers.

The following images are of a simple list of numbers in a floating panel.

|iPhone|iPad|
|:--:|:--:|
|![image](https://user-images.githubusercontent.com/3998072/202795901-b86d6d26-3572-4c88-8f6e-84473ce57002.png)|![image](https://user-images.githubusercontent.com/3998072/202796009-92e3b5c3-d88b-4124-8d9f-bad6df445f02.png)|

## Features:

FloatingPanel:

- Can display any custom content.
- Can be resized by dragging the panel's handle.
- Has three predefined height settings, called "detents", that the panel will snap to when the user drags and releases the handle.
- Can be configured with a custom detent, specifying either a fraction of the maximum height or a fixed value.
- Is displayed using the `.floatingPanel` view modifier.

## Key properties

`FloatingPanel` exposes the following view modifier:

```swift
    /// - Parameters:
    ///   - backgroundColor: The background color of the floating panel.
    ///   - selectedDetent: A binding to the currently selected detent.
    ///   - horizontalAlignment: The horizontal alignment of the floating panel.
    ///   - isPresented: A binding to a Boolean value that determines whether the view is presented.
    ///   - maxWidth: The maximum width of the floating panel.
    ///   - content: A closure that returns the content of the floating panel.
    /// - Returns: A dynamic view with a presentation style similar to that of a sheet in compact
    /// environments and a popover otherwise.
    func floatingPanel<Content>(
        backgroundColor: Color = Color(uiColor: .systemBackground),
        selectedDetent: Binding<FloatingPanelDetent> = .constant(.half),
        horizontalAlignment: HorizontalAlignment = .trailing,
        isPresented: Binding<Bool> = .constant(true),
        maxWidth: CGFloat = 400,
        _ content: @escaping () -> Content
    ) -> some View where Content: View
```

### Behavior:

Content in a floating panel can be resized using a “handle” on the bottom (for regular-width environments) or on the top (compact-width environments).

The height of the floating panel is determined by a selected “detent”. There are pre-defined detents for full screen height, half screen height, and a “summary” height, along with the ability to set custom detent heights. Dragging and releasing the handle will snap the floating panel height to the nearest detent.

The floating panel is displayed via a view modifier that allows you to set the content of the floating panel along with a number of other properties, including:

- `backgroundColor`: The background color of the floating panel.
- `selectedDetent`: A binding to the currently selected detent.
- `horizontalAlignment`: The horizontal alignment of the floating panel.
- `maxWidth`: The maximum width of the floating panel.

### Usage

```swift
MapView(
    map: map
)
.floatingPanel() {
    List(1..<21) { Text("\($0)") }
        .listStyle(.plain)
}
```

To see it in action, try out the [Examples](../../Examples) and refer to [FloatingPanelExampleView.swift](../../Examples/Examples/FloatingPanelExampleView.swift) in the project.
