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
    /// The list items to display.
    let listItems = makeListItems()
    
    /// The visibility of the navigation split view's column.
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    /// The example selected by the user.
    @State private var selectedExample: Example?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(listItems, selection: $selectedExample) { item in
                switch item {
                case .category(let category):
                    DisclosureGroup(category.name) {
                        ForEach(category.examples) { example in
                            Text(example.name)
                                .tag(example)
                        }
                    }
                case .example(let example):
                    Text(example.name)
                        .tag(example)
                }
            }
            .navigationTitle("Toolkit Examples")
        } detail: {
            if let selectedExample {
                selectedExample.view
                    .navigationTitle(selectedExample.name)
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                Text("Select an example")
            }
        }
        // visionOS doesn't provide the column visibility toggle like
        // Mac Catalyst and iPadOS so keep the column always visible.
#if !os(visionOS)
        .onChange(selectedExample) { _ in
            columnVisibility = .detailOnly
        }
#endif
    }
    
    static func makeCategories() -> [ListItem] {
#if os(iOS) && !targetEnvironment(macCatalyst)
        return [.category(.augmentedReality)]
#else
        return []
#endif
    }
    
    static func makeListItems() -> [ListItem] {
        (makeCategories() + makeUncategorizedExamples())
            .sorted(by: { $0.id < $1.id })
    }
    
    static func makeUncategorizedExamples() -> [ListItem] { [
        .example(.init("Basemap Gallery", content: BasemapGalleryExampleView())),
        .example(.init("Bookmarks", content: BookmarksExampleView())),
        .example(.init("Compass", content: CompassExampleView())),
        .example(.init("Feature Form", content: FeatureFormExampleView())),
        .example(.init("Floating Panel", content: FloatingPanelExampleView())),
        .example(.init("Floor Filter", content: FloorFilterExampleView())),
        .example(.init("Overview Map", content: OverviewMapExampleView())),
        .example(.init("Popup", content: PopupExampleView())),
        .example(.init("Scalebar", content: ScalebarExampleView())),
        .example(.init("Search", content: SearchExampleView())),
        .example(.init("Utility Network Trace", content: UtilityNetworkTraceExampleView()))
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
