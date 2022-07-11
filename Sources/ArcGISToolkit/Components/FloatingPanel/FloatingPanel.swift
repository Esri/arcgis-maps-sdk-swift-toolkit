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
public struct FloatingPanel<Content>: View where Content: View {
    // Note:  instead of the FloatingPanel being a view, it might be preferable
    // to have it be a view modifier, similar to how SwiftUI doesn't have a
    // SheetView, but a modifier that presents a sheet.
    
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
    /// The content shown in the floating panel.
    let content: Content
    
    /// Creates a `FloatingPanel`
    /// - Parameter content: The view shown in the floating panel.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
        _height = State(initialValue: .infinity)
    }
    
    /// The color of the handle.
    @State private var handleColor: Color = .defaultHandleColor
    
    /// The height of the content.
    @State private var height: CGFloat
    
    /// The maximum allowed height of the content.
    @State private var maximumHeight: CGFloat = .infinity
    
    /// A Boolean value indicating whether the panel should be configured for a compact environment.
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    public var body: some View {
        GeometryReader { geometryProxy in
            VStack {
                if isCompact {
                    Handle(color: handleColor)
                        .gesture(drag)
                    Divider()
                    content
                        .frame(minHeight: .minHeight, maxHeight: height)
                } else {
                    content
                        .frame(minHeight: .minHeight, maxHeight: height)
                    Divider()
                    Handle(color: handleColor)
                        .gesture(drag)
                }
            }
            .esriBorder()
            .padding(isCompact ? [] : [.leading, .top, .trailing])
            .padding(.bottom, isCompact ? 0 : 50)
            .frame(
                width: geometryProxy.size.width,
                height: geometryProxy.size.height,
                alignment: isCompact ? .bottom : .top
            )
            .onSizeChange {
                maximumHeight = $0.height
                if height > maximumHeight {
                    height = maximumHeight
                }
            }
        }
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                handleColor = .activeHandleColor
                let proposedHeight: CGFloat
                if isCompact {
                    proposedHeight = max(
                        .minHeight,
                        height - value.translation.height
                    )
                } else {
                    proposedHeight = max(
                        .minHeight,
                        height + value.translation.height
                    )
                }
                height = min(proposedHeight, maximumHeight)
            }
            .onEnded { _ in
                handleColor = .defaultHandleColor
            }
    }
}

/// The "Handle" view of the floating panel.
private struct Handle: View {
    /// The color of the handle.
    var color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4.0)
            .foregroundColor(color)
            .frame(width: 100, height: 8.0)
    }
}

private extension CGFloat {
    static let minHeight: CGFloat = 66
}

private extension Color {
    static var defaultHandleColor: Color { .secondary }
    static var activeHandleColor: Color { .primary }
}
