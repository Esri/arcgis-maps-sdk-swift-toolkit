// Copyright 2026 Esri
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

/// The building explorer component enables a user to explore a building model
/// in a `BuildingSceneLayer`.
///
/// ![An image of the BuildingExplorer component](BuildingExplorer)
///
/// This component provides a way for users to browse the levels, phases, and
/// sublayers of a building scene layer. The component can highlight specified levels or phases
/// and show or hide building features of different categories and subcategories.
///
/// **Features**
/// - Support for multiple building scene layers within a scene.
/// - A button to zoom to the building (if the proxy is provided).
/// - Visibility of the building scene layer can be toggled on and off.
/// - Visibility of the full model can be toggled on and off. If the full model is turned off, the
/// overview (shell of the building) will show. If the full model is turned on, the full model will
/// show and the overview will be turned off.
/// - Selecting a level of the building to highlight in the building scene layer.
///     - The selected level and all of the features of the level are rendered normally using
///     the solid filter mode.
///     - Levels above are hidden.
///     - Levels below are rendered using a X-ray filter mode.
/// - Selecting a construction phase to highlight in the building scene layer.
///     - The selected phase is rendered normally using the solid filter mode.
/// - Visibility of building feature categories and subcategories can be toggled on and off.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [BuildingExplorerExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/BuildingExplorerExampleView.swift)
/// in the project.
///
/// - Note: The building explorer only supports local scenes and the scene must contain at least
/// one building scene layer. If there is an active filter on the building scene layer that
/// wasn't set by the explorer, then it will be ignored.
/// - Since: 300.0
public struct BuildingExplorer: View {
    /// The scene being used to create items for the explorer.
    private let scene: ArcGIS.Scene
    /// The proxy needed to set the viewpoint when pressing the
    /// "Zoom to building" button.
    private let localSceneViewProxy: LocalSceneViewProxy?
    
    /// An error that occurred while setting up the explorer.
    @State private var setUpError: (any Error)?
    /// A Boolean value indicating if the explorer finished setting up.
    @State private var setUpIsDone = false
    
    /// The items to use in the explorer.
    @Binding private var items: [BuildingExplorerItem]
    /// The currently selected item in the explorer.
    @Binding private var selection: BuildingExplorerItem?
    
    /// Creates the building explorer view.
    /// - Parameters:
    ///   - scene: The scene which contains the building scene layers that will
    ///   be used in the explorer.
    ///   - items: The items being shown in the building explorer.
    ///   - selection: The selected item in the building explorer.
    ///   - localSceneViewProxy: The proxy to provide access to the set viewpoint
    ///   operation for the "Zoom to building" button. If the proxy is `nil` then that button
    ///   will not display in the toolbar.
    public init(
        scene: ArcGIS.Scene,
        items: Binding<[BuildingExplorerItem]>,
        selection: Binding<BuildingExplorerItem?>,
        localSceneViewProxy: LocalSceneViewProxy? = nil
    ) {
        self.scene = scene
        self._items = items
        self._selection = selection
        self.localSceneViewProxy = localSceneViewProxy
    }
    
    public var body: some View {
        Group {
            if setUpIsDone {
                BuildingExplorerForm(
                    items: items,
                    selection: $selection,
                    localSceneViewProxy: localSceneViewProxy
                )
            } else if let setUpError {
                ContentUnavailableView("\(setUpError.localizedDescription)", systemImage: "exclamationmark.triangle")
            } else {
                ProgressView()
            }
        }
        .task {
            await setUp()
        }
    }
    
    /// Sets up the building explorer.
    private func setUp() async {
        do {
            try await scene.load()
            
            guard scene.viewingMode == .local else {
                throw SetUpError.globalScenesNotSupported
            }
            
            let buildingSceneLayers = scene.operationalLayers
                .compactMap { $0 as? BuildingSceneLayer }
            
            guard !buildingSceneLayers.isEmpty else {
                throw SetUpError.noBuildingSceneLayers
            }
            
            await buildingSceneLayers.load()
            
            let newItems: [BuildingExplorerItem] = buildingSceneLayers
                .map {
                    let item = BuildingExplorerItem(layer: $0)
                    
                    // If this item is already in the items that was
                    // passed in then use that instead.
                    //
                    // If the item doesn't exist already then
                    // the operational layers could have changed
                    // and we should add the new item.
                    guard let matchingItem = items.first(where: { $0 == item }) else { return item }
                    
                    return matchingItem
                }
                .sorted(by: { $0.layer.name < $1.layer.name })
            
            items = newItems
            
            // If we have a selection but it isn't in the items
            // then default to the first item.
            if let selection, !items.contains(selection) {
                self.selection = items.first
            }
            
            setUpIsDone = true
        } catch {
            setUpError = error
        }
    }
}

private extension BuildingExplorer {
    /// An error that can occur when setting up the explorer.
    enum SetUpError: LocalizedError {
        /// Global scenes are not supported in the Building Explorer. Only local scenes
        /// are supported.
        case globalScenesNotSupported
        /// There are no building scene layers in the scene so there is nothing
        /// to display in the building explorer.
        case noBuildingSceneLayers
        
        var errorDescription: String? {
            switch self {
            case .globalScenesNotSupported:
                String(
                    localized: "Global scenes aren't supported in the Building Explorer.",
                    bundle: .toolkitModule,
                    comment: "Description of error thrown when a global scene is being provided to the Building Explorer."
                )
            case .noBuildingSceneLayers:
                String(
                    localized: "No building scene layers in the scene.",
                    bundle: .toolkitModule,
                    comment: "Description of error thrown there are no building scene layers in the scene provided to the Building Explorer."
                )
            }
        }
    }
}
