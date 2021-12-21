//
//  SwiftUIView.swift
//  
//
//  Created by Mark Dostal on 12/17/21.
//

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
            .disabled(item.basemap.loadStatus != .loaded)
        }
    }
}
