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
import ArcGIS

/// A view displaying chart popup media.
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
        self.chartData = ChartData.getChartData(popupMedia: popupMedia)
    }
    
    /// A Boolean value specifying whether the media should be shown full screen.
    @State private var isShowingDetailView = false
    
    /// The corner radius for the view.
    private let cornerRadius: CGFloat = 8

    var body: some View {
        if #available(iOS 16, *) {
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
                    isShowingDetalView: $isShowingDetailView
                )
                .padding()
            }
        }
    }
}

@available(iOS 16, *)
/// A view describing a chart.
struct ChartView: View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    /// The data to display in the chart.
    let data: [ChartData]
    
    /// A Boolean value specifying whether the chart is being draw full screen.
    let isFullScreen: Bool
    
    /// Creates a `ChartView`.
    /// - Parameters:
    ///   - popupMedia: The popup media to display.
    ///   - data: The data to display in the chart.
    ///   - isFullScreen: Specifies whether the chart is being draw full screen.
    init(popupMedia: PopupMedia, data: [ChartData], isFullScreen: Bool = false) {
        self.popupMedia = popupMedia
        self.data = data
        self.isFullScreen = isFullScreen
    }
    
    var body: some View {
        switch popupMedia.kind {
        case .barChart, .columnChart:
            BarChart(chartData: data, isColumnChart: (popupMedia.kind == .columnChart))
        case .pieChart:
            PieChart(chartData: data, showLegend: isFullScreen)
        case .lineChart:
            LineChart(chartData: data)
        default:
            EmptyView()
        }
    }
}
