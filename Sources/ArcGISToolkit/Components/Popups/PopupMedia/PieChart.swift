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
import Charts

/// A view displaying details for popup media.
struct PieChart: View {
    @ObservedObject private var viewModel: PieChartModel
    
    let showLegend: Bool
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    /// A Boolean value denoting if the view should be shown as regular width.
    var isRegularWidth: Bool {
        !(horizontalSizeClass == .compact && verticalSizeClass == .regular)
    }

    init(chartData: [ChartData], showLegend: Bool = false) {
        self.showLegend = showLegend
        _viewModel = ObservedObject(wrappedValue: PieChartModel(chartData: chartData))
    }
    
    var body: some View {
        Pie(viewModel: viewModel)
            .padding()
        if showLegend {
            makeLegend(slices: viewModel.pieSlices)
        }
    }
    
    @ViewBuilder func makeLegend(slices: [PieSlice]) -> some View {
        LazyVGrid(
            columns: Array(
                repeating: GridItem(.flexible(), alignment: .top),
                count: isRegularWidth ? 3 : 2
            )
        ) {
            ForEach(slices) { slice in
                HStack {
                    Rectangle()
                        .stroke(.gray, lineWidth: 1)
                        .frame(width: 20, height: 20)
                        .background(slice.color)
                    Text(slice.name)
                        .font(.footnote)
                    Spacer()
                }
            }
        }
    }
}

struct Pie: View {
    @ObservedObject private var viewModel: PieChartModel

    init(viewModel: PieChartModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            let radius = min(geometry.size.width, geometry.size.height) / 2.0
            let center = CGPoint(
                x: geometry.size.width / 2.0,
                y: geometry.size.height / 2.0
            )
            var startAngle: Double = -90
            ForEach(viewModel.pieSlices, id: \.self) { slice in
                let endAngle = startAngle + slice.fraction * 360.0
                let path = Path { pieChart in
                    pieChart.move(to: center)
                    pieChart.addArc(
                        center: center,
                        radius: radius,
                        startAngle: .degrees(startAngle),
                        endAngle: .degrees(endAngle),
                        clockwise: false
                    )
                    
                    pieChart.closeSubpath()
                    startAngle = endAngle
                }
                path.fill(slice.color)
                path.stroke(.gray, lineWidth: 1)
            }
        }
    }
}
