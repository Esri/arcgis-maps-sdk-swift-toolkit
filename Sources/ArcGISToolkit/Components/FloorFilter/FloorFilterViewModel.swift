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
                if sites.count == 1, let firstSite = sites.first {
                    // If we have only one site, select it.
                    selection = .site(firstSite)
                }
            } catch  {
                // Note: Should user get to know about this error?
                print("error: \(error)")
            }
            isLoading = false
        }
    }

    /// The `Viewpoint` used to pan/zoom to the selected site or facility.
    /// If `nil`, there will be no automatic pan/zoom operations.
    var viewpoint: Binding<Viewpoint>?

    /// The `FloorManager` containing the site, floor, and level information.
    let floorManager: FloorManager

    /// A Boolean value that indicates whether the model is loading.
    @Published
    private(set) var isLoading = true

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

    /// The selected site, floor, or level.
    @Published
    var selection: Selection? {
        didSet {
            if case let .facility(facility) = selection,
               let level = defaultLevel(for: facility) {
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

    /// A Boolean value that indicates whether there are levels to display. This will be `false` if
    /// there is no selected facility or if the selected facility has no levels.
    var hasLevelsToDisplay: Bool {
        guard let selectedFacility = selectedFacility else {
            return false
        }
        return !selectedFacility.levels.isEmpty
    }

    // Mark: Private Functions

    /// Zooms to the selected facility; if there is no selected facility, zooms to the selected site.
    private func zoomToSelection() {
        guard let selection = selection else {
            return
        }

        switch selection {
        case .site(let site):
            zoomToExtent(site.geometry?.extent)
        case .facility(let facility):
            zoomToExtent(facility.geometry?.extent)
        case .level(let level):
            zoomToExtent(level.facility?.geometry?.extent)
        }
    }

    /// Zoom to given extent.
    private func zoomToExtent(_ extent: Envelope?) {
        // Make sure we have an extent and viewpoint to zoom to.
        guard let extent = extent,
              let viewpoint = viewpoint
        else { return }

        let builder = EnvelopeBuilder(envelope: extent)
        builder.expand(factor: 1.5)
        let targetExtent = builder.toGeometry()
        if !targetExtent.isEmpty {
            viewpoint.wrappedValue = Viewpoint(
                targetExtent: targetExtent
            )
        }
    }

    /// Sets the visibility of all the levels on the map based on the vertical order of the current
    /// selected level.
    private func filterMapToSelectedLevel() {
        guard let selectedLevel = selectedLevel else { return }
        levels.forEach {
            $0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
        }
    }

    /// Gets the default level for a facility.
    /// - Parameter facility: The facility to get the default level for.
    /// - Returns: The default level for the facility, which is the level with vertical order 0;
    /// if there's no level with vertical order of 0, it returns the lowest level.
    private func defaultLevel(for facility: FloorFacility?) -> FloorLevel? {
        return levels.first(where: { level in
            level.facility == facility && level.verticalOrder == .zero
        }) ?? lowestLevel()
    }

    /// Returns the level with the lowest vertical order.
    private func lowestLevel() -> FloorLevel? {
        let sortedLevels = levels.sorted {
            $0.verticalOrder < $1.verticalOrder
        }
        return sortedLevels.first {
            $0.verticalOrder != .min && $0.verticalOrder != .max
        }
    }
}
