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
/// | ![image](https://user-images.githubusercontent.com/3998072/202811733-dcd640e9-3b27-43a8-8bec-fd9aeb6798c7.png) | ![image](https://user-images.githubusercontent.com/3998072/202811772-bf6009e7-82ec-459f-86ae-6651f519b2ef.png) |
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
/// | ![Image of button that displays the list of sites when tapped](https://user-images.githubusercontent.com/3998072/203417956-5161103d-5d29-42fa-8564-de254159efe2.png) |
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
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
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
    
    /// A Boolean value that indicates whether the site and facility selector is presented.
    @State private var siteAndFacilitySelectorIsPresented = false
    
    /// A Boolean value controlling whether a site is automatically selected upon load completion.
    ///
    /// This property is only relevant when the FloorManager contains a single site.
    private var automaticSingleSiteSelectionDisabled: Bool = false
    
    /// The selected site, floor, or level.
    private var selection: Binding<FloorFilterSelection?>?
    
    /// The alignment configuration.
    private let alignment: Alignment
    
    /// The width of the level selector.
    private var levelSelectorWidth: CGFloat = 60
    
    /// The `Viewpoint` used to pan/zoom to the selected site/facility.
    /// If `nil`, there will be no automatic pan/zoom operations or automatic selection support.
    private var viewpoint: Binding<Viewpoint?>
    
    /// Button to open and close the site and facility selector.
    @ViewBuilder
    private var sitesAndFacilitiesButton: some View {
        if [.notLoaded, .loading].contains(viewModel.loadStatus) {
            ProgressView()
                .padding(.toolkitDefault)
                .progressViewStyle(.circular)
        } else if viewModel.loadStatus == .loaded {
            Button {
                siteAndFacilitySelectorIsPresented.toggle()
            } label: {
                Image(systemName: "building.2")
                    .padding(.toolkitDefault)
                    .contentShape(.rect(cornerRadius: 5))
                    .hoverEffect()
            }
            .accessibilityIdentifier("Floor Filter button")
            .buttonStyle(.plain)
#if !os(visionOS)
            .modify {
                if #unavailable(iOS 26.0) {
                    $0.foregroundStyle(.tint)
                }
            }
#endif
            .popover(isPresented: $siteAndFacilitySelectorIsPresented) {
                SiteAndFacilitySelector(isPresented: $siteAndFacilitySelectorIsPresented)
            }
        } else {
            Image(systemName: "exclamationmark.circle")
                .padding(.toolkitDefault)
        }
    }
    
    /// A view that displays the level selector and the sites and facilities button.
    private var levelSelectorContainer: some View {
        VStack(spacing: 0) {
            if isTopAligned {
                sitesAndFacilitiesButton
                if viewModel.hasLevelsToDisplay {
                    //Divider()
                    levelSelector
                }
            } else {
                if viewModel.hasLevelsToDisplay {
                    levelSelector
                    //Divider()
                }
                sitesAndFacilitiesButton
            }
        }
        .frame(width: levelSelectorWidth)
        .modify {
            if #available(iOS 26.0, *) {
                $0.glassEffect(.regular.interactive())
            } else {
                $0.esriBorder()
            }
        }
        .frame(
            maxWidth: horizontalSizeClass == .compact ? .infinity : nil,
            maxHeight: .infinity,
            alignment: alignment
        )
    }
    
    /// A Boolean value indicating whether the map or scene is currently being navigated.
    private var isNavigating: Binding<Bool>
    
    /// Indicates that the selector should be presented with a top oriented alignment configuration.
    private var isTopAligned: Bool {
        alignment.vertical == .top
    }
    
    /// A view that allows selecting between levels.
    @ViewBuilder private var levelSelector: some View {
        LevelSelector(
            isTopAligned: isTopAligned,
            levels: viewModel.sortedLevels
        )
    }
    
    public var body: some View {
        if #available(iOS 26.0, *) {
            FloorFilter26()
                .environmentObject(viewModel)
        } else {
            levelSelectorContainer
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
                    guard isNavigating.wrappedValue else { return }
                    if let newViewpoint = viewpoint.wrappedValue {
                        viewModel.onViewpointChanged(newViewpoint)
                    }
                }
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

@available(iOS 26.0, *)
struct FloorFilter26: View {
    @Namespace private var namespace
    @State private var isSiteSelectorPresented = false
    
    var buttonShape: some Shape {
        Capsule()
    }
    
    static let buttonSize: CGFloat = 56
    
    var body: some View {
        VStack(spacing: 12) {
            LevelSelector26()
            siteSelectorButton
        }
    }
    
    @ViewBuilder private var siteSelectorButton: some View {
        Button {
            isSiteSelectorPresented.toggle()
        } label: {
            Image(systemName: "building.2")
                .frame(width: FloorFilter26.buttonSize, height: FloorFilter26.buttonSize)
                .font(.system(size: 22))
                .glassEffect(.regular.interactive(), in: buttonShape)
                .glassEffectUnion(id: "siteSelector", namespace: namespace)
        }
        .buttonStyle(.plain)
        .contentShape(buttonShape)
        .popover(isPresented: $isSiteSelectorPresented) {
            SiteAndFacilitySelector(isPresented: $isSiteSelectorPresented)
        }
    }
}

@available(iOS 26.0, *)
struct LevelSelector26: View {
    @Namespace private var namespace
    @EnvironmentObject private var model: FloorFilterViewModel
    
    @State private var isCollapsed = false
    @State private var contentHeight: CGFloat = .zero
    
    var buttonShape: some Shape {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if model.sortedLevels.count > 1 {
                Button {
                    isCollapsed.toggle()
                } label: {
                    Image(systemName: "chevron.up")
                        .rotationEffect(isCollapsed ? .degrees(0) : .degrees(180))
                        .frame(width: FloorFilter26.buttonSize, height: FloorFilter26.buttonSize)
                        .font(.system(size: 20))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .contentShape(buttonShape)
            }
            
            levelButtons
        }
        .glassEffect(.regular.interactive(), in: buttonShape)
        .clipShape(buttonShape)
        .animation(.default, value: isCollapsed)
    }
    
    @ViewBuilder private var levelButtons: some View {
        ScrollViewReader { scrollView in
            VStack(spacing: 0) {
                if isCollapsed {
                    if let level = model.selection?.level {
                        LevelButton26(level: level, isSelected: true, isCollapsed: true)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(model.sortedLevels, id:\.id) { level in
                                LevelButton26(level: level, isSelected: level == model.selection?.level)
                                    .id(level.id)
                            }
                        }
                    }
                    .onScrollGeometryChange(for: CGFloat.self) { geometry in
                        geometry.contentSize.height
                    } action: { _, newValue in
                        contentHeight = newValue
                    }
                    .frame(maxHeight: contentHeight)
                }
            }
            .onChange(of: isCollapsed) {
                guard !isCollapsed else { return }
                scrollToSelectedLevel(with: scrollView)
            }
        }
    }
    
    /// Scrolls the list within the provided proxy to the button representing the selected level.
    /// - Parameter scrollView: The scroll view proxy containing the scroll view.
    func scrollToSelectedLevel(with scrollView: ScrollViewProxy) {
        if let level = model.selection?.level {
            withAnimation {
                scrollView.scrollTo(level.id)
            }
        }
    }
}

@available(iOS 26.0, *)
private struct LevelButton26: View {
    @Namespace private var namespace
    @EnvironmentObject var model: FloorFilterViewModel
    
    let level: FloorLevel
    let isSelected: Bool
    var isCollapsed: Bool = false
    
    let textSize: CGFloat = 56
    
    var buttonShape: some Shape {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }
    
    var body: some View {
        Button {
            model.setLevel(level)
        }
        label: {
            Text(level.shortName)
                .frame(width: textSize, height: textSize)
                .font(.system(size: 20))
                .foregroundStyle(isSelected ? .primary : .secondary)
                .modify {
                    if isSelected {
                        $0.background(Color(uiColor: .systemBackground).opacity(0.75))
                            .fontWeight(.semibold)
                            .clipShape(buttonShape)
                    }
                }
        }
        .buttonStyle(.plain)
        .contentShape(buttonShape)
    }
}
