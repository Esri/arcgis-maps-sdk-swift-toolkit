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

import ArcGIS
import SwiftUI

/// The `FloorFilter` component simplifies visualization of GIS data for a specific floor of a
/// building in your application. It allows you to filter the floor plan data displayed in your map
/// or scene view to a site, a facility (building) in the site, or a floor in the facility.
///
/// The ArcGIS Maps SDK currently supports filtering a floor aware map or scene based on the sites,
/// buildings, or levels in the geo model's floor definition.
///
/// | iPhone | iPad |
/// | ------ | ---- |
/// | ![image](https://github.com/user-attachments/assets/f7c8747b-1269-48d8-9dac-b783a63d3f15) | ![image](https://github.com/user-attachments/assets/f2e338f9-f29d-4621-9823-098037e9a135) |
///
/// **Features**
///
/// - Automatically hides the floor browsing view when the associated map or scene is not floor-aware.
/// - Selects the facility in view automatically (can be configured through the
/// ``FloorFilterAutomaticSelectionMode``).
/// - Shows the selected facility's levels in proper vertical order.
/// - Filters the map/scene content to show the selected level.
/// - Allows browsing the full floor-aware hierarchy of sites, facilities, and levels.
/// - Shows the ground floor of all facilities when there is no active selection.
/// - Updates the visibility of floor levels across all facilities (e.g. if you are looking at floor
///  3 in building A, floor 3 will be shown in neighboring buildings).
/// - Adjusts layout and presentation to work well regardless of positioning - left/right and
/// top/bottom.
/// - Keeps the selected facility visible in the list while the selection is changing in response to
/// map or scene navigation.
///
/// **Behavior**
///
/// | Sites Button |
/// | ----------- |
/// | ![Image of button that displays the list of sites when tapped](https://github.com/user-attachments/assets/be79d4b2-080b-439a-b1f1-26eb7535850d) |
///
/// When the Site button is tapped, a prompt opens so the user can select a site and then a
/// facility. After selecting a site and facility, a list of levels is displayed. The list of sites
/// and facilities can be dynamically filtered using the search bar.
///
/// **Associated Types**
///
/// Floor Filter has two associated enum type:
///
/// - ``FloorFilterAutomaticSelectionMode``
/// - ``FloorFilterSelection``
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [FloorFilterExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/FloorFilterExampleView.swift)
/// in the project. To learn more about using the `FloorFilter` see the <doc:FloorFilterTutorial>.
public struct FloorFilter: View {
    /// Creates a `FloorFilter`.
    /// - Parameters:
    ///   - floorManager: The floor manager used by the `FloorFilter`.
    ///   - alignment: Determines the display configuration of Floor Filter elements.
    ///   - automaticSelectionMode: The selection behavior of the floor filter.
    ///   - viewpoint: Viewpoint updated when the selected site or facility changes.
    ///   - isNavigating: A Boolean value indicating whether the map or scene is currently being navigated.
    ///   - selection: The selected site, facility, or level.
    public init(
        floorManager: FloorManager,
        alignment: Alignment,
        automaticSelectionMode: FloorFilterAutomaticSelectionMode = .always,
        viewpoint: Binding<Viewpoint?> = .constant(nil),
        isNavigating: Binding<Bool>,
        selection: Binding<FloorFilterSelection?>? = nil
    ) {
        _viewModel = StateObject(
            wrappedValue: FloorFilterViewModel(
                automaticSelectionMode: automaticSelectionMode,
                floorManager: floorManager,
                viewpoint: viewpoint
            )
        )
        self.alignment = alignment
        self.isNavigating = isNavigating
        self.viewpoint = viewpoint
        self.selection = selection
    }
    
    /// The view model used by the `FloorFilter`.
    @StateObject private var viewModel: FloorFilterViewModel
    
    /// A Boolean value controlling whether a site is automatically selected upon load completion.
    ///
    /// This property is only relevant when the FloorManager contains a single site.
    private var automaticSingleSiteSelectionDisabled: Bool = false
    
    /// The selected site, floor, or level.
    private var selection: Binding<FloorFilterSelection?>?
    
    /// The alignment configuration.
    private let alignment: Alignment
    
    /// The width of the level selector.
    private var levelSelectorWidth: CGFloat = FloorFilterBody.buttonSize
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facility.
    /// If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
    private var viewpoint: Binding<Viewpoint?>
    
    /// A Boolean value indicating whether the map or scene is currently being navigated.
    private var isNavigating: Binding<Bool>
    
    public var body: some View {
        FloorFilterBody(isTopAligned: alignment.vertical == .top, width: levelSelectorWidth)
            .environmentObject(viewModel)
            .disabled(viewModel.loadStatus != .loaded)
            .onChange(of: selection?.wrappedValue) {
                let newValue = selection?.wrappedValue
                // Prevent a double-set if the view model triggered the original change.
                guard newValue != viewModel.selection else { return }
                switch newValue {
                case .site(let site): viewModel.setSite(site)
                case .facility(let facility): viewModel.setFacility(facility)
                case .level(let level): viewModel.setLevel(level)
                case .none: viewModel.clearSelection()
                }
            }
            .onChange(of: viewModel.loadStatus) {
                if viewModel.loadStatus == .loaded,
                   !automaticSingleSiteSelectionDisabled,
                   viewModel.sites.count == 1,
                   let firstSite = viewModel.sites.first {
                    // If we have only one site, select it.
                    viewModel.setSite(firstSite, zoomTo: true)
                }
            }
            .onChange(of: viewModel.selection) {
                let newValue = viewModel.selection
                // Prevent a double-set if the user triggered the original change.
                guard selection?.wrappedValue != newValue else { return }
                selection?.wrappedValue = newValue
            }
            .onChange(of: viewpoint.wrappedValue) {
                guard isNavigating.wrappedValue, let newViewpoint = viewpoint.wrappedValue else {
                    return
                }
                viewModel.onViewpointChanged(newViewpoint)
            }
    }
}

public extension FloorFilter {
    /// Adds a condition that controls whether a site in the Floor Manager
    /// is automatically selected upon loading.
    ///
    /// Automatic selection only occurs when the Floor Manager contains a
    /// single site.
    /// - Parameter disabled: A Boolean value that determines whether
    /// automatic single site selection is disabled..
    /// - Returns: A view that conditionally disables automatic single site
    /// selection.
    /// - Since: 200.7
    func automaticSingleSiteSelectionDisabled(_ disabled: Bool = true) -> Self {
        var copy = self
        copy.automaticSingleSiteSelectionDisabled = disabled
        return copy
    }
    
    /// The width of the level selector.
    /// - Parameter width: The new width for the level selector.
    /// - Returns: The `FloorFilter`.
    func levelSelectorWidth(_ width: CGFloat) -> Self {
        var copy = self
        copy.levelSelectorWidth = width
        return copy
    }
}

/// The combined UI components for the floor filter.
private struct FloorFilterBody: View {
    @EnvironmentObject private var model: FloorFilterViewModel
    @State private var isSiteSelectorPresented = false
    
    let isTopAligned: Bool
    let width: CGFloat
    
    static let buttonShape = RoundedRectangle(cornerRadius: 18)
    #if targetEnvironment(macCatalyst)
    static let buttonSize: CGFloat = 48
    static let fontSize: CGFloat = 18
    #else
    static let buttonSize: CGFloat = 54
    static let fontSize: CGFloat = 20
    #endif
    static let padding: CGFloat = 3
    
    var body: some View {
        VStack(spacing: 0) {
            if isTopAligned {
                siteSelectorButton
                divider
                LevelSelector(isTopAligned: isTopAligned)
            } else {
                LevelSelector(isTopAligned: isTopAligned)
                divider
                siteSelectorButton
            }
        }
        .frame(width: width)
        .modify {
            if #available(iOS 26, *) {
#if os(visionOS)
                $0.glassBackgroundEffect(in: FloorFilterBody.buttonShape)
#else
                $0.glassEffect(.regular, in: FloorFilterBody.buttonShape)
#endif
            } else {
                $0.background(.regularMaterial)
            }
        }
        .clipShape(FloorFilterBody.buttonShape)
    }
    
    @ViewBuilder private var divider: some View {
        if !model.sortedLevels.isEmpty {
            Divider()
        }
    }
    
    @ViewBuilder private var siteSelectorButton: some View {
        Button {
            isSiteSelectorPresented.toggle()
        } label: {
            Image(systemName: "building.2")
                .frame(minWidth: FloorFilterBody.buttonSize, maxWidth: .infinity)
                .frame(height: FloorFilterBody.buttonSize)
                .font(.system(size: FloorFilterBody.fontSize))
                .contentShape(FloorFilterBody.buttonShape)
        }
        .accessibilityIdentifier("FloorFilter.siteSelectorButton")
        .buttonStyle(.plain)
        .popover(isPresented: $isSiteSelectorPresented) {
            SiteAndFacilitySelector(isPresented: $isSiteSelectorPresented)
                // To work-around an iOS 26 bug on dark mode where the
                // sheet appears half in dark mode and half in light mode.
                .background(Color(uiColor: .systemBackground))
        }
    }
}

/// The level selector portion of the floor filter.
private struct LevelSelector: View {
    let isTopAligned: Bool
    
    @EnvironmentObject private var model: FloorFilterViewModel
    @State private var isCollapsed = false
    @State private var contentHeight: CGFloat = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            if !model.sortedLevels.isEmpty {
                if isTopAligned {
                    levelButtons
                    collapseButton
                } else {
                    collapseButton
                    levelButtons
                }
            }
        }
        .animation(.default, value: isCollapsed)
    }
    
    @ViewBuilder private var collapseButton: some View {
        if model.sortedLevels.count > 1 {
            Button {
                isCollapsed.toggle()
            } label: {
                Image(systemName: isTopAligned ? "chevron.down" : "chevron.up")
                    .rotationEffect(isCollapsed ? .degrees(0) : .degrees(180))
                    .frame(minWidth: FloorFilterBody.buttonSize, maxWidth: .infinity)
                    .frame(height: FloorFilterBody.buttonSize)
                    .font(.system(size: FloorFilterBody.fontSize))
                    .foregroundStyle(.secondary)
                    .contentShape(FloorFilterBody.buttonShape)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("FloorFilter.collapseButton")
        }
    }
    
    @ViewBuilder private var levelButtons: some View {
        ScrollViewReader { scrollView in
            VStack(spacing: 0) {
                if isCollapsed || model.sortedLevels.count == 1 {
                    if let level = model.selection?.level {
                        LevelButton(
                            isCollapsed: $isCollapsed,
                            isSelected: true,
                            level: level
                        )
                        .transition(
                            .move(edge: isTopAligned ? .bottom : .top)
                            .combined(with: .opacity)
                        )
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(model.sortedLevels, id:\.id) { level in
                                LevelButton(
                                    isCollapsed: $isCollapsed,
                                    isSelected: level == model.selection?.level,
                                    level: level
                                )
                                .id(level.id)
                            }
                        }
                        .modify {
                            if #unavailable(iOS 18.0) {
                                $0.onGeometryChange(for: CGFloat.self) { proxy in
                                    proxy.frame(in: .global).height
                                } action: { newHeight in
                                    contentHeight = newHeight
                                }
                            }
                        }
                    }
                    .modify {
                        if #available(iOS 18.0, *) {
                            $0.onScrollGeometryChange(
                                for: CGFloat.self,
                                of: \.contentSize.height
                            ) { _, newValue in
                                contentHeight = newValue
                            }
                        }
                    }
                    .clipShape(FloorFilterBody.buttonShape)
                    .frame(maxHeight: contentHeight)
                    .transition(
                        .move(edge: isTopAligned ? .top : .bottom)
                        .combined(with: .opacity)
                    )
                }
            }
            .onChange(of: isCollapsed) {
                guard !isCollapsed else { return }
                scrollToSelectedLevel(with: scrollView)
            }
            .onChange(of: model.selection, initial: true) {
                guard model.selection?.facility != nil, !isCollapsed else { return }
                scrollToSelectedLevel(with: scrollView)
            }
        }
    }
    
    /// Scrolls the list within the provided proxy to the button representing the selected level.
    /// - Parameter scrollView: The scroll view proxy containing the scroll view.
    func scrollToSelectedLevel(with scrollView: ScrollViewProxy) {
        guard let level = model.selection?.level else { return }
        withAnimation {
            scrollView.scrollTo(level.id)
        }
    }
}

/// A level button within the level selector.
private struct LevelButton: View {
    @EnvironmentObject var model: FloorFilterViewModel
    
    @Binding var isCollapsed: Bool
    let isSelected: Bool
    let level: FloorLevel
    
    var body: some View {
        Button {
            if isCollapsed && model.sortedLevels.count > 1 {
                isCollapsed = false
            } else {
                model.setLevel(level)
            }
        } label: {
            Text(level.shortName)
                .frame(minWidth: FloorFilterBody.buttonSize, maxWidth: .infinity)
                .frame(height: FloorFilterBody.buttonSize)
                .font(.system(size: FloorFilterBody.fontSize))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .fontWeight(isSelected ? .semibold : .regular)
                .modify {
                    if isSelected && !isCollapsed && model.sortedLevels.count > 1 {
                        $0.background(
                            Color(uiColor: .systemBackground).opacity(0.75)
                                .clipShape(FloorFilterBody.buttonShape)
                                .padding(FloorFilterBody.padding)
                        )
                    }
                }
                .contentShape(FloorFilterBody.buttonShape)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("FloorFilter.levelButton.\(level.shortName)")
    }
}
