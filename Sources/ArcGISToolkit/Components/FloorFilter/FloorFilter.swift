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

/// The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a building
/// in your application. It allows you to filter the floor plan data displayed in your map or scene view
/// to a site, a facility (building) in the site, or a floor in the facility.
public struct FloorFilter: View {
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass: UserInterfaceSizeClass?
    
    /// If `true`, the site and facility selector will appear as a sheet.
    /// If `false`, the site and facility selector will appear as a popup modal alongside the level selector.
    private var isCompact: Bool {
        return horizontalSizeClass == .compact || verticalSizeClass == .compact
    }
    
    /// Creates a `FloorFilter`.
    /// - Parameters:
    ///   - floorManager: The floor manager used by the `FloorFilter`.
    ///   - alignment: Determines the display configuration of Floor Filter elements.
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    public init(
        floorManager: FloorManager,
        alignment: Alignment,
        automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
        viewpoint: Binding<Viewpoint?> = .constant(nil)
    ) {
        _viewModel = StateObject(wrappedValue: FloorFilterViewModel(
            automaticSelectionMode: automaticSelectionMode,
            floorManager: floorManager,
            viewpoint: viewpoint
        ))
        self.alignment = alignment
        self.viewpoint = viewpoint
    }
    
    /// The view model used by the `FloorFilter`.
    @StateObject private var viewModel: FloorFilterViewModel
    
    /// A Boolean value that indicates whether the levels view is currently collapsed.
    @State private var isLevelsViewCollapsed: Bool = false
    
    /// A Boolean value that indicates whether the site and facility selector is presented.
    @State private var siteAndFacilitySelectorIsPresented: Bool = false
    
    /// The alignment configuration.
    private let alignment: Alignment
    
    /// The width of the level selector.
    private let filterWidth: CGFloat = 60
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facilty.
    /// If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
    private var viewpoint: Binding<Viewpoint?>
    
    /// Button to open and close the site and facility selector.
    private var sitesAndFacilitiesButton: some View {
        Button {
            siteAndFacilitySelectorIsPresented.toggle()
        } label: {
            Image(systemName: "building.2")
                .padding(.esriInsets)
        }
        .sheet(
            isAllowed: isCompact,
            isPresented: $siteAndFacilitySelectorIsPresented
        ) {
            SiteAndFacilitySelector(isHidden: $siteAndFacilitySelectorIsPresented)
                .onChange(of: viewpoint.wrappedValue) {
                    viewModel.onViewpointChanged($0)
                }
        }
    }
    
    /// A view that allows selecting between levels.
    private var floorFilter: some View {
        VStack {
            if topAligned {
                sitesAndFacilitiesButton
                if viewModel.hasLevelsToDisplay {
                    Divider()
                    levelSelector
                }
            } else {
                if viewModel.hasLevelsToDisplay {
                    levelSelector
                    Divider()
                }
                sitesAndFacilitiesButton
            }
        }
        .frame(width: filterWidth)
        .esriBorder()
        .frame(
            maxWidth: isCompact ? .infinity : nil,
            maxHeight: .infinity,
            alignment: alignment
        )
    }
    
    /// Indicates that the selector should be presented with a top oriented aligment configuration.
    private var topAligned: Bool {
        alignment.vertical == .top
    }
    
    /// Displays the available levels.
    @ViewBuilder private var levelSelector: some View {
        LevelSelector(
            isTopAligned: topAligned,
            levels: viewModel.sortedLevels
        )
    }
    
    /// A configured `SiteAndFacilitySelector`.
    @ViewBuilder private var siteAndFacilitySelector: some View {
        if !isCompact {
            SiteAndFacilitySelector(isHidden: $siteAndFacilitySelectorIsPresented)
                .esriBorder()
                .opacity(siteAndFacilitySelectorIsPresented ? 1 : .zero)
                .onChange(of: viewpoint.wrappedValue) {
                    viewModel.onViewpointChanged($0)
                }
        }
    }
    
    public var body: some View {
        HStack(alignment: .bottom) {
            if alignment.horizontal == .trailing {
                siteAndFacilitySelector
                floorFilter
            } else {
                floorFilter
                siteAndFacilitySelector
            }
        }
        // Ensure space for filter text field on small screens in landscape
        .frame(minHeight: 100)
        .environmentObject(viewModel)
        .disabled(viewModel.isLoading)
    }
}
