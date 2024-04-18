# Floating Panel

A floating panel is a view that overlays a view and supplies view-related
content. A map view, for instance, could display a legend, bookmarks, search results, etc..

Floating panels are non-modal and can be transient, only displaying
information for a short period of time like identify results,
or persistent, where the information is always displayed, for example a
dedicated search panel. They will also be primarily simple containers
that clients will fill with their own content.

The floating panel allows for interaction with background content by default, unlike native
sheets or popovers.

The following images are of a simple list of numbers in a floating panel.

| iPhone | iPad |
| ------ | ---- |
| ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202795901-b86d6d26-3572-4c88-8f6e-84473ce57002.png) | ![image](https:***REMOVED***user-images.githubusercontent.com/3998072/202796009-92e3b5c3-d88b-4124-8d9f-bad6df445f02.png) |
- Note: The Floating Panel is exposed as a view modifier.

**Features**

- Can display any custom content.
- Can be resized by dragging the panel's handle.
- Has three predefined height settings, called "detents", that the panel will snap to when the
user drags and releases the handle.
- Can be configured with a custom detent, specifying either a fraction of the maximum height or
a fixed value.

**Behavior**

- Content in a floating panel can be resized using a “handle” on the bottom (for regular-width
environments) or on the top (compact-width environments).
- The height of the floating panel is determined by a selected “detent”. There are pre-defined
detents for full screen height, half screen height, and a “summary” height, along with the
ability to set custom detent heights. Dragging and releasing the handle will snap the floating
panel height to the nearest detent.
- The floating panel view modifier allows you to set the content along with a number of other
properties, including:
  - `backgroundColor`: The background color of the floating panel.
  - `selectedDetent`: A binding to the currently selected detent.
  - `horizontalAlignment`: The horizontal alignment of the floating panel.
  - `maxWidth`: The maximum width of the floating panel.

To see it in action, try out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
and refer to [FloatingPanelExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/FloatingPanelExampleView.swift)
in the project. To learn more about using the Floating Panel see the <doc:FloatingPanelTutorial>.
