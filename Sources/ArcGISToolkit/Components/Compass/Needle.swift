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

/// Represents the spinning needle at the center of the compass.
struct Needle: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        NeedleQuadrant(color: .lightRed)
                        NeedleQuadrant(color: .darkRed)
#if os(visionOS)
                            .perspectiveRotationEffect(
                                .degrees(180),
                                axis: (x: 0, y: 1, z: 0)
                            )
#else
                            .rotation3DEffect(
                                .degrees(180),
                                axis: (x: 0, y: 1, z: 0)
                            )
#endif
                    }
                    HStack(spacing: 0) {
                        NeedleQuadrant(color: .lightGray)
#if os(visionOS)
                            .perspectiveRotationEffect(
                                .degrees(180),
                                axis: (x: 1, y: 0, z: 0)
                            )
#else
                            .rotation3DEffect(
                                .degrees(180),
                                axis: (x: 1, y: 0, z: 0)
                            )
#endif
                        NeedleQuadrant(color: .darkGray)
#if os(visionOS)
                            .perspectiveRotationEffect(
                                .degrees(180),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .perspectiveRotationEffect(
                                .degrees(180),
                                axis: (x: 1, y: 0, z: 0)
                            )
#else
                            .rotation3DEffect(
                                .degrees(180),
                                axis: (x: 0, y: 1, z: 0)
                            )
                            .rotation3DEffect(
                                .degrees(180),
                                axis: (x: 1, y: 0, z: 0)
                            )
#endif
                    }
                }
                NeedleCenter()
            }
            .aspectRatio(1/3, contentMode: .fit)
            .frame(
                width: min(geometry.size.width, geometry.size.height),
                height: min(geometry.size.width, geometry.size.height)
            )
            .scaleEffect(0.6)
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}

/// Represents the center of the spinning needle at the center of the compass.
struct NeedleCenter: View {
    var body: some View {
        Circle()
            .scale(0.25)
            .foregroundStyle(Color.bronze)
    }
}

/// Represents 1/4 (one triangle) of the spinning needle at the center of the compass.
struct NeedleQuadrant: View {
    /// The color of this needle quadrant.
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                path.move(to: CGPoint(x: 0, y: height))
                path.addLine(to: CGPoint(x: width, y: 0))
                path.addLine(to: CGPoint(x: width, y: height))
            }
            .fill(color)
        }
    }
}

private extension Color {
    /// The bronze color of the center of the compass needle.
    static let bronze = Color(red: 241, green: 169, blue: 59)
    
    /// The dark gray color of the compass needle.
    static let darkGray = Color(red: 128, green: 128, blue: 128)
    
    /// The dark red color of the compass needle.
    static let darkRed = Color(red: 124, green: 22, blue: 13)
    
    /// The light gray color of the compass needle.
    static let lightGray = Color(red: 169, green: 168, blue: 168)
    
    /// The light red color of the compass needle.
    static let lightRed = Color(red: 233, green: 51, blue: 35)
}
