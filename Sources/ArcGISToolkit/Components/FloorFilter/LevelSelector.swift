// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
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
    
    /// The height of the scroll view's content.
    @State private var contentHeight: CGFloat = .zero
    
    /// A Boolean value indicating the whether the view shows only the selected level or all levels.
    /// If the value is`false`, the view will display all levels; if it is `true`, the view will
    /// only display the selected level.
    @State private var isCollapsed: Bool = false
    
    /// The alignment configuration.
    let isTopAligned: Bool
    
    /// The levels to display.
    let levels: [FloorLevel]
    
    public var body: some View {
        VStack {
            if !isTopAligned {
                makeCollapseButton()
                Divider()
            }
            makeLevelButtons()
            if isTopAligned {
                Divider()
                makeCollapseButton()
            }
        }
    }
}

extension LevelSelector {
    /// A list of all the levels to be displayed.
    ///
    /// If the selector is collapsed, only the selected level is shown.
    var filteredLevels: [FloorLevel] {
        if !isCollapsed, levels.count > 1 {
            return levels
        } else {
            if let selectedLevel = viewModel.selection?.level {
                return [selectedLevel]
            } else {
                return []
            }
        }
    }
    
    /// The system name of the icon that reflects the current state of `isCollapsed`.
    var iconForCollapsedState: String {
        switch (isCollapsed, isTopAligned) {
        case (true, true), (false, false): return "chevron.down"
        case (true, false), (false, true): return "chevron.up"
        }
    }
    
    /// A button used to collapse the floor level list.
    /// - Returns: The button used to collapse and expand the selector.
    @ViewBuilder func makeCollapseButton() -> some View {
        Button {
            withAnimation {
                isCollapsed.toggle()
            }
        } label: {
            Image(systemName: iconForCollapsedState)
                .padding(.toolkitDefault)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(levels.count == 1)
    }
    
    /// A button for a level in the floor level list.
    /// - Parameter level: The level represented by the button.
    /// - Returns: The button representing the provided level.
    @ViewBuilder func makeLevelButton(_ level: FloorLevel) -> some View {
        Button {
            viewModel.setLevel(level)
            if isCollapsed && levels.count > 1 {
                isCollapsed = false
            }
        } label: {
            let roundedRectangle = RoundedRectangle(cornerRadius: 5)
            Text(level.shortName)
                .foregroundStyle(textColor(for: level))
                .frame(maxWidth: .infinity)
                .padding([.vertical], 4)
                .background {
                    roundedRectangle
                        .fill(buttonColor(for: level))
                }
                .contentShape(.hoverEffect, roundedRectangle)
                .hoverEffect()
        }
        .buttonStyle(.plain)
    }
    
    /// A scrollable list of buttons; one for each level to be displayed.
    /// - Returns: The scrollable list of level buttons.
    @ViewBuilder func makeLevelButtons() -> some View {
        let scrollView = ScrollViewReader { proxy in
            ScrollView {
                let list = VStack(spacing: 4) {
                    ForEach(filteredLevels, id: \.id) { level in
                        makeLevelButton(level)
                    }
                }
                if #available (iOS 18.0, *) {
                    list
                } else {
                    list
                        .onGeometryChange(for: CGFloat.self) { proxy in
                            proxy.frame(in: .global).height
                        } action: { newHeight in
                            contentHeight = newHeight
                        }
                }
            }
            .frame(maxHeight: contentHeight)
            .onAppear { scrollToSelectedLevel(with: proxy) }
            .onChange(isCollapsed) { _ in scrollToSelectedLevel(with: proxy) }
        }
        if #available (iOS 18.0, *) {
            scrollView
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentSize.height
                } action: { _, newValue in
                    contentHeight = newValue
                }
        } else {
            scrollView
        }
    }
    
    /// Determines a appropriate color for a button in the floor level list.
    /// - Parameter level: The level represented by the button.
    /// - Returns: The color for the button representing the provided level.
    func buttonColor(for level: FloorLevel) -> Color {
        return if viewModel.selection?.level == level {
#if os(visionOS)
            .white
#else
            .accentColor
#endif
        } else {
            .secondary.opacity(0.1)
        }
    }
    
    /// Determines a appropriate text color for a button in the floor level list.
    /// - Parameter level: The level represented by the button.
    /// - Returns: The color for the text on the button that is representing the provided level.
    func textColor(for level: FloorLevel) -> Color {
#if os(visionOS)
        if viewModel.selection?.level == level {
            // We need to change the text color on visionOS when a level is selected
            // because the background is now white so the text needs to be black
            // so the text is visible.
            return .black
        }
#endif
        return .primary
    }
    
    /// Scrolls the list within the provided proxy to the button representing the selected level.
    /// - Parameter proxy: The proxy containing the scroll view.
    func scrollToSelectedLevel(with proxy: ScrollViewProxy) {
        if let level = viewModel.selection?.level {
            withAnimation {
                proxy.scrollTo(level.id)
            }
        }
    }
}
