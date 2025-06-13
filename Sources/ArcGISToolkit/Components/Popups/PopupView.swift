// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

/// The `PopupView` component will display a popup for an individual feature. This includes showing
/// the feature's title, attributes, custom description, media, and attachments. The new online Map
/// Viewer allows users to create a popup definition by assembling a list of “popup elements”.
/// `PopupView` will support the display of popup elements created by the Map Viewer, including:
/// Text, Fields, Attachments, and Media (Images and Charts).
///
/// Thanks to the backward compatibility support in the API, it will also work with the legacy
/// popup definitions created by the classic Map Viewer. It does not support editing.
///
/// | iPhone | iPad |
/// | ------ | ---- |
/// | ![image](https://user-images.githubusercontent.com/3998072/203422507-66b6c6dc-a6c3-4040-b996-9c0da8d4e580.png) | ![image](https://user-images.githubusercontent.com/3998072/203422665-c4759c1f-5863-4251-94df-ed7a06ac7a8f.png) |
///
/// > Note: Attachment previews are not available when running on Mac (regardless of Xcode version).
///
/// **Features**
///
/// - Display a popup for a feature based on the popup definition defined in a web map.
/// - Supports image refresh intervals on image popup media, refreshing the image at a given
/// interval defined in the popup element.
/// - Supports elements containing Arcade expressions and automatically evaluates expressions.
/// - Displays media (images and charts) full-screen.
/// - Supports hyperlinks in text, media, and field elements.
/// - Fully supports dark mode, as do all Toolkit components.
/// - Supports auto-refresh for popups where the geo element is a dynamic entity.
/// - Supports navigating through associations in a utility network.
///
/// **Behavior**
///
/// The popup view can display an optional "close" button, allowing the user to dismiss the view.
/// The popup view can be embedded in any type of container view, including, as demonstrated in the
/// example, the Toolkit's `FloatingPanel`.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to
/// [PopupExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/PopupExampleView.swift)
/// in the project. To learn more about using the `PopupView`, see the <doc:PopupViewTutorial>.
public struct PopupView: View {
    /// The `Popup` to display in the root `EmbeddedPopupView`.
    private let rootPopup: Popup
    
    /// The popups that have been presented in the navigation layer.
    ///
    /// There is one popup for every `EmbeddedPopupView` in the current
    /// navigation stack.
    @State private var presentedPopups: [Popup] = []
    
    /// The model for the navigation layer.
    @State private var navigationLayerModel: NavigationLayerModel?
    
    /// The visibility of the close button.
    var closeButtonVisibility: Visibility = .automatic
    
    /// A binding to a Boolean value that determines whether the view is presented.
    var isPresented: Binding<Bool>?
    
    /// The closure to perform when a new popup is shown in the `NavigationLayer`.
    var onPopupChanged: ((Popup) -> Void)?
    
    /// Creates a `PopupView` with the given popup.
    /// - Parameters:
    ///   - popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(popup: Popup, isPresented: Binding<Bool>? = nil) {
        self.rootPopup = popup
        self.isPresented = isPresented
    }
    
    public var body: some View {
        NavigationLayer { model in
            EmbeddedPopupView(popup: rootPopup)
                .onAppear {
                    navigationLayerModel = model
                }
        } headerTrailing: {
            XButton(.dismiss) {
                isPresented?.wrappedValue = false
            }
            .font(.title)
            // This is a workaround for a NavigationLayer issue where
            // the navigation title is not centered when the
            // `headerTrailing` content is empty.
            .disabled(closeButtonVisibility == .hidden)
            .opacity(closeButtonVisibility == .hidden ? 0 : 1)
        }
        .backNavigationAction { navigationLayerModel in
            // If an `EmbeddedPopupView` is disappearing, the last
            // `EmbeddedPopupView`'s popup is passed to `onPopupChanged`.
            if navigationLayerModel.presented?.view is EmbeddedPopupView {
                presentedPopups.removeLast()
                presentedPopups.last.map { onPopupChanged?($0) }
            }
            
            navigationLayerModel.pop()
        }
        .onNavigationPathChanged { item in
            // If an `EmbeddedPopupView` is appearing for the first time,
            // the new view's popup is passed to `onPopupChanged`.
            if let embeddedPopupView = item?.view as? EmbeddedPopupView,
               embeddedPopupView.popup.id != presentedPopups.last?.id {
                presentedPopups.append(embeddedPopupView.popup)
                onPopupChanged?(embeddedPopupView.popup)
            }
        }
        .onChange(of: rootPopup.id, initial: true) {
            // Resets the navigation stack when a new popup is passed to the view.
            navigationLayerModel?.popAll()
            presentedPopups = [rootPopup]
            onPopupChanged?(rootPopup)
        }
    }
}

public extension PopupView {
    /// Sets the visibility of the close button on the popup view.
    /// - Parameter visibility: The visibility of the close button.
    /// - Since: 200.8
    func closeButton(_ visibility: Visibility) -> Self {
        var copy = self
        copy.closeButtonVisibility = visibility
        return copy
    }
    
    /// Sets a closure to perform when a new popup is shown in the view.
    ///
    /// This can happen when navigating through the associations in a `UtilityAssociationsPopupElement`.
    /// - Parameter action: The closure to perform when the new popup is shown.
    /// - Since: 200.8
    func onPopupChanged(perform action: @escaping (Popup) -> Void) -> Self {
        var copy = self
        copy.onPopupChanged = action
        return copy
    }
}

private extension Popup {
    /// The identifier for the popup object.
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
