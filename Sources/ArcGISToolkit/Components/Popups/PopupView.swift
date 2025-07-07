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
/// As of 200.8, PopupView uses a NavigationStack internally to support browsing utility network
/// associations. As a result, a PopupView requires a navigation context isolated from any
/// app-level navigation. Basic apps without navigation can continue to place a PopupView where
/// desired. More complex apps using NavigationStack or NavigationSplitView will need to relocate
/// the PopupView outside of that navigation context. If the PopupView can be presented modally (no
/// background interaction with the map is needed), consider using a Sheet. If a non-modal
/// presentation is needed, consider placing the PopupView in a Floating Panel or Inspector, on the
/// app-level navigation container. On supported platforms, WindowGroups are another alternative to
/// consider as a PopupView container.
///
/// The popup view can display an optional "close" button, allowing the user to dismiss the view.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to
/// [PopupExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/PopupExampleView.swift)
/// in the project. To learn more about using the `PopupView`, see the <doc:PopupViewTutorial>.
public struct PopupView: View {
    /// The `Popup` to display in the root `EmbeddedPopupView`.
    private let popup: Popup
    
    /// A binding to a Boolean value that determines whether the view is presented.
    private let isPresented: Binding<Bool>?
    
    /// The visibility of the close button.
    var closeButtonVisibility: Visibility = .automatic
    
    /// The closure to perform when a new popup is shown in the navigation stack.
    var onPopupChanged: ((Popup) -> Void)?
    
    /// Creates a `PopupView` with the given popup.
    /// - Parameters:
    ///   - popup: The popup to display.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    public init(popup: Popup, isPresented: Binding<Bool>? = nil) {
        self.popup = popup
        self.isPresented = isPresented
    }
    
    public var body: some View {
        NavigationStack {
            EmbeddedPopupView(popup: popup)
        }
        .environment(\.popupCloseButtonVisibility, closeButtonVisibility)
        .environment(\.isPresented, isPresented)
        .onPreferenceChange(PresentedPopupPreferenceKey.self) { wrappedPopup in
            guard let wrappedPopup else { return }
            onPopupChanged?(wrappedPopup.popup)
        }
    }
}

extension EnvironmentValues {
    /// The visibility of the popup view's close button.
    @Entry var popupCloseButtonVisibility: Visibility = .automatic
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

/// A preference key that specifies the popup currently presented in the `PopupView` navigation stack.
struct PresentedPopupPreferenceKey: PreferenceKey {
    /// A wrapper for making a popup equatable.
    struct EquatablePopup: Equatable {
        let popup: Popup
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.popup === rhs.popup
        }
    }
    
    // MARK: PreferenceKey Conformance
    
    static let defaultValue: EquatablePopup? = nil
    
    static func reduce(value: inout EquatablePopup?, nextValue: () -> EquatablePopup?) {
        guard let nextValue = nextValue() else { return }
        value = nextValue
    }
}
