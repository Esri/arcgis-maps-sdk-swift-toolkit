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
import ArcGIS

/// A view displaying chart popup media.
@available(visionOS, unavailable)
struct ChartMediaView: View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    /// The size of the media's frame.
    let mediaSize: CGSize
    
    /// The data to display in the chart.
    let chartData: [ChartData]
    
    /// Creates a `ChartMediaView`.
    /// - Parameters:
    ///   - popupMedia: The popup media to display.
    ///   - mediaSize: The size of the media's frame.
    init(popupMedia: PopupMedia, mediaSize: CGSize) {
        self.popupMedia = popupMedia
        self.mediaSize = mediaSize
        self.chartData = ChartData.getChartData(from: popupMedia)
    }
    
    /// The corner radius for the view.
    private let cornerRadius: CGFloat = 8
    
    /// A Boolean value specifying whether the media should be drawn in a larger format.
    @State private var isShowingDetailView = false
    
    var body: some View {
        ZStack {
            ChartView(popupMedia: popupMedia, data: chartData)
            VStack {
                Spacer()
                PopupMediaFooter(
                    popupMedia: popupMedia,
                    mediaSize: mediaSize
                )
            }
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(.gray, lineWidth: 1)
                .frame(width: mediaSize.width, height: mediaSize.height)
        }
        .frame(width: mediaSize.width, height: mediaSize.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .onTapGesture {
            isShowingDetailView = true
        }
        .sheet(isPresented: $isShowingDetailView) {
            MediaDetailView(
                popupMedia: popupMedia,
                isShowingDetailView: $isShowingDetailView
            )
            .padding()
        }
    }
}

/// A view describing a chart.
struct ChartView: View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    /// The data to display in the chart.
    let data: [ChartData]
    
    /// A Boolean value specifying whether the chart is being drawn in a larger format.
    let isShowingDetailView: Bool
    
    /// Creates a `ChartView`.
    /// - Parameters:
    ///   - popupMedia: The popup media to display.
    ///   - data: The data to display in the chart.
    ///   - isShowingDetailView: Specifies whether the chart is being drawn in a larger format.
    init(popupMedia: PopupMedia, data: [ChartData], isShowingDetailView: Bool = false) {
        self.popupMedia = popupMedia
        self.data = data
        self.isShowingDetailView = isShowingDetailView
    }
    
    var body: some View {
        switch popupMedia.kind {
        case .barChart, .columnChart:
            BarChart(
                chartData: data,
                isColumnChart: (popupMedia.kind == .columnChart),
                isShowingDetailView: isShowingDetailView
            )
        case .pieChart:
            PieChart(
                chartData: data,
                isShowingDetailView: isShowingDetailView
            )
        case .lineChart:
            LineChart(
                chartData: data,
                isShowingDetailView: isShowingDetailView
            )
        default:
            EmptyView()
        }
    }
}
