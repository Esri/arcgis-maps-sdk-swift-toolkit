// Copyright 2025 Esri
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

import ArcGIS
import SwiftUI

struct OnDemandMapAreaSelectorView: View {
    /// The maximum size of the area selector view.
    @State private var maxRect: CGRect = .zero
    
    /// A Binding to the CGRect of the selected area.
    @Binding var selectedRect: CGRect
    
    /// The safe area insets of the view.
    @State private var safeAreaInsets = EdgeInsets()
    
    /// The rectangle for the area selector view handles.
    private var handlesRect: CGRect {
        selectedRect.insetBy(dx: -2, dy: -2)
    }
    
    /// The corner radius of the area selector view.
    static let cornerRadius: CGFloat = 16
    
    /// The minimum width of the selected area.
    static let minimumWidth: CGFloat = 50
    
    /// The minimum height of the selected area.
    static let minimumHeight: CGFloat  = 50
    
    /// Top right handle position.
    private var topRight: CGPoint { CGPoint(x: selectedRect.maxX, y: selectedRect.minY) }
    
    /// Top left handle position.
    private var topLeft: CGPoint { CGPoint(x: selectedRect.minX, y: selectedRect.minY) }
    
    /// Bottom left handle position.
    private var bottomLeft: CGPoint { CGPoint(x: selectedRect.minX, y: selectedRect.maxY) }
    
    /// Bottom right handle position.
    private var bottomRight: CGPoint { CGPoint(x: selectedRect.maxX, y: selectedRect.maxY) }
    
    /// The orientation for a handle that resizes the selector view.
    enum HandleOrientation {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    var body: some View {
        GeometryReader { geometry in
            dimmedMaskedView
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
                .overlay { handles }
                .onChange(of: safeAreaInsets) { _, _ in
                    updateMaxRect(geometry: geometry)
                }
        }
        .edgesIgnoringSafeArea(.all)
        .onGeometryChange(for: EdgeInsets.self, of: \.safeAreaInsets) { safeAreaInsets in
            self.safeAreaInsets = safeAreaInsets
        }
    }
    
    /// The darker dimmed background view that shows the selected area masked.
    @ViewBuilder private var dimmedMaskedView: some View {
        Rectangle()
            .fill(.black.opacity(0.2))
            .reverseMask {
                RoundedRectangle(cornerRadius: OnDemandMapAreaSelectorView.cornerRadius, style: .continuous)
                    .frame(width: selectedRect.width, height: selectedRect.height)
                    .position(selectedRect.center)
            }
        
        RoundedRectangle(cornerRadius: OnDemandMapAreaSelectorView.cornerRadius, style: .continuous)
            .stroke(.white, lineWidth: 4)
            .frame(width: selectedRect.width, height: selectedRect.height)
            .position(selectedRect.center)
    }
    
    /// The view for the handles that allow resizing the selected area.
    @ViewBuilder private var handles: some View {
        Handle(orientation: .topLeft, position: topLeft) { handleOrientation, location in
            resize(for: handleOrientation, location: location)
        }
        
        Handle(orientation: .topRight, position: topRight) { handleOrientation, location in
            resize(for: handleOrientation, location: location)
        }
        
        Handle(orientation: .bottomLeft, position: bottomLeft) { handleOrientation, location in
            resize(for: handleOrientation, location: location)
        }
        
        Handle(orientation: .bottomRight, position: bottomRight) { handleOrientation, location in
            resize(for: handleOrientation, location: location)
        }
    }
    
    /// Updates the maximum rectangle for a change to the safe area insets.
    private func updateMaxRect(geometry: GeometryProxy) {
        let frame = CGRect(
            x: safeAreaInsets.leading,
            y: safeAreaInsets.top,
            width: geometry.size.width - safeAreaInsets.trailing - safeAreaInsets.leading,
            height: geometry.size.height - safeAreaInsets.bottom - safeAreaInsets.top
        )
        
        // Use default insets of 50 unless we cannot because of the size
        // of the frame being too small.
        var defaultInsets: CGFloat = 50
        if frame.width < defaultInsets || frame.height < defaultInsets {
            defaultInsets = min(frame.width * 0.1, frame.height * 0.1)
        }
        
        maxRect = frame.insetBy(dx: defaultInsets, dy: defaultInsets)
        
        /// Set the selected rectangle to the intersection of the max rect and the
        /// current selected rect.
        selectedRect = CGRectIntersection(maxRect, selectedRect)
        
        /// If that resulting rect is empty or less than the minimum dimensions,
        /// then set the selected rect to the max rectangle.
        if selectedRect.isEmpty
            || selectedRect.width < Self.minimumWidth
            || selectedRect.height < Self.minimumHeight {
            selectedRect = maxRect
        }
    }
    
    /// Resizes the area selectpor view.
    /// - Parameters:
    ///   - handleOrientation: The handle orientation.
    ///   - location: The location of the drag gesture.
    private func resize(for handleOrientation: HandleOrientation, location: CGPoint) {
        // Resize the rect.
        let rectangle: CGRect
        
        switch handleOrientation {
        case .topLeft:
            let minX = location.x
            let maxX = selectedRect.maxX
            let minY = location.y
            let maxY = selectedRect.maxY
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        case .topRight:
            let minX = selectedRect.minX
            let maxX = location.x
            let minY = location.y
            let maxY = selectedRect.maxY
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        case .bottomLeft:
            let minX = location.x
            let maxX = selectedRect.maxX
            let minY = selectedRect.minY
            let maxY = location.y
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            break
        case .bottomRight:
            let minX = selectedRect.minX
            let maxX = location.x
            let minY = selectedRect.minY
            let maxY = location.y
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            break
        }
        
        // Keep rectangle within the maximum rect.
        var corrected = CGRectIntersection(maxRect, rectangle)
        
        // Keep rectangle outside the minimum rect.
        corrected = CGRectUnion(corrected, minimumRect(for: handleOrientation))
        
        // Update selection.
        selectedRect = corrected
    }
    
    /// Calculates the minimum rect size for a drag point handle using the adjacent handle position.
    /// - Parameter handleOrientation: The handle orientation.
    /// - Returns: The minimum rect for a handle.
    private func minimumRect(for handleOrientation: HandleOrientation) -> CGRect {
        switch handleOrientation {
        case .topLeft:
            // Anchor is opposite corner.
            return CGRect(
                x: selectedRect.maxX - Self.minimumWidth,
                y: selectedRect.maxY - Self.minimumHeight,
                width: Self.minimumWidth,
                height: Self.minimumHeight
            )
        case .topRight:
            return CGRect(
                x: selectedRect.minX,
                y: selectedRect.maxY - Self.minimumHeight,
                width: Self.minimumWidth,
                height: Self.minimumHeight
            )
        case .bottomLeft:
            return CGRect(
                x: selectedRect.maxX - Self.minimumWidth,
                y: selectedRect.minY,
                width: Self.minimumWidth,
                height: Self.minimumHeight
            )
        case .bottomRight:
            return CGRect(
                x: selectedRect.minX,
                y: selectedRect.minY,
                width: Self.minimumWidth,
                height: Self.minimumHeight
            )
        }
    }
    
    /// The handle view for the map area selector.
    struct Handle: View {
        /// The handle orientation.
        let orientation: HandleOrientation
        /// The position of the handle.
        let position: CGPoint
        /// The closure to call when the map area selector should be resized.
        let resize: (HandleOrientation, CGPoint) -> Void
        /// The gesture state of the drag gesture.
        @GestureState var gestureState: State = .started
        /// The types of gesture states.
        enum State {
            case started, changed
        }
        
        var body: some View {
            HandleShape(
                orientation: orientation,
                cornerRadius: OnDemandMapAreaSelectorView.cornerRadius
            )
#if os(visionOS)
            .stroke(.ultraThinMaterial, style: StrokeStyle(lineWidth: 5, lineCap: .round))
#else
            .stroke(.ultraThickMaterial, style: StrokeStyle(lineWidth: 5, lineCap: .round))
            .environment(\.colorScheme, .light)
#endif
            .contentShape(RoundedRectangle(cornerRadius: 8))
#if os(visionOS)
            .frame(width: 36, height: 36)
#else
            .frame(width: 44, height: 44)
#endif
            .hoverEffect()
            .position(position)
            .gesture(
                DragGesture()
                    .updating($gestureState) { value, state, _ in
                        switch state {
                        case .started:
                            state = .changed
#if !os(visionOS)
                            UISelectionFeedbackGenerator().selectionChanged()
#endif
                        case .changed:
                            resize(orientation, value.location)
                        }
                    }
            )
        }
    }
    
    /// The rounded corner shape for drawing a handle.
    struct HandleShape: Shape {
        /// The handle orientation.
        let orientation: HandleOrientation
        /// The corner radius.
        let cornerRadius: CGFloat
        /// The offset padding.
        let offset: CGFloat = 2
        
        // Add a rounded corner for the handle.
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            switch orientation {
            case .topLeft:
                let offsetPosition = rect.center.offsetBy(dx: -offset, dy: -offset)
                path.move(to: CGPoint(x: offsetPosition.x, y: offsetPosition.y + cornerRadius))
                path.addQuadCurve(
                    to: CGPoint(x: offsetPosition.x + cornerRadius, y: offsetPosition.y),
                    control: CGPoint(x: offsetPosition.x, y: offsetPosition.y)
                )
            case .topRight:
                let offsetPosition = rect.center.offsetBy(dx: offset, dy: -offset)
                path.move(to: CGPoint(x: offsetPosition.x - cornerRadius, y: offsetPosition.y))
                path.addQuadCurve(
                    to: CGPoint(x: offsetPosition.x, y: offsetPosition.y + cornerRadius),
                    control: CGPoint(x: offsetPosition.x, y: offsetPosition.y)
                )
            case .bottomLeft:
                let offsetPosition = rect.center.offsetBy(dx: -offset, dy: offset)
                path.move(to: CGPoint(x: offsetPosition.x + cornerRadius, y: offsetPosition.y))
                path.addQuadCurve(
                    to: CGPoint(x: offsetPosition.x, y: offsetPosition.y - cornerRadius),
                    control: CGPoint(x: offsetPosition.x, y: offsetPosition.y)
                )
            case .bottomRight:
                let offsetPosition = rect.center.offsetBy(dx: offset, dy: offset)
                path.move(to: CGPoint(x: offsetPosition.x, y: offsetPosition.y - cornerRadius))
                path.addQuadCurve(
                    to: CGPoint(x: offsetPosition.x - cornerRadius, y: offsetPosition.y),
                    control: CGPoint(x: offsetPosition.x, y: offsetPosition.y)
                )
            }
            
            return path
        }
    }
}

private extension View {
    /// A reverse mask overlay.
    func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

private extension CGPoint {
    /// Offests a point by a given x and y amount.
    /// - Parameters:
    ///   - dx: The x offset.
    ///   - dy: The y offset.
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint {
        return CGPoint(x: x + dx, y: y + dy)
    }
}

private extension CGRect {
    /// The center point of the rectangle.
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
