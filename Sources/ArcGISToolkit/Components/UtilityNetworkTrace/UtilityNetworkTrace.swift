***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

public struct UtilityNetworkTrace: View {
***REMOVED******REMOVED*** MARK: Enums
***REMOVED***
***REMOVED******REMOVED***/ Activities users will perform while creating a new trace.
***REMOVED***private enum TraceCreationActivity: Hashable {
***REMOVED******REMOVED******REMOVED***/ The user is adding starting points.
***REMOVED******REMOVED***case addingStartingPoints
***REMOVED******REMOVED******REMOVED***/ The user is inspecting details of a chosen starting point.
***REMOVED******REMOVED***case inspectingStartingPoint(UtilityNetworkTraceStartingPoint)
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of advanced options.
***REMOVED******REMOVED***case viewingAdvancedOptions
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of available networks.
***REMOVED******REMOVED***case viewingNetworkOptions
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of chosen starting points.
***REMOVED******REMOVED***case viewingStartingPoints
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of available trace configurations.
***REMOVED******REMOVED***case viewingTraceConfigurations
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Activities users will perform while viewing completed traces.
***REMOVED***private enum TraceViewingActivity: Hashable {
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of available trace options.
***REMOVED******REMOVED***case viewingAdvancedOptions
***REMOVED******REMOVED******REMOVED***/ The user is viewing a list of element results, grouped by asset group and asset type.
***REMOVED******REMOVED***case viewingElementGroup([String: [UtilityElement]])
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of feature results.
***REMOVED******REMOVED***case viewingFeatureResults
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of function results.
***REMOVED******REMOVED***case viewingFunctionResults
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Activities users will perform while using the Utility Network Trace tool.
***REMOVED***private enum UserActivity: Hashable {
***REMOVED******REMOVED******REMOVED***/ The user is creating a new trace.
***REMOVED******REMOVED***case creatingTrace(TraceCreationActivity?)
***REMOVED******REMOVED******REMOVED***/ The user is viewing traces that have been created.
***REMOVED******REMOVED***case viewingTraces(TraceViewingActivity?)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: States
***REMOVED***
***REMOVED******REMOVED***/ The current user activity.
***REMOVED***@State private var currentActivity: UserActivity = .creatingTrace(nil)
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the map should be zoomed to the extent of the trace result.
***REMOVED***@State private var shouldZoomOnTraceCompletion = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the warning that all traces will be deleted is presented.
***REMOVED***@State private var showWarningAlert = false
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `UtilityNetworkTraceViewModel` manages state.
***REMOVED******REMOVED***/ The view observes `UtilityNetworkTraceViewModel` for changes in state.
***REMOVED***@StateObject private var viewModel: UtilityNetworkTraceViewModel
***REMOVED***
***REMOVED******REMOVED*** MARK: Bindings
***REMOVED***
***REMOVED******REMOVED***/ Starting points programmatically provided to the trace tool.
***REMOVED***@Binding private var externalStartingPoints: [UtilityNetworkTraceStartingPoint]
***REMOVED***
***REMOVED******REMOVED***/ The graphics overlay to hold generated starting point and trace graphics.
***REMOVED***@Binding private var graphicsOverlay: GraphicsOverlay
***REMOVED***
***REMOVED******REMOVED***/ Provides a method of layer identification when starting points are being chosen.
***REMOVED***@Binding private var mapViewProxy: MapViewProxy?
***REMOVED***
***REMOVED******REMOVED***/ Acts as the point of identification for items tapped in the utility network.
***REMOVED***@Binding private var viewPoint: CGPoint?
***REMOVED***
***REMOVED******REMOVED***/ Acts as the point at which newly selected starting point graphics will be created.
***REMOVED***@Binding private var mapPoint: Point?
***REMOVED***
***REMOVED******REMOVED***/ Allows the Utility Network Trace Tool to update the parent map view's viewpoint.
***REMOVED***@Binding private var viewpoint: Viewpoint?
***REMOVED***
***REMOVED******REMOVED*** MARK: Subviews
***REMOVED***
***REMOVED******REMOVED***/ Allows the user to switch between the trace creation and viewing tabs.
***REMOVED***private var activityPicker: some View {
***REMOVED******REMOVED***Picker(
***REMOVED******REMOVED******REMOVED***"Mode",
***REMOVED******REMOVED******REMOVED***selection: Binding<UserActivity>(
***REMOVED******REMOVED******REMOVED******REMOVED***get: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch currentActivity {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .creatingTrace(_):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return UserActivity.creatingTrace(nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .viewingTraces:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return UserActivity.viewingTraces(nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***, set: { newActivity, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = newActivity
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***Text("New trace").tag(UserActivity.creatingTrace(nil))
***REMOVED******REMOVED******REMOVED***Text("Results").tag(UserActivity.viewingTraces(nil))
***REMOVED***
***REMOVED******REMOVED***.pickerStyle(.segmented)
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Allows the user to cancel out of selecting a new starting point.
***REMOVED***private var cancelAddStartingPoints: some View {
***REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text("Cancel starting point selection")
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays information about a chosen asset group.
***REMOVED***@ViewBuilder private var assetGroupDetail: some View {
***REMOVED******REMOVED***if let assetGroup = selectedAssetGroup {
***REMOVED******REMOVED******REMOVED***makeBackButton(title: featureResultsTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces(.viewingFeatureResults)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***makeDetailSectionHeader(
***REMOVED******REMOVED******REMOVED******REMOVED***title: assetGroup.first?.value.first?.assetGroup.name ?? "Unnamed Asset Group"
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(assetGroup.sorted(by: { $0.key < $1.key ***REMOVED***), id: \.key) { assetTypeGroup in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let elements = assetTypeGroup.value.sorted {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0.objectID < $1.objectID
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section(assetTypeGroup.key) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(elements) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***makeZoomToButton(text: "Object ID \(element.objectID.description)") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await viewModel.getFeatureFor(element: element),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let geometry = feature.geometry {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = Viewpoint(targetExtent: geometry.extent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("(\(elements.count))")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the list of available named trace configurations.
***REMOVED***@ViewBuilder private var configurationsList: some View {
***REMOVED******REMOVED***if viewModel.configurations.isEmpty {
***REMOVED******REMOVED******REMOVED***Text("No configurations available")
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***ForEach(viewModel.configurations) { configuration in
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setPendingTrace(configuration: configuration)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(configuration.name)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(configuration == viewModel.pendingTrace.configuration ? Color.secondary.opacity(0.5) : nil)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the list of available networks.
***REMOVED***@ViewBuilder private var networksList: some View {
***REMOVED******REMOVED***ForEach(viewModel.networks, id: \.self) { network in
***REMOVED******REMOVED******REMOVED***Text(network.name)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(network == viewModel.network ? Color.secondary.opacity(0.5) : nil)
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setNetwork(network)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The tab that allows for a new trace to be configured.
***REMOVED***@ViewBuilder private var newTraceTab: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***if viewModel.networks.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***Section("Network") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.network?.name ?? "None selected",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { isFocused(traceCreationActivity: .viewingNetworkOptions) ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { currentActivity = .creatingTrace($0 ? .viewingNetworkOptions : nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***networksList
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Trace Configuration") {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.configuration?.name ?? "None selected",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { isFocused(traceCreationActivity: .viewingTraceConfigurations) ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { currentActivity = .creatingTrace($0 ? .viewingTraceConfigurations : nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***configurationsList
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section(startingPointsTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.addingStartingPoints)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Add new")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !viewModel.pendingTrace.startingPoints.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"\(viewModel.pendingTrace.startingPoints.count) selected",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { isFocused(traceCreationActivity: .viewingStartingPoints) ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { currentActivity = .creatingTrace($0 ? .viewingStartingPoints : nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPointsList
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Advanced Options",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { isFocused(traceCreationActivity: .viewingAdvancedOptions) ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { currentActivity = .creatingTrace($0 ? .viewingAdvancedOptions : nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Name")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Name",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text: $viewModel.pendingTrace.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.userDidSpecifyName = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.trailing)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.blue)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ColorPicker(selection: $viewModel.pendingTrace.color) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Color")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Toggle(isOn: $shouldZoomOnTraceCompletion) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Zoom to result")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***if await viewModel.trace() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces(nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if shouldZoomOnTraceCompletion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let extent = viewModel.selectedTrace?.resultExtent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = Viewpoint(targetExtent: extent)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text("Trace")
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED***.disabled(!viewModel.canRunTrace)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The tab that allows for viewing completed traces.
***REMOVED***@ViewBuilder private var resultsTab: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***if viewModel.completedTraces.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectPreviousTrace()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.backward")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(currentTraceLabel)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED***if viewModel.completedTraces.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectNextTrace()
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.forward")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding(2.5)
***REMOVED******REMOVED***if let traceName = viewModel.selectedTrace?.name, !traceName.isEmpty {
***REMOVED******REMOVED******REMOVED***Text(traceName)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title3)
***REMOVED***
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***Section(featureResultsTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"(\(viewModel.selectedTrace?.assetCount ?? 0))",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { isFocused(traceViewingActivity: .viewingFeatureResults) ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { currentActivity = .viewingTraces($0 ? .viewingFeatureResults : nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***(viewModel.selectedTrace?.assets ?? [:]).sorted(by: { $0.key < $1.key ***REMOVED***), id: \.key
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) { assetGroup in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(assetGroup.key)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("(\(assetGroup.value.compactMap({ $0.value.count ***REMOVED***).reduce(0, +)))")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.blue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces(.viewingElementGroup(assetGroup.value))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Function Results") {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"(\(viewModel.selectedTrace?.utilityFunctionTraceResult?.functionOutputs.count ?? 0))",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { isFocused(traceViewingActivity: .viewingFunctionResults) ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { currentActivity = .viewingTraces($0 ? .viewingFunctionResults : nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.selectedTrace?.functionOutputs ?? [], id: \.id) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.function.networkAttribute?.name ?? "Unnamed")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text((item.result as? Double)?.description ?? "N/A")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Advanced Options",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { isFocused(traceViewingActivity: .viewingAdvancedOptions) ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { currentActivity = .viewingTraces($0 ? .viewingAdvancedOptions : nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ColorPicker(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: Binding(get: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectedTrace?.color ?? Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***, set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if var trace = viewModel.selectedTrace {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***trace.color = newValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.update(completedTrace: trace)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Color")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***makeZoomToButton {
***REMOVED******REMOVED******REMOVED***if let extent = viewModel.selectedTrace?.resultExtent {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = Viewpoint(targetExtent: extent)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding([.vertical], 2)
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***showWarningAlert.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text("Clear All Results")
***REMOVED******REMOVED******REMOVED******REMOVED***.tint(.red)
***REMOVED***
***REMOVED******REMOVED***.alert("Clear All Results", isPresented: $showWarningAlert) {
***REMOVED******REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.deleteAllTraces()
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("OK")
***REMOVED******REMOVED***
***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text("Are you sure? All the trace inputs and results will be lost.")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays information about a chosen starting point.
***REMOVED***@ViewBuilder private var startingPointDetail: some View {
***REMOVED******REMOVED***makeBackButton(title: startingPointsTitle) {
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED***
***REMOVED******REMOVED***Menu(selectedStartingPoint?.utilityElement?.assetType.name ?? "Unnamed Asset Type") {
***REMOVED******REMOVED******REMOVED***Button("Zoom To") {
***REMOVED******REMOVED******REMOVED******REMOVED***if let selectedStartingPoint = selectedStartingPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***   let extent = selectedStartingPoint.geoElement.geometry?.extent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = Viewpoint(targetExtent: extent)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button("Delete", role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let startingPoint = selectedStartingPoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.delete(startingPoint)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***if selectedStartingPoint?.utilityElement?.networkSource.kind == .edge {
***REMOVED******REMOVED******REMOVED******REMOVED***Section("Fraction Along Edge") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Slider(value: Binding(get: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.startingPoints.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0 == selectedStartingPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***?.utilityElement?.fractionAlongEdge ?? .zero
***REMOVED******REMOVED******REMOVED******REMOVED***, set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let selectedStartingPoint = selectedStartingPoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setFractionAlongEdgeFor(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPoint: selectedStartingPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: newValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if selectedStartingPoint?.utilityElement?.networkSource.kind == .junction &&
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedStartingPoint?.utilityElement?.terminal != nil &&
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***!(selectedStartingPoint?.utilityElement?.assetType.terminalConfiguration?.terminals.isEmpty ?? true) {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Picker(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Terminal Configuration",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: Binding(get: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedStartingPoint!.utilityElement!.terminal!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***, set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setTerminalConfigurationFor(startingPoint: selectedStartingPoint!, to: newValue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.pendingTrace.startingPoints.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0 == selectedStartingPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***?.utilityElement?.assetType.terminalConfiguration?.terminals ?? [], id: \.self) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text($0.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.blue)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Attributes") {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(Array(selectedStartingPoint!.geoElement.attributes.sorted(by: { $0.key < $1.key***REMOVED***)), id: \.key) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack{
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.key)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.value as? String ?? "")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the chosen starting points for the new trace.
***REMOVED***private var startingPointsList: some View {
***REMOVED******REMOVED***ForEach(viewModel.pendingTrace.startingPoints, id: \.self) { startingPoint in
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.inspectingStartingPoint(startingPoint)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(startingPoint.utilityElement?.assetType.name ?? "")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let image = startingPoint.image {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 25, height: 25)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(.white)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(5)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.swipeActions {
***REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.delete(startingPoint)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "trash")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A graphical interface to run pre-configured traces on a map's utility networks.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - graphicsOverlay: The graphics overlay to hold generated starting point and trace
***REMOVED******REMOVED***/   graphics.
***REMOVED******REMOVED***/   - map: The map containing the utility network(s).
***REMOVED******REMOVED***/   - mapPoint: Acts as the point at which newly selected starting point graphics will be
***REMOVED******REMOVED***/   created.
***REMOVED******REMOVED***/   - viewPoint: Acts as the point of identification for items tapped in the utility network.
***REMOVED******REMOVED***/   - mapViewProxy: Provides a method of layer identification when starting points are being
***REMOVED******REMOVED***/   chosen.
***REMOVED******REMOVED***/   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
***REMOVED******REMOVED***/   - startingPoints: An optional list of programmatically provided starting points.
***REMOVED***public init(
***REMOVED******REMOVED***graphicsOverlay: Binding<GraphicsOverlay>,
***REMOVED******REMOVED***map: Map,
***REMOVED******REMOVED***mapPoint: Binding<Point?>,
***REMOVED******REMOVED***viewPoint: Binding<CGPoint?>,
***REMOVED******REMOVED***mapViewProxy: Binding<MapViewProxy?>,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
***REMOVED***) {
***REMOVED******REMOVED***_viewPoint = viewPoint
***REMOVED******REMOVED***_mapPoint = mapPoint
***REMOVED******REMOVED***_mapViewProxy = mapViewProxy
***REMOVED******REMOVED***_graphicsOverlay = graphicsOverlay
***REMOVED******REMOVED***_viewpoint = viewpoint
***REMOVED******REMOVED***_externalStartingPoints = startingPoints
***REMOVED******REMOVED***_viewModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay: graphicsOverlay.wrappedValue,
***REMOVED******REMOVED******REMOVED******REMOVED***startingPoints: startingPoints.wrappedValue
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !viewModel.completedTraces.isEmpty &&
***REMOVED******REMOVED******REMOVED******REMOVED***!isFocused(traceCreationActivity: .addingStartingPoints) {
***REMOVED******REMOVED******REMOVED******REMOVED***activityPicker
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***switch currentActivity {
***REMOVED******REMOVED******REMOVED***case .creatingTrace(let activity):
***REMOVED******REMOVED******REMOVED******REMOVED***switch activity {
***REMOVED******REMOVED******REMOVED******REMOVED***case .addingStartingPoints:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cancelAddStartingPoints
***REMOVED******REMOVED******REMOVED******REMOVED***case .inspectingStartingPoint:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPointDetail
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***newTraceTab
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***case .viewingTraces(let activity):
***REMOVED******REMOVED******REMOVED******REMOVED***switch activity {
***REMOVED******REMOVED******REMOVED******REMOVED***case .viewingElementGroup:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assetGroupDetail
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***resultsTab
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.background(Color(uiColor: .systemGroupedBackground))
***REMOVED******REMOVED***.animation(.default, value: currentActivity)
***REMOVED******REMOVED***.onChange(of: viewPoint) { newValue in
***REMOVED******REMOVED******REMOVED***guard isFocused(traceCreationActivity: .addingStartingPoints),
***REMOVED******REMOVED******REMOVED******REMOVED***  let mapViewProxy = mapViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED***  let mapPoint = mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***  let viewPoint = viewPoint else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***await viewModel.createStartingPoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: viewPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: externalStartingPoints) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.externalStartingPoints = externalStartingPoints
***REMOVED***
***REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED***"Warning",
***REMOVED******REMOVED******REMOVED***isPresented: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED***get: { !viewModel.userWarning.isEmpty ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***set: { _ in viewModel.userWarning = "" ***REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***) { ***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text(viewModel.userWarning)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Computed Properties
***REMOVED***
***REMOVED******REMOVED***/ Indicates the number of the trace currently being viewed out the total number of traces.
***REMOVED***private var currentTraceLabel: String {
***REMOVED******REMOVED***guard let index = viewModel.selectedTraceIndex else { return "Error" ***REMOVED***
***REMOVED******REMOVED***return "Trace \(index+1) of \(viewModel.completedTraces.count.description)"
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The selected utility element asset group.
***REMOVED***private var selectedAssetGroup: [String: [UtilityElement]]? {
***REMOVED******REMOVED***if case let .viewingTraces(activity) = currentActivity,
***REMOVED******REMOVED***   case let .viewingElementGroup(elementGroup) = activity {
***REMOVED******REMOVED******REMOVED***return elementGroup
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The starting point being inspected (if one exists).
***REMOVED***private var selectedStartingPoint: UtilityNetworkTraceStartingPoint? {
***REMOVED******REMOVED***if case let .creatingTrace(activity) = currentActivity,
***REMOVED******REMOVED***   case let .inspectingStartingPoint(startingPoint) = activity {
***REMOVED******REMOVED******REMOVED***return startingPoint
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines if the provided creation activity is the currently focused creation activity.
***REMOVED******REMOVED***/ - Parameter traceCreationActivity: A possible focus activity when creating traces.
***REMOVED******REMOVED***/ - Returns: A Boolean value indicating whether the provided activity is the currently focused
***REMOVED******REMOVED***/ creation activity.
***REMOVED***private func isFocused(traceCreationActivity: TraceCreationActivity) -> Bool {
***REMOVED******REMOVED***if case let .creatingTrace(activity) = currentActivity {
***REMOVED******REMOVED******REMOVED***return traceCreationActivity == activity
***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Determines if the provided viewing activity is the currently focused viewing activity.
***REMOVED******REMOVED***/ - Parameter traceViewingActivity: A possible focus activity when viewing traces.
***REMOVED******REMOVED***/ - Returns: A Boolean value indicating whether the provided activity is the currently focused
***REMOVED******REMOVED***/ viewing activity.
***REMOVED***private func isFocused(traceViewingActivity: TraceViewingActivity) -> Bool {
***REMOVED******REMOVED***if case let .viewingTraces(activity) = currentActivity {
***REMOVED******REMOVED******REMOVED***return traceViewingActivity == activity
***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a "Back" button that performs a specified action when pressed.
***REMOVED******REMOVED***/ - Parameter title: The button's title.
***REMOVED******REMOVED***/ - Parameter action: The action to be performed.
***REMOVED******REMOVED***/ - Returns: The configured button.
***REMOVED***private func makeBackButton(title: String, _ action: @escaping () -> Void) -> some View {
***REMOVED******REMOVED***Button { action() ***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.backward")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a section header.
***REMOVED******REMOVED***/ - Parameter title: The title of the header.
***REMOVED******REMOVED***/ - Returns: The configured title.
***REMOVED***private func makeDetailSectionHeader(title: String) -> some View {
***REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a "Zoom To" button that performs a specified action when pressed.
***REMOVED******REMOVED***/ - Parameter text: The custom text to be displayed within the button.
***REMOVED******REMOVED***/ - Parameter action: The action to be performed.
***REMOVED******REMOVED***/ - Returns: The configured button.
***REMOVED***private func makeZoomToButton(
***REMOVED******REMOVED***text: String = "Zoom To",
***REMOVED******REMOVED***_ action: @escaping () -> Void
***REMOVED***) -> some View {
***REMOVED******REMOVED***Button { action() ***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(text)
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "scope")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Title for the feature results section
***REMOVED***private let featureResultsTitle = "Feature Results"
***REMOVED***
***REMOVED******REMOVED***/ Title for the starting points section
***REMOVED***private let startingPointsTitle = "Starting Points"
***REMOVED***
