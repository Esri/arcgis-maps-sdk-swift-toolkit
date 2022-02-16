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

/// Manages the state for a `FloorFilter`.
@MainActor
final class FloorFilterViewModel: ObservableObject {
    ///  A selected site, floor, or level.
    enum Selection {
        /// A selected site.
        case site(FloorSite)
        /// A selected facility.
        case facility(FloorFacility)
        /// A selected level.
        case level(FloorLevel)
    }
    
    /// Creates a `FloorFilterViewModel`.
    /// - Parameters:
    ///   - floorManager: The floor manager used by the `FloorFilterViewModel`.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    init(
        floorManager: FloorManager,
        viewpoint: Binding<Viewpoint>? = nil
    ) {
        self.floorManager = floorManager
        self.viewpoint = viewpoint

        Task {
            do {
                try await floorManager.load()
                if sites.count == 1 {
                    // If we have only one site, select it.
                    selection = .site(sites.first!)
                }
            } catch  {
                print("error: \(error)")
            }
            isLoading = false
        }
    }

    /// The `Viewpoint` used to pan/zoom to the selected site/facilty.
    /// If `nil`, there will be no automatic pan/zoom operations.
    var viewpoint: Binding<Viewpoint>?
    
    /// The `FloorManager` containing the site, floor, and level information.
    let floorManager: FloorManager
    
    /// The floor manager sites.
    var sites: [FloorSite] {
        floorManager.sites
    }
    
    /// The floor manager facilities.
    var facilities: [FloorFacility] {
        floorManager.facilities
    }
    
    /// The floor manager levels.
    var levels: [FloorLevel] {
        floorManager.levels
    }

    /// `true` if the model is loading it's properties, `false` if not loading.
    @Published
    private(set) var isLoading = true
    
    /// Gets the default level for a facility. Uses level with vertical order 0 otherwise gets the lowest level.
    public func getDefaultLevelForFacility(
        facility: FloorFacility?
    ) -> FloorLevel? {
        let candidateLevels = levels.filter { $0.facility == facility }
        return candidateLevels.first { $0.verticalOrder == 0 } ?? getLowestLevel()
    }
    
    /// Returns the AGSFloorLevel with the lowest verticalOrder.
    private func getLowestLevel() -> FloorLevel? {
        let sortedLevels = levels.sorted {
            $0.verticalOrder < $1.verticalOrder
        }
        return sortedLevels.first {
            $0.verticalOrder != .min && $0.verticalOrder != .max
        }
    }
    
    /// The selected site, floor, or level.
    @Published
    var selection: Selection? {
        didSet {
            if case let .facility(facility) = selection,
               let level = getDefaultLevelForFacility(facility: facility) {
                selection = .level(level)
            } else {
                filterMapToSelectedLevel()
            }
            zoomToSelection()
        }
    }
    
    /// The selected site.
    var selectedSite: FloorSite? {
        guard let selection = selection else {
            return nil
        }
        
        switch selection {
        case .site(let site):
            return site
        case .facility(let facility):
            return facility.site
        case .level(let level):
            return level.facility?.site
        }
    }
    
    /// The selected facility.
    var selectedFacility: FloorFacility? {
        guard let selection = selection else {
            return nil
        }
        
        switch selection {
        case .site:
            return nil
        case .facility(let facility):
            return facility
        case .level(let level):
            return level.facility
        }
    }
    
    /// The selected level.
    var selectedLevel: FloorLevel? {
        if case let .level(level) = selection {
            return level
        } else {
            return nil
        }
    }
    
    /// Zooms to the selected facility; if there is no selected facility, zooms to the selected site.
    func zoomToSelection() {
        guard let selection = selection else {
            return
        }
        
        switch selection {
        case .site(let site):
            zoomToExtent(extent: site.geometry?.extent)
        case .facility(let facility):
            zoomToExtent(extent: facility.geometry?.extent)
        case .level(let level):
            zoomToExtent(extent: level.facility?.geometry?.extent)
        }
    }
    
    private func zoomToExtent(extent: Envelope?) {
        // Make sure we have an extent and viewpoint to zoom to.
        guard let extent = extent,
              let viewpoint = viewpoint
        else { return }
        
        let builder = EnvelopeBuilder(envelope: extent)
        builder.expand(factor: 1.5)
        let targetExtent = builder.toGeometry() as! Envelope
        if !targetExtent.isEmpty {
            viewpoint.wrappedValue = Viewpoint(
                targetExtent: targetExtent
            )
        }
    }
    
    /// Sets the visibility of all the levels on the map based on the vertical order of the current selected level.
    public func filterMapToSelectedLevel() {
        guard let selectedLevel = selectedLevel else { return }
        levels.forEach {
            $0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
        }
    }
}
