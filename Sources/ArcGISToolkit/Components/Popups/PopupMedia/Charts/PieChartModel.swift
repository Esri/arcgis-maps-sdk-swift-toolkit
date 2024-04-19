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

/// The view model for pie charts.
final class PieChartModel: ObservableObject {
    /// The slices that make up the pie chart.
    let pieSlices: [PieSlice]
    
    /// Creates a `PieChartModel`
    /// - Parameter chartData: The data used for the pie chart.
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
    
    /// The pre-defined colors for the pie slices.
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
    
    /// Calculates a slice color for the given slice index.
    /// - Parameter index: The index of the slice.
    /// - Returns: The color for the slice at `index`.
    static func color(for index: Int) -> Color {
        // We don't want to just wrap color indices because we don't want
        // two adjacent slices to have the same color. "extra" will skip the
        // the 1st color for the second time through the list, skip the 2nd
        // color the third time through the list, etc., ensuring that we
        // don't get adjacent colors.
        let extra = index / sliceColors.count
        return sliceColors[(index + extra) % sliceColors.count].opacity(0.75)
    }
}

/// A single slice of a pie chart.
final class PieSlice: Identifiable {
    /// The fraction of the whole the slice represents.
    let fraction: Double
    
    /// The color of the slice.
    let color: Color
    
    /// The name of the slice.
    let name: String
    
    /// Creates a `PieSlice`.
    /// - Parameters:
    ///   - fraction: The fraction of the whole the slice represents.
    ///   - color: The color of the slice.
    ///   - name: The name of the slice.
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
