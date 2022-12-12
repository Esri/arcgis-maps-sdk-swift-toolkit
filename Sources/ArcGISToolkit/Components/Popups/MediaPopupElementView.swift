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

/// A view displaying a `MediaPopupElement`.
struct MediaPopupElementView: View {
    /// The `PopupElement` to display.
    var popupElement: MediaPopupElement
    
    @State var isExpanded: Bool = true
    
    var body: some View {
        if displayableMediaCount > 0 {
            DisclosureGroup(isExpanded: $isExpanded) {
                Divider()
                    .padding(.bottom, 4)
                PopupMediaView(
                    popupMedia: popupElement.media,
                    displayableMediaCount: displayableMediaCount
                )
            } label: {
                VStack(alignment: .leading) {
                    PopupElementHeader(
                        title: popupElement.displayTitle,
                        description: popupElement.description
                    )
                }
            }
            Divider()
        }
    }
    
    /// The number of popup media that can be displayed. The count includes
    /// all image media and chart media when running on iOS 16 or newer.
    var displayableMediaCount: Int {
#if canImport(Charts)
        let buildsWithMacCatalyst16 = true
#else
        let buildsWithMacCatalyst16 = false
#endif
        if #available(iOS 16, macCatalyst 16, *),
           buildsWithMacCatalyst16 {
            // Include all images and charts.
            return popupElement.media.count
        } else {
            // Only include image media.
            let imageMedia = popupElement.media.filter { $0.kind == .image }
            return imageMedia.count
        }
    }
    
    /// A view displaying an array of `PopupMedia`.
    struct PopupMediaView: View {
        /// The popup media to display.
        let popupMedia: [PopupMedia]
        
        /// The number of popup media that can be displayed.
        let displayableMediaCount: Int
        
        /// The width of the view content.
        @State private var width: CGFloat = .zero
        
        var body: some View {
            ScrollView(.horizontal) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(popupMedia) { media in
                        Group {
                            switch media.kind {
                            case .image:
                                ImageMediaView(
                                    popupMedia: media,
                                    mediaSize: mediaSize
                                )
                            case .barChart, .columnChart, .lineChart, .pieChart:
                                ChartMediaView(
                                    popupMedia: media,
                                    mediaSize: mediaSize
                                )
                            default:
                                EmptyView()
                            }
                        }
                        .frame(width: mediaSize.width, height: mediaSize.height)
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .onSizeChange {
                width = $0.width * widthScaleFactor
            }
        }
        
        /// The scale factor for specifying the width of popup media.  If there is only one popup media,
        /// the scale is 1.0 (full width); if there is more than one, the scale is 0.85, which allows for
        /// second and subsequent media to be partially visible, to indicate there is more than one.
        var widthScaleFactor: Double {
            get {
                displayableMediaCount > 1 ? 0.75 : 1
            }
        }
        
        /// The size of the image or chart media.
        var mediaSize: CGSize {
            CGSize(width: width, height: 200)
        }
    }
}

extension PopupMedia: Identifiable {}

private extension MediaPopupElement {
    /// Provides a default title to display if `title` is empty.
    var displayTitle: String {
        title.isEmpty ? "Media" : title
    }
}
