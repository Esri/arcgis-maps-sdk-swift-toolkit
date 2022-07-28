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

import ArcGIS
import SwiftUI

public struct UtilityNetworkTrace: View {
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
        /// The user is viewing a list of element results, grouped by asset group and asset type.
        case viewingElementGroup([String: [UtilityElement]])
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
    
    /// The current user activity.
    @State private var currentActivity: UserActivity = .creatingTrace(nil)
    
    /// A Boolean value indicating whether the map should be zoomed to the extent of the trace result.
    @State private var shouldZoomOnTraceCompletion = false
    
    /// A Boolean value indicating if the warning that all traces will be deleted is presented.
    @State private var showWarningAlert = false
    
    /// The view model used by the view. The `UtilityNetworkTraceViewModel` manages state.
    /// The view observes `UtilityNetworkTraceViewModel` for changes in state.
    @StateObject private var viewModel: UtilityNetworkTraceViewModel
    
    // MARK: Bindings
    
    /// Starting points programmatically provided to the trace tool.
    @Binding private var externalStartingPoints: [UtilityNetworkTraceStartingPoint]
    
    /// The graphics overlay to hold generated starting point and trace graphics.
    @Binding private var graphicsOverlay: GraphicsOverlay
    
    /// Provides a method of layer identification when starting points are being chosen.
    @Binding private var mapViewProxy: MapViewProxy?
    
    /// Acts as the point of identification for items tapped in the utility network.
    @Binding private var viewPoint: CGPoint?
    
    /// Acts as the point at which newly selected starting point graphics will be created.
    @Binding private var mapPoint: Point?
    
    /// Allows the Utility Network Trace Tool to update the parent map view's viewpoint.
    @Binding private var viewpoint: Viewpoint?
    
    // MARK: Subviews
    
    /// Allows the user to switch between the trace creation and viewing tabs.
    private var activityPicker: some View {
        Picker(
            "Mode",
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
            Text("New trace").tag(UserActivity.creatingTrace(nil))
            Text("Results").tag(UserActivity.viewingTraces(nil))
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    /// Allows the user to cancel out of selecting a new starting point.
    private var cancelAddStartingPoints: some View {
        Button(role: .destructive) {
            currentActivity = .creatingTrace(nil)
        } label: {
            Text("Cancel starting point selection")
        }
        .buttonStyle(.bordered)
    }
    
    /// Displays information about a chosen asset group.
    @ViewBuilder private var assetGroupDetail: some View {
        if let assetGroup = selectedAssetGroup {
            makeBackButton(title: featureResultsTitle) {
                currentActivity = .viewingTraces(.viewingFeatureResults)
            }
            makeDetailSectionHeader(
                title: assetGroup.first?.value.first?.assetGroup.name ?? "Unnamed Asset Group"
            )
            List {
                ForEach(assetGroup.sorted(by: { $0.key < $1.key }), id: \.key) { assetTypeGroup in
                    let elements = assetTypeGroup.value.sorted {
                        $0.objectID < $1.objectID
                    }
                    Section(assetTypeGroup.key) {
                        DisclosureGroup {
                            ForEach(elements) { element in
                                makeZoomToButton(text: "Object ID \(element.objectID.description)") {
                                    Task {
                                        if let feature = await viewModel.getFeatureFor(element: element),
                                           let geometry = feature.geometry {
                                            viewpoint = Viewpoint(targetExtent: geometry.extent)
                                        }
                                    }
                                }
                            }
                        } label: {
                            Text("(\(elements.count))")
                        }
                    }
                }
            }
        }
    }
    
    /// Displays the list of available named trace configurations.
    @ViewBuilder private var configurationsList: some View {
        if viewModel.configurations.isEmpty {
            Text("No configurations available")
        } else {
            ForEach(viewModel.configurations) { configuration in
                Button {
                    viewModel.setPendingTrace(configuration: configuration)
                    currentActivity = .creatingTrace(nil)
                } label: {
                    Text(configuration.name)
                }
                .listRowBackground(configuration == viewModel.pendingTrace.configuration ? Color.secondary.opacity(0.5) : nil)
            }
        }
    }
    
    /// Displays the list of available networks.
    @ViewBuilder private var networksList: some View {
        ForEach(viewModel.networks, id: \.self) { network in
            Text(network.name)
                .lineLimit(1)
                .listRowBackground(network == viewModel.network ? Color.secondary.opacity(0.5) : nil)
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
                Section("Network") {
                    DisclosureGroup(
                        viewModel.network?.name ?? "None selected",
                        isExpanded: Binding(
                            get: { isFocused(traceCreationActivity: .viewingNetworkOptions) },
                            set: { currentActivity = .creatingTrace($0 ? .viewingNetworkOptions : nil) }
                        )
                    ) {
                        networksList
                    }
                }
            }
            Section("Trace Configuration") {
                DisclosureGroup(
                    viewModel.pendingTrace.configuration?.name ?? "None selected",
                    isExpanded: Binding(
                        get: { isFocused(traceCreationActivity: .viewingTraceConfigurations) },
                        set: { currentActivity = .creatingTrace($0 ? .viewingTraceConfigurations : nil) }
                    )
                ) {
                    configurationsList
                }
            }
            Section(startingPointsTitle) {
                Button {
                    currentActivity = .creatingTrace(.addingStartingPoints)
                } label: {
                    Text("Add new")
                }
                if !viewModel.pendingTrace.startingPoints.isEmpty {
                    DisclosureGroup(
                        "\(viewModel.pendingTrace.startingPoints.count) selected",
                        isExpanded: Binding(
                            get: { isFocused(traceCreationActivity: .viewingStartingPoints) },
                            set: { currentActivity = .creatingTrace($0 ? .viewingStartingPoints : nil) }
                        )
                    ) {
                        startingPointsList
                    }
                }
            }
            Section {
                DisclosureGroup(
                    "Advanced Options",
                    isExpanded: Binding(
                        get: { isFocused(traceCreationActivity: .viewingAdvancedOptions) },
                        set: { currentActivity = .creatingTrace($0 ? .viewingAdvancedOptions : nil) }
                    )
                ) {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField(
                            "Name",
                            text: $viewModel.pendingTrace.name
                        )
                        .onSubmit {
                            viewModel.pendingTrace.userDidSpecifyName = true
                        }
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.blue)
                    }
                    ColorPicker(selection: $viewModel.pendingTrace.color) {
                        Text("Color")
                    }
                    Toggle(isOn: $shouldZoomOnTraceCompletion) {
                        Text("Zoom to result")
                    }
                }
            }
        }
        Button {
            Task {
                if await viewModel.trace() {
                    currentActivity = .viewingTraces(nil)
                    if shouldZoomOnTraceCompletion,
                       let extent = viewModel.selectedTrace?.resultExtent {
                        viewpoint = Viewpoint(targetExtent: extent)
                    }
                }
            }
        } label: {
            Text("Trace")
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
                    } label: {
                        Image(systemName: "chevron.backward")
                    }
                }
                Text(currentTraceLabel)
                    .padding(.horizontal)
                if viewModel.completedTraces.count > 1 {
                    Button {
                        viewModel.selectNextTrace()
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
                    Button("Zoom To") {
                        viewpoint = Viewpoint(targetExtent: resultExtent)
                    }
                }
                Button("Delete", role: .destructive) {
                    if viewModel.completedTraces.count == 1 {
                        currentActivity = .creatingTrace(nil)
                    }
                    viewModel.delete(selectedTrace)
                }
            }
            .font(.title3)
        }
        List {
            Section(featureResultsTitle) {
                DisclosureGroup(
                    "(\(viewModel.selectedTrace?.assetCount ?? 0))",
                    isExpanded: Binding(
                        get: { isFocused(traceViewingActivity: .viewingFeatureResults) },
                        set: { currentActivity = .viewingTraces($0 ? .viewingFeatureResults : nil) }
                    )
                ) {
                    ForEach(
                        (viewModel.selectedTrace?.assets ?? [:]).sorted(by: { $0.key < $1.key }), id: \.key
                    ) { assetGroup in
                        HStack {
                            Text(assetGroup.key)
                            Spacer()
                            Text("(\(assetGroup.value.compactMap({ $0.value.count }).reduce(0, +)))")
                        }
                        .foregroundColor(.blue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            currentActivity = .viewingTraces(.viewingElementGroup(assetGroup.value))
                        }
                    }
                }
            }
            Section("Function Results") {
                DisclosureGroup(
                    "(\(viewModel.selectedTrace?.utilityFunctionTraceResult?.functionOutputs.count ?? 0))",
                    isExpanded: Binding(
                        get: { isFocused(traceViewingActivity: .viewingFunctionResults) },
                        set: { currentActivity = .viewingTraces($0 ? .viewingFunctionResults : nil) }
                    )
                ) {
                    ForEach(viewModel.selectedTrace?.functionOutputs ?? [], id: \.id) { item in
                        HStack {
                            Text(item.function.networkAttribute?.name ?? "Unnamed")
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(item.function.functionType.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text((item.result as? Double)?.description ?? "N/A")
                            }
                        }
                    }
                }
            }
            Section {
                DisclosureGroup(
                    "Advanced Options",
                    isExpanded: Binding(
                        get: { isFocused(traceViewingActivity: .viewingAdvancedOptions) },
                        set: { currentActivity = .viewingTraces($0 ? .viewingAdvancedOptions : nil) }
                    )
                ) {
                    ColorPicker(
                        selection: Binding(get: {
                            viewModel.selectedTrace?.color ?? Color.clear
                        }, set: { newValue in
                            if var trace = viewModel.selectedTrace {
                                trace.color = newValue
                                viewModel.update(completedTrace: trace)
                            }
                        })
                    ) {
                        Text("Color")
                    }
                }
            }
        }
        .padding([.vertical], 2)
        Button(role: .destructive) {
            showWarningAlert.toggle()
        } label: {
            Text(clearResultsTitle)
        }
        .buttonStyle(.bordered)
        .alert(clearResultsTitle, isPresented: $showWarningAlert) {
            Button(role: .destructive) {
                viewModel.deleteAllTraces()
                currentActivity = .creatingTrace(nil)
            } label: {
                Text("OK")
            }
        } message: {
            Text("Are you sure? All the trace inputs and results will be lost.")
        }
    }
    
    /// Displays information about a chosen starting point.
    @ViewBuilder private var startingPointDetail: some View {
        makeBackButton(title: startingPointsTitle) {
            currentActivity = .creatingTrace(.viewingStartingPoints)
        }
        Menu(selectedStartingPoint?.utilityElement?.assetType.name ?? "Unnamed Asset Type") {
            Button("Zoom To") {
                if let selectedStartingPoint = selectedStartingPoint,
                   let extent = selectedStartingPoint.geoElement.geometry?.extent {
                    viewpoint = Viewpoint(targetExtent: extent)
                }
            }
            Button("Delete", role: .destructive) {
                if let startingPoint = selectedStartingPoint {
                    viewModel.delete(startingPoint)
                    currentActivity = .creatingTrace(.viewingStartingPoints)
                }
            }
        }
        .font(.title3)
        List {
            if selectedStartingPoint?.utilityElement?.networkSource.kind == .edge {
                Section("Fraction Along Edge") {
                    Slider(value: Binding(get: {
                        viewModel.pendingTrace.startingPoints.first {
                            $0 == selectedStartingPoint
                        }?.utilityElement?.fractionAlongEdge ?? .zero
                    }, set: { newValue in
                        if let selectedStartingPoint = selectedStartingPoint {
                            viewModel.setFractionAlongEdgeFor(
                                startingPoint: selectedStartingPoint,
                                to: newValue
                            )
                        }
                    }))
                }
            } else if selectedStartingPoint?.utilityElement?.networkSource.kind == .junction &&
                        selectedStartingPoint?.utilityElement?.terminal != nil &&
                        !(selectedStartingPoint?.utilityElement?.assetType.terminalConfiguration?.terminals.isEmpty ?? true) {
                Section {
                    Picker(
                        "Terminal Configuration",
                        selection: Binding(get: {
                            selectedStartingPoint!.utilityElement!.terminal!
                        }, set: { newValue in
                            viewModel.setTerminalConfigurationFor(startingPoint: selectedStartingPoint!, to: newValue)
                        })
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
            Section("Attributes") {
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
                    viewModel.delete(startingPoint)
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
    
    /// A graphical interface to run pre-configured traces on a map's utility networks.
    /// - Parameters:
    ///   - graphicsOverlay: The graphics overlay to hold generated starting point and trace
    ///   graphics.
    ///   - map: The map containing the utility network(s).
    ///   - mapPoint: Acts as the point at which newly selected starting point graphics will be
    ///   created.
    ///   - viewPoint: Acts as the point of identification for items tapped in the utility network.
    ///   - mapViewProxy: Provides a method of layer identification when starting points are being
    ///   chosen.
    ///   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
    ///   - startingPoints: An optional list of programmatically provided starting points.
    public init(
        graphicsOverlay: Binding<GraphicsOverlay>,
        map: Map,
        mapPoint: Binding<Point?>,
        viewPoint: Binding<CGPoint?>,
        mapViewProxy: Binding<MapViewProxy?>,
        viewpoint: Binding<Viewpoint?>,
        startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
    ) {
        _viewPoint = viewPoint
        _mapPoint = mapPoint
        _mapViewProxy = mapViewProxy
        _graphicsOverlay = graphicsOverlay
        _viewpoint = viewpoint
        _externalStartingPoints = startingPoints
        _viewModel = StateObject(
            wrappedValue: UtilityNetworkTraceViewModel(
                map: map,
                graphicsOverlay: graphicsOverlay.wrappedValue,
                startingPoints: startingPoints.wrappedValue
            )
        )
    }
    
    public var body: some View {
        VStack {
            if !viewModel.completedTraces.isEmpty &&
                !isFocused(traceCreationActivity: .addingStartingPoints) {
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
        .onChange(of: viewPoint) { newValue in
            guard isFocused(traceCreationActivity: .addingStartingPoints),
                  let mapViewProxy = mapViewProxy,
                  let mapPoint = mapPoint,
                  let viewPoint = viewPoint else {
                return
            }
            currentActivity = .creatingTrace(.viewingStartingPoints)
            Task {
                await viewModel.makeStartingPoint(
                    at: viewPoint,
                    mapPoint: mapPoint,
                    with: mapViewProxy
                )
            }
        }
        .onChange(of: externalStartingPoints) { _ in
            viewModel.externalStartingPoints = externalStartingPoints
        }
        .alert(
            "Warning",
            isPresented: Binding(
                get: { !viewModel.userWarning.isEmpty },
                set: { _ in viewModel.userWarning = "" }
            )
        ) { } message: {
            Text(viewModel.userWarning)
        }
    }
    
    // MARK: Computed Properties
    
    /// Indicates the number of the trace currently being viewed out the total number of traces.
    private var currentTraceLabel: String {
        guard let index = viewModel.selectedTraceIndex else { return "Error" }
        return "Trace \(index+1) of \(viewModel.completedTraces.count.description)"
    }
    
    /// The selected utility element asset group.
    private var selectedAssetGroup: [String: [UtilityElement]]? {
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
    
    /// Returns a "Zoom To" button that performs a specified action when pressed.
    /// - Parameter text: The custom text to be displayed within the button.
    /// - Parameter action: The action to be performed.
    /// - Returns: The configured button.
    private func makeZoomToButton(
        text: String = "Zoom To",
        _ action: @escaping () -> Void
    ) -> some View {
        Button { action() } label: {
            Label {
                Text(text)
            } icon: {
                Image(systemName: "scope")
            }
        }
    }
    
    /// Title for the clear all results feature
    private let clearResultsTitle = "Clear All Results"
    
    /// Title for the feature results section
    private let featureResultsTitle = "Feature Results"
    
    /// Title for the starting points section
    private let startingPointsTitle = "Starting Points"
}
