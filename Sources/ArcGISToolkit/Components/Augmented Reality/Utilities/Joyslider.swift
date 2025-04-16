// Copyright 2024 Esri
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

/// A slider that acts similar to a joystick controller.
/// The slider provides delta values as they change between -1...1.
struct Joyslider: View {
    private var onChangedAction: ((Double) -> Void)?
    private var onEndedAction: (() -> Void)?
    
    /// The x offset of the thumb in points.
    @State private var offset: Double = 0
    /// A factor between -1 and 1 that specifies the current percentage of the thumb's position.
    @State private var factor: Double = 0
    /// A Boolean value indicating if the user is dragging the thumb.
    @State private var isChanging = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Track(offset: offset, factor: factor)
                Thumb()
                    .offset(x: offset)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                isChanging = true
                                
                                let halfWidth = (geometry.size.width / 2)
                                offset = value.translation.width.clamped(to: -halfWidth...halfWidth)
                                factor = offset / halfWidth
                            }
                            .onEnded { _ in
                                isChanging = false
                                withAnimation(.bouncy.speed(1.5)) {
                                    offset = 0
                                }
                                onEndedAction?()
                            }
                    )
            }
        }
        .frame(height: Thumb.size + 4)
        .task(id: isChanging) {
            // This task block executes whenever isChanging property changes.
            // If isChanging is `false`, then return.
            guard isChanging else { return }
            // Run a loop while the Task is not cancelled.
            while !Task.isCancelled {
                // Sleep for 50 milliseconds.
                try? await Task.sleep(for: .milliseconds(50))
                // If task is cancelled after sleeping, return.
                if Task.isCancelled { return }
                // Otherwise change the value.
                onChangedAction?(factor)
            }
        }
    }
    
    /// Specifies an action to perform when the value changes.
    func onChanged(perform action: @escaping (Double) -> Void) -> Joyslider {
        var copy = self
        copy.onChangedAction = action
        return copy
    }
    
    /// Specifies an action to perform when the value stops changing.
    func onEnded(perform action: @escaping () -> Void) -> Joyslider {
        var copy = self
        copy.onEndedAction = action
        return copy
    }
}

/// Thumb view for the joyslider.
private struct Thumb: View {
    /// The size of the thumb.
    static let size: Double = 26
    
    var body: some View {
        Circle()
            .stroke(Color.accentColor, lineWidth: 2)
            .frame(width: Self.size, height: Self.size)
            .background {
                Circle()
                    .frame(width: Self.size, height: Self.size)
                    .foregroundStyle(.background)
                    .shadow(color: .secondary.opacity(0.5), radius: 5, x: 0, y: 2)
            }
    }
}

/// Track view for the joyslider.
private struct Track: View {
    /// The x offset of the thumb in points.
    let offset: Double
    /// A factor between -1 and 1 that specifies the current percentage of the thumb's position.
    let factor: Double
    
    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(Color.systemFill)
            if offset != 0 {
                Capsule(style: .continuous)
                    .fill(fill)
                    .frame(width: abs(offset))
                    .offset(x: offset / 2)
            }
        }
        .frame(height: 4)
    }
    
    var fill: some ShapeStyle {
        if offset >= 0 {
            return LinearGradient(
                gradient: Gradient(colors: [.clear, .accentColor]),
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [.clear, .accentColor]),
                startPoint: .trailing,
                endPoint: .leading
            )
        }
    }
}

private extension Color {
    /// The system fill color.
    static var systemFill: Color { Color(UIColor.systemFill) }
}
