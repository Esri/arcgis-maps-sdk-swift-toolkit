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

public enum PartialSheetPreset {
    case min, mid, max
}

/// A partial sheet is a view that overlays a view and supplies view-related
/// content.
///
/// A partial sheet offers an advantage over a native sheet in that it allows user interaction with any view
/// behind it.
public struct PartialSheet<Content: View>: View {
    /// Records the drag gesture for new height calculations.
    @State private var dragTranslation: CGFloat = .zero
    
    /// The color of the handle.
    @State private var handleColor: Color = .defaultHandleColor
    
    /// Allows the user to drag the sheet to a specific height.
    @State private var yOffset: CGFloat = 0
    
    /// Allows the parent to control the height of the sheet.
    @Binding var preset: PartialSheetPreset?
    
    /// The content shown in the partial sheet.
    private let content: Content
    
    /// Creates a `PartialSheet`
    /// - Parameter content: The view shown in the partial sheet.
    public init(preset: Binding<PartialSheetPreset?>, @ViewBuilder content: () -> Content) {
        self.content = content()
        _preset = preset
    }
    
    /// Determines the current height of the sheet, either from the preset value or `yOffset`.
    private func heightFromPreset(with geometryProxy: GeometryProxy) -> CGFloat {
        switch preset {
        case .min:
            return 200.0
        case .mid:
            return geometryProxy.size.height / 2.0
        case .max:
            return geometryProxy.size.height - 50.0
        default:
            return yOffset
        }
    }
    
    public var body: some View {
        GeometryReader { geometryProxy in
            return VStack {
                Handle(color: handleColor)
                    .padding()
                    .gesture(drag)
                content
            }
            .frame(maxWidth: .infinity)
            .frame(height: heightFromPreset(with: geometryProxy))
            .background(Color(uiColor: .systemGroupedBackground))
            .cornerRadius(
                15,
                corners: [.topLeft, .topRight]
            )
            .shadow(radius: 10)
            .frame(
                maxHeight: .infinity,
                alignment: .bottom
            )
            .edgesIgnoringSafeArea(.bottom)
            .animation(.default, value: preset)
            .onChange(of: dragTranslation) { newValue in
                preset = nil
                yOffset = max(
                    200,
                    min(
                        geometryProxy.size.height - 50,
                        yOffset - newValue
                    )
                )
            }
        }
    }
    
    private var drag: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                handleColor = .activeHandleColor
                dragTranslation = value.translation.height
            }
            .onEnded { _ in
                handleColor = .defaultHandleColor
            }
    }
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
