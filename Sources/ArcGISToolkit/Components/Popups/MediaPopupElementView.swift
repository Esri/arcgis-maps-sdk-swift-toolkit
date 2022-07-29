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
import Charts

/// A view displaying a `MediaPopupElement`.
struct MediaPopupElementView: View {
    /// The `PopupElement` to display.
    var popupElement: MediaPopupElement

    var body: some View {
        PopupElementHeader(
            title: popupElement.title,
            description: popupElement.description
        )
        .padding([.bottom], 4)
        PopupMediaView(popupMedia: popupElement.media)
    }
    
    /// A view to display an array of `PopupMedia`.
    struct PopupMediaView: View {
        /// The popup media to display.
        let popupMedia: [PopupMedia]

        var body: some View {
            TabView {
                ForEach(popupMedia) { media in
                    Group {
                        switch media.kind {
                        case .image:
                            ImageMediaView(popupMedia: media)
                        case .barChart,
                                .columnChart,
                                .lineChart,
                                .pieChart:
                            ChartMediaView(popupMedia: media)
                        default:
                            EmptyView()
                        }
                    }
                    .padding(
                        EdgeInsets(
                            top: 8,
                            leading: 8,
                            bottom: popupMedia.count > 1 ? 48: 8,
                            trailing: 8
                        )
                    )
                    .tabItem {
                        Text(media.title)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: popupMedia.count > 1 ? .always : .never))
            .indexViewStyle(
                PageIndexViewStyle(
                    backgroundDisplayMode: .always
                )
            )
            .frame(maxWidth: .infinity, minHeight: 250, maxHeight: .infinity)
//            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 300, maxHeight: .infinity)
        }
    }
}

extension PopupMedia: Identifiable {}
