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

/*
 
 // method that gets/sets the facility in the floor filter using the facility ID
 string selectedFacilityId()
 void setSelectedFacilityId(string facilityId)
 
 // method that gets/sets the level in the floor filter using the level ID
 string selectedLevelId()
 void setSelectedtLevelId(String levelId)
 
 // method that gets/sets the site in the floor filter using the site ID
 string selectedSiteId()
 void setSelectedSiteId(String siteId)
 
 */

@MainActor
/// View Model class that contains the Data Model of the Floor Filter
/// Also contains the business logic to filter and change the map extent based on selected site/level/facility
public class FloorFilterViewModel: ObservableObject {
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
//                viewpoint?.wrappedValue = floorManager
            } catch  {
                print("error: \(error)")
            }
            isLoading = false
        }
    }
    
    /// The `Viewpoint` used to pan/zoom to the floor level. If `nil`, there will be no zooming.
    var viewpoint: Binding<Viewpoint>? = nil
    
    var floorManager: FloorManager
    
    public var sites: [FloorSite] {
        floorManager.sites
    }
    
    /// `true` if the model is loading it's properties, `false` if not loading.
    @Published
    public var isLoading = true
    
    /// Facilities in the selected site
    /// If no site is selected then the list is empty
    /// If the sites data does not exist in the map, then use all the facilities in the map
    public var facilities: [FloorFacility] {
        sites.isEmpty ? floorManager.facilities : floorManager.facilities.filter {
            $0.site == selectedSite
        }
    }
    
    /// Levels that are visible in the expanded Floor Filter levels table view
    /// Reverse the order of the levels to make it in ascending order
    public var visibleLevelsInExpandedList: [FloorLevel] {
        facilities.isEmpty ? floorManager.levels : floorManager.levels.filter {
            $0.facility == selectedFacility
        }.reversed()
    }
    
    /// All the levels in the map
    public var allLevels: [FloorLevel] {
        floorManager.levels
    }
    
    /// The site, facility, and level that are selected by the user
    public var selectedSite: FloorSite? = nil
    public var selectedFacility: FloorFacility? = nil
    public var selectedLevel: FloorLevel? = nil
    
    /// The default vertical order is 0 according to Runtime 100.12 update for FloorManager
    public let defaultVerticalOrder: Int32 = 0
    
    public func reset() {
        selectedSite = nil
        selectedFacility = nil
        selectedLevel = nil
    }
    
    public func getDefaultLevelForFacility(facility: FloorFacility?) -> FloorLevel? {
        let candidateLevels = allLevels.filter {$0.facility == facility}
        return candidateLevels.first {$0.verticalOrder == 0} ?? getLowestLevel(levels: candidateLevels)
    }
    
    /// Returns the FloorLevel with the lowest verticalOrder.
    private func getLowestLevel(levels: [FloorLevel]) -> FloorLevel? {
        var lowestLevel: FloorLevel? = nil
        allLevels.forEach {
            if ($0.verticalOrder != Int.min && $0.verticalOrder != Int.max) {
                let lowestVerticalOrder = lowestLevel?.verticalOrder
                if (lowestVerticalOrder == nil || lowestVerticalOrder ?? defaultVerticalOrder > $0.verticalOrder) {
                    lowestLevel = $0
                }
            }
        }
        return lowestLevel
    }
    
    /// Sets the visibility of all the levels on the map based on the vertical order of the current selected level
    public func filterMapToSelectedLevel() {
        guard let selectedLevel = selectedLevel else { return }
        allLevels.forEach {
            $0.isVisible = $0.verticalOrder == selectedLevel.verticalOrder
        }
    }
    
    /// Zooms to the facility if there is a selected facility, otherwise zooms to the site.
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

extension UIImage {
    static var site: UIImage {
        return UIImage(named: "Site", in: Bundle.module, with: nil)!
    }
}
