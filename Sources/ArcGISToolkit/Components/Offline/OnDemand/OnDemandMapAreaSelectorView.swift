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
    
    /// The top left corner point of the area selector view.
    @State private var topLeft: CGPoint = .zero
    
    /// The top right corner point of the area selector view.
    @State private var topRight: CGPoint = .zero
    
    /// The bottom left corner point of the area selector view.
    @State private var bottomLeft: CGPoint = .zero
    
    /// The bottom right corner point of the area selector view.
    @State private var bottomRight: CGPoint = .zero
    
    /// The safe area insets of the view.
    @State private var safeAreaInsets = EdgeInsets()
    
    /// The rectangle for the area selector view handles.
    private var handlesRect: CGRect {
        selectedRect.insetBy(dx: -2, dy: -2)
    }
    
    /// The corner radius of the area selector view.
    private let cornerRadius: CGFloat = 16
    
    /// The location for a handle that resizes the selector view.
    enum HandleLocation {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    var body: some View {
        GeometryReader { geometry in
            dimmedMaskedView
                .edgesIgnoringSafeArea(.all)
                .allowsHitTesting(false)
                .overlay { handles }
                .onChange(of: safeAreaInsets) { _ in
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
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .frame(width: selectedRect.width, height: selectedRect.height)
                    .position(selectedRect.center)
            }
        
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(.white, lineWidth: 4)
            .frame(width: selectedRect.width, height: selectedRect.height)
            .position(selectedRect.center)
    }
    
    /// The view for the handles that allow resizing the selected area.
    @ViewBuilder private var handles: some View {
        Handle(location: .topLeft, position: topLeft, cornerRadius: cornerRadius) {
            resize(for: .topLeft, location: $0)
        }
        
        Handle(location: .topRight, position: topRight, cornerRadius: cornerRadius) {
            resize(for: .topRight, location: $0)
        }
        
        Handle(location: .bottomLeft, position: bottomLeft, cornerRadius: cornerRadius) {
            resize(for: .bottomLeft, location: $0)
        }
        
        Handle(location: .bottomRight, position: bottomRight, cornerRadius: cornerRadius) {
            resize(for: .bottomRight, location: $0)
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
        
        // NOTE: This causes everything to get reset when insets change.
        selectedRect = maxRect
        updateHandles()
    }
    
    /// Resizes the area selectpor view.
    /// - Parameters:
    ///   - handle: The handle location.
    ///   - location: The location of the drag gesture.
    private func resize(for handle: HandleLocation, location: CGPoint) {
        // Resize the rect.
        let rectangle: CGRect
        
        switch handle {
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
        corrected = CGRectUnion(corrected, minimumRect(forHandle: handle))
        
        selectedRect = corrected
        
        // Now update handles for new bounding rect.
        updateHandles()
    }
    
    /// Calculates the minimum rect size for a drag point handle using the adjacent handle position.
    /// - Parameter handle: The handle location.
    /// - Returns: The minimum rect for a handle.
    private func minimumRect(forHandle handle: HandleLocation) -> CGRect {
        let maxWidth: CGFloat = 50
        let maxHeight: CGFloat  = 50
        
        switch handle {
        case .topLeft:
            // Anchor is opposite corner.
            return CGRect(
                x: selectedRect.maxX - maxWidth,
                y: selectedRect.maxY - maxHeight,
                width: maxWidth,
                height: maxHeight
            )
        case .topRight:
            return CGRect(
                x: selectedRect.minX,
                y: selectedRect.maxY - maxHeight,
                width: maxWidth,
                height: maxHeight
            )
        case .bottomLeft:
            return CGRect(
                x: selectedRect.maxX - maxWidth,
                y: selectedRect.minY,
                width: maxWidth,
                height: maxHeight
            )
        case .bottomRight:
            return CGRect(
                x: selectedRect.minX,
                y: selectedRect.minY,
                width: maxWidth,
                height: maxHeight
            )
        }
    }
    
    /// Updates the handle locations using the boudning rect.
    private func updateHandles() {
        topRight = CGPoint(x: selectedRect.maxX, y: selectedRect.minY)
        topLeft = CGPoint(x: selectedRect.minX, y: selectedRect.minY)
        bottomLeft = CGPoint(x: selectedRect.minX, y: selectedRect.maxY)
        bottomRight = CGPoint(x: selectedRect.maxX, y: selectedRect.maxY)
    }
    
    /// The handle view for the map area selector.
    struct Handle: View {
        let location: HandleLocation
        /// The position of the handle.
        let position: CGPoint
        /// The corner radius of the handle.
        let cornerRadius: CGFloat
        /// The closure to call when the map area selector should be resized.
        let resize: (CGPoint) -> Void
        /// The gesture state of the drag gesture.
        @GestureState var gestureState: State = .started
        /// The types of gesture states.
        enum State {
            case started, changed
        }
        
        var body: some View {
            ZStack {
                RoundedCorner(handle: location, position: position, cornerRadius: cornerRadius)
                    .stroke(.ultraThickMaterial, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                Color.clear
                    .contentShape(Rectangle())
                    .frame(width: 44, height: 44)
                    .position(position)
                    .gesture(DragGesture(coordinateSpace: .local)
                        .updating($gestureState) { value, state, _ in
                            switch state {
                            case .started:
                                state = .changed
                                UISelectionFeedbackGenerator().selectionChanged()
                            case .changed:
                                resize(value.location)
                            }
                        }
                    )
            }
        }
    }
    
    /// The view for a rounded corner shape.
    struct RoundedCorner: Shape {
        /// The handle location.
        let handle: HandleLocation
        /// The handle position.
        let position: CGPoint
        /// The corner radius.
        let cornerRadius: CGFloat
        /// The offset padding.
        let offset: CGFloat = 2
        
        // Add a rounded corner for the handle.
        func path(in rect: CGRect) -> Path {
            var path = Path()
            var clippingPath = Path()
            
            switch handle {
            case .topLeft:
                let offsetPosition = position.offsetBy(dx: -offset, dy: -offset)
                path.move(to: CGPoint(x: offsetPosition.x, y: offsetPosition.y + cornerRadius))
                path.addQuadCurve(to: CGPoint(x: offsetPosition.x + cornerRadius, y: offsetPosition.y), control: CGPoint(x: offsetPosition.x, y: offsetPosition.y))
            case .topRight:
                let offsetPosition = position.offsetBy(dx: offset, dy: -offset)
                path.move(to: CGPoint(x: offsetPosition.x - cornerRadius, y: offsetPosition.y))
                path.addQuadCurve(to: CGPoint(x: offsetPosition.x, y: offsetPosition.y + cornerRadius), control: CGPoint(x: offsetPosition.x, y: offsetPosition.y))
            case .bottomLeft:
                let offsetPosition = position.offsetBy(dx: -offset, dy: offset)
                path.move(to: CGPoint(x: offsetPosition.x + cornerRadius, y: offsetPosition.y))
                path.addQuadCurve(to: CGPoint(x: offsetPosition.x, y: offsetPosition.y - cornerRadius), control: CGPoint(x: offsetPosition.x, y: offsetPosition.y))
            case .bottomRight:
                let offsetPosition = position.offsetBy(dx: offset, dy: offset)
                path.move(to: CGPoint(x: offsetPosition.x, y: offsetPosition.y - cornerRadius))
                path.addQuadCurve(to: CGPoint(x: offsetPosition.x - cornerRadius, y: offsetPosition.y), control: CGPoint(x: offsetPosition.x, y: offsetPosition.y))
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
