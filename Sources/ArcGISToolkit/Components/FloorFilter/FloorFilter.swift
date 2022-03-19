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
    /// Creates a `FloorFilter`
    /// - Parameters:
    ///   - alignment: Determines the display configuration of Floor Filter elements.
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - floorManager: The floor manager used by the `FloorFilter`.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    public init(
        alignment: Alignment,
        automaticSelectionMode: AutomaticSelectionMode = .always,
        floorManager: FloorManager,
        viewpoint: Binding<Viewpoint?>
    ) {
        _viewModel = StateObject(wrappedValue: FloorFilterViewModel(
            automaticSelectionMode: automaticSelectionMode,
            floorManager: floorManager,
            viewpoint: viewpoint
        ))
        self.alignment = alignment
        self.viewpoint = viewpoint
    }

    /// A Boolean value that indicates whether the levels view is currently collapsed.
    @State
    private var isLevelsViewCollapsed: Bool = false

    /// A Boolean value that indicates whether the site/facility selector is hidden.
    @State
    private var isSelectorHidden: Bool = true

    /// The alignment configuration.
    private let alignment: Alignment

    /// A Boolean value that indicates whether there are levels to display.  This will be false if
    /// there is no selected facility or if the selected facility has no levels.
    private var hasLevelsToDisplay: Bool {
        !(viewModel.selectedFacility == nil ||
          viewModel.selectedFacility!.levels.isEmpty)
    }

    /// Displays the available levels.
    private var levelsAndDividerView: some View {
        Group {
            if hasLevelsToDisplay {
                if topAligned {
                    Divider()
                        .frame(width: 30)
                }
                LevelSelector(
                    topAligned: topAligned,
                    levels: sortedLevels,
                    isCollapsed: $isLevelsViewCollapsed
                )
                if !topAligned {
                    Divider()
                        .frame(width: 30)
                }
            }
        }
    }

    /// Button to open and close the site and facility selector.
    private var facilityButtonView: some View {
        Button {
            isSelectorHidden.toggle()
        } label: {
            Image(systemName: "building.2")
        }
            .frame(maxWidth: .infinity)
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
                    levelsAndDividerView
                } else {
                    levelsAndDividerView
                    facilityButtonView
                }
            }
                .esriBorder()
            if topAligned {
                Spacer()
            }
        }
            .frame(width: 75)
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
        SiteAndFacilitySelector(isHidden: $isSelectorHidden)
            .esriBorder()
            .opacity(isSelectorHidden ? .zero : 1)
            .onChange(of: viewpoint.wrappedValue?.targetGeometry) { _ in
                viewModel.updateSelection()
            }
    }

    /// The selected facility's levels, sorted by `level.verticalOrder`.
    private var sortedLevels: [FloorLevel] {
        let levels = viewModel.selectedFacility?.levels ?? []
        return levels.sorted {
            $0.verticalOrder > $1.verticalOrder
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

    /// The view model used by the `FloorFilter`.
    @StateObject
    private var viewModel: FloorFilterViewModel

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
