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
    
    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding(12)
            } else {
                HStack(alignment: .bottom) {
                    VStack {
                        LevelsView(isCollapsed: $isLevelsViewCollapsed)
                        Button {
                            isSelectorHidden.toggle()
                        } label: {
                            Image(systemName: "building.2")
                        }
                    }
                    .esriBorder()
                    if !isSelectorHidden {
                        SiteAndFacilitySelector(isHidden: $isSelectorHidden)
                            .esriBorder()
                    }
                }
            }
        }
        .environmentObject(viewModel)
    }
}

struct LevelsView: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    var isCollapsed: Binding<Bool>
    
    /// The view model used by the `LevelsView`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    private var sortedLevels: [FloorLevel] {
        viewModel.selectedFacility?.levels.sorted() {
            $0.verticalOrder > $1.verticalOrder
        } ?? []
    }
    
    public var body: some View {
        if viewModel.selectedFacility == nil ||
            viewModel.selectedFacility!.levels.isEmpty{
            EmptyView()
        } else {
            VStack {
                if !isCollapsed.wrappedValue {
                    CollapseButton(isCollapsed: isCollapsed)
                    Divider()
                        .frame(width: 30)
                    if let levels = sortedLevels {
                        if  levels.count > 3 {
                            ScrollView {
                                LevelsStack(levels: levels)
                            }
                        } else {
                            LevelsStack(levels: levels)
                        }
                    }
                }
                else if isCollapsed.wrappedValue {
                    // Button for the selected level.
                    Button {
                        isCollapsed.wrappedValue.toggle()
                    } label: {
                        Text(viewModel.selectedLevel?.shortName ?? (sortedLevels.first?.shortName ?? "None"))
                    }
                    .padding(8)
                    .selected(true)
                }
                
                Divider()
                    .frame(width: 30)
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
                .padding(8)
                .selected(level == viewModel.selectedLevel)
            }
        }
    }
}

/// A button used to collapse the floor level list.
struct CollapseButton: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    var isCollapsed: Binding<Bool>
    
    var body: some View {
        Button {
            isCollapsed.wrappedValue.toggle()
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
