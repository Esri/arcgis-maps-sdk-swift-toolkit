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
import ArcGISToolkit

/// A view that displays portal items.
struct PortalItemsView: View {
    var portal: Portal
    @State var isLoading = true
    @State var featuredItems = [PortalItem]()
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                List(featuredItems) { item in
                    NavigationLink {
                        MapItemView(map: Map(item: item))
                    } label: {
                        ItemView(item: item)
                    }
                }
            }
        }
        .task {
            guard featuredItems.isEmpty else { return }
            do {
                featuredItems = try await portal.homePageFeaturedContent
                    .filter { $0.kind == .webMap }
            } catch {}
            
            isLoading = false
        }
        .navigationTitle("Featured Maps")
    }
}

struct ItemView: View {
    var item: PortalItem
    
    var body: some View {
        HStack {
            if let thumbnail = item.thumbnail {
                LoadableImageView(loadableImage: thumbnail)
                    .frame(width: 64, height: 44)
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
