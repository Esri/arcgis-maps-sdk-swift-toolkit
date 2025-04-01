// Copyright 2021 Esri
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

/// A row or grid element representing a basemap gallery item.
struct BasemapGalleryCell: View {
    /// The displayed item.
    @ObservedObject var item: BasemapGalleryItem
    
    /// A Boolean value indicating whether the item should be displayed is selected.
    let isSelected: Bool
    
    /// The action executed when the item is selected.
    let onSelection: () -> Void
    
    var body: some View {
        Button {
            onSelection()
        } label: {
            VStack {
                ZStack(alignment: .center) {
                    // Display the thumbnail, if available.
                    if let thumbnailImage = item.thumbnail {
                        Group {
                            Image(uiImage: thumbnailImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(.rect(cornerRadius: 8))
                                .overlay(make3DBadge(), alignment: .topLeading)
                                .overlay(makeOverlay())
                        }
                        .padding(.all, 4)
                    }
                    
                    // Display a progress view if the item is loading.
                    if item.isBasemapLoading {
                        makeProgressView()
                    }
                }
                
                // Display the name of the item.
                Text(item.name ?? "")
                    .font(.basemapGallery)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(item.hasError ? .secondary : .primary)
            }
#if os(visionOS)
            .contentShape(.hoverEffect, .rect(cornerRadius: 12))
            .hoverEffect()
#endif
        }
        .buttonStyle(.plain)
        .disabled(item.isBasemapLoading)
    }
    
    /// Creates a badge which indicates the basemap supports 3D visualization.
    /// - Returns: A 3D badge overlay view.
    @ViewBuilder private func make3DBadge() -> some View {
        if item.is3D {
            Text(
                "3D",
                bundle: .toolkitModule,
                comment: "A reference to 3D content."
            )
            .font(.basemapGallery)
            .foregroundStyle(item.hasError ? .secondary : .primary)
            .padding(2.5)
            .background(Material.regular)
            .cornerRadius(5)
            .padding(2.5)
        }
    }
    
    /// Creates an overlay which is either a selection outline or an error icon.
    /// - Returns: A thumbnail overlay view.
    @ViewBuilder private func makeOverlay() -> some View {
        if item.hasError {
            HStack {
                Spacer()
                VStack {
                    ZStack {
                        // For a white background behind the exclamation mark.
                        Circle()
                            .foregroundStyle(.white)
                            .frame(width: 16, height: 16)
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundStyle(.red)
                            .frame(width: 32, height: 32)
                    }
                    Spacer()
                }
            }
            .padding(.all, -10)
        } else {
            RoundedRectangle(cornerRadius: 8)
                .stroke(lineWidth: isSelected ? 2 : 0)
                .foregroundStyle(Color.accentColor)
        }
    }
    
    /// Creates a circular progress view with a rounded rectangle background.
    /// - Returns: A new progress view.
    private func makeProgressView() -> some View {
        ProgressView()
            .progressViewStyle(.circular)
            .padding(EdgeInsets(
                top: 8,
                leading: 12,
                bottom: 8,
                trailing: 12)
            )
            .background(Color(uiColor: .systemBackground))
            .clipShape(.rect(cornerRadius: 8))
    }
}

extension BasemapGalleryItem {
    /// A Boolean value indicating whether the item has an error.
    var hasError: Bool {
        loadBasemapError != nil ||
        spatialReferenceStatus == .noMatch
    }
}

private extension Font {
    static var basemapGallery: Self {
        custom("AvenirNext-Regular", fixedSize: 12)
    }
}
