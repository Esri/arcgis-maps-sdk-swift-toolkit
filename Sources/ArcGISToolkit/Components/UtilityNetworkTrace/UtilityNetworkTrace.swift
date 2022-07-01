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
***REMOVED***@Environment(\.horizontalSizeClass)
***REMOVED***private var horizontalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED***@Environment(\.verticalSizeClass)
***REMOVED***private var verticalSizeClass: UserInterfaceSizeClass?
***REMOVED***
***REMOVED******REMOVED***/ If `true`, the site and facility selector will appear as a sheet.
***REMOVED******REMOVED***/ If `false`, the site and facility selector will appear as a popup modal alongside the level selector.
***REMOVED***private var isCompact: Bool {
***REMOVED******REMOVED***return horizontalSizeClass == .compact || verticalSizeClass == .compact
***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of chosen starting points.
***REMOVED******REMOVED***case viewingStartingPoints
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of available trace configurations.
***REMOVED******REMOVED***case viewingTraceConfigurations
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Activities users will perform while using the Utility Network Trace tool.
***REMOVED***private enum UserActivity: Hashable {
***REMOVED******REMOVED******REMOVED***/ The user is creating a new trace.
***REMOVED******REMOVED***case creatingTrace(TraceCreationActivity?)
***REMOVED******REMOVED******REMOVED***/ The user is viewing traces that have been created.
***REMOVED******REMOVED***case viewingTraces
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: States
***REMOVED***
***REMOVED******REMOVED***/ The current user activity.
***REMOVED***@State private var currentActivity: UserActivity = .creatingTrace(nil)
***REMOVED***
***REMOVED******REMOVED***/ Indicates if the warning that all traces will be deleted is presented.
***REMOVED***@State private var warningIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The view model used by the view. The `UtilityNetworkTraceViewModel` manages state.
***REMOVED******REMOVED***/ The view observes `UtilityNetworkTraceViewModel` for changes in state.
***REMOVED***@StateObject private var viewModel: UtilityNetworkTraceViewModel
***REMOVED***
***REMOVED******REMOVED*** MARK: Bindings
***REMOVED***
***REMOVED******REMOVED***/ The graphics overlay to hold generated starting point and trace graphics.
***REMOVED***@Binding private var graphicsOverlay: GraphicsOverlay
***REMOVED***
***REMOVED******REMOVED***/ Provides a method of layer identification when starting points are being chosen.
***REMOVED***@Binding private var mapViewProxy: MapViewProxy?
***REMOVED***
***REMOVED******REMOVED***/ Acts as the point of identification for items tapped in the utility network.
***REMOVED***@Binding private var pointInScreen: CGPoint?
***REMOVED***
***REMOVED******REMOVED***/ Acts as the point at which newly selected starting point graphics will be created.
***REMOVED***@Binding private var pointInMap: Point?
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return UserActivity.viewingTraces
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***, set: { newActivity, _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = newActivity
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***Text("New trace").tag(UserActivity.creatingTrace(nil))
***REMOVED******REMOVED******REMOVED***Text("Results").tag(UserActivity.viewingTraces)
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
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the list of available named trace configurations.
***REMOVED***@ViewBuilder private var configurationsList: some View {
***REMOVED******REMOVED***if viewModel.configurations.isEmpty {
***REMOVED******REMOVED******REMOVED***Text("No configurations available")
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***ForEach(viewModel.configurations, id: \.name) { configuration in
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***withAnimation {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setPendingTrace(configuration: configuration)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(configuration.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.symbolVariant(configuration == viewModel.pendingTrace.configuration ? .fill: .none)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The tab that allows for a new trace to be configured.
***REMOVED***@ViewBuilder private var newTraceTab: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***Section("Trace Configuration") {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.configuration?.name ?? "None selected",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: configurationOptionsIsExpanded
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***configurationsList
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Starting Points") {
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.addingStartingPoints)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Add new")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !viewModel.pendingTrace.startingPoints.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"\(viewModel.pendingTrace.startingPoints.count) selected",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: startingPointsListIsExpanded
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPointsList
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Advanced Options",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: advancedOptionsIsExpanded
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ColorPicker(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: $viewModel.pendingTrace.color
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Trace Color")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Trace Name",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***text: $viewModel.pendingTrace.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.userDidSpecifyName = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***viewModel.trace()
***REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces
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
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectPreviousTrace()
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.backward")
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(currentTraceLabel)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectNextTrace()
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.forward")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***if let traceName = viewModel.selectedTrace?.name, !traceName.isEmpty {
***REMOVED******REMOVED******REMOVED***Text(traceName)
***REMOVED***
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***Section("Element Result") {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(viewModel
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selectedTrace?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.utilityElementTraceResult?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.elements.count.description ?? "0") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.selectedTrace?.assetLabels ?? [], id: \.self) { label in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(label)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section("Function Result") {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(viewModel
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.selectedTrace?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.utilityFunctionTraceResult?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.functionOutputs.count.description ?? "0") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.selectedTrace?.functionOutputs ?? [], id: \.id) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.function.networkAttribute?.name ?? "Unnamed")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text((item.result as? Double)?.description ?? "N/A")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***warningIsPresented.toggle()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text("Clear All Results")
***REMOVED******REMOVED******REMOVED******REMOVED***.tint(.red)
***REMOVED***
***REMOVED******REMOVED***.alert("Clear All Results", isPresented: $warningIsPresented) {
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
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Back")
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.backward")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.padding()
***REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED***Text(selectedStartingPoint?.utilityElement.assetType.name ?? "Unnamed")
***REMOVED******REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .center)
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***if selectedStartingPoint?.utilityElement.networkSource.kind == .edge {
***REMOVED******REMOVED******REMOVED******REMOVED***Section("Fraction Along Edge") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Slider(value: Binding(get: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.startingPoints.first { sp in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sp.utilityElement.globalID == selectedStartingPoint?.utilityElement.globalID
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***?.utilityElement.fractionAlongEdge ?? .zero
***REMOVED******REMOVED******REMOVED******REMOVED***, set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let selectedStartingPoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setFractionAlongEdgeFor(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPoint: selectedStartingPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: newValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if selectedStartingPoint?.utilityElement.networkSource.kind == .junction &&
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***!(selectedStartingPoint?.utilityElement.assetType.terminalConfiguration?.terminals.isEmpty ?? true) {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Picker(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Terminal Configuration",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: Binding(get: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedStartingPoint!.utilityElement.terminal!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***, set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setTerminalConfigurationFor(startingPoint: selectedStartingPoint!, to: newValue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(viewModel.pendingTrace.startingPoints.first { sp in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***sp.utilityElement.globalID == selectedStartingPoint?.utilityElement.globalID
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***?.utilityElement.assetType.terminalConfiguration?.terminals ?? [], id: \.self) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text($0.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(selectedStartingPoint?.utilityElement.globalID.uuidString ?? "N/A")
***REMOVED******REMOVED******REMOVED***ForEach(Array(selectedStartingPoint!.geoElement.attributes.sorted(by: { $0.key < $1.key***REMOVED***)), id: \.key) { item in
***REMOVED******REMOVED******REMOVED******REMOVED***HStack{
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.key)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.value as? String ?? "")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***if let selectedStartingPoint {
***REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = Viewpoint(targetExtent: selectedStartingPoint.extent)
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED***Text("Zoom To")
***REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "scope")
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the chosen starting points for the new trace.
***REMOVED***private var startingPointsList: some View {
***REMOVED******REMOVED***ForEach(viewModel.pendingTrace.startingPoints, id: \.utilityElement.globalID) { startingPoint in
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.inspectingStartingPoint(startingPoint)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(startingPoint.utilityElement.assetType.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: startingPoint.image)
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
***REMOVED******REMOVED***/   - map: The parent map.
***REMOVED******REMOVED***/   - pointInMap: Acts as the point at which newly selected starting point graphics will be
***REMOVED******REMOVED***/   created.
***REMOVED******REMOVED***/   - pointInScreen: Acts as the point of identification for items tapped in the utility network.
***REMOVED******REMOVED***/   - mapViewProxy: Provides a method of layer identification when starting points are being
***REMOVED******REMOVED***/   chosen.
***REMOVED******REMOVED***/   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
***REMOVED***public init(
***REMOVED******REMOVED***_ graphicsOverlay: Binding<GraphicsOverlay>,
***REMOVED******REMOVED***_ map: Map,
***REMOVED******REMOVED***_ pointInMap: Binding<Point?>,
***REMOVED******REMOVED***_ pointInScreen: Binding<CGPoint?>,
***REMOVED******REMOVED***_ mapViewProxy: Binding<MapViewProxy?>,
***REMOVED******REMOVED***_ viewpoint: Binding<Viewpoint?>
***REMOVED***) {
***REMOVED******REMOVED***_pointInScreen = pointInScreen
***REMOVED******REMOVED***_pointInMap = pointInMap
***REMOVED******REMOVED***_mapViewProxy = mapViewProxy
***REMOVED******REMOVED***_graphicsOverlay = graphicsOverlay
***REMOVED******REMOVED***_viewpoint = viewpoint
***REMOVED******REMOVED***_viewModel = StateObject(
***REMOVED******REMOVED******REMOVED***wrappedValue: UtilityNetworkTraceViewModel(
***REMOVED******REMOVED******REMOVED******REMOVED***map: map,
***REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlay: graphicsOverlay.wrappedValue
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***UITableView.appearance().backgroundColor = .systemGroupedBackground
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !viewModel.completedTraces.isEmpty && !isAddingStartingPoints {
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
***REMOVED******REMOVED******REMOVED***case .viewingTraces:
***REMOVED******REMOVED******REMOVED******REMOVED***resultsTab
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.background(Color(uiColor: .systemGroupedBackground))
***REMOVED******REMOVED***.animation(.default, value: currentActivity)
***REMOVED******REMOVED***.onChange(of: pointInScreen) { newValue in
***REMOVED******REMOVED******REMOVED***guard isAddingStartingPoints,
***REMOVED******REMOVED******REMOVED******REMOVED***  let mapViewProxy = mapViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED***  let pointInMap = pointInMap,
***REMOVED******REMOVED******REMOVED******REMOVED***  let pointInScreen = pointInScreen else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***await viewModel.setStartingPoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: pointInScreen,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: pointInMap,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Computed Properties
***REMOVED***
***REMOVED******REMOVED***/ Indicates if the list of advanced options is expanded.
***REMOVED***private var advancedOptionsIsExpanded: Binding<Bool> {
***REMOVED******REMOVED***Binding(get: {
***REMOVED******REMOVED******REMOVED***switch currentActivity {
***REMOVED******REMOVED******REMOVED***case .creatingTrace(let activity):
***REMOVED******REMOVED******REMOVED******REMOVED***switch activity {
***REMOVED******REMOVED******REMOVED******REMOVED***case .viewingAdvancedOptions:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED***, set: { val in
***REMOVED******REMOVED******REMOVED***if val {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingAdvancedOptions)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Indicates if the list of trace configuration options is expanded.
***REMOVED***private var configurationOptionsIsExpanded: Binding<Bool> {
***REMOVED******REMOVED***Binding(get: {
***REMOVED******REMOVED******REMOVED***switch currentActivity {
***REMOVED******REMOVED******REMOVED***case .creatingTrace(let activity):
***REMOVED******REMOVED******REMOVED******REMOVED***switch activity {
***REMOVED******REMOVED******REMOVED******REMOVED***case .viewingTraceConfigurations:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED***, set: { val in
***REMOVED******REMOVED******REMOVED***if val {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingTraceConfigurations)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Indicates if the list of chosen starting points is expanded.
***REMOVED***private var startingPointsListIsExpanded: Binding<Bool> {
***REMOVED******REMOVED***Binding(get: {
***REMOVED******REMOVED******REMOVED***switch currentActivity {
***REMOVED******REMOVED******REMOVED***case .creatingTrace(let activity):
***REMOVED******REMOVED******REMOVED******REMOVED***switch activity {
***REMOVED******REMOVED******REMOVED******REMOVED***case .viewingStartingPoints:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED***, set: { val in
***REMOVED******REMOVED******REMOVED***if val {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Indicates the number of the trace currently being viewed out the total number of traces.
***REMOVED***private var currentTraceLabel: String {
***REMOVED******REMOVED***guard let index = viewModel.selectedTraceIndex else { return "Error" ***REMOVED***
***REMOVED******REMOVED***return "Trace \(index+1) of \(viewModel.completedTraces.count.description)"
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Indicates if the user is currently adding starting points.
***REMOVED***private var isAddingStartingPoints: Bool {
***REMOVED******REMOVED***switch currentActivity {
***REMOVED******REMOVED***case .creatingTrace(let activity):
***REMOVED******REMOVED******REMOVED***switch activity {
***REMOVED******REMOVED******REMOVED***case .addingStartingPoints:
***REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***return false
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The starting point being inspected (if one exists).
***REMOVED***private var selectedStartingPoint: UtilityNetworkTraceStartingPoint? {
***REMOVED******REMOVED***switch currentActivity {
***REMOVED******REMOVED***case .creatingTrace(let activity):
***REMOVED******REMOVED******REMOVED***switch activity {
***REMOVED******REMOVED******REMOVED***case .inspectingStartingPoint(let startingPoint):
***REMOVED******REMOVED******REMOVED******REMOVED***return startingPoint
***REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
