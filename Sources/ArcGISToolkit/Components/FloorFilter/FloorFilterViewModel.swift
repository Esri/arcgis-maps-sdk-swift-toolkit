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

@MainActor
/// Manages the state for a `FloorFilter`.
public class FloorFilterViewModel: ObservableObject {
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
                    selectedSite = sites.first
                }
            } catch  {
                print("error: \(error)")
            }
            isLoading = false
        }
    }
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facilty.
    /// If `nil`, there will be automatic no pan/zoom operations.
    var viewpoint: Binding<Viewpoint>? = nil
    
    /// The `FloorManager` containing the site, floor, and level information.
    var floorManager: FloorManager
    
    /// The floor manager sites.
    public var sites: [FloorSite] {
        floorManager.sites
    }
    
    /// `true` if the model is loading it's properties, `false` if not loading.
    @Published
    public var isLoading = true
    
    /// Facilities in the selected site. If no site is selected then the list is empty.
    /// If the sites list is empty, all facilities will be returned.
    public var facilities: [FloorFacility] {
        sites.isEmpty ? floorManager.facilities : floorManager.facilities.filter {
            $0.site == selectedSite
        }
    }
    
    /// Levels in the selected facility. If no facility is selected then the list is empty.
    /// If the facilities list is empty, all levels will be returned. 
    /// The levels are returned in ascending order.
    public var levels: [FloorLevel] {
        facilities.isEmpty ? floorManager.levels : floorManager.levels.filter {
            $0.facility == selectedFacility
        }.reversed()
    }
    
    /// All the levels in the map
    public var allLevels: [FloorLevel] {
        floorManager.levels
    }
    
    /// The selected site.
    @Published
    public var selectedSite: FloorSite? = nil {
        didSet {
            zoomToSite()
        }
    }

    /// The selected facility.
    @Published
    public var selectedFacility: FloorFacility? = nil {
        didSet {
            zoomToFacility()
        }
    }

    /// The selected level.
    @Published
    public var selectedLevel: FloorLevel? = nil
    
    /// Zooms to the selected facility; if there is no selected facility, zooms to the selected site.
    public func zoomToSelection() {
        if selectedFacility != nil {
            zoomToFacility()
        } else if selectedSite != nil {
            zoomToSite()
        }
    }
    
    private func zoomToSite() {
        zoomToExtent(extent: selectedSite?.geometry?.extent)
    }
    
    private func zoomToFacility() {
        zoomToExtent(extent: selectedFacility?.geometry?.extent)
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
