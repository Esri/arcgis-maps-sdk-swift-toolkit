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

/// The form which displays the content of the building explorer.
struct BuildingExplorerForm: View {
    /// The items to show in the form.
    let items: [BuildingExplorerItem]
    /// The proxy which we used to zoom into the building.
    let localSceneViewProxy: LocalSceneViewProxy?
    
    /// The currently selected explorer item.
    @Binding var selection: BuildingExplorerItem
    
    /// The group sublayers which is used to show the toggles for the
    /// discipline and categories.
    @State private var groupSublayers: [BuildingGroupSublayer] = []
    
    /// A Boolean value indicating if the camera should change to zoom into
    /// the building.
    @State private var shouldZoomToBuilding = false
    
    @State private var layerIsVisible = false
    
    // MARK: Layer picker properties.
    
    /// The name of the selected layer in the layer picker.
    @State private var selectedLayerName = ""
    /// The names of the layers that can be selected in the picker.
    @State private var layerNames: [String] = []
    
    // MARK: Level picker properties.
    
    /// The selected level in the level picker.
    @State private var selectedLevel: String = ""
    /// The available levels in the level picker.
    @State private var availableLevels: [String] = []
    
    // MARK: Phase picker properties.
    
    /// The selected phase in the phase picker.
    @State private var selectedPhase = ""
    /// The available phase in the phase picker.
    @State private var availablePhases: [String] = []
    
    @State private var phasePickerStyle: (any PickerStyle) = .automatic
    
    // MARK: Full model and sublayer toggle properties.
    
    /// A Boolean value indicating if the full model sublayer is showing.
    @State private var showFullModel = true
    /// The full model sublayer in the building scene layer.
    @State private var fullModelSublayer: BuildingGroupSublayer?
    /// The overview sublayer in the building scene layer.
    @State private var overviewSublayer: BuildingSublayer?
    
    init(
        items: [BuildingExplorerItem],
        selection: Binding<BuildingExplorerItem?>,
        localSceneViewProxy: LocalSceneViewProxy?
    ) {
        self.items = items
        self._selection = .init {
            // If we don't have a selection then this is the first
            // time the explorer was opened and we can default to the
            // first item.
            selection.wrappedValue ?? items.first!
        } set: {
            selection.wrappedValue = $0
        }
        self.localSceneViewProxy = localSceneViewProxy
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    layerVisibilityToggle
                    
                    // These options are only helpful if the
                    // layer is visible.
                    if layerIsVisible {
                        fullModelToggle
                        
                        if showFullModel {
                            if !availableLevels.isEmpty {
                                levelPicker
                                
                            }
                            
                            if availablePhases.count > 1 {
                                phasePicker
                            }
                        }
                    }
                }
                
                // Only show options to filter the full model
                // if the full model is being shown and the BSL
                // is visible.
                if showFullModel && layerIsVisible {
                    Section {
                        ForEach(groupSublayers) { sublayer in
                            BuildingGroupSublayerToggleView(groupSublayer: sublayer)
                        }
                    } header: {
                        Text.disciplinesAndCategories
                    }
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: updateBuildingPicker)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) { zoomToButton }
#if os(visionOS)
                ToolbarItem(placement: .principal) { layerPicker }
#else
                ToolbarItem(placement: .principal) { Text(verbatim: selectedLayerName) }
#endif
                ToolbarItem(placement: .topBarTrailing) { DismissButton(kind: .close) }
            }
            // visionOS puts the title menu above the main window which doesn't
            // make sense in this context so we don't use the title menu
            // on visionOS. Instead we put the layer picker in a toolbar item.
#if !os(visionOS)
            .toolbarTitleMenu { layerPicker }
#endif
            .task(id: selectedLayerName) {
                selection = items.first(where: { $0.layer.name == selectedLayerName })!
                
                // Update explorer contents.
                await updateForm()
            }
        }
    }
    
    /// The building scene layer visibility toggle.
    private var layerVisibilityToggle: some View {
        Toggle(String.visible, isOn: $layerIsVisible)
            .onChange(of: layerIsVisible) {
                selection.layer.isVisible = layerIsVisible
            }
    }
    
    /// The layer picker which is used to switch between different building
    /// scene layers in the scene.
    private var layerPicker: some View {
        Picker(selection: $selectedLayerName) {
            ForEach(layerNames, id: \.self) { layerName in
                Text(verbatim: layerName)
            }
        } label: {
            Text.buildingSceneLayers
        }
#if os(visionOS)
        .pickerStyle(.menu)
#else
        .pickerStyle(.inline)
#endif
    }
    
    /// A toggle to switch between the visibility of the full model sublayer.
    @ViewBuilder private var fullModelToggle: some View {
        // We need a valid overview and full model for this
        // toggle to be functional.
        if let overviewSublayer, let fullModelSublayer {
            Toggle(String.showFullModel, isOn: $showFullModel)
                .onChange(of: showFullModel) {
                    let selectedLayer = selection.layer
                    
                    if !showFullModel {
                        // Save last filter for when we come back to
                        // full model.
                        selection.filter = selectedLayer.activeFilter
                        
                        // We need to remove the filter now since it
                        // isn't valid for the overview sublayer.
                        // If a filter isn't valid then nothing renders
                        // but we want to show the overview.
                        selectedLayer.activeFilter = nil
                    } else if let oldFilter = selection.filter {
                        // If we saved a filter and the user switched between
                        // overview and full model then they would see
                        // the same filter from before.
                        selectedLayer.activeFilter = oldFilter
                    }
                    
                    fullModelSublayer.isVisible = showFullModel
                    overviewSublayer.isVisible = !showFullModel
                }
        }
    }
    
    /// The zoom to building button.
    @ViewBuilder private var zoomToButton: some View {
        if let proxy = localSceneViewProxy,
           let layerExtent = selection.layer.fullExtent {
            Button(String.zoomToBuilding, systemImage: "plus.magnifyingglass") {
                shouldZoomToBuilding = true
            }
            .foregroundStyle(.primary)
            .task(id: shouldZoomToBuilding) {
                guard shouldZoomToBuilding else { return }
                
                let camera = Camera(
                    lookingAt: layerExtent.center,
                    distance: 250,
                    heading: 40,
                    pitch: 60,
                    roll: .zero
                )
                await proxy.setViewpointCamera(camera, duration: 1.5)
                
                shouldZoomToBuilding = false
            }
        }
    }
    
    /// The level picker to select a level on the building.
    private var levelPicker: some View {
        Picker(selection: $selectedLevel) {
            ForEach(availableLevels, id: \.self) { level in
                Text(verbatim: level)
            }
        } label: {
            Text.level
        }
        .onChange(of: selectedLevel) {
            if selection.level != selectedLevel {
                selection.level = selectedLevel
                
                // Only change filter if the new selected level
                // is different. If the user has a filter
                // already present then we don't want to
                // change that when they open up the building
                // explorer. Only change the filter if they
                // selected a new level.
                selection.layer.activeFilter = levelAndPhaseFilter
            }
        }
    }
    
    /// The construction phase picker to select a phase on the building.
    private var phasePicker: some View {
        Picker(selection: $selectedPhase) {
            ForEach(availablePhases, id: \.self) { phase in
                Text(verbatim: phase)
            }
            .onChange(of: selectedPhase) {
                if selection.phase != selectedPhase {
                    selection.phase = selectedPhase
                    
                    // Only change filter if the new selected phase
                    // is different. If the user has a filter
                    // already present then we don't want to
                    // change that when they open up the building
                    // explorer. Only change the filter if they
                    // selected a new phase.
                    selection.layer.activeFilter = levelAndPhaseFilter
                }
            }
        } label: {
            Text.constructionPhase
        }
    }
    
    /// The filter used with the building scene layer to show the selected floor
    /// and phase that the user has selected.
    private var levelAndPhaseFilter: BuildingFilter? {
        // If no level or phase is selected then we need show everything
        // so return 'nil' for the filter.
        guard selectedLevel != .allLabel || !selectedPhase.isEmpty else { return nil }
        
        // Construct the where clauses based on the selection state.
        
        var solidWhereClause = ""
        var xrayWhereClause = ""
        
        if !selectedPhase.isEmpty {
            solidWhereClause = "\(String.phaseFieldKey) <= \(selectedPhase)"
        }
        
        if selectedLevel != .allLabel {
            let levelSolidWhereClause = "\(String.levelFieldKey) = \(selectedLevel)"
            xrayWhereClause = "\(String.levelFieldKey) < \(selectedLevel)"
            
            // Create or combine where clauses.
            if solidWhereClause.isEmpty {
                solidWhereClause = levelSolidWhereClause
            } else {
                solidWhereClause = "\(solidWhereClause) AND \(levelSolidWhereClause)"
            }
        }
        
        let solidFilterBlock = BuildingFilterBlock(
            title: "Solid",
            whereClause: solidWhereClause,
            mode: .solid()
        )
        
        let xrayFilterBlock = BuildingFilterBlock(
            title: "Xray",
            whereClause: xrayWhereClause,
            mode: .xray()
        )
        let blocks = if xrayWhereClause.isEmpty {
            [solidFilterBlock]
        } else {
            [solidFilterBlock, xrayFilterBlock]
        }
        
        return BuildingFilter(
            name: "Building Explorer filter",
            description: "Show selected level and phases using filter blocks.",
            blocks: blocks
        )
    }
    
    /// Updates the explorer when the view appears with the latest information
    /// for the building scene layer picker.
    private func updateBuildingPicker() {
        // Update layer name picker.
        
        selectedLayerName = selection.layer.name
        layerNames = items.map { $0.layer.name }
    }
    
    /// Updates the contents of the form with the latest selected layer.
    private func updateForm() async {
        let selectedLayer = selection.layer
        
        layerIsVisible = selectedLayer.isVisible
        
        // According to the spec, if there is no full model then
        // we should use the sublayers directly as the disciplines.
        
        var sublayers: [BuildingSublayer] = []
        if let fullModelSublayer = selectedLayer.sublayers.first(where: { $0.modelName.lowercased() == .fullModelName }) as? BuildingGroupSublayer {
            self.fullModelSublayer = fullModelSublayer
            showFullModel = fullModelSublayer.isVisible
            sublayers = fullModelSublayer.sublayers
        } else {
            sublayers = selectedLayer.sublayers
        }
        
        groupSublayers = sublayers
            .compactMap { $0 as? BuildingGroupSublayer }
        overviewSublayer = selectedLayer.sublayers
            .first(where: { $0.modelName.lowercased() == .overviewModelName })
        
        // Gets the level and phase statistics.
        
        guard let statistics = try? await selectedLayer.statistics,
              let levelStatistics = statistics[.levelFieldKey],
              let phaseStatistics = statistics[.phaseFieldKey] else { return }
        
        // Gets all the levels and phases and sort them.
        
        availableLevels = levelStatistics.mostFrequentValues.sorted { Int($0) ?? .zero > Int($1) ?? .zero } + [.allLabel]
        availablePhases = phaseStatistics.mostFrequentValues.sorted { Int($0) ?? .zero > Int($1) ?? .zero }
        
        // Restore last selected level and phase if there was one.
        // If not, give a default.
        
        selectedLevel = if selection.level.isEmpty {
            .allLabel
        } else {
            selection.level
        }
        
        selectedPhase = if selection.phase.isEmpty {
            availablePhases.first ?? ""
        } else {
            selection.phase
        }
    }
}

private extension String {
    /// The label used in the floor picker to see all the floors.
    static var allLabel: String { "All" }
    /// The model name of the full model sublayer.
    /// - Note: This string is lowercased so the model name  it is being compared against
    /// should be lowercased too. There shouldn't be a problem with the casing of the
    /// model name but we are doing this just in case.
    static var fullModelName: String { "fullmodel" }
    /// The attribute name for the levels.
    static var levelFieldKey: String { "BldgLevel" }
    /// The model name of the overview sublayer.
    /// - Note: This string is lowercased so the model name it is being compared against
    /// should be lowercased too. There shouldn't be a problem with the casing of the
    /// model name but we are doing this just in case.
    static var overviewModelName: String { "overview" }
    /// The attribute name for the phases.
    static var phaseFieldKey: String { "CreatedPhase" }
}

private extension String {
    /// Localized text for the phrase "Show Full Model".
    static var showFullModel: String {
        .init(
            localized: "Show Full Model",
            bundle: .toolkitModule,
            comment: "A label for the Show Full Model toggle in the Building Explorer."
        )
    }
    /// Localized text for the word "visible".
    static var visible: String {
        .init(
            localized: "Visible",
            bundle: .toolkitModule,
            comment: "A label for the visible toggle in the Building Explorer."
        )
    }
    /// A localized label for a zoom to building button.
    static var zoomToBuilding: String {
        .init(
            localized: "Zoom to building",
            bundle: .toolkitModule,
            comment: "A label for the zoom to building button in the Building Explorer."
        )
    }
}

private extension Text {
    /// Localized text for the phrase "Building Scene Layers".
    static var buildingSceneLayers: Self {
        .init(
            "Building Scene Layers",
            bundle: .toolkitModule,
            comment: "A label for layer picker in the Building Explorer."
        )
    }
    /// Localized text for the phrase "Construction Phase".
    static var constructionPhase: Self {
        .init(
            "Construction Phase",
            bundle: .toolkitModule,
            comment: "A label for construction phase picker in the Building Explorer."
        )
    }
    /// Localized text for the phrase "Disciplines & Categories".
    static var disciplinesAndCategories: Self {
        .init(
            "Disciplines & Categories",
            bundle: .toolkitModule,
            comment: "A label for Disciplines & Categories section in the Building Explorer."
        )
    }
    /// Localized text for the word "Level".
    static var level: Self {
        .init(
            "Level",
            bundle: .toolkitModule,
            comment: "A label for the level picker in the Building Explorer."
        )
    }
}
