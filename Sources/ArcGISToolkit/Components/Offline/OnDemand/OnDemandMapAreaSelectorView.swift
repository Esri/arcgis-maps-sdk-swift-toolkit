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
    
    /// A Binding to the CGRect of the selected map area.
    @Binding var selectedMapRect: CGRect
    
    /// The bounding rectangle for the area selector view.
    @State private var boundingRect: CGRect = .zero
    
    /// The inset rectangle for the area selector view.
    @State private var insetRect: CGRect = .zero
    
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
    
    /// The corner radius of the area selector view.
    private let cordnerRadius: CGFloat = 16
    
    /// The drag point for a drag gesture.
    private enum DragPoint {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ZStack {
                    Rectangle()
                        .fill(.black.opacity(0.10))
                        .reverseMask {
                            Rectangle()
                                .frame(width: boundingRect.width, height: boundingRect.height)
                                .position(boundingRect.center)
                            
                        }
                    RoundedCorners(cornerRadius: cordnerRadius)
                        .stroke(.ultraThickMaterial, style: StrokeStyle(lineWidth: 6, lineCap: .butt))
                        .frame(width: insetRect.width, height: insetRect.height)
                        .position(insetRect.center)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: cordnerRadius, style: .continuous)
                            .stroke(.white, lineWidth: 4)
                        
                    }
                    .frame(width: boundingRect.width, height: boundingRect.height)
                    .position(boundingRect.center)
                }
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .onAppear {
                    boundingRect = maxRect
                    insetRect = boundingRect.insetBy(dx: -2, dy: -2)
                    updateHandles()
                }
                .onChange(of: boundingRect) {
                    selectedMapRect = $0
                }
                
                Handle(position: topLeft) {
                    resize(for: .topLeft, location: $0)
                }
                
                Handle(position: topRight) {
                    resize(for: .topRight, location: $0)
                }
                
                Handle(position: bottomLeft) {
                    resize(for: .bottomLeft, location: $0)
                }
                
                Handle(position: bottomRight) {
                    resize(for: .bottomRight, location: $0)
                }
            }
            .onChange(of: safeAreaInsets) { _ in
                let frame = CGRect(
                    x: safeAreaInsets.leading,
                    y: safeAreaInsets.top,
                    width: geometry.size.width - safeAreaInsets.trailing - safeAreaInsets.leading,
                    height: geometry.size.height - safeAreaInsets.bottom - safeAreaInsets.top
                )
                
                maxRect = frame
                    .insetBy(
                        dx: frame.width * 0.1,
                        dy: frame.height * 0.1
                    )
                boundingRect = maxRect
                
                insetRect = boundingRect.insetBy(dx: -2, dy: -2)
                
                updateHandles()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onGeometryChange(for: EdgeInsets.self, of: \.safeAreaInsets) { safeAreaInsets in
            self.safeAreaInsets = safeAreaInsets
        }
    }
    
    /// Resizes the area selectpor view.
    /// - Parameters:
    ///   - handle: The drag point handle.
    ///   - location: The location of the drag gesture.
    private func resize(for handle: DragPoint, location: CGPoint) {
        // Resize the rect.
        let rectangle: CGRect
        
        switch handle {
        case .topLeft:
            let minX = location.x
            let maxX = boundingRect.maxX
            let minY = location.y
            let maxY = boundingRect.maxY
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        case .topRight:
            let minX = boundingRect.minX
            let maxX = location.x
            let minY = location.y
            let maxY = boundingRect.maxY
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        case .bottomLeft:
            let minX = location.x
            let maxX = boundingRect.maxX
            let minY = boundingRect.minY
            let maxY = location.y
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            break
        case .bottomRight:
            let minX = boundingRect.minX
            let maxX = location.x
            let minY = boundingRect.minY
            let maxY = location.y
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            break
        }
        
        // Keep rectangle within the maximum rect.
        var corrected = CGRectIntersection(maxRect, rectangle)
        
        // Keep rectangle outside the minimum rect.
        corrected = CGRectUnion(corrected, minimumRect(forHandle: handle))
        
        boundingRect = corrected
        
        insetRect = boundingRect.insetBy(dx: -2, dy: -2)
        
        // Now update handles for new bounding rect.
        updateHandles()
    }
    
    /// Calculates the minimum rect size for a drag point handle using the adjacent handle position.
    /// - Parameter handle: The drag point handle.
    /// - Returns: The minimum rect for a handle.
    private func minimumRect(forHandle handle: DragPoint) -> CGRect {
        let maxWidth: CGFloat = 50
        let maxHeight: CGFloat  = 50
        
        switch handle {
        case .topLeft:
            // Anchor is opposite corner.
            return CGRect(
                x: boundingRect.maxX - maxWidth,
                y: boundingRect.maxY - maxHeight,
                width: maxWidth,
                height: maxHeight
            )
        case .topRight:
            return CGRect(
                x: boundingRect.minX,
                y: boundingRect.maxY - maxHeight,
                width: maxWidth,
                height: maxHeight
            )
        case .bottomLeft:
            return CGRect(
                x: boundingRect.maxX - maxWidth,
                y: boundingRect.minY,
                width: maxWidth,
                height: maxHeight
            )
        case .bottomRight:
            return CGRect(
                x: boundingRect.minX,
                y: boundingRect.minY,
                width: maxWidth,
                height: maxHeight
            )
        }
    }
    
    /// Updates the handle locations using the boudning rect.
    private func updateHandles() {
        topRight = CGPoint(x: boundingRect.maxX, y: boundingRect.minY)
        topLeft = CGPoint(x: boundingRect.minX, y: boundingRect.minY)
        bottomLeft = CGPoint(x: boundingRect.minX, y: boundingRect.maxY)
        bottomRight = CGPoint(x: boundingRect.maxX, y: boundingRect.maxY)
    }
    
    /// The handle view for the map area selector.
    struct Handle: View {
        /// The position of the handle.
        let position: CGPoint
        /// The closure to call when the map area selector should be resized.
        let resize: (CGPoint) -> Void
        /// The gesture state of the drag gesture.
        @GestureState var gestureState: State = .started
        /// The types of gesture states.
        enum State {
            case started, changed
        }
        
        var body: some View {
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
    
    /// A view that displays rounded corners for a rectangle view.
    struct RoundedCorners: Shape {
        /// The corner radius.
        let cornerRadius: CGFloat
        /// The padding to add to the corner shape.
        let padding = CGFloat(4)
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            // Add the rounded corners
            path.move(to: CGPoint(x: rect.minX, y: rect.minY + cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.minX + cornerRadius, y: rect.minY), control: CGPoint(x: rect.minX, y: rect.minY))
            
            path.move(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY + cornerRadius + padding), control: CGPoint(x: rect.maxX, y: rect.minY))
            
            path.move(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
            path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius - padding, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
            
            path.move(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), control: CGPoint(x: rect.minX, y: rect.maxY))
            
            return path
        }
    }
}

private extension View {
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

private extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}
