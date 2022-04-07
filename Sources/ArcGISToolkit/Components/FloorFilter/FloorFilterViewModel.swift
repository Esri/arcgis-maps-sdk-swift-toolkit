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

import ArcGIS
import Combine
import SwiftUI

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
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - floorManager: The floor manager used by the `FloorFilterViewModel`.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    init(
        automaticSelectionMode: AutomaticSelectionMode = .always,
        floorManager: FloorManager,
        viewpoint: Binding<Viewpoint?>
    ) {
        self.automaticSelectionMode = automaticSelectionMode
        self.floorManager = floorManager
        self.viewpoint = viewpoint
        
        viewpointSubscription = viewpointSubject
            .debounce(for: delay, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let self = self,
                      let viewpoint = self.viewpoint.wrappedValue,
                      !viewpoint.targetScale.isZero else {
                          return
                }
                self.makeAutoSelection()
            })
        
        Task {
            do {
                try await floorManager.load()
                if sites.count == 1,
                    let firstSite = sites.first {
                    // If we have only one site, select it.
                    setSite(firstSite)
                }
            } catch {
                print("error: \(error)")
            }
            isLoading = false
        }
    }
    
    // MARK: Published members
    
    /// `true` if the model is loading it's properties, `false` if not loading.
    @Published private(set) var isLoading = true
    
    /// The selected site, floor, or level.
    @Published var selection: Selection? {
        didSet {
            if case let .level(oldLevel) = oldValue,
               case let .facility(facility) = selection,
               let newLevel = facility.levels.first(where: { level in
                       level.verticalOrder == oldLevel.verticalOrder
                }) {
                    selection = .level(newLevel)
            } else if case let .facility(facility) = selection,
               let level = defaultLevel(for: facility) {
                selection = .level(level)
            } else {
                filterMapToSelectedLevel()
            }
        }
    }
    
    // MARK: Constants
    
    /// The selection behavior of the floor filter.
    private let automaticSelectionMode: AutomaticSelectionMode
    
    /// The amount of time to wait between selection updates.
    private let delay = DispatchQueue.SchedulerTimeType.Stride.seconds(0.20)
    
    /// The `FloorManager` containing the site, floor, and level information.
    let floorManager: FloorManager
    
    // MARK: Public members
    
    /// The floor manager facilities.
    var facilities: [FloorFacility] {
        floorManager.facilities
    }
    
    /// A Boolean value that indicates whether there are levels to display. This will be `false` if
    /// there is no selected facility or if the selected facility has no levels.
    var hasLevelsToDisplay: Bool {
        guard let selectedFacility = selectedFacility else {
            return false
        }
        return !selectedFacility.levels.isEmpty
    }
    
    /// The floor manager levels.
    var levels: [FloorLevel] {
        floorManager.levels
    }
    
    /// The selected site.
    var selectedSite: FloorSite? {
        switch selection {
        case .site(let site):
            return site
        case .facility(let facility):
            return facility.site
        case .level(let level):
            return level.facility?.site
        default:
            return nil
        }
    }
    
    /// The selected facility.
    var selectedFacility: FloorFacility? {
        switch selection {
        case .site:
            return nil
        case .facility(let facility):
            return facility
        case .level(let level):
            return level.facility
        default:
            return nil
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
    
    /// The floor manager sites.
    var sites: [FloorSite] {
        floorManager.sites
    }
    
    /// The selected facility's levels, sorted by `level.verticalOrder`.
    var sortedLevels: [FloorLevel] {
        let levels = selectedFacility?.levels ?? []
        return levels.sorted {
            $0.verticalOrder > $1.verticalOrder
        }
    }
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facilty.
    /// If `nil`, there will be no automatic pan/zoom operations.
    var viewpoint: Binding<Viewpoint?>
    
    /// A subject to which viewpoint updates can be submitted.
    var viewpointSubject = PassthroughSubject<Viewpoint?, Never>()
    
    // MARK: Public methods
    
    /// Gets the default level for a facility.
    /// - Parameter facility: The facility to get the default level for.
    /// - Returns: The default level for the facility, which is the level with vertical order 0;
    /// if there's no level with vertical order of 0, it returns the lowest level.
    func defaultLevel(for facility: FloorFacility?) -> FloorLevel? {
        return levels.first(where: { level in
            level.facility == facility && level.verticalOrder == .zero
        }) ?? nil
    }
    
    /// Updates the selected site, facility, and level based on a newly selected facility.
    /// - Parameter floorFacility: The selected facility.
    func setFacility(_ floorFacility: FloorFacility?) {
        if let floorFacility = floorFacility {
            selection = .facility(floorFacility)
        }
        zoomToSelection()
    }
    
    /// Updates the selected site, facility, and level based on a newly selected level.
    /// - Parameter floorLevel: The selected level.
    func setLevel(_ floorLevel: FloorLevel?) {
        if let floorLevel = floorLevel {
            selection = .level(floorLevel)
        }
    }
    
    /// Updates the selected site, facility, and level based on a newly selected site.
    /// - Parameter floorSite: The selected site.
    func setSite(_ floorSite: FloorSite?) {
        if let floorSite = floorSite {
            selection = .site(floorSite)
        }
        zoomToSelection()
    }
    
    // MARK: Private items
    
    /// Attempts to make an automated selection based on the current viewpoint.
    ///
    /// This method first attempts to select a facility, if that fails, a site selection is attempted.
    internal func makeAutoSelection() {
        guard automaticSelectionMode != .never else {
            return
        }
        if !autoSelectFacility() {
            autoSelectSite()
        }
    }
    
    /// Sets the visibility of all the levels on the map based on the vertical order of the current selected level.
    private func filterMapToSelectedLevel() {
        if let selectedLevel = selectedLevel {
            levels.forEach {
                $0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
            }
        }
    }
    
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
            selection = .facility(facilityResult)
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
                selection = nil
            }
            return false
        }
        
        // If the centerpoint is within a site's geometry, select that site.
        let siteResult = floorManager.sites.first { site in
            guard let extent1 = viewpoint.wrappedValue?.targetGeometry.extent,
                  let extent2 = site.geometry?.extent else {
                return false
            }
            return GeometryEngine.isGeometry(extent1, intersecting: extent2)
        }
        
        if let siteResult = siteResult {
            selection = .site(siteResult)
        } else if automaticSelectionMode == .always {
            selection = nil
        }
        return true
    }
    
    /// Zoom to given extent.
    private func zoomToExtent(_ extent: Envelope?) {
        // Make sure we have an extent and viewpoint to zoom to.
        guard let extent = extent else {
            return
        }
        
        let builder = EnvelopeBuilder(envelope: extent)
        builder.expand(factor: 1.5)
        let targetExtent = builder.toGeometry()
        if !targetExtent.isEmpty {
            viewpoint.wrappedValue = Viewpoint(
                targetExtent: targetExtent
            )
        }
    }
    
    /// Zooms to the selected facility; if there is no selected facility, zooms to the selected site.
    private func zoomToSelection() {
        switch selection {
        case .site(let site):
            zoomToExtent(site.geometry?.extent)
        case .facility(let facility):
            zoomToExtent(facility.geometry?.extent)
        case .level(let level):
            zoomToExtent(level.facility?.geometry?.extent)
        default:
            break
        }
    }
    
    /// A subscription to handle listening for viewpoint changes.
    private var viewpointSubscription: AnyCancellable?
}

/// Defines automatic selection behavior.
public enum AutomaticSelectionMode {
    /// Always update selection based on the current viewpoint; clear the selection when the user
    /// navigates away.
    case always
    /// Only update the selection when there is a new site or facility in the current viewpoint; don't clear
    /// selection when the user navigates away.
    case alwaysNotClearing
    /// Never update selection based on the GeoView's current viewpoint.
    case never
}

extension FloorSite: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.name)
    }
}

extension FloorFilterViewModel.Selection: Hashable {
    static func == (
        lhs: FloorFilterViewModel.Selection,
        rhs: FloorFilterViewModel.Selection
    ) -> Bool {
        switch (lhs, rhs) {
        case (.site(let a), .site(let b)):
            return a.id == b.id
        case (.facility(let a), .facility(let b)):
            return a.id == b.id
        case (.level(let a), .level(let b)):
            return a.id == b.id
        default: return false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .site(let site):
            hasher.combine(site.id)
        case.facility(let facility):
            hasher.combine(facility.id)
        case .level(let level):
            hasher.combine(level.id)
        }
    }
}
