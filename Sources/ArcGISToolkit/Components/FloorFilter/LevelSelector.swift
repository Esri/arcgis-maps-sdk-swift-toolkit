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
    @State private var isCollapsed: Bool = false
    
    /// The alignment configuration.
    let isTopAligned: Bool
    
    /// The levels to display.
    let levels: [FloorLevel]
    
    /// The short name of the currently selected level, the first level, or "None" if none of the levels
    /// are available.
    private var selectedLevelName: String {
        viewModel.selectedLevel?.shortName ?? ""
    }
    
    public var body: some View {
        if !isCollapsed,
           levels.count > 1 {
            VStack {
                if !isTopAligned {
                    makeCollapseButton()
                    Divider()
                }
                LevelsStack(levels: levels)
                if isTopAligned {
                    Divider()
                    makeCollapseButton()
                }
            }
        } else {
            Toggle(isOn: $isCollapsed) {
                Text(selectedLevelName)
                    .modifier(LevelNameFormat())
            }
            .toggleStyle(.selectedButton)
        }
    }
    
    /// A button used to collapse the floor level list.
    @ViewBuilder func makeCollapseButton() -> some View {
        Button {
            withAnimation {
                isCollapsed.toggle()
            }
        } label: {
            Image(systemName: isTopAligned ? "chevron.up.circle" : "chevron.down.circle")
                .padding(.toolkitDefault)
        }
    }
}

/// A vertical list of floor levels.
private struct LevelsStack: View {
    /// The view model used by the `LevelsView`.
    @EnvironmentObject var viewModel: FloorFilterViewModel
    
    /// The height of the scroll view's content.
    @State private var contentHeight: CGFloat = .zero
    
    /// The levels to display.
    let levels: [FloorLevel]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    ForEach(levels, id: \.id) { level in
                        Toggle(
                            isOn: Binding(
                                get: {
                                    viewModel.selectedLevel == level
                                },
                                set: { newIsOn in
                                    guard newIsOn else { return }
                                    viewModel.setLevel(level)
                                }
                            )
                        ) {
                            Text(level.shortName)
                                .modifier(LevelNameFormat())
                        }
                        .toggleStyle(.selectableButton)
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

private struct LevelNameFormat: ViewModifier {
    func body(content: Content) -> some View {
        content
            .lineLimit(1)
            .fixedSize()
            .frame(minWidth: 40)
    }
}
