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
    /// The alignment configuration.
    var topAligned: Bool

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

    /// Returns the short name of the currently selected level, the first level or "None" if none of the listed
    /// are available.
    private var selectedLevelName: String {
        if let shortName = viewModel.selectedLevel?.shortName {
            return shortName
        } else if let firstLevelShortName = levels.first?.shortName {
            return firstLevelShortName
        } else {
            return "None"
        }
    }

    public var body: some View {
        VStack {
            if !isCollapsed,
                levels.count > 1 {
                if !topAligned {
                    CollapseButton(isCollapsed: $isCollapsed)
                    Divider()
                        .frame(width: 30)
                }
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
                if topAligned {
                    Divider()
                        .frame(width: 30)
                    CollapseButton(isCollapsed: $isCollapsed)
                }
            } else {
                Button {
                    if levels.count > 1 {
                        isCollapsed.toggle()
                    }
                } label: {
                    Text(selectedLevelName)
                        .lineLimit(1)
                }
                    .selected(true)
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
                    viewModel.setLevel(level)
                } label: {
                    Text(level.shortName)
                        .lineLimit(1)
                }
                    .selected(level == viewModel.selectedLevel)
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
            withAnimation {
                isCollapsed.toggle()
            }
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
