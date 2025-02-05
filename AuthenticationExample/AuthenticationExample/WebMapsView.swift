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

import ArcGIS
import SwiftUI

/// A view that displays the web maps of a portal.
struct WebMapsView: View {
    /// The portal from which the web maps can be fetched.
    var portal: Portal
    
    /// A Boolean value indicating whether the featured content is being loaded.
    @State private var isLoading = true
    
    /// The web map portal items.
    @State private var webMapItems = [PortalItem]()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                List(webMapItems, id: \.id) { item in
                    NavigationLink {
                        MapItemView(map: Map(item: item))
                    } label: {
                        PortalItemView(item: item)
                    }
                }
            }
        }
        .task {
            guard webMapItems.isEmpty else { return }
            do {
                // Try to fetch the featured items but if none available then find webmap items.
                var items = try await portal.featuredItems
                    .filter { $0.kind == .webMap }
                if items.isEmpty {
                    items = try await portal.findItems(
                        queryParameters: .items(ofKinds: [.webMap])
                    )
                    .results
                }
                webMapItems = items
            } catch {}
            
            isLoading = false
        }
        .navigationTitle("Web Maps")
    }
}

/// A view that displays information about a portal item for viewing that information within a list.
struct PortalItemView: View {
    /// The portal item to display information about.
    var item: PortalItem
    
    var body: some View {
        HStack {
            if let thumbnail = item.thumbnail {
                LoadableImageView(loadableImage: thumbnail) { image in
                    image
                        .resizable()
                        .frame(width: 64, height: 44)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.headline)
                    .lineLimit(2)
                Text("Owner: \(item.owner), Views: \(item.viewCount)")
                    .font(.caption)
                Text(item.snippet)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
    }
}
