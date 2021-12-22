// Copyright 2021 Esri.

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

/// A row or grid element representing a basemap gallery item.
struct BasemapGalleryCell: View {
    /// The displayed item.
    @ObservedObject var item: BasemapGalleryItem

    /// A Boolean specifying if the item should be displayed ais selected.
    let isSelected: Bool
    
    /// The action executed when the item is selected.
    let onSelection: () -> Void

    var body: some View {
        VStack {
            Button(action: {
                onSelection()
            }, label: {
                VStack {
                    ZStack(alignment: .center) {
                        // Display the thumbnail, if available.
                        if let thumbnailImage = item.thumbnail {
                            Image(uiImage: thumbnailImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .border(
                                    isSelected ? Color.accentColor: Color.clear,
                                    width: 3.0)
                        }
                        
                        // Display an image representing either a load basemap error
                        // or a spatial reference mismatch error.
                        if item.loadBasemapsError != nil {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                        }
                        
                        // Display a progress view if the item is loading.
                        if item.isBasemapLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .esriBorder()
                        }
                    }
                    
                    // Display the name of the item.
                    Text(item.name ?? "")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                }
            })
                .disabled(item.isBasemapLoading)
        }
    }
}
