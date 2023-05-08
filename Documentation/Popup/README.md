#  Popup

The `PopupView` component will display a popup for an individual feature. This includes showing the feature's title, attributes, custom description, media, and attachments. The new online Map Viewer allows users to create a popup definition by assembling a list of “popup elements”. `PopupView` will support the display of popup elements created by the Map Viewer, including:

- Text
- Fields
- Attachments
- Media (Images and Charts)

Thanks to the backwards compatibility support in the API, it will also work with the legacy popup definitions created by the classic Map Viewer. It does not support editing.

|iPhone|iPad|
|:--:|:--:|
|![image](https://user-images.githubusercontent.com/3998072/203422507-66b6c6dc-a6c3-4040-b996-9c0da8d4e580.png)|![image](https://user-images.githubusercontent.com/3998072/203422665-c4759c1f-5863-4251-94df-ed7a06ac7a8f.png)|

> **NOTE**: Displaying charts in a popup requires running on a device with iOS 16.0 or greater. Displaying charts in MacCatalyst requires building your application with Xcode 14.1 or greater and running on a Mac with macOS 13.0 (Ventura) or greater.  Also, Attachment previews are not available when running on MacCatalyst (regardless of Xcode version).

## Features

- Display a popup for a feature based on the popup definition defined in a web map.
- Supports image refresh intervals on image popup media, refreshing the image at a given interval defined in the popup element.
- Supports elements containing Arcade expression and automatically evaluates expressions.
- Displays media (images and charts) full-screen.
- Supports hyperlinks in text, media, and fields elements.
- Fully supports dark mode, as do all Toolkit components.

## Key properties

`PopupView` has the following initializer:

```swift
    /// Creates a `PopupView` with the given popup.
    /// - Parameters
    ///     popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(popup: Popup, isPresented: Binding<Bool>? = nil)
```

`PopupView` has the following instance method:

```swift
    /// Specifies whether a "close" button should be shown to the right of the popup title. If the "close"
    /// button is shown, you should pass in the `isPresented` argument to the `PopupView`
    /// initializer, so that the the "close" button can close the view.
    /// Defaults to `false`.
    /// - Parameter newShowCloseButton: The new value.
    /// - Returns: A new `PopupView`.
    public func showCloseButton(_ newShowCloseButton: Bool) -> PopupView.PopupView
```

## Behavior:

The popup view can display an optional "close" button, allowing the user to dismiss the view.  The popup view can be embedded in any type of container view including, as demonstrated in the example, the Toolkit's `FloatingPanel`.

## Usage

### Basic usage for displaying a `PopupView`.

```swift
static func makeMap() -> Map {
    let portalItem = PortalItem(
        portal: .arcGISOnline(connection: .anonymous),
        id: Item.ID(rawValue: "67c72e385e6e46bc813e0b378696aba8")!
    )
    return Map(item: portalItem)
}

/// The map displayed in the map view.
@StateObject private var map = makeMap()

/// The point on the screen the user tapped on to identify a feature.
@State private var identifyScreenPoint: CGPoint?

/// The popup to be shown as the result of the layer identify operation.
@State private var popup: Popup?

/// A Boolean value specifying whether the popup view should be shown or not.
@State private var showPopup = false

/// The detent value specifying the initial `FloatingPanelDetent`.  Defaults to "full".
@State private var floatingPanelDetent: FloatingPanelDetent = .full

var body: some View {
    MapViewReader { proxy in
        VStack {
            MapView(map: map)
                .onSingleTapGesture { screenPoint, _ in
                    identifyScreenPoint = screenPoint
                }
                .task(id: identifyScreenPoint) {
                    guard let identifyScreenPoint = identifyScreenPoint,
                          let identifyResult = await Result(awaiting: {
                              try await proxy.identifyLayers(
                                screenPoint: identifyScreenPoint,
                                tolerance: 10,
                                returnPopupsOnly: true
                              )
                          })
                        .cancellationToNil()
                    else {
                        return
                    }
                    
                    self.identifyScreenPoint = nil
                    self.popup = try? identifyResult.get().first?.popups.first
                    self.showPopup = self.popup != nil
                }
                .floatingPanel(
                    selectedDetent: $floatingPanelDetent,
                    horizontalAlignment: .leading,
                    isPresented: $showPopup
                ) {
                    Group {
                        if let popup = popup {
                            PopupView(popup: popup, isPresented: $showPopup)
                                .showCloseButton(true)
                        }
                    }
                    .padding()
                }
        }
    }
}
```

To see it in action, try out the [Examples](../../Examples) and refer to [PopupExampleView.swift](../../Examples/Examples/PopupExampleView.swift) in the project.
