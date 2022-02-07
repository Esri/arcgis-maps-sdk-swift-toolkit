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

/// Represents the spinning needle at the center of the compass.
struct Needle: View {
    /// The dark gray color of the compass needle.
    private let grayDark = Color(red: 128, green: 128, blue: 128)

    /// The light gray color of the compass needle.
    private let grayLight = Color(red: 169, green: 168, blue: 168)

    /// The dark red color of the compass needle.
    private let redDark = Color(red: 124, green: 22, blue: 13)

    /// The light red color of the compass needle.
    private let redLight = Color(red: 233, green: 51, blue: 35)

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    NeedleQuadrant(color: redLight)
                    NeedleQuadrant(color: redDark)
                        .rotation3DEffect(
                            Angle(degrees: 180),
                            axis: (x: 0, y: 1, z: 0))
                }
                HStack(spacing: 0) {
                    NeedleQuadrant(color: grayLight)
                        .rotation3DEffect(
                            Angle(degrees: 180),
                            axis: (x: 1, y: 0, z: 0))
                    NeedleQuadrant(color: grayDark)
                        .rotation3DEffect(
                            Angle(degrees: 180),
                            axis: (x: 0, y: 1, z: 0))
                        .rotation3DEffect(
                            Angle(degrees: 180),
                            axis: (x: 1, y: 0, z: 0))
                }
            }
            NeedleCenter()
        }
        .aspectRatio(1.0/3.0, contentMode: .fit)
        .scaleEffect(0.6)
    }
}
