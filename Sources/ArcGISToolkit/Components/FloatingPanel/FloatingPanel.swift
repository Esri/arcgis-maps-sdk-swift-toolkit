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
struct FloatingPanel<Content>: View where Content: View {
    // Note:  instead of the FloatingPanel being a view, it might be preferable
    // to have it be a view modifier, similar to how SwiftUI doesn't have a
    // SheetView, but a modifier that presents a sheet.
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    /// The content shown in the floating panel.
    let content: Content
    
    /// Creates a `FloatingPanel`
    /// - Parameter content: The view shown in the floating panel.
    /// - Parameter detent: <#detent description#>
    init(
        detent: Binding<FloatingPanelDetent>,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        _detent = detent
    }
    
    /// The color of the handle.
    @State private var handleColor: Color = .defaultHandleColor
    
    /// The height of the content.
    @State private var height: CGFloat = .minHeight
    
    /// The maximum allowed height of the content.
    @State private var maximumHeight: CGFloat = .infinity
    
    /// <#Description#>
    @Binding var detent: FloatingPanelDetent
    
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
                }
                content
                    .frame(minHeight: .minHeight, maxHeight: height)
                if !isCompact {
                    Divider()
                    Handle(color: handleColor)
                        .gesture(drag)
                }
            }
            .padding([.top, .bottom], 10)
            .background(Color(uiColor: .systemGroupedBackground))
            .cornerRadius(10, corners: isCompact ? [.topLeft, .topRight] : [.allCorners])
            .shadow(radius: 10)
            .padding([.leading, .top, .trailing], isCompact ? 0 : 10)
            .padding([.bottom], isCompact ? 0 : 50)
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
            .onChange(of: detent) { newValue in
                withAnimation {
                    height = heightWithDetent(given: geometryProxy.size.height)
                }
            }
            .onAppear {
                withAnimation {
                    height = heightWithDetent(given: geometryProxy.size.height)
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
    
    /// - Parameter height: Maximum available height
    /// - Returns: Height given the current detent
    func heightWithDetent(given height: CGFloat) -> CGFloat {
        switch detent {
        case .min:
            return .minHeight
        case .oneQuarter:
            return height * 0.25
        case .half:
            return height * 0.5
        case .threeQuarters:
            return height * 0.75
        case .max:
            return height
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

private struct RoundedCorner: Shape {
    var corners: UIRectCorner
    
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(
                width: radius,
                height: radius
            )
        )
        return Path(path.cgPath)
    }
}

private extension View {
    func cornerRadius(
        _ radius: CGFloat,
        corners: UIRectCorner
    ) -> some View {
        clipShape(RoundedCorner(
            corners: corners,
            radius: radius
        ))
    }
}
