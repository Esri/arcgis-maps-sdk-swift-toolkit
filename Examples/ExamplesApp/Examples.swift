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
            List(listItems, id: \.name, selection: $selectedExample) { item in
                switch item {
                case .category(let name, let examples):
                    DisclosureGroup(name) {
                        ForEach(examples, id: \.name) { example in
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
        // iPadOS and Mac Catalyst so conditionally hide the column.
#if !os(visionOS)
        .onChange(selectedExample) { _ in
            columnVisibility = .detailOnly
        }
#endif
    }
    
    static func makeCategories() -> [ListItem] {
#if os(iOS) && !targetEnvironment(macCatalyst)
        return [.augmentedRealityCategory]
#else
        return []
#endif
    }
    
    static func makeListItems() -> [ListItem] {
        (makeCategories() + makeUncategorizedExamples())
            .sorted(by: { $0.name < $1.name })
    }
    
    static func makeUncategorizedExamples() -> [ListItem] {
        return [
            .example("Basemap Gallery", content: BasemapGalleryExampleView()),
            .example("Bookmarks", content: BookmarksExampleView()),
            .example("Compass", content: CompassExampleView()),
            .example("Feature Editor", content: FeatureEditorExampleView()),
            .example("Feature Form", content: FeatureFormExampleView()),
            .example("Floating Panel", content: FloatingPanelExampleView()),
            .example("Floor Filter", content: FloorFilterExampleView()),
            .example("Overview Map", content: OverviewMapExampleView()),
            .example("Popup", content: PopupExampleView()),
            .example("Scalebar", content: ScalebarExampleView()),
            .example("Search", content: SearchExampleView()),
            .example("Utility Network Trace", content: UtilityNetworkTraceExampleView())
        ]
    }
}

#if os(iOS) && !targetEnvironment(macCatalyst)
extension Examples.ListItem {
    static var augmentedRealityCategory: Self {
        .category(
            "Augmented Reality",
            examples: [
                Example("Flyover", content: FlyoverExampleView()),
                Example("Tabletop", content: TableTopExampleView()),
                Example("World Scale", content: WorldScaleExampleView())
            ]
        )
    }
}
#endif
