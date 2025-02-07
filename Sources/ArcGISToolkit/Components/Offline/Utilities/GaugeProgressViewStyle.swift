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

extension ProgressViewStyle where Self == GaugeProgressViewStyle {
    /// A progress view that visually indicates its progress with a gauge.
    static var gauge: Self { .init() }
    
    /// A progress view that visually indicates its progress with a gauge,
    /// and also visually indicates cancel iconography.
    static var cancelGauge: Self { .init(showsCancelIcon: true) }
}

/// A circular gauge progress view style.
struct GaugeProgressViewStyle: ProgressViewStyle {
    var strokeColor = Color.accentColor
    var strokeWidth = 3.0
    var showsCancelIcon = false

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .stroke(.quinary, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
            Circle()
                .trim(from: 0, to: configuration.fractionCompleted ?? 0)
                .stroke(strokeColor, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if showsCancelIcon {
                Rectangle()
                    .fill(Color.accentColor)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(width: 20, height: 20)
        .padding(2)
    }
}
