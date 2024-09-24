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

public extension View {
    /// A floating panel is a view that overlays a view and supplies view-related
    /// content. For more information see <doc:FloatingPanel>.
    ///
    /// - Parameters:
    ///   - attributionBarHeight: The height of a geo-view's attribution bar.
    ///   - backgroundColor: The background color of the floating panel.
    ///   - selectedDetent: A binding to the currently selected detent.
    ///   - horizontalAlignment: The horizontal alignment of the floating panel.
    ///   - isPresented: A binding to a Boolean value that determines whether the view is presented.
    ///   - maxWidth: The maximum width of the floating panel.
    ///   - content: A closure that returns the content of the floating panel.
    /// - Returns: A dynamic view with a presentation style similar to that of a sheet in compact
    /// environments and a popover otherwise.
    @available(iOS 16.0, *)
    @available(macCatalyst 16.0, *)
    @available(visionOS, unavailable, message: "Use 'floatingPanel(attributionBarHeight:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
    func floatingPanel<Content>(
        attributionBarHeight: CGFloat = 0,
        backgroundColor: Color = Color(uiColor: .systemBackground),
        selectedDetent: Binding<FloatingPanelDetent>? = nil,
        horizontalAlignment: HorizontalAlignment = .trailing,
        isPresented: Binding<Bool> = .constant(true),
        maxWidth: CGFloat = 400,
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            FloatingPanelModifier(
                attributionBarHeight: attributionBarHeight,
                backgroundColor: backgroundColor,
                boundDetent: selectedDetent,
                horizontalAlignment: horizontalAlignment,
                isPresented: isPresented,
                maxWidth: maxWidth,
                panelContent: content
            )
        )
    }
    
    /// A floating panel is a view that overlays a view and supplies view-related
    /// content. For more information see <doc:FloatingPanel>.
    ///
    /// - Parameters:
    ///   - attributionBarHeight: The height of a geo-view's attribution bar.
    ///   - selectedDetent: A binding to the currently selected detent.
    ///   - horizontalAlignment: The horizontal alignment of the floating panel.
    ///   - isPresented: A binding to a Boolean value that determines whether the view is presented.
    ///   - maxWidth: The maximum width of the floating panel.
    ///   - content: A closure that returns the content of the floating panel.
    /// - Returns: A dynamic view with a presentation style similar to that of a sheet in compact
    /// environments and a popover otherwise.
    @available(visionOS 2.0, *)
    @available(iOS, unavailable, message: "Use 'floatingPanel(attributionBarHeight:backgroundColor:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
    @available(macCatalyst, unavailable, message: "Use 'floatingPanel(attributionBarHeight:backgroundColor:selectedDetent:horizontalAlignment:isPresented:maxWidth:_:)' instead.")
    func floatingPanel<Content>(
        attributionBarHeight: CGFloat = 0,
        selectedDetent: Binding<FloatingPanelDetent>? = nil,
        horizontalAlignment: HorizontalAlignment = .trailing,
        isPresented: Binding<Bool> = .constant(true),
        maxWidth: CGFloat = 400,
        @ViewBuilder _ content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            FloatingPanelModifier(
                attributionBarHeight: attributionBarHeight,
                backgroundColor: nil,
                boundDetent: selectedDetent,
                horizontalAlignment: horizontalAlignment,
                isPresented: isPresented,
                maxWidth: maxWidth,
                panelContent: content
            )
        )
    }
}

/// Overlays a floating panel on the parent content.
private struct FloatingPanelModifier<PanelContent>: ViewModifier where PanelContent: View {
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    /// The height of a geo-view's attribution bar.
    ///
    /// When the panel is detached from the bottom of the screen this value allows
    /// the panel to be aligned correctly between the top of a geo-view and the top of the
    /// its attribution bar.
    let attributionBarHeight: CGFloat
    
    /// The background color of the floating panel.
    let backgroundColor: Color?
    
    /// A user provided detent.
    let boundDetent: Binding<FloatingPanelDetent>?
    
    /// A managed detent when a user bound one isn't provided.
    @State private var managedDetent: FloatingPanelDetent = .half
    
    /// The horizontal alignment of the floating panel.
    let horizontalAlignment: HorizontalAlignment
    
    /// A binding to a Boolean value that determines whether the view is presented.
    let isPresented: Binding<Bool>
    
    /// The maximum width of the floating panel.
    let maxWidth: CGFloat
    
    /// The content to be displayed within the floating panel.
    let panelContent: () -> PanelContent
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: Alignment(horizontal: horizontalAlignment, vertical: .top)) {
                FloatingPanel(
                    attributionBarHeight: attributionBarHeight,
                    backgroundColor: backgroundColor,
                    selectedDetent: boundDetent ?? $managedDetent,
                    isPresented: isPresented,
                    content: panelContent
                )
                .frame(maxWidth: isPortraitOrientation ? .infinity : maxWidth)
            }
    }
}
