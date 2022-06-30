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
    
    /// If `true`, the site and facility selector will appear as a sheet.
    /// If `false`, the site and facility selector will appear as a popup modal alongside the level selector.
    private var isCompact: Bool {
        return horizontalSizeClass == .compact || verticalSizeClass == .compact
    }
    
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
    
    /// The current user activity.
    @State private var currentActivity: UserActivity = .creatingTrace(nil)
    
    /// Indicates if the warning that all traces will be deleted is presented.
    @State private var warningIsPresented = false
    
    /// The view model used by the view. The `UtilityNetworkTraceViewModel` manages state.
    /// The view observes `UtilityNetworkTraceViewModel` for changes in state.
    @StateObject private var viewModel: UtilityNetworkTraceViewModel
    
    // MARK: Bindings
    
    /// The graphics overlay to hold generated starting point and trace graphics.
    @Binding private var graphicsOverlay: GraphicsOverlay
    
    /// Provides a method of layer identification when starting points are being chosen.
    @Binding private var mapViewProxy: MapViewProxy?
    
    /// Acts as the point of identification for items tapped in the utility network.
    @Binding private var pointInScreen: CGPoint?
    
    /// Acts as the point at which newly selected starting point graphics will be created.
    @Binding private var pointInMap: Point?
    
    /// Allows the Utility Network Trace Tool to update the parent map view's viewpoint.
    @Binding private var viewpoint: Viewpoint?
    
    // MARK: ViewBuilders
    
    /// Allows the user to switch between the trace creation and viewing tabs.
    @ViewBuilder private var activityPicker: some View {
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
    
    /// Displays the list of available named trace configurations.
    @ViewBuilder private var configurationsList: some View {
        if viewModel.configurations.isEmpty {
            Text("No configurations available")
        } else {
            ForEach(viewModel.configurations, id: \.name) { configuration in
                Button {
                    withAnimation {
                        viewModel.pendingTrace.configuration = configuration
                        currentActivity = .creatingTrace(nil)
                    }
                } label: {
                    Label {
                        Text(configuration.name)
                            .lineLimit(1)
                    } icon: {
                        Image(systemName: "circle")
                            .symbolVariant(configuration == viewModel.pendingTrace.configuration ? .fill: .none)
                    }
                }
            }
        }
    }
    
    /// The tab that allows for a new trace to be configured.
    @ViewBuilder private var newTraceTab: some View {
        List {
            if !isAddingStartingPoints {
                Section("Trace Configuration") {
                    DisclosureGroup(
                        viewModel.pendingTrace.configuration?.name ?? "None selected",
                        isExpanded: configurationOptionsIsExpanded
                    ) {
                        configurationsList
                    }
                }
            }
            Section("Starting Points") {
                if isAddingStartingPoints {
                    Button {
                        currentActivity = .creatingTrace(nil)
                    } label: {
                        Text("Cancel starting point selection")
                    }
                    .tint(.red)
                } else {
                    Button {
                        currentActivity = .creatingTrace(.addingStartingPoints)
                    } label: {
                        Text("Add new starting point")
                    }
                    DisclosureGroup(
                        "\(viewModel.pendingTrace.startingPoints.count) selected",
                        isExpanded: startingPointsListIsExpanded
                    ) {
                        startingPointsList
                    }
                }
            }
            if !isAddingStartingPoints {
                Section("Advanced") {
                    ColorPicker(
                        selection: $viewModel.pendingTrace.color
                    ) {
                        Text("Trace Color")
                    }
                    if !isCompact {
                        TextField(
                            "Trace Name",
                            text: $viewModel.pendingTrace.name
                        )
                    }
                }
            }
        }
        if !isAddingStartingPoints {
            Button {
                viewModel.trace()
                currentActivity = .viewingTraces
            } label: {
                Text("Trace")
            }
            .buttonStyle(.bordered)
            .disabled(!viewModel.canRunTrace)
        }
    }
    
    /// The tab that allows for viewing completed traces.
    @ViewBuilder private var resultsTab: some View {
        HStack {
            Button {
                viewModel.selectPreviousTrace()
            } label: {
                Image(systemName: "chevron.backward")
            }
            Text(currentTraceLabel)
                .padding(.horizontal)
            Button {
                viewModel.selectNextTrace()
            } label: {
                Image(systemName: "chevron.forward")
            }
        }
        .font(.title3)
        .padding()
        if let traceName = viewModel.selectedTrace?.name, traceName != "" {
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
                                Text(item.output.function.networkAttribute?.name ?? "Unnamed")
                                Spacer()
                                Text((item.output.result as? Double)?.description ?? "N/A")
                            }
                        }
                    }
            }
        }
        Button {
            warningIsPresented.toggle()
        } label: {
            Text("Clear All Results")
                .tint(.red)
        }
        .padding()
        .alert("Clear All Results", isPresented: $warningIsPresented) {
            Button(role: .destructive) {
                viewModel.deleteAllTraces()
                currentActivity = .creatingTrace(nil)
            } label: {
                Text("OK")
            }
        } message: {
            Text("Are you sure? All the trace Inputs and Results will be lost.")
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
            Text(selectedStartingPoint?.utilityElement.globalID.uuidString ?? "N/A")
            ForEach(Array(selectedStartingPoint!.geoElement.attributes.sorted(by: { $0.key < $1.key})), id: \.key) { item in
                HStack{
                    Text(item.key)
                    Spacer()
                    Text(item.value as? String ?? "")
                }
            }
        }
        Button {
            if let selectedStartingPoint {
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
    @ViewBuilder private var startingPointsList: some View {
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
    ///   - map: The parent map view.
    ///   - pointInMap: Acts as the point at which newly selected starting point graphics will be
    ///   created.
    ///   - pointInScreen: Acts as the point of identification for items tapped in the utility network.
    ///   - mapViewProxy: Provides a method of layer identification when starting points are being
    ///   chosen.
    ///   - viewpoint: Allows the Utility Network Trace Tool to update the parent map view's viewpoint.
    public init(
        _ graphicsOverlay: Binding<GraphicsOverlay>,
        _ map: Map,
        _ pointInMap: Binding<Point?>,
        _ pointInScreen: Binding<CGPoint?>,
        _ mapViewProxy: Binding<MapViewProxy?>,
        _ viewpoint: Binding<Viewpoint?>
    ) {
        _pointInScreen = pointInScreen
        _pointInMap = pointInMap
        _mapViewProxy = mapViewProxy
        _graphicsOverlay = graphicsOverlay
        _viewpoint = viewpoint
        _viewModel = StateObject(
            wrappedValue: UtilityNetworkTraceViewModel(
                map: map,
                graphicsOverlay: graphicsOverlay.wrappedValue
            )
        )
        UITableView.appearance().backgroundColor = UIColor.systemGroupedBackground
    }
    
    public var body: some View {
        VStack {
            if !viewModel.completedTraces.isEmpty && !isAddingStartingPoints {
                activityPicker
            }
            switch currentActivity {
            case .creatingTrace(let activity):
                switch activity {
                case .inspectingStartingPoint:
                    startingPointDetail
                default:
                    newTraceTab
                }
            case .viewingTraces:
                resultsTab
            }
        }
        .animation(.default, value: currentActivity)
        .onChange(of: pointInScreen) { newValue in
            guard isAddingStartingPoints,
                  let mapViewProxy = mapViewProxy,
                  let pointInMap = pointInMap,
                  let pointInScreen = pointInScreen else {
                return
            }
            currentActivity = .creatingTrace(.viewingStartingPoints)
            Task {
                await viewModel.setStartingPoint(
                    at: pointInScreen,
                    mapPoint: pointInMap,
                    with: mapViewProxy
                )
            }
        }
    }
    
    // MARK: Computed Properties
    
    /// Indicates if the list of trace configuration options is expanded.
    private var configurationOptionsIsExpanded: Binding<Bool> {
        Binding(get: {
            switch currentActivity {
            case .creatingTrace(let activity):
                switch activity {
                case .viewingTraceConfigurations:
                    return true
                default:
                    return false
                }
            default:
                return false
            }
        }, set: { val in
            if val {
                currentActivity = .creatingTrace(.viewingTraceConfigurations)
            } else {
                currentActivity = .creatingTrace(nil)
            }
        })
    }
    
    /// Indicates if the list of chosen starting points is expanded.
    private var startingPointsListIsExpanded: Binding<Bool> {
        Binding(get: {
            switch currentActivity {
            case .creatingTrace(let activity):
                switch activity {
                case .viewingStartingPoints:
                    return true
                default:
                    return false
                }
            default:
                return false
            }
        }, set: { val in
            if val {
                currentActivity = .creatingTrace(.viewingStartingPoints)
            } else {
                currentActivity = .creatingTrace(nil)
            }
        })
    }
    
    /// Indicates the number of the trace currently being viewed out the total number of traces.
    private var currentTraceLabel: String {
        guard let index = viewModel.selectedTraceIndex else { return "Error" }
        return "Trace \(index+1) of \(viewModel.completedTraces.count.description)"
    }
    
    /// Indicates if the user is currently adding starting points.
    private var isAddingStartingPoints: Bool {
        switch currentActivity {
        case .creatingTrace(let activity):
            switch activity {
            case .addingStartingPoints:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    /// The starting point being inspected (if one exists).
    private var selectedStartingPoint: UtilityNetworkTraceStartingPoint? {
        switch currentActivity {
        case .creatingTrace(let activity):
            switch activity {
            case .inspectingStartingPoint(let startingPoint):
                return startingPoint
            default:
                return nil
            }
        default:
            return nil
        }
    }
}
