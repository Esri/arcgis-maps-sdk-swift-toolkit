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
/// Thanks to the backwards compatibility support in the API, it will also work with the legacy
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
/// - Supports elements containing Arcade expression and automatically evaluates expressions.
/// - Displays media (images and charts) full-screen.
/// - Supports hyperlinks in text, media, and fields elements.
/// - Fully supports dark mode, as do all Toolkit components.
/// - Supports auto-refresh for popups where the geo element is a dynamic entity.
///
/// **Behavior**
///
/// The popup view can display an optional "close" button, allowing the user to dismiss the view.
/// The popup view can be embedded in any type of container view including, as demonstrated in the
/// example, the Toolkit's `FloatingPanel`.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to
/// [PopupExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/PopupExampleView.swift)
/// in the project. To learn more about using the `PopupView` see the <doc:PopupViewTutorial>.
public struct PopupView: View {
    /// A binding to the popup currently being presented in the navigation layer.
    @Binding private var presentedPopup: Popup?
    
    /// The popups that have been presented in the navigation layer.
    ///
    /// There is one popup for every `InternalPopupView` in the current
    /// navigation stack.
    @State private var presentedPopups: [Popup] = []
    
    /// The model for the navigation layer.
    @State private var navigationLayerModel: NavigationLayerModel?
    
    /// The visibility of the close button.
    var closeButtonVisibility: Visibility = .automatic
    
    /// A binding to a Boolean value that determines whether the view is presented.
    ///
    /// This property can be removed once the deprecated
    /// `init(popup:isPresented:)` initializer is removed.
    var isPresented: Binding<Bool>?
    
    /// Creates a `PopupView` to display a given popup.
    /// - Parameters:
    ///   - popup: A binding to the popup that view displays. When `popup` is non-`nil`, the `PopupView` is displayed.
    /// - Since: 200.8
    public init(popup: Binding<Popup?>) {
        self._presentedPopup = popup
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let popup = presentedPopups.first {
                NavigationLayer { model in
                    InternalPopupView(popup: popup)
                        .onAppear {
                            navigationLayerModel = model
                        }
                } headerTrailing: {
                    XButton(.dismiss) {
                        isPresented?.wrappedValue = false
                        presentedPopup = nil
                    }
                    .font(.title)
                    // This is a workaround for a NavigationLayer issue where
                    // the navigation title is not centered when the
                    // headerTrailing content is empty.
                    .disabled(closeButtonVisibility == .hidden)
                    .opacity(closeButtonVisibility == .hidden ? 0 : 1)
                }
                .backNavigationAction { navigationLayerModel in
                    // If an InternalPopupView is disappearing, the binding is
                    // set to the last InternalPopupView's popup.
                    if navigationLayerModel.presented?.view is InternalPopupView {
                        presentedPopups.removeLast()
                        presentedPopup = presentedPopups.last
                    }
                    
                    navigationLayerModel.pop()
                }
                .onNavigationPathChanged { item in
                    // If an InternalPopupView is appearing for the first time,
                    // the binding is set to the new view's popup.
                    if let internalPopupView = item?.view as? InternalPopupView,
                       internalPopupView.popup.id != presentedPopups.last?.id {
                        presentedPopups.append(internalPopupView.popup)
                        presentedPopup = internalPopupView.popup
                    }
                }
            }
        }
        .onChange(of: presentedPopup?.id, initial: true) {
            // If presentedPopups does not contain the new popup, the binding
            // was set upstream, and the navigation stack needs reset.
            guard !presentedPopups.contains(where: { $0.id == presentedPopup?.id }) else {
                return
            }
            
            navigationLayerModel?.popAll()
            presentedPopups = presentedPopup.map { [$0] } ?? []
        }
    }
}

public extension PopupView {
    /// Sets the visibility of the close button on the popup.
    /// - Parameter visibility: The visibility of the close button.
    /// - Since: 200.8
    func closeButton(_ visibility: Visibility) -> Self {
        var copy = self
        copy.closeButtonVisibility = visibility
        return copy
    }
}

private extension Popup {
    /// The identifier for the popup object.
    var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }
}
