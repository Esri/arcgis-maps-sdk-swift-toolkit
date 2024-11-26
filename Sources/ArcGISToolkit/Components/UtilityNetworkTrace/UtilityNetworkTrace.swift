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

/// `UtilityNetworkTrace` runs traces on a webmap published with a utility network and trace configurations.
///
/// | iPhone | iPad |
/// | ------ | ---- |
/// | ![image](UtilityNetworkTrace-iPhone) | ![image](UtilityNetworkTrace-iPad) |
///
/// **Features**
///
/// The utility network trace tool displays a list of named trace configurations defined for utility
/// networks in a web map. It enables users to add starting points and perform trace analysis from
/// the selected named trace configuration.
///
/// A named trace configuration defined for a utility network in a webmap comprises the parameters
/// used for a utility network trace.
///
/// **Behavior**
///
/// The tool allows users to:
///
///  - Choose between multiple networks (if more than one is defined in a webmap).
///  - Choose between named trace configurations:
/// ![image](UtilityNetworkTraceConfigurations)
///  - Add trace starting points either programmatically or by tapping on a map view, then use the
///  inspection view to narrow the selection:
/// ![image](UtilityNetworkTraceStartingPointDetail-iPad)
///  - View trace results:
///
/// | iPhone | iPad |
/// | ------ | ---- |
/// | ![image](UtilityNetworkTraceResult-iPhone) | ![image](UtilityNetworkTraceResult-iPad) |
///
///  - Run multiple trace scenarios, then use color and name to compare results:
/// ![image](UtilityNetworkTraceAdvancedOptions)
///
///  - See user-friendly warnings to help avoid common mistakes, including specifying too many
/// starting points or running the same trace configuration multiple times.
///
/// **Associated Types**
///
/// `UtilityNetworkTrace` has the following associated type:
///
/// - ``UtilityNetworkTraceStartingPoint``
///
/// To see the `UtilityNetworkTrace` in action, check out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [UtilityNetworkTraceExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/UtilityNetworkTraceExampleView.swift)
/// in the project. To learn more about using the `UtilityNetworkTrace` see the <doc:UtilityNetworkTraceTutorial>.
@available(visionOS, unavailable)
public struct UtilityNetworkTrace: View {
    /// The proxy to provide access to map view operations.
    private var mapViewProxy: MapViewProxy?
    
    // MARK: Enums
    
    /// Activities users will perform while creating a new trace.
    private enum TraceCreationActivity: Hashable {
        /// The user is adding starting points.
        case addingStartingPoints
        /// The user is inspecting details of a chosen starting point.
        case inspectingStartingPoint(UtilityNetworkTraceStartingPoint)
        /// The user is viewing the list of advanced options.
        case viewingAdvancedOptions
        /// The user is viewing the list of available networks.
        case viewingNetworkOptions
        /// The user is viewing the list of chosen starting points.
        case viewingStartingPoints
        /// The user is viewing the list of available trace configurations.
        case viewingTraceConfigurations
    }
    
    /// Activities users will perform while viewing completed traces.
    private enum TraceViewingActivity: Hashable {
        /// The user is viewing the list of available trace options.
        case viewingAdvancedOptions
        /// The user is viewing the list of element results.
        case viewingElementGroup(named: String)
        /// The user is viewing the list of feature results.
        case viewingFeatureResults
        /// The user is viewing the list of function results.
        case viewingFunctionResults
    }
    
    /// Activities users will perform while using the Utility Network Trace tool.
    private enum UserActivity: Hashable {
        /// The user is creating a new trace.
        case creatingTrace(TraceCreationActivity?)
        /// The user is viewing traces that have been created.
        case viewingTraces(TraceViewingActivity?)
    }
    
    // MARK: States
    
    /// The current detent of the floating panel.
    @Binding private var activeDetent: FloatingPanelDetent?
    
    /// The current user activity.
    @State private var currentActivity: UserActivity = .creatingTrace(nil)
    
    /// A Boolean value indicating whether the map should be zoomed to the extent of the trace result.
    @State private var shouldZoomOnTraceCompletion = true
    
    /// A Boolean value indicating whether the Clear All Results confirmation
    /// dialog is being shown.
    @State private var isShowingClearAllResultsConfirmationDialog = false
    
    /// The view model used by the view. The `UtilityNetworkTraceViewModel` manages state.
    /// The view observes `UtilityNetworkTraceViewModel` for changes in state.
    @StateObject private var viewModel: UtilityNetworkTraceViewModel
    
    // MARK: Bindings
    
    /// Starting points programmatically provided to the trace tool.
    @Binding private var externalStartingPoints: [UtilityNetworkTraceStartingPoint]
    
    /// The graphics overlay to hold generated starting point and trace graphics.
    @Binding private var graphicsOverlay: GraphicsOverlay
    
    /// Acts as the point at which newly selected starting point graphics will be created.
    @Binding private var mapPoint: Point?
    
    // MARK: Subviews
    
    /// Allows the user to switch between the trace creation and viewing tabs.
    private var activityPicker: some View {
        Picker(
            String.modePickerTitle,
            selection: Binding<UserActivity>(
                get: {
                    switch currentActivity {
                    case .creatingTrace(_):
                        return UserActivity.creatingTrace(nil)
                    case .viewingTraces:
                        return UserActivity.viewingTraces(nil)
                    }
                }, set: { newActivity, _ in
                    currentActivity = newActivity
                }
            )
        ) {
            Text(String.newTraceOptionLabel).tag(UserActivity.creatingTrace(nil))
            Text(String.resultsOptionLabel).tag(UserActivity.viewingTraces(nil))
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    /// Allows the user to cancel out of selecting a new starting point.
    private var cancelAddStartingPoints: some View {
        Button(String.cancelStartingPointSelection, role: .destructive) {
            currentActivity = .creatingTrace(nil)
            activeDetent = .half
        }
        .buttonStyle(.bordered)
    }
    
    /// Displays information about a chosen asset group.
    @ViewBuilder private var assetGroupDetail: some View {
        if let assetGroupName = selectedAssetGroupName,
           let assetTypeGroups = viewModel.selectedTrace?.elementsByType(inGroupNamed: assetGroupName) {
            makeBackButton(title: .featureResultsTitle) {
                currentActivity = .viewingTraces(.viewingFeatureResults)
            }
            makeDetailSectionHeader(title: assetGroupName)
            List {
                ForEach(
                    assetTypeGroups.sorted(using: KeyPathComparator(\.key)),
                    id: \.key
                ) { (name, elements) in
                    Section(name) {
                        DisclosureGroup {
                            ForEach(elements, id: \.globalID) { element in
                                Button {
                                    Task {
                                        if let feature = await viewModel.feature(for: element),
                                           let geometry = feature.geometry {
                                            updateViewpoint(to: geometry.extent)
                                        }
                                    }
                                } label: {
                                    Label {
                                        Text(
                                            "Object ID: \(element.objectID, format: .number.grouping(.never))",
                                            bundle: .toolkitModule,
                                            comment: "A string identifying a utility network object."
                                        )
                                    } icon: {
                                        Image(systemName: "scope")
                                    }
                                }
                            }
                        } label: {
                            Text(elements.count, format: .number)
                                .catalystPadding(4)
                        }
                    }
                }
            }
        }
    }
    
    /// Displays the list of available named trace configurations.
    @ViewBuilder private var configurationsList: some View {
        if viewModel.configurations.isEmpty {
            Text(String.noConfigurationsAvailable)
        } else {
            ForEach(viewModel.configurations.sorted { $0.name < $1.name }, id: \.name) { configuration in
                Button {
                    viewModel.setPendingTrace(configuration: configuration)
                    currentActivity = .creatingTrace(nil)
                } label: {
                    Text(configuration.name)
                }
                .listRowBackground(configuration.name == viewModel.pendingTrace.configuration?.name ? Color.secondary.opacity(0.5) : nil)
            }
        }
    }
    
    /// Displays the list of available networks.
    @ViewBuilder private var networksList: some View {
        ForEach(viewModel.networks, id: \.name) { network in
            Text(network.name)
                .lineLimit(1)
                .listRowBackground(network.name == viewModel.network?.name ? Color.secondary.opacity(0.5) : nil)
                .onTapGesture {
                    viewModel.setNetwork(network)
                    currentActivity = .creatingTrace(nil)
                }
        }
    }
    
    /// The tab that allows for a new trace to be configured.
    @ViewBuilder private var newTraceTab: some View {
        List {
            if viewModel.networks.count > 1 {
                Section(String.networkSectionLabel) {
                    DisclosureGroup(
                        isExpanded: Binding {
                            isFocused(traceCreationActivity: .viewingNetworkOptions)
                        } set: {
                            currentActivity = .creatingTrace($0 ? .viewingNetworkOptions : nil)
                        }
                    ) {
                        networksList
                    } label: {
                        Text(viewModel.network?.name ?? .selectNetwork)
                            .catalystPadding(4)
                    }
                }
            }
            Section(String.traceConfigurationSectionLabel) {
                DisclosureGroup(
                    isExpanded: Binding {
                        isFocused(traceCreationActivity: .viewingTraceConfigurations)
                    } set: {
                        currentActivity = .creatingTrace($0 ? .viewingTraceConfigurations : nil)
                    }
                ) {
                    configurationsList
                } label: {
                    Text(viewModel.pendingTrace.configuration?.name ?? .selectTraceConfiguration)
                        .catalystPadding(4)
                }
            }
            Section(String.startingPointsTitle) {
                Button(String.addNewButtonLabel) {
                    currentActivity = .creatingTrace(.addingStartingPoints)
                    activeDetent = .summary
                }
                if !viewModel.pendingTrace.startingPoints.isEmpty {
                    DisclosureGroup(
                        isExpanded: Binding {
                            isFocused(traceCreationActivity: .viewingStartingPoints)
                        } set: {
                            currentActivity = .creatingTrace($0 ? .viewingStartingPoints : nil)
                        }
                    ) {
                        startingPointsList
                    } label: {
                        Text(
                            "\(viewModel.pendingTrace.startingPoints.count) selected",
                            bundle: .toolkitModule,
                            comment: "A label declaring the number of starting points selected for a utility network trace."
                        )
                        .catalystPadding(4)
                    }
                }
            }
            Section {
                DisclosureGroup(
                    isExpanded: Binding {
                        isFocused(traceCreationActivity: .viewingAdvancedOptions)
                    } set: {
                        currentActivity = .creatingTrace($0 ? .viewingAdvancedOptions : nil)
                    }
                ) {
                    HStack {
                        Text(String.nameLabel)
                        Spacer()
                        TextField(String.nameLabel, text: $viewModel.pendingTrace.name)
                            .onSubmit {
                                viewModel.pendingTrace.userDidSpecifyName = true
                            }
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.blue)
                    }
                    ColorPicker(String.colorLabel, selection: $viewModel.pendingTrace.color)
                    Toggle(String.zoomToResult, isOn: $shouldZoomOnTraceCompletion)
                } label: {
                    Text(String.advancedOptionsHeaderLabel)
                        .catalystPadding(4)
                }
            }
        }
        Button(String.traceButtonLabel) {
            Task {
                if await viewModel.trace() {
                    currentActivity = .viewingTraces(nil)
                    if shouldZoomOnTraceCompletion,
                       let extent = viewModel.selectedTrace?.resultExtent {
                        updateViewpoint(to: extent)
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .disabled(!viewModel.canRunTrace)
    }
    
    /// Navigator at the top of the results tab that allows users to cycle through completed traces.
    @ViewBuilder private var resultsNavigator: some View {
        if viewModel.completedTraces.count > 1 {
            HStack {
                if viewModel.completedTraces.count > 1 {
                    Button {
                        viewModel.selectPreviousTrace()
                        if let extent = viewModel.selectedTrace?.resultExtent {
                            updateViewpoint(to: extent)
                        }
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
                Text(currentTraceLabel)
                    .padding(.horizontal)
                if viewModel.completedTraces.count > 1 {
                    Button {
                        viewModel.selectNextTrace()
                        if let extent = viewModel.selectedTrace?.resultExtent {
                            updateViewpoint(to: extent)
                        }
                    } label: {
                        Image(systemName: "chevron.forward")
                    }
                }
            }
        }
    }
    
    /// The tab that allows for viewing completed traces.
    @ViewBuilder private var resultsTab: some View {
        resultsNavigator
            .padding(2.5)
        if let selectedTrace = viewModel.selectedTrace {
            Menu(selectedTrace.name) {
                if let resultExtent = selectedTrace.resultExtent {
                    Button(String.zoomToButtonLabel) {
                        updateViewpoint(to: resultExtent)
                    }
                }
                Button(String.deleteButtonLabel) {
                    if viewModel.completedTraces.count == 1 {
                        currentActivity = .creatingTrace(nil)
                    }
                    viewModel.deleteTrace(selectedTrace)
                }
            }
            .font(.title3)
            .catalystPadding()
        }
        if activeDetent != .summary {
            List {
                Section(String.featureResultsTitle) {
                    DisclosureGroup(
                        isExpanded: Binding {
                            isFocused(traceViewingActivity: .viewingFeatureResults)
                        } set: {
                            currentActivity = .viewingTraces($0 ? .viewingFeatureResults : nil)
                        }
                    ) {
                        if let selectedTrace = viewModel.selectedTrace {
                            ForEach(selectedTrace.assetGroupNames.sorted(), id: \.self) { assetGroupName in
                                HStack {
                                    Text(assetGroupName)
                                    Spacer()
                                    Text(selectedTrace.elements(inAssetGroupNamed: assetGroupName).count, format: .number)
                                }
                                .foregroundColor(.blue)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    currentActivity = .viewingTraces(.viewingElementGroup(named: assetGroupName))
                                }
                            }
                        }
                    } label: {
                        Text.makeResultsLabel(viewModel.selectedTrace?.elementResults.count ?? 0)
                            .catalystPadding(4)
                    }
                }
                Section(String.functionResultsSectionTitle) {
                    DisclosureGroup(
                        isExpanded: Binding {
                            isFocused(traceViewingActivity: .viewingFunctionResults)
                        } set: {
                            currentActivity = .viewingTraces($0 ? .viewingFunctionResults : nil)
                        }
                    ) {
                        if let selectedTrace = viewModel.selectedTrace {
                            ForEach(selectedTrace.functionOutputs, id: \.objectID) { item in
                                HStack {
                                    Text(item.function.networkAttribute.name)
                                    Spacer()
                                    VStack(alignment: .trailing) {
                                        Text(item.function.functionType.title)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        if let result = item.result as? Double {
                                            Text(result, format: .number)
                                        } else {
                                            Text(
                                                "Not Available",
                                                bundle: .toolkitModule,
                                                comment: "A trace function output result was not provided."
                                            )
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Text.makeResultsLabel(viewModel.selectedTrace?.utilityFunctionTraceResult?.functionOutputs.count ?? 0)
                            .catalystPadding(4)
                    }
                }
                Section {
                    DisclosureGroup(
                        isExpanded: Binding {
                            isFocused(traceViewingActivity: .viewingAdvancedOptions)
                        } set: {
                            currentActivity = .viewingTraces($0 ? .viewingAdvancedOptions : nil)
                        }
                    ) {
                        ColorPicker(
                            String.colorLabel,
                            selection: Binding {
                                viewModel.selectedTrace?.color ?? Color.clear
                            } set: { newValue in
                                if var trace = viewModel.selectedTrace {
                                    trace.color = newValue
                                    viewModel.update(completedTrace: trace)
                                }
                            }
                        )
                    } label: {
                        Text(String.advancedOptionsHeaderLabel)
                            .catalystPadding(4)
                    }
                }
            }
            .padding([.vertical], 2)
            Button(String.clearAllResults, role: .destructive) {
                isShowingClearAllResultsConfirmationDialog = true
            }
            .buttonStyle(.bordered)
            .confirmationDialog(
                String.clearAllResults,
                isPresented: $isShowingClearAllResultsConfirmationDialog
            ) {
                Button(String.clearAllResults, role: .destructive) {
                    viewModel.deleteAllTraces()
                    currentActivity = .creatingTrace(nil)
                }
            } message: {
                Text(String.clearAllResultsMessage)
            }
        }
    }
    
    /// Displays information about a chosen starting point.
    @ViewBuilder private var startingPointDetail: some View {
        makeBackButton(title: .startingPointsTitle) {
            currentActivity = .creatingTrace(.viewingStartingPoints)
        }
        Menu(selectedStartingPoint?.utilityElement?.assetType.name ?? String.unnamedAssetType) {
            Button(String.zoomToButtonLabel) {
                if let selectedStartingPoint = selectedStartingPoint,
                   let extent = selectedStartingPoint.geoElement.geometry?.extent {
                    updateViewpoint(to: extent)
                }
            }
            Button(String.deleteButtonLabel, role: .destructive) {
                if let startingPoint = selectedStartingPoint {
                    viewModel.deleteStartingPoint(startingPoint)
                    currentActivity = .creatingTrace(.viewingStartingPoints)
                }
            }
        }
        .font(.title3)
        .catalystPadding()
        List {
            if selectedStartingPoint?.utilityElement?.networkSource.kind == .edge {
                Section(String.fractionAlongEdgeSectionTitle) {
                    Slider(
                        value: Binding {
                            viewModel.pendingTrace.startingPoints.first {
                                $0 == selectedStartingPoint
                            }?.utilityElement?.fractionAlongEdge ?? .zero
                        } set: { newValue in
                            if let selectedStartingPoint = selectedStartingPoint {
                                viewModel.setFractionAlongEdgeFor(
                                    startingPoint: selectedStartingPoint,
                                    to: newValue
                                )
                            }
                        }
                    )
                }
            } else if selectedStartingPoint?.utilityElement?.networkSource.kind == .junction &&
                        selectedStartingPoint?.utilityElement?.terminal != nil &&
                        !(selectedStartingPoint?.utilityElement?.assetType.terminalConfiguration?.terminals.isEmpty ?? true) {
                Section {
                    Picker(
                        String.terminalConfigurationPickerTitle,
                        selection: Binding {
                            selectedStartingPoint!.utilityElement!.terminal!
                        } set: { newValue in
                            viewModel.setTerminalConfigurationFor(startingPoint: selectedStartingPoint!, to: newValue)
                        }
                    ) {
                        ForEach(viewModel.pendingTrace.startingPoints.first {
                            $0 == selectedStartingPoint
                        }?.utilityElement?.assetType.terminalConfiguration?.terminals ?? [], id: \.self) {
                            Text($0.name)
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            Section(String.attributesSectionTitle) {
                ForEach(Array(selectedStartingPoint!.geoElement.attributes.sorted(by: { $0.key < $1.key})), id: \.key) { item in
                    HStack{
                        Text(item.key)
                        Spacer()
                        Text(item.value as? String ?? "")
                    }
                }
            }
        }
    }
    
    /// Displays the chosen starting points for the new trace.
    private var startingPointsList: some View {
        ForEach(viewModel.pendingTrace.startingPoints, id: \.self) { startingPoint in
            Button {
                currentActivity = .creatingTrace(
                    .inspectingStartingPoint(startingPoint)
                )
            } label: {
                Label {
                    Text(startingPoint.utilityElement?.assetType.name ?? "")
                        .lineLimit(1)
                } icon: {
                    if let image = startingPoint.image {
                        Image(uiImage: image)
                            .frame(width: 25, height: 25)
                            .background(.white)
                            .cornerRadius(5)
                    }
                }
            }
            .swipeActions {
                Button(role: .destructive) {
                    viewModel.deleteStartingPoint(startingPoint)
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    /// A graphical interface to run pre-configured traces on a map's utility networks.
    /// - Parameters:
    ///   - graphicsOverlay: The graphics overlay to hold generated starting point and trace graphics.
    ///   - map: The map containing the utility network(s).
    ///   - mapPoint: Acts as the point at which newly selected starting point graphics will be created.
    ///   - mapViewProxy: The proxy to provide access to map view operations.
    ///   - startingPoints: An optional list of programmatically provided starting points.
    public init(
        graphicsOverlay: Binding<GraphicsOverlay>,
        map: Map,
        mapPoint: Binding<Point?>,
        mapViewProxy: MapViewProxy,
        startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
    ) {
        self.mapViewProxy = mapViewProxy
        _activeDetent = .constant(nil)
        _mapPoint = mapPoint
        _graphicsOverlay = graphicsOverlay
        _externalStartingPoints = startingPoints
        _viewModel = StateObject(
            wrappedValue: UtilityNetworkTraceViewModel(
                map: map,
                graphicsOverlay: graphicsOverlay.wrappedValue,
                startingPoints: startingPoints.wrappedValue
            )
        )
    }
    
    /// Sets the active detent for a hosting floating panel.
    /// - Parameter detent: A binding to a value that determines the height of a hosting
    /// floating panel.
    /// - Returns: A trace tool that automatically sets and responds to detent values to improve user
    /// experience.
    public func floatingPanelDetent(
        _ detent: Binding<FloatingPanelDetent>
    ) -> UtilityNetworkTrace {
        var copy = self
        copy._activeDetent = Binding(detent)
        return copy
    }
    
    /// Updates the viewpoint to the provided extent. If a map view proxy is provided, the update is
    /// animated. Otherwise the bound viewpoint is set directly.
    /// - Parameter extent: The new extent to be shown.
    func updateViewpoint(to extent: Envelope) {
        let newViewpoint = Viewpoint(boundingGeometry: extent)
        if let mapViewProxy {
            Task { await mapViewProxy.setViewpoint(newViewpoint, duration: nil) }
        }
    }
    
    public var body: some View {
        VStack {
            if !viewModel.completedTraces.isEmpty &&
                !isFocused(traceCreationActivity: .addingStartingPoints) &&
                activeDetent != .summary {
                activityPicker
            }
            switch currentActivity {
            case .creatingTrace(let activity):
                switch activity {
                case .addingStartingPoints:
                    cancelAddStartingPoints
                case .inspectingStartingPoint:
                    startingPointDetail
                default:
                    newTraceTab
                }
            case .viewingTraces(let activity):
                switch activity {
                case .viewingElementGroup:
                    assetGroupDetail
                default:
                    resultsTab
                }
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .animation(.default, value: currentActivity)
        .onChange(mapPoint) { newMapPoint in
            guard isFocused(traceCreationActivity: .addingStartingPoints),
                  let mapPoint = newMapPoint,
                  let mapViewProxy = mapViewProxy else {
                return
            }
            currentActivity = .creatingTrace(.viewingStartingPoints)
            activeDetent = .half
            Task {
                await viewModel.addStartingPoints(
                    mapPoint: mapPoint,
                    with: mapViewProxy
                )
            }
        }
        .onChange(externalStartingPoints) { _ in
            viewModel.externalStartingPoints = externalStartingPoints
        }
        .alert(
            viewModel.userAlert?.title ?? "",
            isPresented: Binding(
                get: { viewModel.userAlert != nil },
                set: { _ in viewModel.userAlert = nil }
            )
        ) {
            viewModel.userAlert?.button
        } message: {
            Text(viewModel.userAlert?.description ?? "")
        }
    }
    
    // MARK: Computed Properties
    
    /// Indicates the number of the trace currently being viewed out the total number of traces.
    private var currentTraceLabel: String {
        guard let index = viewModel.selectedTraceIndex else { return "Error" }
        return String(
            localized: "Trace \(index+1, specifier: "%1$lld") of \(viewModel.completedTraces.count, specifier: "%2$lld")",
            bundle: .toolkitModule,
            comment: "A label indicating the index of the trace being viewed out of the total number of traces completed."
        )
    }
    
    /// The name of the selected utility element asset group.
    private var selectedAssetGroupName: String? {
        if case let .viewingTraces(activity) = currentActivity,
           case let .viewingElementGroup(elementGroup) = activity {
            return elementGroup
        }
        return nil
    }
    
    /// The starting point being inspected (if one exists).
    private var selectedStartingPoint: UtilityNetworkTraceStartingPoint? {
        if case let .creatingTrace(activity) = currentActivity,
           case let .inspectingStartingPoint(startingPoint) = activity {
            return startingPoint
        }
        return nil
    }
    
    /// Determines if the provided creation activity is the currently focused creation activity.
    /// - Parameter traceCreationActivity: A possible focus activity when creating traces.
    /// - Returns: A Boolean value indicating whether the provided activity is the currently focused
    /// creation activity.
    private func isFocused(traceCreationActivity: TraceCreationActivity) -> Bool {
        if case let .creatingTrace(activity) = currentActivity {
            return traceCreationActivity == activity
        }
        return false
    }
    
    /// Determines if the provided viewing activity is the currently focused viewing activity.
    /// - Parameter traceViewingActivity: A possible focus activity when viewing traces.
    /// - Returns: A Boolean value indicating whether the provided activity is the currently focused
    /// viewing activity.
    private func isFocused(traceViewingActivity: TraceViewingActivity) -> Bool {
        if case let .viewingTraces(activity) = currentActivity {
            return traceViewingActivity == activity
        }
        return false
    }
    
    /// Returns a "Back" button that performs a specified action when pressed.
    /// - Parameter title: The button's title.
    /// - Parameter action: The action to be performed.
    /// - Returns: The configured button.
    private func makeBackButton(title: String, _ action: @escaping () -> Void) -> some View {
        Button { action() } label: {
            Label {
                Text(title)
            } icon: {
                Image(systemName: "chevron.backward")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Returns a section header.
    /// - Parameter title: The title of the header.
    /// - Returns: The configured title.
    private func makeDetailSectionHeader(title: String) -> some View {
        Text(title)
            .font(.title3)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

private extension String {
    static var addNewButtonLabel: Self {
        .init(
            localized: "Add New",
            bundle: .toolkitModule,
            comment: "A button to add new utility trace starting points."
        )
    }
    
    static var advancedOptionsHeaderLabel: Self {
        .init(
            localized: "Advanced Options",
            bundle: .toolkitModule,
            comment: "A section header for advanced options."
        )
    }
    
    static var attributesSectionTitle: Self {
        .init(
            localized: "Attributes",
            bundle: .toolkitModule,
            comment: "A label in reference to the attributes of a geo element."
        )
    }
    
    static var cancelStartingPointSelection: Self {
        .init(
            localized: "Cancel Starting Point Selection",
            bundle: .toolkitModule,
            comment: "A label for a button to cancel the starting point selection operation."
        )
    }
    
    static var clearAllResults: Self {
        .init(
            localized: "Clear All Results",
            bundle: .toolkitModule,
            comment: "A directive to clear all of the completed utility network traces."
        )
    }
    
    static var clearAllResultsMessage: Self {
        .init(
            localized: "All the trace inputs and results will be lost.",
            bundle: .toolkitModule,
            comment: "A message describing the outcome of clearing all utility network trace results."
        )
    }
    
    static var colorLabel: Self {
        .init(
            localized: "Color",
            bundle: .toolkitModule,
            comment: "A label in reference to the color used to display utility trace result graphics."
        )
    }
    
    static var deleteButtonLabel: Self {
        .init(
            localized: "Delete",
            bundle: .toolkitModule,
            comment: "A label for a button used to delete a utility network trace input component or result."
        )
    }
    
    /// Title for the feature results section
    static var featureResultsTitle: Self {
        .init(
            localized: "Feature Results",
            bundle: .toolkitModule,
            comment: """
                A label in reference to utility elements returned as results of a utility network
                trace operation.
                """
        )
    }
    
    static var fractionAlongEdgeSectionTitle: Self {
        .init(
            localized: "Fraction Along Edge",
            bundle: .toolkitModule,
            comment: "A label in reference to a fractional distance along an edge style utility network element."
        )
    }
    
    static var functionResultsSectionTitle: Self {
        .init(
            localized: "Function Results",
            bundle: .toolkitModule,
            comment: """
                A label in reference to function outputs returned as results of a utility network
                trace operation.
                """
        )
    }
    
    static var modePickerTitle: Self {
        .init(
            localized: "Mode",
            bundle: .toolkitModule,
            comment: "The mode in which the utility network trace tool is being used (either creating traces or viewing traces)."
        )
    }
    
    static var nameLabel: Self {
        .init(
            localized: "Name",
            bundle: .toolkitModule,
            comment: "A label in reference to the user defined name for an individual utility network trace."
        )
    }
    
    static var networkSectionLabel: Self {
        .init(
            localized: "Network",
            bundle: .toolkitModule,
            comment: "A label in reference to a specific utility network."
        )
    }
    
    static var newTraceOptionLabel: Self {
        .init(
            localized: "New Trace",
            bundle: .toolkitModule,
            comment: "A label for a button to show new utility network trace configuration options."
        )
    }
    
    static var noConfigurationsAvailable: Self {
        .init(
            localized: "No configurations available.",
            bundle: .toolkitModule,
            comment: "A statement that no utility trace configurations are available."
        )
    }
    
    static var resultsOptionLabel: Self {
        .init(
            localized: "Results",
            bundle: .toolkitModule,
            comment: "A label for a button to show utility network trace results."
        )
    }
    
    /// A label for button to select a utility network.
    static var selectNetwork: Self {
        .init(
            localized: "Select Network",
            bundle: .toolkitModule,
            comment: "A label for button to select a utility network."
        )
    }
    
    /// A label for button to select a utility network trace configuration.
    static var selectTraceConfiguration: Self {
        .init(
            localized: "Select Trace Configuration",
            bundle: .toolkitModule,
            comment: "A label for button to select a utility network trace configuration."
        )
    }
    
    /// Title for the starting points section
    static var startingPointsTitle: Self {
        .init(
            localized: "Starting Points",
            bundle: .toolkitModule,
            comment: """
                A label in reference to the utility elements chosen as starting points for a utility
                network trace operation.
                """
        )
    }
    
    static var terminalConfigurationPickerTitle: Self {
        .init(
            localized: "Terminal Configuration",
            bundle: .toolkitModule,
            comment: "A label in reference to the chosen terminal configuration of a utility network element."
        )
    }
    
    static var traceButtonLabel: Self {
        .init(
            localized: "Trace",
            bundle: .toolkitModule,
            comment: "A label for a button to begin a utility network trace operation."
        )
    }
    
    static var traceConfigurationSectionLabel: Self {
        .init(
            localized: "Trace Configuration",
            bundle: .toolkitModule,
            comment: "A label in reference to a utility network trace configuration."
        )
    }
    
    static var unnamedAssetType: Self {
        .init(
            localized: "Unnamed Asset Type",
            bundle: .toolkitModule,
            comment: "A label to use in place of a utility element asset type name."
        )
    }
    
    static var zoomToButtonLabel: Self {
        .init(
            localized: "Zoom To",
            bundle: .toolkitModule,
            comment: "A button to change the map to the extent of the selected trace."
        )
    }
    
    static var zoomToResult: Self {
        .init(
            localized: "Zoom To Result",
            bundle: .toolkitModule,
            comment: "A user option specifying that a map should automatically change to show completed trace results."
        )
    }
}


@available(visionOS, unavailable)
public extension UtilityNetworkTrace /* Deprecated */ {
    /// A graphical interface to run pre-configured traces on a map's utility networks.
    /// - Parameters:
    ///   - graphicsOverlay: The graphics overlay to hold generated starting point and trace graphics.
    ///   - map: The map containing the utility network(s).
    ///   - mapPoint: Acts as the point at which newly selected starting point graphics will be created.
    ///   - screenPoint: Acts as the point of identification for items tapped in the utility network.
    ///   - mapViewProxy: The proxy to provide access to map view operations.
    ///   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
    ///   - startingPoints: An optional list of programmatically provided starting points.
    /// - Attention: Deprecated at 200.7.
    @available(*, deprecated, message: "Use 'init(graphicsOverlay:map:mapPoint:mapViewProxy:startingPoints:)' instead.")
    init(
        graphicsOverlay: Binding<GraphicsOverlay>,
        map: Map,
        mapPoint: Binding<Point?>,
        screenPoint: Binding<CGPoint?>,
        mapViewProxy: MapViewProxy?,
        viewpoint: Binding<Viewpoint?>,
        startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
    ) {
        self.mapViewProxy = mapViewProxy
        _activeDetent = .constant(nil)
        _mapPoint = mapPoint
        _graphicsOverlay = graphicsOverlay
        _externalStartingPoints = startingPoints
        _viewModel = StateObject(
            wrappedValue: UtilityNetworkTraceViewModel(
                map: map,
                graphicsOverlay: graphicsOverlay.wrappedValue,
                startingPoints: startingPoints.wrappedValue
            )
        )
    }
}

private extension Text {
    static func makeResultsLabel(_ results: Int) -> Self {
        .init(
            "^[\(results) Results](inflect: true)",
            bundle: .toolkitModule,
            comment: "A label indicating the number of results of a utility network trace."
        )
    }
}
