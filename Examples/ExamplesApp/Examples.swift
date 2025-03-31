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

struct Examples: View {
    /// The categories to display.
    let categories = makeCategories()
    
    /// The category selected by the user.
    @State private var selectedCategory: Category?
    /// The example selected by the user.
    @State private var selectedExample: Example?
    
    var body: some View {
        NavigationSplitView {
            NavigationStack {
                List(categories, id: \.name, selection: $selectedCategory) { category in
                    NavigationLink(category.name) {
                        List(category.examples, id: \.name, selection: $selectedExample) { example in
                            Text(example.name)
                                .tag(example)
                        }
                        .listStyle(.sidebar)
                        .navigationTitle(category.name)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .isDetailLink(false)
                }
                .navigationTitle("Toolkit Examples")
            }
        } detail: {
            NavigationStack {
                if let example = selectedExample {
                    example.view
                        .navigationTitle(example.name)
                        .navigationBarTitleDisplayMode(.inline)
                } else if selectedCategory != nil {
                    Text("Select an example")
                } else {
                    Text("Select a category")
                }
            }
        }
    }
    
    static func makeCategories() -> [Category] {
#if os(iOS) && !targetEnvironment(macCatalyst)
        [.accessories, .augmentedReality, .data, .other]
#else
        [.accessories, .data, .other]
#endif
    }
}

@MainActor
extension Category {
    /// Components that can be used with any geoview.
    static var accessories: Self {
        .init(
            name: "Accessories",
            examples: [
                Example("Basemap Gallery", content: BasemapGalleryExampleView()),
                Example("Compass", content: CompassExampleView()),
                Example("Overview Map", content: OverviewMapExampleView()),
                Example("Scalebar", content: ScalebarExampleView())
            ]
        )
    }
    
#if os(iOS) && !targetEnvironment(macCatalyst)
    /// Augmented reality components.
    static var augmentedReality: Self {
        .init(
            name: "Augmented Reality",
            examples: [
                Example("Flyover", content: FlyoverExampleView()),
                Example("Tabletop", content: TableTopExampleView()),
                Example("World Scale", content: WorldScaleExampleView())
            ]
        )
    }
#endif
    
    /// Components requiring specific data.
    static var data: Self {
        .init(
            name: "Data",
            examples: [
                Example("Bookmarks", content: BookmarksExampleView()),
                Example("Feature Form", content: FeatureFormExampleView()),
                Example("Floor Filter", content: FloorFilterExampleView()),
                Example("Overview Map", content: OverviewMapExampleView()),
                Example("Popup", content: PopupExampleView()),
                Example("Search", content: SearchExampleView()),
                Example("Utility Network Trace", content: UtilityNetworkTraceExampleView())
            ]
        )
    }
    
    /// General purpose components.
    static var other: Self {
        .init(
            name: "Other",
            examples: [
                Example("Floating Panel", content: FloatingPanelExampleView())
            ]
        )
    }
}
