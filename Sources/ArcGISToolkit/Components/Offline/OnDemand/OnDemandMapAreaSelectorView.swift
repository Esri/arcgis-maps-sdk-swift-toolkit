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
    
    let mapViewProxy: MapViewProxy

    let envelope: Envelope
    
    let cordnerRadius: CGFloat = 16

    @State var boundingRect: CGRect
    
    @State var insetRect: CGRect = .zero
    
    @State private var initialRect: CGRect = .zero
    
    let minimumSize = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        
    @State private var topLeft: CGPoint = .zero
    
    @State private var topRight: CGPoint = .zero
    
    @State private var bottomLeft: CGPoint = .zero
    
    @State private var bottomRight: CGPoint = .zero
    
    enum DragPoint {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    init(mapViewProxy: MapViewProxy, envelope: Envelope) {
        self.mapViewProxy = mapViewProxy
        self.envelope = envelope
        self.boundingRect = mapViewProxy.viewRect(fromEnvelope: envelope) ?? minimumSize
    }
    
    var body: some View {
        ZStack {
            ZStack {
                RoundedRectangle(cornerRadius: cordnerRadius, style: .continuous)
                    .fill(.black.opacity(0.10))
                    .reverseMask {
                        RoundedRectangle(cornerRadius: cordnerRadius, style: .continuous)
                            .frame(width: boundingRect.width, height: boundingRect.height)
                            .position(boundingRect.center)
                        
                    }
                RoundedRectangleWithRoundedCorners(cornerRadius: cordnerRadius, style: .continuous)
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
            .task {
                initialRect = boundingRect
                insetRect = boundingRect.insetBy(dx: -2, dy: -2)
                updateHandles()
            }
            
            Handle(position: topLeft, color: .blue) {
                resize(for: .topLeft, location: $0)
            }
            
            Handle(position: topRight, color: .green) {
                resize(for: .topRight, location: $0)
            }
            
            Handle(position: bottomLeft, color: .yellow) {
                resize(for: .bottomLeft, location: $0)
            }
            
            Handle(position: bottomRight, color: .pink) {
                resize(for: .bottomRight, location: $0)
            }
        }
    }
    
    private func validate(rect: CGRect) -> Bool {
        if rect.width < 50 || rect.height < 50 {
            return false
        }
        
        if rect.width > initialRect.width || rect.height > initialRect.height {
            return false
        }
        return true
    }
    
    private func resize(for handle: DragPoint, location: CGPoint) -> Void {
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
        case .bottomRight:
            let minX = boundingRect.minX
            let maxX = location.x
            let minY = boundingRect.minY
            let maxY = location.y
            rectangle = CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
        }
        
        // Validate proposed resized rectangle.
        guard validate(rect: rectangle) else { return }
        
        // Update bounding rect for valid proposed resize.
        boundingRect = rectangle
        
        insetRect = boundingRect.insetBy(dx: -2, dy: -2)
        
        // Now update handles for new bounding rect.
        updateHandles()
    }
    
    private func updateHandles() {
        topRight = CGPoint(x: boundingRect.maxX, y: boundingRect.minY)
        topLeft = CGPoint(x: boundingRect.minX, y: boundingRect.minY)
        bottomLeft = CGPoint(x: boundingRect.minX, y: boundingRect.maxY)
        bottomRight = CGPoint(x: boundingRect.maxX, y: boundingRect.maxY)
    }
    
    struct Handle: View {
        let position: CGPoint
        let color: Color
        let resize: (CGPoint) -> Void
        
        var body: some View {
            Color.clear
                .contentShape(Rectangle())
                .frame(width: 44, height: 44)
                .position(position)
                .gesture(DragGesture(coordinateSpace: .local)
                    .onChanged { value in
                        resize(value.location)
                    }
                )
        }
    }
    
    struct RoundedRectangleWithRoundedCorners: Shape {
        var cornerRadius: CGFloat
        
        var style: RoundedCornerStyle
        
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
    public func reverseMask<Mask: View>(
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
