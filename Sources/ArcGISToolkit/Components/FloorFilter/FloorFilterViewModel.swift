// Copyright 2022 Esri
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
import Combine
import SwiftUI

/// Manages the state for a `FloorFilter`.
@MainActor
@available(visionOS, unavailable)
final class FloorFilterViewModel: ObservableObject {
    /// Creates a `FloorFilterViewModel`.
    /// - Parameters:
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - floorManager: The floor manager used by the `FloorFilterViewModel`.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    init(
        automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
        floorManager: FloorManager,
        viewpoint: Binding<Viewpoint?>
    ) {
        self.automaticSelectionMode = automaticSelectionMode
        self.floorManager = floorManager
        self.viewpoint = viewpoint
        
        floorManagerLoadStatusTask = Task {
            for await loadStatus in floorManager.$loadStatus {
                self.loadStatus = loadStatus
            }
        }
        
        loadFloorManager()
    }
    
    deinit {
        floorManagerLoadStatusTask?.cancel()
    }
    
    // MARK: Published members
    
    /// Load status of the FloorManager.
    @Published private(set) var loadStatus: LoadStatus?
    
    /// The selected site, floor, or level.
    @Published private(set) var selection: FloorFilterSelection?
    
    // MARK: Constants
    
    /// The selection behavior of the floor filter.
    private let automaticSelectionMode: FloorFilterAutomaticSelectionMode
    
    /// The `FloorManager` containing the site, floor, and level information.
    private let floorManager: FloorManager
    
    // MARK: Properties
    
    /// The floor manager facilities.
    var facilities: [FloorFacility] {
        floorManager.facilities
    }
    
    /// A Boolean value that indicates whether there are levels to display. This will be `false` if
    /// there is no selected facility or if the selected facility has no levels.
    var hasLevelsToDisplay: Bool {
        !(selection?.facility?.levels.isEmpty ?? true)
    }
    
    /// The floor manager levels.
    var levels: [FloorLevel] {
        floorManager.levels
    }
    
    /// The floor manager sites.
    var sites: [FloorSite] {
        floorManager.sites.sorted { $0.name <  $1.name }
    }
    
    /// The selected facility's levels, sorted by `level.verticalOrder`.
    var sortedLevels: [FloorLevel] {
        selection?.facility?.levels
            .sorted(by: { $0.verticalOrder > $1.verticalOrder }) ?? []
    }
    
    // MARK: Methods
    
    /// Sets the current selection to `nil`.
    func clearSelection() {
        selection = nil
    }
    
    /// Allows model users to alert the model that the viewpoint has changed.
    func onViewpointChanged(_ viewpoint: Viewpoint?) {
        guard let viewpoint = viewpoint,
              !viewpoint.targetScale.isZero else {
            return
        }
        automaticallySelectFacilityOrSite()
    }
    
    /// Updates the selected site, facility, and level based on a newly selected facility.
    /// - Parameters:
    ///   - newFacility: The new facility to be selected.
    ///   - zoomTo: If `true`, changes the viewpoint to the extent of the new facility.
    func setFacility(_ newFacility: FloorFacility, zoomTo: Bool = false) {
        if let oldLevel = selection?.level,
           let newLevel = newFacility.levels.first(
            where: { $0.verticalOrder == oldLevel.verticalOrder }
           ) {
            setLevel(newLevel)
        } else if let defaultLevel = newFacility.defaultLevel {
            setLevel(defaultLevel)
        } else {
            selection = .facility(newFacility)
        }
        
        if zoomTo {
            zoomToExtent(newFacility.geometry?.extent)
        }
    }
    
    /// Updates the selected site, facility, and level based on a newly selected level.
    /// - Parameter newLevel: The selected level.
    func setLevel(_ newLevel: FloorLevel) {
        selection = .level(newLevel)
        levels.forEach {
            $0.isVisible = $0.verticalOrder == newLevel.verticalOrder
        }
    }
    
    /// Updates the selected site, facility, and level based on a newly selected site.
    /// - Parameters:
    ///   - newSite: The new site to be selected.
    ///   - zoomTo: If `true`, changes the viewpoint to the extent of the new site.
    func setSite(_ newSite: FloorSite, zoomTo: Bool = false) {
        selection = .site(newSite)
        if zoomTo {
            zoomToExtent(newSite.geometry?.extent)
        }
    }
    
    /// Attempts to make an automated selection based on the current viewpoint.
    ///
    /// This method first attempts to select a facility, if that fails, site selection is attempted.
    func automaticallySelectFacilityOrSite() {
        guard automaticSelectionMode != .never else {
            return
        }
        if !autoSelectFacility() {
            autoSelectSite()
        }
    }
    
    // MARK: Private items
    
    /// A task to track the load status of the FloorManager.
    private var floorManagerLoadStatusTask: Task<Void, Never>?
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facility.
    /// If `nil`, there will be no automatic pan/zoom operations.
    private var viewpoint: Binding<Viewpoint?>
    
    /// Updates `selectedFacility` if a good selection exists.
    /// - Returns: `false` if a selection was not made.
    @discardableResult
    private func autoSelectFacility() -> Bool {
        // Only select a facility if it is within minimum scale. Default at 1500.
        let facilityMinScale: Double
        if let minScale = floorManager.facilityLayer?.minScale,
           minScale != .zero {
            facilityMinScale = minScale
        } else {
            facilityMinScale = 1500
        }
        
        if viewpoint.wrappedValue?.targetScale ?? .zero > facilityMinScale {
            return false
        }
        
        // If the centerpoint is within a facilities' geometry, select that site.
        let facilityResult = floorManager.facilities.first { facility in
            guard let extent1 = viewpoint.wrappedValue?.targetGeometry.extent,
                  let extent2 = facility.geometry?.extent else {
                return false
            }
            return GeometryEngine.isGeometry(extent1, intersecting: extent2)
        }
        
        if let facilityResult = facilityResult {
            setFacility(facilityResult)
        } else if automaticSelectionMode == .always {
            return false
        }
        return true
    }
    
    /// Updates `selectedSite` if a good selection exists.
    /// - Returns: `false` if a selection was not made.
    @discardableResult
    private func autoSelectSite() -> Bool {
        // Only select a facility if it is within minimum scale. Default at 4300.
        let siteMinScale: Double
        if let minScale = floorManager.siteLayer?.minScale,
           minScale != .zero {
            siteMinScale = minScale
        } else {
            siteMinScale = 4300
        }
        
        // If viewpoint is out of range, reset selection and return early.
        if viewpoint.wrappedValue?.targetScale ?? .zero > siteMinScale {
            if automaticSelectionMode == .always {
                clearSelection()
            }
            return false
        }
        
        // If the centerpoint is within a site's geometry, select that site.
        let siteResult = sites.first { site in
            guard let extent1 = viewpoint.wrappedValue?.targetGeometry.extent,
                  let extent2 = site.geometry?.extent else {
                return false
            }
            return GeometryEngine.isGeometry(extent1, intersecting: extent2)
        }
        
        if let siteResult {
            setSite(siteResult)
        } else if automaticSelectionMode == .always {
            clearSelection()
        }
        return true
    }
    
    /// Sets the visibility of all the levels on the map based on the vertical order of the current
    /// selected level.
    private func filterMapToSelectedLevel() {
        if let selectedLevel = selection?.level {
            levels.forEach {
                $0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
            }
        }
    }
    
    /// Loads the `FloorManager` if needed.
    private func loadFloorManager() {
        guard floorManager.loadStatus == .notLoaded,
              floorManager.loadStatus != .loading else {
            return
        }
        Task {
            do {
                try await floorManager.load()
            } catch {
                print("error: \(error)")
            }
        }
    }
    
    /// Zoom to given extent.
    private func zoomToExtent(_ extent: Envelope?) {
        // Make sure we have an extent and viewpoint to zoom to.
        guard let extent = extent else {
            return
        }
        
        let builder = EnvelopeBuilder(envelope: extent)
        builder.expand(by: 1.5)
        let targetExtent = builder.toGeometry()
        if !targetExtent.isEmpty {
            viewpoint.wrappedValue = Viewpoint(
                boundingGeometry: targetExtent
            )
        }
    }
}
