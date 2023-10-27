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
    /// The height of a geo-view's attribution bar.
    ///
    /// When the panel is detached from the bottom of the screen (non-compact) this value allows
    /// the panel to be aligned correctly between the top of a geo-view and the top of the its
    /// attribution bar.
    let attributionBarHeight: CGFloat
    /// The background color of the floating panel.
    let backgroundColor: Color
    /// A binding to the currently selected detent.
    @Binding var selectedDetent: FloatingPanelDetent
    /// A binding to a Boolean value that determines whether the view is presented.
    @Binding var isPresented: Bool
    /// The content shown in the floating panel.
    let content: () -> Content
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    /// The color of the handle.
    @State private var handleColor: Color = .defaultHandleColor
    
    /// The height of the content.
    @State private var height: CGFloat = .minHeight
    
    /// A Boolean value indicating whether the keyboard is open.
    @State private var keyboardIsOpen = false
    
    /// The latest recorded drag gesture value.
    @State private var latestDragGesture: DragGesture.Value?
    
    /// The maximum allowed height of the content.
    @State private var maximumHeight: CGFloat = .zero
    
    /// A Boolean value indicating whether the resignFirstResponder should be sent for the current
    /// drag gesture.
    @State private var shouldSendResign = true
    
    /// A Boolean value indicating whether the panel should be configured for a compact environment.
    private var isCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: 0) {
                if isPresented {
                    if isCompact {
                        makeHandleView()
                        Divider()
                    }
                    content()
                        .frame(height: height)
                        .clipped()
                    if !isCompact {
                        Divider()
                        makeHandleView()
                    }
                }
            }
            // Set frame width to infinity to prevent horizontal shrink on dismissal.
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .clipShape(
                RoundedCorners(
                    corners: isCompact ? [.topLeft, .topRight] : .allCorners,
                    radius: 10
                )
            )
            .shadow(radius: 10)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: isCompact ? .bottom : .top
            )
            .animation(.easeInOut, value: isPresented)
            .animation(.default, value: attributionBarHeight)
            .onAppear {
                maximumHeight = geometryProxy.size.height
                updateHeight()
            }
            .onChange(of: geometryProxy.size.height) { height in
                maximumHeight = height
                updateHeight()
            }
            .onChange(of: isPresented) { _ in
                updateHeight()
            }
            .onChange(of: selectedDetent) { _ in
                updateHeight()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                keyboardIsOpen = true
                updateHeight()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
                keyboardIsOpen = false
                updateHeight()
            }
        }
        
        // If non-compact, add uniform padding around all edges.
        .padding(.all, isCompact ? 0 : .externalPadding)
        
        // If non-compact, and the keyboard isn't open add padding for the attribution bar.
        .padding(.bottom, !isCompact && !keyboardIsOpen ? attributionBarHeight : 0)
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged {
                let deltaY = $0.location.y - (latestDragGesture?.location.y ?? $0.location.y)
                let proposedHeight = height + ((isCompact ? -1 : +1) * deltaY)
                
                if shouldSendResign {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    shouldSendResign = false
                }
                
                handleColor = .activeHandleColor
                height = min(max(.minHeight, proposedHeight), maximumHeight)
                latestDragGesture = $0
            }
            .onEnded {
                let predictedEndLocation = $0.predictedEndLocation.y
                let inferredHeight = isCompact ? maximumHeight - predictedEndLocation : predictedEndLocation
                
                selectedDetent = [.summary, .half, .full]
                    .map { (detent: $0, height: heightFor(detent: $0)) }
                    .min { abs(inferredHeight - $0.height) < abs(inferredHeight - $1.height) }!
                    .detent
                
                updateHeight()
                handleColor = .defaultHandleColor
                latestDragGesture = nil
                shouldSendResign = true
            }
    }
    
    /// Calculates the height for the `detent`.
    /// - Parameter detent: The detent to use when calculating height
    /// - Returns: A height for the provided detent based on the current maximum height
    func heightFor(detent: FloatingPanelDetent) -> CGFloat {
        switch detent {
        case .summary:
            return max(.minHeight, maximumHeight * 0.25)
        case .half:
            return maximumHeight * 0.5
        case .full:
            return maximumHeight
        case let .fraction(fraction):
            return min(maximumHeight, max(.minHeight, maximumHeight * fraction))
        case let .height(height):
            return min(maximumHeight, max(.minHeight, height))
        }
    }
    
    /// Updates height to an appropriate value.
    func updateHeight() {
        let newHeight: CGFloat = {
            if !isPresented {
                return .zero
            } else if keyboardIsOpen {
                return heightFor(detent: .full)
            } else {
                return heightFor(detent: selectedDetent)
            }
        }()
        withAnimation { height = max(0, (newHeight - .handleFrameHeight))  }
    }
    
    /// Configures a handle view.
    /// - Returns: A configured handle view, suitable for placement in the panel.
    @ViewBuilder func makeHandleView() -> some View {
        Handle(color: handleColor)
            .background(backgroundColor)
            .frame(height: .handleFrameHeight)
            .gesture(drag)
            .zIndex(1)
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
    /// The amount of padding around the floating panel.
    static let externalPadding: CGFloat = 10
    
    /// THe height of the area containing the handle.
    static let handleFrameHeight: CGFloat = 30
    
    static let minHeight: CGFloat = 66
}

private extension Color {
    static var defaultHandleColor: Color { .secondary }
    static var activeHandleColor: Color { .primary }
}

private struct RoundedCorners: Shape {
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
