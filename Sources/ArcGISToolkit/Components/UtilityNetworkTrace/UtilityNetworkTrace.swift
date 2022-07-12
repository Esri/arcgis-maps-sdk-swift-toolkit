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
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass: UserInterfaceSizeClass?
    
    @Environment(\.verticalSizeClass)
    private var verticalSizeClass: UserInterfaceSizeClass?
    
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
        case viewingElementResults
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
    
    /// A Boolean value indicating if the warning that all traces will be deleted is presented.
    @State private var showWarningAlert = false
    
    /// The view model used by the view. The `UtilityNetworkTraceViewModel` manages state.
    /// The view observes `UtilityNetworkTraceViewModel` for changes in state.
    @StateObject private var viewModel: UtilityNetworkTraceViewModel
    
    // MARK: Bindings
    
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
    
    /// Displays the list of available named trace configurations.
    @ViewBuilder private var configurationsList: some View {
        if viewModel.configurations.isEmpty {
            Text("No configurations available")
        } else {
            ForEach(viewModel.configurations) { configuration in
                Text(configuration.name)
                    .lineLimit(1)
                    .listRowBackground(configuration == viewModel.pendingTrace.configuration ? Color.secondary.opacity(0.5) : nil)
                    .onTapGesture {
                        viewModel.setPendingTrace(configuration: configuration)
                        currentActivity = .creatingTrace(nil)
                    }
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
            Section("Starting Points") {
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
                    ColorPicker(selection: $viewModel.pendingTrace.color) {
                        Text("Trace Color")
                    }
                    TextField(
                        "Trace Name",
                        text: $viewModel.pendingTrace.name
                    )
                    .onSubmit {
                        viewModel.pendingTrace.userDidSpecifyName = true
                    }
                }
            }
        }
        Button {
            Task {
                let traceSuccess = await viewModel.trace()
                if traceSuccess {
                    currentActivity = .viewingTraces(nil)
                }
            }
        } label: {
            Text("Trace")
        }
        .buttonStyle(.bordered)
        .disabled(!viewModel.canRunTrace)
    }
    
    /// The tab that allows for viewing completed traces.
    @ViewBuilder private var resultsTab: some View {
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
        .font(.title3)
        .padding(2.5)
        if let traceName = viewModel.selectedTrace?.name, !traceName.isEmpty {
            Text(traceName)
        }
        List {
            Section("Element Result") {
                DisclosureGroup(
                    viewModel.selectedTrace?.utilityElementTraceResult?.elements.count.description ?? "0",
                    isExpanded: Binding(
                        get: { isFocused(traceViewingActivity: .viewingElementResults) },
                        set: { currentActivity = .viewingTraces($0 ? .viewingElementResults : nil) }
                    )
                ) {
                    ForEach(viewModel.selectedTrace?.assetLabels ?? [], id: \.self) { label in
                        Text(label)
                    }
                }
            }
            Section("Function Result") {
                DisclosureGroup(
                    viewModel.selectedTrace?.utilityFunctionTraceResult?.functionOutputs.count.description ?? "0",
                    isExpanded: Binding(
                        get: { isFocused(traceViewingActivity: .viewingFunctionResults) },
                        set: { currentActivity = .viewingTraces($0 ? .viewingFunctionResults : nil) }
                    )
                ) {
                    ForEach(viewModel.selectedTrace?.functionOutputs ?? [], id: \.id) { item in
                        HStack {
                            Text(item.function.networkAttribute?.name ?? "Unnamed")
                            Spacer()
                            Text((item.result as? Double)?.description ?? "N/A")
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
                        Text("Trace Color")
                    }
                }
            }
        }
        makeZoomToButtom {
            if let resultEnvelope = GeometryEngine.combineExtents(of: [
                viewModel.selectedTrace?.utilityGeometryTraceResult?.multipoint,
                viewModel.selectedTrace?.utilityGeometryTraceResult?.polygon,
                viewModel.selectedTrace?.utilityGeometryTraceResult?.polyline
            ].compactMap { $0 }) {
                viewpoint = Viewpoint(targetExtent: resultEnvelope.extent)
            }
        }
        .padding([.vertical], 2)
        Button {
            showWarningAlert.toggle()
        } label: {
            Text("Clear All Results")
                .tint(.red)
        }
        .alert("Clear All Results", isPresented: $showWarningAlert) {
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
        Button {
            currentActivity = .creatingTrace(.viewingStartingPoints)
        } label: {
            Label {
                Text("Back")
            } icon: {
                Image(systemName: "chevron.backward")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        Text(selectedStartingPoint?.utilityElement.assetType.name ?? "Unnamed")
            .font(.title3)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .center)
        List {
            if selectedStartingPoint?.utilityElement.networkSource.kind == .edge {
                Section("Fraction Along Edge") {
                    Slider(value: Binding(get: {
                        viewModel.pendingTrace.startingPoints.first { sp in
                            sp.utilityElement.globalID == selectedStartingPoint?.utilityElement.globalID
                        }?.utilityElement.fractionAlongEdge ?? .zero
                    }, set: { newValue in
                        if let selectedStartingPoint {
                            viewModel.setFractionAlongEdgeFor(
                                startingPoint: selectedStartingPoint,
                                to: newValue
                            )
                        }
                    }))
                }
            } else if selectedStartingPoint?.utilityElement.networkSource.kind == .junction &&
                        selectedStartingPoint?.utilityElement.terminal != nil &&
                        !(selectedStartingPoint?.utilityElement.assetType.terminalConfiguration?.terminals.isEmpty ?? true) {
                Section {
                    Picker(
                        "Terminal Configuration",
                        selection: Binding(get: {
                            selectedStartingPoint!.utilityElement.terminal!
                        }, set: { newValue in
                            viewModel.setTerminalConfigurationFor(startingPoint: selectedStartingPoint!, to: newValue)
                        })
                    ) {
                        ForEach(viewModel.pendingTrace.startingPoints.first { sp in
                            sp.utilityElement.globalID == selectedStartingPoint?.utilityElement.globalID
                        }?.utilityElement.assetType.terminalConfiguration?.terminals ?? [], id: \.self) {
                            Text($0.name)
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            ForEach(Array(selectedStartingPoint!.geoElement.attributes.sorted(by: { $0.key < $1.key})), id: \.key) { item in
                HStack{
                    Text(item.key)
                    Spacer()
                    Text(item.value as? String ?? "")
                }
            }
        }
        makeZoomToButtom {
            if let selectedStartingPoint {
                viewpoint = Viewpoint(targetExtent: selectedStartingPoint.extent)
            }
        }
    }
    
    /// Displays the chosen starting points for the new trace.
    private var startingPointsList: some View {
        ForEach(viewModel.pendingTrace.startingPoints, id: \.utilityElement.globalID) { startingPoint in
            Button {
                currentActivity = .creatingTrace(
                    .inspectingStartingPoint(startingPoint)
                )
            } label: {
                Label {
                    Text(startingPoint.utilityElement.assetType.name)
                        .lineLimit(1)
                } icon: {
                    Image(uiImage: startingPoint.image)
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
    public init(
        _ graphicsOverlay: Binding<GraphicsOverlay>,
        _ map: Map,
        _ mapPoint: Binding<Point?>,
        _ viewPoint: Binding<CGPoint?>,
        _ mapViewProxy: Binding<MapViewProxy?>,
        _ viewpoint: Binding<Viewpoint?>
    ) {
        _viewPoint = viewPoint
        _mapPoint = mapPoint
        _mapViewProxy = mapViewProxy
        _graphicsOverlay = graphicsOverlay
        _viewpoint = viewpoint
        _viewModel = StateObject(
            wrappedValue: UtilityNetworkTraceViewModel(
                map: map,
                graphicsOverlay: graphicsOverlay.wrappedValue
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
            case .viewingTraces:
                resultsTab
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
                await viewModel.setStartingPoint(
                    at: viewPoint,
                    mapPoint: mapPoint,
                    with: mapViewProxy
                )
            }
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
        if case let .creatingTrace(activity) = currentActivity{
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
    
    /// Returns a "Zoom To" button that performs a specified action when pressed.
    /// - Parameter action: The action to be performed.
    /// - Returns: The configured button.
    private func makeZoomToButtom(_ action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Label {
                Text("Zoom To")
            } icon: {
                Image(systemName: "scope")
            }
        }
    }
}
