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
final public class FloorFilterViewModel: ObservableObject {
    /// The current selection.
    public enum Selection {
        /// The selected site.
        case site(FloorSite)
        /// The selected facility.
        case facility(FloorFacility)
        /// The selected level.
        case level(FloorLevel)
    }

    /// Creates a `FloorFilterViewModel`.
    /// - Parameters:
    ///   - floorManager: A floor manager.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    public init(
        floorManager: FloorManager,
        viewpoint: Binding<Viewpoint>? = nil
    ) {
        self.viewpoint = viewpoint
        self.floorManager = floorManager
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
    var viewpoint: Binding<Viewpoint>? = nil
    
    /// The `FloorManager` containing the site, floor, and level information.
    var floorManager: FloorManager
    
    /// The floor manager sites.
    public var sites: [FloorSite] {
        floorManager.sites
    }
    
    /// The floor manager facilities.
    public var facilities: [FloorFacility] {
        floorManager.facilities
    }
    
    /// The floor manager levels.
    public var levels: [FloorLevel] {
        floorManager.levels
    }

    /// `true` if the model is loading it's properties, `false` if not loading.
    @Published
    private(set) var isLoading = true
    
    /// The selected site, floor, or level.
    @Published
    public var selection: Selection? {
        didSet {
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
    public func zoomToSelection() {
        if let selectedFacility = selectedFacility {
            zoomToExtent(extent: selectedFacility.geometry?.extent)
        } else if let selectedSite = selectedSite {
            zoomToExtent(extent: selectedSite.geometry?.extent)
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
}
