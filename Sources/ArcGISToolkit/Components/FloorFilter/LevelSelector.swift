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

/// A view which allows selection of levels represented in `FloorFacility`.
struct LevelSelector: View {
    /// The view model used by the `LevelsView`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    /// A Boolean value indicating the whether the view shows only the selected level or all levels.
    /// If the value is`false`, the view will display all levels; if it is `true`, the view will only display
    /// the selected level.
    @State var isCollapsed: Bool = false
    
    /// The width for buttons in the level selector.
    let buttonWidth: Double
    
    /// The alignment configuration.
    let isTopAligned: Bool
    
    /// The levels to display.
    let levels: [FloorLevel]
    
    /// Returns the short name of the currently selected level, the first level or "None" if none of the listed
    /// are available.
    private var selectedLevelName: String {
        viewModel.selectedLevel?.shortName ?? ""
    }
    
    public var body: some View {
        if !isCollapsed,
            levels.count > 1 {
            VStack {
                if !isTopAligned {
                    CollapseButton(
                        isCollapsed: $isCollapsed,
                        isTopAligned: isTopAligned
                    )
                    Divider()
                        .frame(width: 30)
                }
                LevelsStack(
                    buttonWidth: buttonWidth,
                    levels: levels
                )
                if isTopAligned {
                    Divider()
                        .frame(width: 30)
                    CollapseButton(
                        isCollapsed: $isCollapsed,
                        isTopAligned: isTopAligned
                    )
                }
            }
        } else {
            Button {
                isCollapsed.toggle()
            } label: {
                Text(selectedLevelName)
                    .lineLimit(1)
                    .frame(width: buttonWidth)
            }
            .selected(true)
        }
    }
}

/// A vertical list of floor levels.
struct LevelsStack: View {
    /// The view model used by the `LevelsView`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    /// The height of the scroll view's content.
    @State private var contentHeight: CGFloat = .zero
    
    /// The width for buttons in the level selector.
    let buttonWidth: Double
    
    /// The levels to display.
    let levels: [FloorLevel]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(levels, id: \.id) { level in
                        Button {
                            viewModel.setLevel(level)
                        } label: {
                            Text(level.shortName)
                                .lineLimit(1)
                                .frame(width: buttonWidth)
                        }
                        .selected(viewModel.selectedLevel == level)
                    }
                }
                .onSizeChange {
                    contentHeight = $0.height
                }
            }
            .frame(maxHeight: contentHeight)
            .onAppear {
                if let floorLevel = viewModel.selectedLevel {
                    withAnimation {
                        proxy.scrollTo(
                            floorLevel.id
                        )
                    }
                }
            }
        }
    }
}

/// A button used to collapse the floor level list.
struct CollapseButton: View {
    /// Allows the user to toggle the visibility of the site and facility selector.
    @Binding var isCollapsed: Bool
    
    /// The alignment configuration.
    let isTopAligned: Bool
    
    var body: some View {
        Button {
            withAnimation {
                isCollapsed.toggle()
            }
        } label: {
            Image(systemName: isTopAligned ? "chevron.up.circle" : "chevron.down.circle")
                .padding(EdgeInsets.esriInsets)
        }
    }
}
