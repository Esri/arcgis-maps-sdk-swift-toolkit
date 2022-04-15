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
    
    /// Creates a `FloorFilter`
    /// - Parameters:
    ///   - alignment: Determines the display configuration of Floor Filter elements.
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - floorManager: The floor manager used by the `FloorFilter`.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    public init(
        alignment: Alignment,
        automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
        floorManager: FloorManager,
        levelSelectorWidth: Double = 30.0,
        viewpoint: Binding<Viewpoint?>
    ) {
        _viewModel = StateObject(wrappedValue: FloorFilterViewModel(
            automaticSelectionMode: automaticSelectionMode,
            floorManager: floorManager,
            viewpoint: viewpoint
        ))
        self.alignment = alignment
        self.levelSelectorWidth = levelSelectorWidth
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
    
    /// The width for buttons in the level selector.
    private let levelSelectorWidth: Double
    
    /// Button to open and close the site and facility selector.
    private var facilityButtonView: some View {
        Button {
            siteAndFacilitySelectorIsPresented.toggle()
        } label: {
            Image(systemName: "building.2")
                .frame(width: levelSelectorWidth)
                .padding(.horizontal)
        }
        .sheet(
            isAllowed: isCompact,
            isPresented: $siteAndFacilitySelectorIsPresented
        ) {
            SiteAndFacilitySelector(isHidden: $siteAndFacilitySelectorIsPresented)
                .onChange(of: viewpoint.wrappedValue?.targetGeometry) { _ in
                    viewModel.viewpointSubject.send(viewpoint.wrappedValue)
                }
        }
    }
    
    /// Displays the available levels.
    @ViewBuilder private var levelsSelectorView: some View {
        if viewModel.hasLevelsToDisplay {
            if topAligned {
                Divider()
                    .frame(width: levelSelectorWidth)
            }
            LevelSelector(
                isCollapsed: $isLevelsViewCollapsed,
                buttonWidth: levelSelectorWidth,
                isTopAligned: topAligned,
                levels: viewModel.sortedLevels
            )
            if !topAligned {
                Divider()
                    .frame(width: levelSelectorWidth)
            }
        }
    }
    
    /// A view that allows selecting between levels.
    private var levelSelectorView: some View {
        VStack {
            if !topAligned {
                Spacer()
            }
            VStack {
                if topAligned {
                    facilityButtonView
                    levelsSelectorView
                } else {
                    levelsSelectorView
                    facilityButtonView
                }
            }
            .esriBorder()
            if topAligned {
                Spacer()
            }
        }
        .frame(maxWidth: isCompact ? .infinity : nil, alignment: alignment)
    }
    
    /// Indicates that the selector should be presented with a right oriented aligment configuration.
    private var rightAligned: Bool {
        switch alignment {
        case .topTrailing, .trailing, .bottomTrailing:
            return true
        default:
            return false
        }
    }
    
    /// A configured `SiteAndFacilitySelector` view.
    private var siteAndFacilitySelectorView: some View {
        Group {
            if !isCompact {
                SiteAndFacilitySelector(isHidden: $siteAndFacilitySelectorIsPresented)
                    .esriBorder()
                    .opacity(siteAndFacilitySelectorIsPresented ? 1 : .zero)
                    .onChange(of: viewpoint.wrappedValue?.targetGeometry) { _ in
                        viewModel.viewpointSubject.send(viewpoint.wrappedValue)
                    }
            }
        }
    }
    
    /// Indicates that the selector should be presented with a top oriented aligment configuration.
    private var topAligned: Bool {
        switch alignment {
        case .topLeading, .top, .topTrailing:
            return true
        default:
            return false
        }
    }
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facilty.
    /// If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
    private var viewpoint: Binding<Viewpoint?>
    
    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: alignment
                    )
            } else {
                HStack(alignment: .bottom) {
                    if rightAligned {
                        siteAndFacilitySelectorView
                        levelSelectorView
                    } else {
                        levelSelectorView
                        siteAndFacilitySelectorView
                    }
                }
            }
        }
        // Ensure space for filter text field on small screens in landscape
        .frame(minHeight: 100)
        .environmentObject(viewModel)
    }
}
