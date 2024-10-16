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

/// A view displaying a popup media in a large format.
@available(visionOS, unavailable)
struct MediaDetailView : View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    /// A Boolean value specifying whether the media should be drawn in a larger format.
    var isShowingDetailView: Binding<Bool>
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isShowingDetailView.wrappedValue = false
                } label: {
                    Text.done
                        .fontWeight(.semibold)
                }
                .padding([.bottom], 4)
            }
            HStack {
                VStack(alignment: .leading) {
                    Text(popupMedia.title)
                        .font(.title2)
                    Text(popupMedia.caption)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            switch popupMedia.kind {
            case .image:
                if let sourceURL = popupMedia.value?.sourceURL {
                    AsyncImageView(
                        url: sourceURL,
                        refreshInterval: popupMedia.imageRefreshInterval
                    )
                    .onTapGesture {
                        if let linkURL = popupMedia.value?.linkURL {
                            UIApplication.shared.open(linkURL)
                        }
                    }
                    if popupMedia.value?.linkURL != nil {
                        HStack {
                            Text(
                                "Tap on the image for more information.",
                                bundle: .toolkitModule,
                                comment: """
                                         A label indicating that tapping an image will reveal
                                         additional information.
                                         """
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
            case .barChart, .columnChart, .pieChart, .lineChart:
                ChartView(
                    popupMedia: popupMedia,
                    data: ChartData.getChartData(from: popupMedia),
                    isShowingDetailView: true
                )
            default:
                EmptyView()
            }
            Spacer()
        }
    }
}
