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
    ///  A selected site, floor, or level.
    enum Selection {
        /// A selected site.
        case site(FloorSite)
        /// A selected facility.
        case facility(FloorFacility)
        /// A selected level.
        case level(FloorLevel)
    }
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facilty.
    /// If `nil`, there will be no automatic pan/zoom operations.
    var viewpoint: Binding<Viewpoint>?
    
    /// The `FloorManager` containing the site, floor, and level information.
    var floorManager: FloorManager? = nil {
        didSet {
            Task {
                do {
                    try await floorManager?.load()
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
    }
    
    /// The floor manager sites.
    public var sites: [FloorSite] {
        floorManager?.sites ?? []
    }
    
    /// The floor manager facilities.
    public var facilities: [FloorFacility] {
        floorManager?.facilities ?? []
    }
    
    /// The floor manager levels.
    public var levels: [FloorLevel] {
        floorManager?.levels ?? []
    }

    /// `true` if the model is loading it's properties, `false` if not loading.
    @Published
    private(set) var isLoading = true
    
    /// The selected site, floor, or level.
    @Published
    var selection: Selection? {
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
        guard let selection = selection else {
            return
        }
        
        switch selection {
        case .site(let site):
            zoomToExtent(extent: site.geometry?.extent)
        case .facility(let facility):
            zoomToExtent(extent: facility.geometry?.extent)
        case .level:
            break
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
