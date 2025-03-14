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

import Charts
import SwiftUI

/// A view displaying details for bar chart popup media.
struct BarChart: View {
    /// The chart data to display.
    let chartData: [ChartData]
    
    /// A Boolean value specifying whether the chart is a "column" chart, with vertical bars. If it's
    /// not a "column" chart, then the bars are horizontal.
    let isColumnChart: Bool
    
    /// A Boolean value determining whether to show the x axis labels for the chart.
    let showXAxisLabels: Bool
    
    /// Creates a `BarChart`.
    /// - Parameters:
    ///   - chartData: The data to display in the chart.
    ///   - isColumnChart: Specifying whether the chart is a "column" chart, with vertical bars.
    ///   - isShowingDetailView: Specifies whether the chart is being drawn in a larger format.
    init(chartData: [ChartData], isColumnChart: Bool, isShowingDetailView: Bool = false) {
        self.chartData = chartData
        self.isColumnChart = isColumnChart
        
        // Only show the x axis labels if we're being shown in a detail view.
        showXAxisLabels = isShowingDetailView
    }
    
    var body: some View {
        Chart(chartData) {
            if isColumnChart {
                // Vertical bars.
                BarMark(
                    x: .value(String.field, $0.label),
                    y: .value(String.value, $0.value)
                )
                .foregroundStyle(Color($0.color))
            } else {
                // Horizontal bars.
                BarMark(
                    x: .value(String.value, $0.value),
                    y: .value(String.field, $0.label)
                )
                .foregroundStyle(Color($0.color))
            }
        }
        .chartXAxis {
            AxisMarks { _ in
                if showXAxisLabels {
                    AxisValueLabel(
                        collisionResolution: .greedy,
                        orientation: .verticalReversed
                    )
                }
            }
        }
    }
}
