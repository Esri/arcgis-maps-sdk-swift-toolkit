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
        /// The user is viewing the list of chosen starting points.
        case viewingStartingPoints
        /// The user is viewing the list of available trace configurations.
        case viewingTraceConfigurations
    }
    
    /// Activities users will perform while using the Utility Network Trace tool.
    private enum UserActivity: Hashable {
        /// The user is creating a new trace.
        case creatingTrace(TraceCreationActivity?)
        /// The user is viewing traces that have been created.
        case viewingTraces
    }
    
    // MARK: States
    
    @State private var activeDetent: FloatingPanelDetent = .mid
    
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
                        return UserActivity.viewingTraces
                    }
                }, set: { newActivity, _ in
                    currentActivity = newActivity
                }
            )
        ) {
            Text("New trace").tag(UserActivity.creatingTrace(nil))
            Text("Results").tag(UserActivity.viewingTraces)
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    /// Allows the user to cancel out of selecting a new starting point.
    private var cancelAddStartingPoints: some View {
        Button(role: .destructive) {
            currentActivity = .creatingTrace(nil)
            activeDetent = .mid
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
                        viewModel.pendingTrace.configuration = configuration
                        currentActivity = .creatingTrace(nil)
                    }
            }
        }
    }
    
    /// The tab that allows for a new trace to be configured.
    @ViewBuilder private var newTraceTab: some View {
        List {
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
                    activeDetent = .min
                } label: {
                    Text("Add new starting point")
                }
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
            Section("Advanced") {
                ColorPicker(selection: $viewModel.pendingTrace.color) {
                    Text("Trace Color")
                }
                TextField(
                    "Trace Name",
                    text: $viewModel.pendingTrace.name
                )
            }
        }
        Button {
            viewModel.trace()
            currentActivity = .viewingTraces
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
                DisclosureGroup(viewModel
                    .selectedTrace?
                    .utilityElementTraceResult?
                    .elements.count.description ?? "0") {
                        ForEach(viewModel.selectedTrace?.assetLabels ?? [], id: \.self) { label in
                            Text(label)
                        }
                    }
            }
            Section("Function Result") {
                DisclosureGroup(viewModel
                    .selectedTrace?
                    .utilityFunctionTraceResult?
                    .functionOutputs.count.description ?? "0") {
                        ForEach(viewModel.selectedTrace?.functionOutputs ?? [], id: \.id) { item in
                            HStack {
                                Text(item.function.networkAttribute?.name ?? "Unnamed")
                                Spacer()
                                Text((item.result as? Double)?.description ?? "N/A")
                            }
                        }
                    }
            }
        }
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
            ForEach(Array(selectedStartingPoint!.geoElement.attributes.sorted(by: { $0.key < $1.key})), id: \.key) { item in
                HStack{
                    Text(item.key)
                    Spacer()
                    Text(item.value as? String ?? "")
                }
            }
        }
        Button {
            if let selectedStartingPoint = selectedStartingPoint {
                viewpoint = Viewpoint(targetExtent: selectedStartingPoint.extent)
            }
        } label: {
            Label {
                Text("Zoom To")
            } icon: {
                Image(systemName: "scope")
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
        graphicsOverlay: Binding<GraphicsOverlay>,
        map: Map,
        mapPoint: Binding<Point?>,
        viewPoint: Binding<CGPoint?>,
        mapViewProxy: Binding<MapViewProxy?>,
        viewpoint: Binding<Viewpoint?>
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
        Color.clear
            .floatingPanel(
                isPresented: .constant(true),
                detent: $activeDetent
            ) {
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
                    activeDetent = .mid
                    Task {
                        await viewModel.setStartingPoint(
                            at: viewPoint,
                            mapPoint: mapPoint,
                            with: mapViewProxy
                        )
                    }
                }
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
        if case let .creatingTrace(activity) = currentActivity {
            return traceCreationActivity == activity
        }
        return false
    }
}
