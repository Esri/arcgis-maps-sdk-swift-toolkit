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
}
/// A circular gauge progress view style.
struct GaugeProgressViewStyle: ProgressViewStyle {
    private var strokeStyle: StrokeStyle { .init(lineWidth: 3, lineCap: .round) }
    
    func makeBody(configuration: Configuration) -> some View {
        if let fractionCompleted = configuration.fractionCompleted {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), style: strokeStyle)
                Circle()
                    .trim(from: 0, to: fractionCompleted)
                    .stroke(.gray, style: strokeStyle)
                    .rotationEffect(.degrees(-90))
            }
            .fixedSize()
        }
    }
}
