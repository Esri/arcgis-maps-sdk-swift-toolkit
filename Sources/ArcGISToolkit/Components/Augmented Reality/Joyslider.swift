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

struct Joyslider: View {
    var onValueChangedAction: ((Double) -> Void)?
    
    @State private var offset: Double = 0
    @State private var factor: Double = 0
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
                                offset = max(min(value.translation.width, halfWidth), -halfWidth)
                                factor = offset / halfWidth
                            }
                            .onEnded { _ in
                                isChanging = false
                                withAnimation(.bouncy) {
                                    offset = 0
                                }
                            }
                    )
            }
        }
        .frame(height: Thumb.size + 4)
        .task(id: isChanging) {
            guard isChanging else { return }
            while !Task.isCancelled {
                if #available(iOS 17, *) {
                    try? await Task.sleep(for: .milliseconds(50))
                } else {
                    try? await Task.sleep(nanoseconds: 50_000_000)
                }
                if Task.isCancelled { return }
                let change = factor
                onValueChangedAction?(change)
            }
        }
    }
    
    func onValueChanged(perform action: @escaping (Double) -> Void) -> Joyslider {
        var copy = self
        copy.onValueChangedAction = action
        return copy
    }
}

private struct Thumb: View {
    static let size: Double = 26
    var body: some View {
        Circle()
            .stroke(Color.accentColor, lineWidth: 2)
            .foregroundStyle(.background)
            .frame(width: Self.size, height: Self.size)
            .background {
                Circle()
                    .frame(width: Self.size, height: Self.size)
                    .foregroundStyle(.background)
                    .shadow(color: .secondary.opacity(0.5), radius: 5, x: 0, y: 2)
            }
    }
}

private struct Track: View {
    let offset: Double
    let factor: Double
    
    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(Color.systemFill)
            if offset != 0 {
                Capsule(style: .continuous)
                    .fill(fill)
                    .frame(width: abs(offset))
                    .offset(x: offset/2)
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
    static var systemFill: Color { Color(UIColor.systemFill) }
}

#Preview {
    VStack {
        Slider(value: .constant(0.5))
        Joyslider()
        Slider(value: .constant(0.5))
    }
    .padding()
}
