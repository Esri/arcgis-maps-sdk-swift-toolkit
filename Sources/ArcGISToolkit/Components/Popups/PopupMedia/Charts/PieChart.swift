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

/// A view displaying details for pie chart popup media.
struct PieChart: View {
    /// The chart data to display.
    let chartData: [ChartData]
    
    /// A Boolean value determining whether to show the legend for the chart.
    let showLegend: Bool
    
    /// Creates a `PieChart`.
    /// - Parameters:
    ///   - chartData: The data to display in the chart.
    ///   - isShowingDetailView: Specifies whether the chart is being drawn in a larger format.
    init(chartData: [ChartData], isShowingDetailView: Bool = false) {
        self.chartData = chartData
        
        // Only show the legend if we're being shown in a detail view.
        showLegend = isShowingDetailView
    }
    
    var body: some View {
        Chart(chartData) {
            SectorMark(angle: .value(.value, $0.value))
                .foregroundStyle(by: .value(.label, $0.label))
        }
        .chartForegroundStyleScale(range: chartData.map { Color($0.color) })
        .chartLegend(showLegend ? .automatic : .hidden)
        .padding()
    }
}

private extension Text {
    /// A label for a `SectorMark` angle value.
    static var value: Self {
        .init(
            "Value",
            bundle: .toolkitModule,
            comment: "A label for the value of a pie chart slice."
        )
    }
    
    /// A label for a `SectorMark` foreground style value.
    static var label: Self {
        .init(
            "Label",
            bundle: .toolkitModule,
            comment: "A label for a pie chart legend item label."
        )
    }
}
