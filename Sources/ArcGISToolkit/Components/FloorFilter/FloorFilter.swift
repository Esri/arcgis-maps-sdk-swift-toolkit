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
    ///   - floorManager: The floor manager used by the `FloorFilter`.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    public init(
        floorManager: FloorManager,
        viewpoint: Binding<Viewpoint>? = nil
    ) {
        _viewModel = StateObject(wrappedValue: FloorFilterViewModel(
            floorManager: floorManager,
            viewpoint: viewpoint
        ))
    }
    
    /// The view model used by the `FloorFilter`.
    @StateObject
    private var viewModel: FloorFilterViewModel
    
    /// A Boolean value that indicates whether the site/facility selector is hidden.
    @State
    private var isSelectorHidden: Bool = true
    
    /// A Boolean value that indicates whether the levels view is currently collapsed.
    @State
    private var isLevelsViewCollapsed: Bool = false
    
    /// A Boolean value that indicates whether there are levels to display.  This will be false if
    /// there is no selected facility or if the selected facility has no levels.
    private var hasLevelsToDisplay: Bool {
        !(viewModel.selectedFacility == nil ||
          viewModel.selectedFacility!.levels.isEmpty)
    }
    
    /// The selected facility's levels, sorted by `level.verticalOrder`.
    private var sortedLevels: [FloorLevel] {
        viewModel.selectedFacility?.levels.sorted() {
            $0.verticalOrder > $1.verticalOrder
        } ?? []
    }
    
    public var body: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                        .padding(12)
                }
            } else {
                HStack(alignment: .bottom) {
                    VStack {
                        Spacer()
                        VStack {
                            if hasLevelsToDisplay {
                                LevelsView(
                                    levels: sortedLevels,
                                    isCollapsed: $isLevelsViewCollapsed
                                )
                                Divider()
                                    .frame(width: 30)
                            }
                            // Site button.
                            Button {
                                isSelectorHidden.toggle()
                            } label: {
                                Image(systemName: "building.2")
                            }
                            .padding(4)
                        }
                        .esriBorder()
                    }
                    SiteAndFacilitySelector(isHidden: $isSelectorHidden)
                        .esriBorder()
                        .opacity(isSelectorHidden ? .zero : 1)
                }
            }
        }
        .environmentObject(viewModel)
    }
}

/// A view displaying the levels in the selected facility.
struct LevelsView: View {
    /// The levels to display.
    let levels: [FloorLevel]
    
    /// A Boolean value indicating the whether the view shows only the selected level or all levels.
    /// If the value is`false`, the view will display all levels; if it is `true`, the view will only display
    /// the selected level.
    @Binding
    var isCollapsed: Bool
    
    /// The view model used by the `LevelsView`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    /// The height of the scroll view's content.
    @State
    private var scrollViewContentHeight: CGFloat = .zero
    
    public var body: some View {
        VStack {
            if !isCollapsed,
               levels.count > 1 {
                CollapseButton(isCollapsed: $isCollapsed)
                Divider()
                    .frame(width: 30)
                ScrollView {
                    LevelsStack(levels: levels)
                        .background(
                            GeometryReader { geometry -> Color in
                                DispatchQueue.main.async {
                                    scrollViewContentHeight = geometry.size.height
                                }
                                return .clear
                            }
                        )
                }
                .frame(maxHeight: scrollViewContentHeight)
            }
            else {
                // Button for the selected level.
                Button {
                    if levels.count > 1 {
                        isCollapsed.toggle()
                    }
                } label: {
                    Text(viewModel.selectedLevel?.shortName ?? (levels.first?.shortName ?? "None"))
                }
                .buttonSelected(true)
                .padding(4)
            }
        }
    }
}

/// A vertical list of floor levels.
struct LevelsStack: View {
    let levels: [FloorLevel]
    
    /// The view model used by the `LevelsView`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    var body: some View {
        VStack {
            ForEach(levels) { level in
                Button {
                    viewModel.selection = .level(level)
                } label: {
                    Text(level.shortName)
                }
                .buttonSelected(level == viewModel.selectedLevel)
                .padding(4)
            }
        }
    }
}

/// A button used to collapse the floor level list.
struct CollapseButton: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    @Binding
    var isCollapsed: Bool
    
    var body: some View {
        Button {
            isCollapsed.toggle()
        } label: {
            Image(systemName: "xmark")
        }
        .padding(EdgeInsets(
            top: 2,
            leading: 4,
            bottom: 2,
            trailing: 4
        ))
    }
}
