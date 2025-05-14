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

/// A floating panel is a view that overlays a view and supplies view-related
/// content. For more information see <doc:FloatingPanel>.
struct FloatingPanel<Content>: View where Content: View {
    /// The height of a geo-view's attribution bar.
    ///
    /// When the panel is detached from the bottom of the screen (non-compact) this value allows
    /// the panel to be aligned correctly between the top of a geo-view and the top of the its
    /// attribution bar.
    let attributionBarHeight: CGFloat
    /// The background color of the floating panel.
    let backgroundColor: Color?
    /// A binding to the currently selected detent.
    @Binding var selectedDetent: FloatingPanelDetent
    /// A binding to a Boolean value that determines whether the view is presented.
    @Binding var isPresented: Bool
    /// The content shown in the floating panel.
    let content: () -> Content
    
    @Environment(\.isPortraitOrientation) var isPortraitOrientation
    
    /// The color of the handle.
    @State private var handleColor: Color = .defaultHandleColor
    
    /// The height of the content.
    @State private var height: CGFloat = .minHeight
    
    /// The current height of the device keyboard.
    @State private var keyboardHeight: CGFloat = 0
    
    /// The current state of the device keyboard.
    @State private var keyboardState: KeyboardState = .closed
    
    /// The latest recorded drag gesture value.
    @State private var latestDragGesture: DragGesture.Value?
    
    /// The maximum allowed height of the content.
    @State private var maximumHeight: CGFloat = .zero
    
    var body: some View {
        GeometryReader { geometryProxy in
            VStack(spacing: 0) {
                if isPresented {
                    if isPortraitOrientation {
                        makeHandleView()
                        Divider()
                    }
                    content()
                        .padding(.bottom, isPortraitOrientation ? keyboardHeight - geometryProxy.safeAreaInsets.bottom : .zero)
                        .frame(height: height)
                        .clipped()
                    if !isPortraitOrientation {
                        Divider()
                        makeHandleView()
                    }
                }
            }
            // Set frame width to infinity to prevent horizontal shrink on dismissal.
            .frame(maxWidth: .infinity)
#if os(visionOS)
            .glassBackgroundEffect()
#else
            .background(backgroundColor)
            .clipShape(
                RoundedCorners(
                    corners: isPortraitOrientation ? [.topLeft, .topRight] : .allCorners,
                    radius: .cornerRadius
                )
            )
#endif
            .shadow(radius: 10)
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: isPortraitOrientation ? .bottom : .top
            )
            .animation(.easeInOut, value: isPresented)
            .animation(.default, value: attributionBarHeight)
            .onChange(of: geometryProxy.size.height, initial: true) {
                maximumHeight = geometryProxy.size.height
                updateHeight()
            }
            .onChange(of: isPresented) {
                updateHeight()
            }
            .onChange(of: selectedDetent) {
                updateHeight()
            }
            .onKeyboardStateChanged { state, height in
                keyboardState = state
                keyboardHeight = height
                updateHeight()
            }
        }
        
        // Disable automatic keyboard avoidance. The panel will handle keyboard avoidance via
        // padding applied to the bottom of the content. This allows the panel to maintain a
        // constant height as they keyboard closes.
        .ignoresSafeArea(.keyboard)
        
        // If compact, ignore the device's bottom safe area so content reaches the physical bottom
        // edge of the screen.
        .ignoresSafeArea(.container, edges: isPortraitOrientation && keyboardState == .closed ? .bottom : [])
        
        // If non-compact, add uniform padding around all edges.
        .padding(.all, isPortraitOrientation ? 0 : .externalPadding)
        
        // If non-compact, and the keyboard isn't open add padding for the attribution bar.
        .padding(.bottom, !isPortraitOrientation && !(keyboardState == .open) ? attributionBarHeight : 0)
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged {
                let deltaY = $0.location.y - (latestDragGesture?.location.y ?? $0.location.y)
                let proposedHeight = height + ((isPortraitOrientation ? -1 : +1) * deltaY)
                
                handleColor = .activeHandleColor
                height = min(max(.minHeight, proposedHeight), maximumHeight)
                latestDragGesture = $0
            }
            .onEnded {
                let predictedEndLocation = $0.predictedEndLocation.y
                let inferredHeight = isPortraitOrientation ? maximumHeight - predictedEndLocation : predictedEndLocation
                
                selectedDetent = [.summary, .half, .full]
                    .map { (detent: $0, height: heightFor(detent: $0)) }
                    .min { abs(inferredHeight - $0.height) < abs(inferredHeight - $1.height) }!
                    .detent
                
                if $0.translation.height.magnitude > 100 {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                
                updateHeight()
                
                handleColor = .defaultHandleColor
                latestDragGesture = nil
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
            } else if keyboardState == .opening || keyboardState == .open {
                return heightFor(detent: .full)
            } else {
                return heightFor(detent: selectedDetent)
            }
        }()
        withAnimation { height = max(0, (newHeight - .handleFrameHeight)) }
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
            .foregroundStyle(color)
            .frame(width: 100, height: 8.0)
            .hoverEffect()
    }
}

private extension CGFloat {
    /// The amount of padding around the floating panel.
    static let externalPadding: CGFloat = 10
    
    /// THe height of the area containing the handle.
    static let handleFrameHeight: CGFloat = 30
    
    static let minHeight: CGFloat = 66
    
    /// The corner radius of the floating panel.
    static let cornerRadius: CGFloat = {
#if os(visionOS)
        32
#else
        10
#endif
    }()
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
