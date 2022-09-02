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

final class PieChartModel: ObservableObject {
    let pieSlices: [PieSlice]
    
    init(chartData: [ChartData]) {
        var slices = [PieSlice]()
        var dataTotal: Double = 0
        _ = chartData.map { dataTotal += $0.value }
        for i in 0..<chartData.count {
            slices.append(
                PieSlice(
                    fraction: chartData[i].value / dataTotal,
                    color: PieChartModel.color(for: i),
                    name: chartData[i].label
                )
            )
        }
        pieSlices = slices
    }
    
    static var sliceColors: [Color] = [
        .mint,
        .teal,
        .green,
        .cyan,
        .yellow,
        .blue,
        .orange,
        .indigo,
        .red,
        .purple,
        .pink,
        .brown
    ]
    
    static func color(for index: Int) -> Color {
        // We don't want to just wrap color indices because we don't want
        // two adjacent slices to have the same color.  "extra" will skip the
        // the first color for the 2nd time through the list, skip the second
        // color the second time through the list, etc.
        let extra = index / sliceColors.count
        return sliceColors[(index + extra) % sliceColors.count].opacity(0.75)
    }
}

class PieSlice: Identifiable {
    let fraction: Double
    let color: Color
    let name: String
    
    init(fraction: Double, color: Color, name: String) {
        self.fraction = fraction
        self.color = color
        self.name = name
    }
}

extension PieSlice: Equatable {
    static func == (lhs: PieSlice, rhs: PieSlice) -> Bool {
        lhs.fraction == rhs.fraction &&
        lhs.color == rhs.color &&
        lhs.name == rhs.name
    }
}

extension PieSlice: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.fraction)
        hasher.combine(self.color)
        hasher.combine(self.name)
    }
}
