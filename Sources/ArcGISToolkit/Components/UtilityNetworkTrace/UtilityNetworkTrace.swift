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
***REMOVED******REMOVED***/ The proxy to provide access to map view operations.
***REMOVED***private var mapViewProxy: MapViewProxy?
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
***REMOVED******REMOVED******REMOVED***/ The user is viewing the list of element results.
***REMOVED******REMOVED***case viewingElementGroup(named: String)
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
***REMOVED******REMOVED***/ The current detent of the floating panel.
***REMOVED***@Binding private var activeDetent: FloatingPanelDetent?
***REMOVED***
***REMOVED******REMOVED***/ The current user activity.
***REMOVED***@State private var currentActivity: UserActivity = .creatingTrace(nil)
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the map should be zoomed to the extent of the trace result.
***REMOVED***@State private var shouldZoomOnTraceCompletion = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the Clear All Results confirmation
***REMOVED******REMOVED***/ dialog is being shown.
***REMOVED***@State private var isShowingClearAllResultsConfirmationDialog = false
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
***REMOVED******REMOVED***/ Acts as the point of identification for items tapped in the utility network.
***REMOVED***@Binding private var screenPoint: CGPoint?
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
***REMOVED******REMOVED******REMOVED***String.modePickerTitle,
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
***REMOVED******REMOVED******REMOVED***Text(String.newTraceOptionLabel).tag(UserActivity.creatingTrace(nil))
***REMOVED******REMOVED******REMOVED***Text(String.resultsOptionLabel).tag(UserActivity.viewingTraces(nil))
***REMOVED***
***REMOVED******REMOVED***.pickerStyle(.segmented)
***REMOVED******REMOVED***.padding()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Allows the user to cancel out of selecting a new starting point.
***REMOVED***private var cancelAddStartingPoints: some View {
***REMOVED******REMOVED***Button(String.cancelStartingPointSelection, role: .destructive) {
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED******REMOVED***activeDetent = .half
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays information about a chosen asset group.
***REMOVED***@ViewBuilder private var assetGroupDetail: some View {
***REMOVED******REMOVED***if let assetGroupName = selectedAssetGroupName,
***REMOVED******REMOVED***   let assetTypeGroups = viewModel.selectedTrace?.elementsByType(inGroupNamed: assetGroupName) {
***REMOVED******REMOVED******REMOVED***makeBackButton(title: .featureResultsTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces(.viewingFeatureResults)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***makeDetailSectionHeader(title: assetGroupName)
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***assetTypeGroups.sorted(using: KeyPathComparator(\.key)),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: \.key
***REMOVED******REMOVED******REMOVED******REMOVED***) { (name, elements) in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Section(name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(elements, id: \.globalID) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await viewModel.feature(for: element),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let geometry = feature.geometry {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let newViewpoint = Viewpoint(boundingGeometry: geometry.extent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let mapViewProxy {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { await mapViewProxy.setViewpoint(newViewpoint, duration: nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = newViewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Object ID: \(element.objectID, format: .number.grouping(.never))",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A string identifying a utility network object."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "scope")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(elements.count, format: .number)
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
***REMOVED******REMOVED******REMOVED***Text(String.noConfigurationsAvailable)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***ForEach(viewModel.configurations, id: \.name) { configuration in
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setPendingTrace(configuration: configuration)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(configuration.name)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(configuration.name == viewModel.pendingTrace.configuration?.name ? Color.secondary.opacity(0.5) : nil)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the list of available networks.
***REMOVED***@ViewBuilder private var networksList: some View {
***REMOVED******REMOVED***ForEach(viewModel.networks, id: \.name) { network in
***REMOVED******REMOVED******REMOVED***Text(network.name)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(network.name == viewModel.network?.name ? Color.secondary.opacity(0.5) : nil)
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
***REMOVED******REMOVED******REMOVED******REMOVED***Section(String.networkSectionLabel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.network?.name ?? .noneSelected,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***get: { isFocused(traceCreationActivity: .viewingNetworkOptions) ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***set: { currentActivity = .creatingTrace($0 ? .viewingNetworkOptions : nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***networksList
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section(String.traceConfigurationSectionLabel) {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.configuration?.name ?? .noneSelected,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceCreationActivity: .viewingTraceConfigurations)
***REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace($0 ? .viewingTraceConfigurations : nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***configurationsList
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section(String.startingPointsTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button(String.addNewButtonLabel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.addingStartingPoints)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***activeDetent = .summary
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***if !viewModel.pendingTrace.startingPoints.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceCreationActivity: .viewingStartingPoints)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace($0 ? .viewingStartingPoints : nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPointsList
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"\(viewModel.pendingTrace.startingPoints.count) selected",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A label declaring the number of starting points selected for a utility network trace."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String.advancedOptionsHeaderLabel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceCreationActivity: .viewingAdvancedOptions)
***REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace($0 ? .viewingAdvancedOptions : nil)
***REMOVED******REMOVED******REMOVED******REMOVED***, content: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.nameLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(String.nameLabel, text: $viewModel.pendingTrace.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.userDidSpecifyName = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.trailing)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.blue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ColorPicker(String.colorLabel, selection: $viewModel.pendingTrace.color)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Toggle(String.zoomToResult, isOn: $shouldZoomOnTraceCompletion)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***Button(String.traceButtonLabel) {
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***if await viewModel.trace() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces(nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if shouldZoomOnTraceCompletion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let extent = viewModel.selectedTrace?.resultExtent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = Viewpoint(boundingGeometry: extent)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED***.disabled(!viewModel.canRunTrace)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Navigator at the top of the results tab that allows users to cycle through completed traces.
***REMOVED***@ViewBuilder private var resultsNavigator: some View {
***REMOVED******REMOVED***if viewModel.completedTraces.count > 1 {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.completedTraces.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectPreviousTrace()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.backward")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(currentTraceLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.completedTraces.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectNextTrace()
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.forward")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The tab that allows for viewing completed traces.
***REMOVED***@ViewBuilder private var resultsTab: some View {
***REMOVED******REMOVED***resultsNavigator
***REMOVED******REMOVED******REMOVED***.padding(2.5)
***REMOVED******REMOVED***if let selectedTrace = viewModel.selectedTrace {
***REMOVED******REMOVED******REMOVED***Menu(selectedTrace.name) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let resultExtent = selectedTrace.resultExtent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(String.zoomToButtonLabel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let newViewpoint = Viewpoint(boundingGeometry: resultExtent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let mapViewProxy {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { await mapViewProxy.setViewpoint(newViewpoint, duration: nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = newViewpoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Button(String.deleteButtonLabel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.completedTraces.count == 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.deleteTrace(selectedTrace)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.font(.title3)
***REMOVED***
***REMOVED******REMOVED***if activeDetent != .summary {
***REMOVED******REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED******REMOVED***Section(String.featureResultsTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceViewingActivity: .viewingFeatureResults)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces($0 ? .viewingFeatureResults : nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let selectedTrace = viewModel.selectedTrace {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(selectedTrace.assetGroupNames.sorted(), id: \.self) { assetGroupName in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(assetGroupName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(selectedTrace.elements(inAssetGroupNamed: assetGroupName).count, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.blue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(Rectangle())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces(.viewingElementGroup(named: assetGroupName))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(viewModel.selectedTrace?.elementResults.count ?? 0, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Section(String.functionResultsSectionTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceViewingActivity: .viewingFunctionResults)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces($0 ? .viewingFunctionResults : nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let selectedTrace = viewModel.selectedTrace {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(selectedTrace.functionOutputs, id: \.objectID) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.function.networkAttribute.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .trailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(item.function.functionType.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let result = item.result as? Double {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(result, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("N/A", bundle: .toolkitModule, comment: "Shorthand for Not Available")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(viewModel.selectedTrace?.utilityFunctionTraceResult?.functionOutputs.count ?? 0, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String.advancedOptionsHeaderLabel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceViewingActivity: .viewingAdvancedOptions)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces($0 ? .viewingAdvancedOptions : nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ColorPicker(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String.colorLabel,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectedTrace?.color ?? Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if var trace = viewModel.selectedTrace {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***trace.color = newValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.update(completedTrace: trace)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding([.vertical], 2)
***REMOVED******REMOVED******REMOVED***Button(String.clearAllResultsButtonLabel, role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED***isShowingClearAllResultsConfirmationDialog = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED***.confirmationDialog(
***REMOVED******REMOVED******REMOVED******REMOVED***String.clearAllResultsQuestion,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isShowingClearAllResultsConfirmationDialog
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button(String.clearAllResultsButtonLabel, role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.deleteAllTraces()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** message: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(String.clearAllResultsMessage)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays information about a chosen starting point.
***REMOVED***@ViewBuilder private var startingPointDetail: some View {
***REMOVED******REMOVED***makeBackButton(title: .startingPointsTitle) {
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED***
***REMOVED******REMOVED***Menu(selectedStartingPoint?.utilityElement?.assetType.name ?? String.unnamedAssetType) {
***REMOVED******REMOVED******REMOVED***Button(String.zoomToButtonLabel) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let selectedStartingPoint = selectedStartingPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***   let extent = selectedStartingPoint.geoElement.geometry?.extent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let newViewpoint = Viewpoint(boundingGeometry: extent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let mapViewProxy {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { await mapViewProxy.setViewpoint(newViewpoint, duration: nil) ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewpoint = newViewpoint
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button(String.deleteButtonLabel, role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let startingPoint = selectedStartingPoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.deleteStartingPoint(startingPoint)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***if selectedStartingPoint?.utilityElement?.networkSource.kind == .edge {
***REMOVED******REMOVED******REMOVED******REMOVED***Section(String.fractionAlongEdgeSectionTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Slider(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.startingPoints.first {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***$0 == selectedStartingPoint
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***?.utilityElement?.fractionAlongEdge ?? .zero
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let selectedStartingPoint = selectedStartingPoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setFractionAlongEdgeFor(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***startingPoint: selectedStartingPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***to: newValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else if selectedStartingPoint?.utilityElement?.networkSource.kind == .junction &&
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedStartingPoint?.utilityElement?.terminal != nil &&
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***!(selectedStartingPoint?.utilityElement?.assetType.terminalConfiguration?.terminals.isEmpty ?? true) {
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Picker(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String.terminalConfigurationPickerTitle,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selection: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectedStartingPoint!.utilityElement!.terminal!
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set: { newValue in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setTerminalConfigurationFor(startingPoint: selectedStartingPoint!, to: newValue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED***Section(String.attributesSectionTitle) {
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.deleteStartingPoint(startingPoint)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "trash")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A graphical interface to run pre-configured traces on a map's utility networks.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - graphicsOverlay: The graphics overlay to hold generated starting point and trace graphics.
***REMOVED******REMOVED***/   - map: The map containing the utility network(s).
***REMOVED******REMOVED***/   - mapPoint: Acts as the point at which newly selected starting point graphics will be created.
***REMOVED******REMOVED***/   - screenPoint: Acts as the point of identification for items tapped in the utility network.
***REMOVED******REMOVED***/   - mapViewProxy: The proxy to provide access to map view operations.
***REMOVED******REMOVED***/   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
***REMOVED******REMOVED***/   - startingPoints: An optional list of programmatically provided starting points.
***REMOVED***public init(
***REMOVED******REMOVED***graphicsOverlay: Binding<GraphicsOverlay>,
***REMOVED******REMOVED***map: Map,
***REMOVED******REMOVED***mapPoint: Binding<Point?>,
***REMOVED******REMOVED***screenPoint: Binding<CGPoint?>,
***REMOVED******REMOVED***mapViewProxy: MapViewProxy?,
***REMOVED******REMOVED***viewpoint: Binding<Viewpoint?>,
***REMOVED******REMOVED***startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
***REMOVED***) {
***REMOVED******REMOVED***self.mapViewProxy = mapViewProxy
***REMOVED******REMOVED***_activeDetent = .constant(nil)
***REMOVED******REMOVED***_screenPoint = screenPoint
***REMOVED******REMOVED***_mapPoint = mapPoint
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
***REMOVED******REMOVED***/ Sets the active detent for a hosting floating panel.
***REMOVED******REMOVED***/ - Parameter detent: A binding to a value that determines the height of a hosting
***REMOVED******REMOVED***/ floating panel.
***REMOVED******REMOVED***/ - Returns: A trace tool that automatically sets and responds to detent values to improve user
***REMOVED******REMOVED***/ experience.
***REMOVED***public func floatingPanelDetent(
***REMOVED******REMOVED***_ detent: Binding<FloatingPanelDetent>
***REMOVED***) -> UtilityNetworkTrace {
***REMOVED******REMOVED***var copy = self
***REMOVED******REMOVED***copy._activeDetent = Binding(detent)
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***
***REMOVED***public var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***if !viewModel.completedTraces.isEmpty &&
***REMOVED******REMOVED******REMOVED******REMOVED***!isFocused(traceCreationActivity: .addingStartingPoints) &&
***REMOVED******REMOVED******REMOVED******REMOVED***activeDetent != .summary {
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
***REMOVED******REMOVED***.onChange(of: screenPoint) { newScreenPoint in
***REMOVED******REMOVED******REMOVED***guard isFocused(traceCreationActivity: .addingStartingPoints),
***REMOVED******REMOVED******REMOVED******REMOVED***  let mapViewProxy = mapViewProxy,
***REMOVED******REMOVED******REMOVED******REMOVED***  let mapPoint = mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***  let screenPoint = newScreenPoint else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED******REMOVED******REMOVED***activeDetent = .half
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***await viewModel.addStartingPoints(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: screenPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: externalStartingPoints) { _ in
***REMOVED******REMOVED******REMOVED***viewModel.externalStartingPoints = externalStartingPoints
***REMOVED***
***REMOVED******REMOVED***.alert(
***REMOVED******REMOVED******REMOVED***viewModel.userAlert?.title ?? "",
***REMOVED******REMOVED******REMOVED***isPresented: Binding(
***REMOVED******REMOVED******REMOVED******REMOVED***get: { viewModel.userAlert != nil ***REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***set: { _ in viewModel.userAlert = nil ***REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED***viewModel.userAlert?.button
***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text(viewModel.userAlert?.description ?? "")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Computed Properties
***REMOVED***
***REMOVED******REMOVED***/ Indicates the number of the trace currently being viewed out the total number of traces.
***REMOVED***private var currentTraceLabel: String {
***REMOVED******REMOVED***guard let index = viewModel.selectedTraceIndex else { return "Error" ***REMOVED***
***REMOVED******REMOVED***return String(
***REMOVED******REMOVED******REMOVED***localized: "Trace \(index+1, specifier: "%lld") of \(viewModel.completedTraces.count, specifier: "%lld")",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating the index of the trace being viewed out of the total number of traces completed."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The name of the selected utility element asset group.
***REMOVED***private var selectedAssetGroupName: String? {
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

private extension String {
***REMOVED***static let addNewButtonLabel = String(
***REMOVED******REMOVED***localized: "Add new",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A button to add new utility trace starting points."
***REMOVED***)
***REMOVED***
***REMOVED***static let advancedOptionsHeaderLabel = String(
***REMOVED******REMOVED***localized: "Advanced Options",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A section header for advanced options."
***REMOVED***)
***REMOVED***
***REMOVED***static let attributesSectionTitle = String(
***REMOVED******REMOVED***localized: "Attributes",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let cancelStartingPointSelection = String(
***REMOVED******REMOVED***localized: "Cancel starting point selection",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let clearAllResultsButtonLabel = String(
***REMOVED******REMOVED***localized: "Clear All Results",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let clearAllResultsQuestion = String(
***REMOVED******REMOVED***localized: "Clear all results?",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let clearAllResultsMessage = String(
***REMOVED******REMOVED***localized: "All the trace inputs and results will be lost.",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A message describing the outcome of clearing all utility network trace results."
***REMOVED***)
***REMOVED***
***REMOVED***static let colorLabel = String(
***REMOVED******REMOVED***localized: "Color",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let deleteButtonLabel = String(
***REMOVED******REMOVED***localized: "Delete",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ Title for the feature results section
***REMOVED***static let featureResultsTitle = String(
***REMOVED******REMOVED***localized: "Feature Results",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let fractionAlongEdgeSectionTitle = String(
***REMOVED******REMOVED***localized: "Fraction Along Edge",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let functionResultsSectionTitle = String(
***REMOVED******REMOVED***localized: "Function Results",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let modePickerTitle = String(
***REMOVED******REMOVED***localized: "Mode",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let nameLabel = String(
***REMOVED******REMOVED***localized: "Name",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let networkSectionLabel = String(
***REMOVED******REMOVED***localized: "Network",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let newTraceOptionLabel = String(
***REMOVED******REMOVED***localized: "New trace",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let noConfigurationsAvailable = String(
***REMOVED******REMOVED***localized: "No configurations available",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let noneSelected = String(
***REMOVED******REMOVED***localized: "None selected",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let resultsOptionLabel = String(
***REMOVED******REMOVED***localized: "Results",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ Title for the starting points section
***REMOVED***static let startingPointsTitle = String(
***REMOVED******REMOVED***localized: "Starting Points",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let terminalConfigurationPickerTitle = String(
***REMOVED******REMOVED***localized: "Terminal Configuration",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let traceButtonLabel = String(
***REMOVED******REMOVED***localized: "Trace",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let traceConfigurationSectionLabel = String(
***REMOVED******REMOVED***localized: "Trace Configuration",
***REMOVED******REMOVED***bundle: .toolkitModule
***REMOVED***)
***REMOVED***
***REMOVED***static let unnamedAssetType = String(
***REMOVED******REMOVED***localized: "Unnamed Asset Type",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A label to use in place of a utility element asset type name."
***REMOVED***)
***REMOVED***
***REMOVED***static let zoomToButtonLabel = String(
***REMOVED******REMOVED***localized: "Zoom To",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A button to change the map to the extent of the selected trace."
***REMOVED***)
***REMOVED***
***REMOVED***static let zoomToResult = String(
***REMOVED******REMOVED***localized: "Zoom to result",
***REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED***comment: "A user option specifying that a map should automatically change to show completed trace results."
***REMOVED***)
***REMOVED***
