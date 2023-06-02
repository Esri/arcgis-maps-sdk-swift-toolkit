// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

public extension View {
    /// A floating panel is a view that overlays a view and supplies view-related
    /// content. For a map view, for instance, it could display a legend, bookmarks, search results, etc..
    /// Apple Maps, Google Maps, Windows 10, and Collector have floating panel
    /// implementations, sometimes referred to as a "bottom sheet".
    ///
    /// Floating panels are non-modal and can be transient, only displaying
    /// information for a short period of time like identify results,
    /// or persistent, where the information is always displayed, for example a
    /// dedicated search panel. They will also be primarily simple containers
    /// that clients will fill with their own content.
    ///
    /// The floating panel allows for interaction with background contents, unlike native sheets or popovers.
    ///
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
    ) -> some View where Content: View {
        modifier(
            FloatingPanelModifier(
                backgroundColor: backgroundColor,
                selectedDetent: selectedDetent,
                horizontalAlignment: horizontalAlignment,
                isPresented: isPresented,
                maxWidth: maxWidth,
                panelContent: content()
            )
        )
    }
}

/// Overlays a floating panel on the parent content.
private struct FloatingPanelModifier<PanelContent>: ViewModifier where PanelContent: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// A Boolean value indicating whether the environment is compact.
    private var isCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    /// The background color of the floating panel.
    let backgroundColor: Color
    
    /// A binding to the currently selected detent.
    let selectedDetent: Binding<FloatingPanelDetent>
    
    /// The horizontal alignment of the floating panel.
    let horizontalAlignment: HorizontalAlignment
    
    /// A binding to a Boolean value that determines whether the view is presented.
    let isPresented: Binding<Bool>
    
    /// The maximum width of the floating panel.
    let maxWidth: CGFloat
    
    /// The content to be displayed within the floating panel.
    let panelContent: PanelContent
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: Alignment(horizontal: horizontalAlignment, vertical: .top)) {
                FloatingPanel(
                    backgroundColor: backgroundColor,
                    selectedDetent: selectedDetent,
                    isPresented: isPresented
                ) {
                    panelContent
                }
                .ignoresSafeArea(.all, edges: .bottom)
                .frame(maxWidth: isCompact ? .infinity : maxWidth)
            }
    }
}
