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
    /// The list of example lists.  Allows for a hierarchical navigation model for examples.
    let lists = makeExamples()
    
    var body: some View {
        NavigationStack {
            List(lists) { (list) in
                NavigationLink(list.name, destination: list)
            }
            .navigationTitle("Toolkit Examples")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    static func makeExamples() -> [ExampleList] {
        let common: [ExampleList] = [
            .geoview,
            .views
        ]
#if os(iOS) && !targetEnvironment(macCatalyst)
        return [.augmentedReality] + common
#else
        return common
#endif
    }
}

extension ExampleList {
#if os(iOS) && !targetEnvironment(macCatalyst)
    static var augmentedReality: Self {
        .init(
            name: "Augmented Reality",
            examples: [
                AnyExample("Flyover", content: FlyoverExampleView()),
                AnyExample("Tabletop", content: TableTopExampleView()),
                AnyExample("World Scale", content: WorldScaleExampleView())
            ]
        )
    }
#endif
    
    static var geoview: Self {
        var examples: [any Example] = [
            AnyExample("Basemap Gallery", content: BasemapGalleryExampleView()),
            AnyExample("Bookmarks", content: BookmarksExampleView()),
            AnyExample("Compass", content: CompassExampleView()),
            AnyExample("Feature Form", content: FeatureFormExampleView()),
            AnyExample("Floor Filter", content: FloorFilterExampleView()),
            AnyExample("Overview Map", content: OverviewMapExampleView()),
            AnyExample("Popup", content: PopupExampleView()),
            AnyExample("Scalebar", content: ScalebarExampleView())
        ]
#if !os(visionOS)
        examples.append(
            contentsOf: [
                AnyExample("Search", content: SearchExampleView()),
                AnyExample("Utility Network Trace", content: UtilityNetworkTraceExampleView())
            ] as [any Example]
        )
#endif
        return .init(
            name: "GeoView",
            examples: examples.sorted(by: { $0.name < $1.name })
        )
    }
    
    static var views: Self {
        .init(
            name: "Views",
            examples: [
                AnyExample("Floating Panel", content: FloatingPanelExampleView())
            ]
        )
    }
}
