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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// The background color of the floating panel.
    let backgroundColor: Color
    
    /// The content shown in the floating panel.
    let content: Content
    
    /// Creates a `FloatingPanel`.
    /// - Parameters:
    ///   - backgroundColor: The background color of the floating panel.
    ///   - selectedDetent: Controls the height of the panel.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    ///   - content: The view shown in the floating panel.
    init(
        backgroundColor: Color,
        selectedDetent: Binding<FloatingPanelDetent>,
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.selectedDetent = selectedDetent
        self.isPresented = isPresented
        self.content = content()
    }
    
    /// A binding to the currently selected detent.
    private var selectedDetent: Binding<FloatingPanelDetent>
    
    /// The color of the handle.
    @State private var handleColor: Color = .defaultHandleColor
    
    /// The height of the content.
    @State private var height: CGFloat = .minHeight
    
    /// A binding to a Boolean value that determines whether the view is presented.
    private var isPresented: Binding<Bool>
    
    /// The latest recorded drag gesture value.
    @State var latestDragGesture: DragGesture.Value?
    
    /// The maximum allowed height of the content.
    @State private var maximumHeight: CGFloat = .infinity
    
    /// A Boolean value indicating whether the panel should be configured for a compact environment.
    private var isCompact: Bool {
        horizontalSizeClass == .compact && verticalSizeClass == .regular
    }
    
    public var body: some View {
        if isPresented.wrappedValue {
            GeometryReader { geometryProxy in
                VStack(spacing: 0) {
                    if isCompact {
                        makeHandleView()
                        Divider()
                    }
                    content
                        .frame(height: height)
                        .padding(.bottom, isCompact ? 25 : 10)
                    if !isCompact {
                        Divider()
                        makeHandleView()
                    }
                }
                .background(backgroundColor)
                .cornerRadius(10, corners: isCompact ? [.topLeft, .topRight] : [.allCorners])
                .shadow(radius: 10)
                .opacity(isPresented.wrappedValue ? 1.0 : .zero)
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
                .onChange(of: selectedDetent.wrappedValue) { _ in
                    withAnimation {
                        height = heightFor(detent: selectedDetent.wrappedValue)
                    }
                }
                .onChange(of: isPresented.wrappedValue) {
                    height = $0 ? heightFor(detent: selectedDetent.wrappedValue) : .zero
                }
                .onAppear {
                    withAnimation {
                        height = heightFor(detent: selectedDetent.wrappedValue)
                    }
                }
                .animation(.default, value: isPresented.wrappedValue)
            }
            .padding([.leading, .top, .trailing], isCompact ? 0 : 10)
            .padding([.bottom], isCompact ? 0 : 50)
        }
    }
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged {
                let deltaY = $0.location.y - (latestDragGesture?.location.y ?? $0.location.y)
                let proposedHeight = height + ((isCompact ? -1 : +1) * deltaY)
                handleColor = .activeHandleColor
                height = min(max(.minHeight, proposedHeight), maximumHeight)
                latestDragGesture = $0
            }
            .onEnded {
                let deltaY = $0.location.y - latestDragGesture!.location.y
                let deltaTime = $0.time.timeIntervalSince(latestDragGesture!.time)
                let velocity = deltaY / deltaTime
                let speed = abs(velocity)
                
                let newDetent = bestDetent(given: height, travelingAt: velocity)
                let targetHeight = heightFor(detent: newDetent)
                
                let distanceAhead = abs(height - targetHeight)
                let travelTime = min(0.35, distanceAhead / speed)
                
                withAnimation(.easeOut(duration: travelTime)) {
                    selectedDetent.wrappedValue = newDetent
                    height = targetHeight
                }
                handleColor = .defaultHandleColor
                latestDragGesture = nil
            }
    }
    
    /// Determines the best detent based on the provided metrics.
    /// - Parameters:
    ///   - currentHeight: The height target for the detent.
    ///   - velocity: The velocity of travel to the new detent.
    /// - Returns: The best detent based on the provided metrics.
    func bestDetent(given currentHeight: CGFloat, travelingAt velocity: Double) -> FloatingPanelDetent {
        let lowSpeedThreshold = 100.0
        let highSpeedThreshold = 2000.0
        let isExpanding = (isCompact && velocity <= 0) || (!isCompact && velocity > 0)
        let speed = abs(velocity)
        let allDetents = [FloatingPanelDetent.summary, .full, .half]
            .map { (detent: $0, height: heightFor(detent: $0)) }
        // If the speed was low, choose the closest detent, regardless of direction.
        guard speed > lowSpeedThreshold else {
            return allDetents.min {
                abs(currentHeight - $0.height) < abs(currentHeight - $1.height)
            }?.detent ?? selectedDetent.wrappedValue
        }
        // Generate a new set of detents, filtering out those that would produce a height in the
        // opposite direction of the gesture, and sorting them in order of closest to furthest from
        // the current height.
        let candidateDetents = allDetents
            .filter { (detent, height) in
                if isExpanding {
                    return height >= currentHeight
                } else {
                    return height < currentHeight
                }
            }
            .sorted {
                if isExpanding {
                    return $0.1 < $1.1
                } else {
                    return $1.1 < $0.1
                }
            }
        
        // If the gesture had high speed, select the last candidate detent (the one that would
        // produce the greatest size difference from the current height). Otherwise, choose the
        // first candidate detent (the one that would produce the least size difference from the
        // current height).
        if speed >= highSpeedThreshold {
            return candidateDetents.last?.0 ?? selectedDetent.wrappedValue
        } else {
            return candidateDetents.first?.0 ?? selectedDetent.wrappedValue
        }
    }
    
    /// Calculates the height for the `detent`.
    /// - Parameter detent: The detent to use when calculating height
    /// - Returns: A height for the provided detent based on the current maximum height
    func heightFor(detent: FloatingPanelDetent) -> CGFloat {
        switch detent {
        case .summary:
            return max(.minHeight, maximumHeight * 0.15)
        case .half:
            return maximumHeight * 0.4
        case .full:
            return maximumHeight * (isCompact ? 0.90 : 1.0)
        case let .fraction(fraction):
            return min(maximumHeight, max(.minHeight, maximumHeight * fraction))
        case let .height(height):
            return min(maximumHeight, max(.minHeight, height))
        }
    }
    
    /// Configures a handle view.
    /// - Returns: A configured handle view, suitable for placement in the panel.
    @ViewBuilder func makeHandleView() -> some View {
        ZStack {
            backgroundColor
            Handle(color: handleColor)
        }
        .frame(height: 30)
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

private extension View {
    /// Clips this view to its bounding frame, with the specified corner radius, on the specified corners.
    /// - Parameters:
    ///   - radius: The radius used to round the corners.
    ///   - corners: The corners to be rounded.
    /// - Returns: A view that clips this view to its bounding frame with the specified corner radius and
    /// corners.
    func cornerRadius(
        _ radius: CGFloat,
        corners: UIRectCorner
    ) -> some View {
        clipShape(RoundedCorners(
            corners: corners,
            radius: radius
        ))
    }
}
