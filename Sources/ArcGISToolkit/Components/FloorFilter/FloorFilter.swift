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
        horizontalSizeClass == .compact || verticalSizeClass == .compact
    }
    
    /// Creates a `FloorFilter`.
    /// - Parameters:
    ///   - floorManager: The floor manager used by the `FloorFilter`.
    ///   - alignment: Determines the display configuration of Floor Filter elements.
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    ///   - isNavigating: The map is currently being navigated.
    public init(
        floorManager: FloorManager,
        alignment: Alignment,
        automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
        viewpoint: Binding<Viewpoint?> = .constant(nil),
        isNavigating: Binding<Bool>
    ) {
        _viewModel = StateObject(wrappedValue: FloorFilterViewModel(
            automaticSelectionMode: automaticSelectionMode,
            floorManager: floorManager,
            viewpoint: viewpoint
        ))
        self.alignment = alignment
        self.isNavigating = isNavigating
        self.viewpoint = viewpoint
    }
    
    /// The view model used by the `FloorFilter`.
    @StateObject private var viewModel: FloorFilterViewModel
    
    /// A Boolean value that indicates whether the levels view is currently collapsed.
    @State private var isLevelsViewCollapsed = false
    
    /// A Boolean value that indicates whether the site and facility selector is presented.
    @State private var isSitesAndFacilitiesHidden = false
    
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
            isSitesAndFacilitiesHidden.toggle()
        } label: {
            Image(systemName: "building.2")
                .padding(.toolkitDefault)
        }
        .sheet(
            isAllowed: isCompact,
            isPresented: $isSitesAndFacilitiesHidden
        ) {
            SiteAndFacilitySelector(isHidden: $isSitesAndFacilitiesHidden)
                .onChange(of: viewpoint.wrappedValue) { viewpoint in
                    reportChange(of: viewpoint)
                }
        }
    }
    
    /// A view that allows selecting between levels.
    private var floorFilter: some View {
        VStack {
            if isTopAligned {
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
    
    /// The map is currently being navigated.
    private var isNavigating: Binding<Bool>
    
    /// Indicates that the selector should be presented with a top oriented aligment configuration.
    private var isTopAligned: Bool {
        alignment.vertical == .top
    }
    
    /// Reports a viewpoint change to the view model if the map is not navigating.
    private func reportChange(of viewpoint: Viewpoint?) {
        guard isNavigating.wrappedValue else { return }
        viewModel.onViewpointChanged(viewpoint)
    }
    
    /// Displays the available levels.
    @ViewBuilder private var levelSelector: some View {
        LevelSelector(
            isTopAligned: isTopAligned,
            levels: viewModel.sortedLevels
        )
    }
    
    /// A configured `SiteAndFacilitySelector` view.
    ///
    /// The layering of the `SiteAndFacilitySelector` over a `RoundedRectangle` is needed to
    /// produce a rounded corners effect. We can not simply use `.esriBorder()` here because
    /// applying the `cornerRadius()` modifier on `SiteAndFacilitySelector`'s underlying
    /// `NavigationView` causes a rendering bug. This bug remains in iOS 16 with
    /// `NavigationStack` and has been reported to Apple as FB10034457.
    @ViewBuilder private var siteAndFacilitySelector: some View {
        if !isCompact {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(uiColor: .systemBackground))
                    .esriBorder()
                SiteAndFacilitySelector(isHidden: $isSitesAndFacilitiesHidden)
                    .onChange(of: viewpoint.wrappedValue) { viewpoint in
                        reportChange(of: viewpoint)
                    }
                    .padding()
            }
            .opacity(isSitesAndFacilitiesHidden ? .zero : 1)
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
        .environment(\.isCompact, isCompact)
        .environmentObject(viewModel)
        .disabled(viewModel.isLoading)
    }
}
