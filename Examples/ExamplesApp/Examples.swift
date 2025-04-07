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
    /// The menu items to display.
    let menuItems = makeMenuItems()
    
    var body: some View {
        NavigationSplitView {
            NavigationStack {
                List(menuItems, id: \.name) { item in
                    if let category = item as? Category {
                        NavigationLink(category.name) {
                            List(category.examples, id: \.name) { example in
                                makeExampleLink(example)
                            }
                            .listStyle(.sidebar)
                            .navigationTitle(category.name)
                            .navigationBarTitleDisplayMode(.inline)
                        }
                        .isDetailLink(false)
                    } else if let example = item as? Example {
                        makeExampleLink(example)
                    }
                }
            }
        } detail: {
            Text("Select a example")
        }
    }
    
    func makeExampleLink(_ example: Example) -> some View {
        NavigationLink(
            example.name,
            destination: example.view
                .navigationTitle(example.name)
                .navigationBarTitleDisplayMode(.inline)
        )
        .isDetailLink(true)
    }
    
    static func makeCategories() -> [Category] {
#if os(iOS) && !targetEnvironment(macCatalyst)
        return [.augmentedReality]
#else
        return []
#endif
    }
    
    static func makeMenuItems() -> [any MenuItem] {
        (makeCategories() + makeUncategorizedExamples())
            .sorted(by: { $0.name < $1.name })
    }
    
    static func makeUncategorizedExamples() -> [Example] { [
        Example("Basemap Gallery", content: BasemapGalleryExampleView()),
        Example("Bookmarks", content: BookmarksExampleView()),
        Example("Compass", content: CompassExampleView()),
        Example("Feature Form", content: FeatureFormExampleView()),
        Example("Floating Panel", content: FloatingPanelExampleView()),
        Example("Floor Filter", content: FloorFilterExampleView()),
        Example("Overview Map", content: OverviewMapExampleView()),
        Example("Popup", content: PopupExampleView()),
        Example("Scalebar", content: ScalebarExampleView()),
        Example("Search", content: SearchExampleView()),
        Example("Utility Network Trace", content: UtilityNetworkTraceExampleView())
    ] }
}

@MainActor
extension Category {
#if os(iOS) && !targetEnvironment(macCatalyst)
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
}
