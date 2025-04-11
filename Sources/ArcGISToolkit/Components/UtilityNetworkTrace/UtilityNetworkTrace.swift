***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ `UtilityNetworkTrace` runs traces on a webmap published with a utility network and trace configurations.
***REMOVED***/
***REMOVED***/ | iPhone | iPad |
***REMOVED***/ | ------ | ---- |
***REMOVED***/ | ![image](UtilityNetworkTrace-iPhone) | ![image](UtilityNetworkTrace-iPad) |
***REMOVED***/
***REMOVED***/ **Features**
***REMOVED***/
***REMOVED***/ The utility network trace tool displays a list of named trace configurations defined for utility
***REMOVED***/ networks in a web map. It enables users to add starting points and perform trace analysis from
***REMOVED***/ the selected named trace configuration.
***REMOVED***/
***REMOVED***/ A named trace configuration defined for a utility network in a webmap comprises the parameters
***REMOVED***/ used for a utility network trace.
***REMOVED***/
***REMOVED***/ **Behavior**
***REMOVED***/
***REMOVED***/ The tool allows users to:
***REMOVED***/
***REMOVED***/  - Choose between multiple networks (if more than one is defined in a webmap).
***REMOVED***/  - Choose between named trace configurations:
***REMOVED***/ ![image](UtilityNetworkTraceConfigurations)
***REMOVED***/  - Add trace starting points either programmatically or by tapping on a map view, then use the
***REMOVED***/  inspection view to narrow the selection:
***REMOVED***/ ![image](UtilityNetworkTraceStartingPointDetail-iPad)
***REMOVED***/  - View trace results:
***REMOVED***/
***REMOVED***/ | iPhone | iPad |
***REMOVED***/ | ------ | ---- |
***REMOVED***/ | ![image](UtilityNetworkTraceResult-iPhone) | ![image](UtilityNetworkTraceResult-iPad) |
***REMOVED***/
***REMOVED***/  - Run multiple trace scenarios, then use color and name to compare results:
***REMOVED***/ ![image](UtilityNetworkTraceAdvancedOptions)
***REMOVED***/
***REMOVED***/  - See user-friendly warnings to help avoid common mistakes, including specifying too many
***REMOVED***/ starting points or running the same trace configuration multiple times.
***REMOVED***/
***REMOVED***/ **Associated Types**
***REMOVED***/
***REMOVED***/ `UtilityNetworkTrace` has the following associated type:
***REMOVED***/
***REMOVED***/ - ``UtilityNetworkTraceStartingPoint``
***REMOVED***/
***REMOVED***/ To see the `UtilityNetworkTrace` in action, check out the [Examples](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
***REMOVED***/ and refer to [UtilityNetworkTraceExampleView.swift](https:***REMOVED***github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/UtilityNetworkTraceExampleView.swift)
***REMOVED***/ in the project. To learn more about using the `UtilityNetworkTrace` see the <doc:UtilityNetworkTraceTutorial>.
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
***REMOVED******REMOVED***/ A Boolean value indicating whether the "Delete All Starting Points" confirmation is presented.
***REMOVED***@State private var deleteAllStartingPointsConfirmationIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the map should be zoomed to the extent of the trace result.
***REMOVED***@State private var shouldZoomOnTraceCompletion = true
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
***REMOVED******REMOVED***/ Acts as the point at which newly selected starting point graphics will be created.
***REMOVED***@Binding private var mapPoint: Point?
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
***REMOVED******REMOVED******REMOVED***List(
***REMOVED******REMOVED******REMOVED******REMOVED***assetTypeGroups.sorted(using: KeyPathComparator(\.key)),
***REMOVED******REMOVED******REMOVED******REMOVED***id: \.key
***REMOVED******REMOVED******REMOVED***) { (name, elements) in
***REMOVED******REMOVED******REMOVED******REMOVED***Section(name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(elements, id: \.globalID) { element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let feature = await viewModel.feature(for: element),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let geometry = feature.geometry {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateViewpoint(to: geometry.extent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Label(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***localized: "Object ID: \(element.objectID, format: .number.grouping(.never))",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A string identifying a utility network object."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***systemImage: "scope"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(elements.count, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED******REMOVED***
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listItemTint(.monochrome)
#endif
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
***REMOVED******REMOVED******REMOVED***ForEach(viewModel.configurations.sorted { $0.name < $1.name ***REMOVED***, id: \.name) { configuration in
***REMOVED******REMOVED******REMOVED******REMOVED***Button(configuration.name) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setPendingTrace(configuration: configuration)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(configuration.name == viewModel.pendingTrace.configuration?.name ? Color.secondary.opacity(0.5) : nil)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Displays the list of available networks.
***REMOVED***@ViewBuilder private var networksList: some View {
***REMOVED******REMOVED***ForEach(viewModel.networks, id: \.name) { network in
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***viewModel.setNetwork(network)
***REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(nil)
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(network.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.listRowBackground(network.name == viewModel.network?.name ? Color.secondary.opacity(0.5) : nil)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The tab that allows for a new trace to be configured.
***REMOVED***@ViewBuilder private var newTraceTab: some View {
***REMOVED******REMOVED***List {
***REMOVED******REMOVED******REMOVED***if viewModel.networks.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED***Section(String.networkSectionLabel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceCreationActivity: .viewingNetworkOptions)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace($0 ? .viewingNetworkOptions : nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***networksList
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(viewModel.network?.name ?? .selectNetwork)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section(String.traceConfigurationSectionLabel) {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceCreationActivity: .viewingTraceConfigurations)
***REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace($0 ? .viewingTraceConfigurations : nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***configurationsList
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(viewModel.pendingTrace.configuration?.name ?? .selectTraceConfiguration)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section {
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** header: {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.startingPointsTitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !viewModel.pendingTrace.startingPoints.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(String.deleteAllStartingPoints, systemImage: "trash") {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***deleteAllStartingPointsConfirmationIsPresented = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
#if !os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.labelStyle(.iconOnly)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.confirmationDialog(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***String.deleteAllStartingPointsQuestion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $deleteAllStartingPointsConfirmationIsPresented,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***titleVisibility: .visible
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(String.deleteButtonLabel, role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***for startingPoint in viewModel.pendingTrace.startingPoints {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.deleteStartingPoint(startingPoint)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***externalStartingPoints.removeAll()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Override default uppercase capitalization for list
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** section headers on iOS and iPadOS.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.textCase(nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isExpanded: Binding {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isFocused(traceCreationActivity: .viewingAdvancedOptions)
***REMOVED******REMOVED******REMOVED******REMOVED*** set: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace($0 ? .viewingAdvancedOptions : nil)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.nameLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***TextField(String.nameLabel, text: $viewModel.pendingTrace.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.onSubmit {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.userDidSpecifyName = true
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.multilineTextAlignment(.trailing)
#if os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(.hoverEffect, .rect(cornerRadius: 12))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.hoverEffect()
#else
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.blue)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ColorPicker(String.colorLabel, selection: $viewModel.pendingTrace.color)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Toggle(String.zoomToResult, isOn: $shouldZoomOnTraceCompletion)
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.advancedOptionsHeaderLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***Button(String.traceButtonLabel) {
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***if await viewModel.trace() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces(nil)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if shouldZoomOnTraceCompletion,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***   let extent = viewModel.selectedTrace?.resultExtent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateViewpoint(to: extent)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let extent = viewModel.selectedTrace?.resultExtent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateViewpoint(to: extent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.backward")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Text(currentTraceLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.horizontal)
***REMOVED******REMOVED******REMOVED******REMOVED***if viewModel.completedTraces.count > 1 {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.selectNextTrace()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let extent = viewModel.selectedTrace?.resultExtent {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateViewpoint(to: extent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateViewpoint(to: resultExtent)
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
***REMOVED******REMOVED******REMOVED***.catalystPadding()
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .viewingTraces(.viewingElementGroup(named: assetGroupName))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(assetGroupName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(selectedTrace.elements(inAssetGroupNamed: assetGroupName).count, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
#if !os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.blue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(.rect)
#endif
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text.makeResultsLabel(viewModel.selectedTrace?.elementResults.count ?? 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let result = item.result as? Double {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(result, format: .number)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"Not Available",
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***comment: "A trace function output result was not provided."
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text.makeResultsLabel(viewModel.selectedTrace?.utilityFunctionTraceResult?.functionOutputs.count ?? 0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DisclosureGroup(
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
***REMOVED******REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(String.advancedOptionsHeaderLabel)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(4)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding([.vertical], 2)
***REMOVED******REMOVED******REMOVED***Button(String.clearAllResults, role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED***isShowingClearAllResultsConfirmationDialog = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.bordered)
***REMOVED******REMOVED******REMOVED***.confirmationDialog(
***REMOVED******REMOVED******REMOVED******REMOVED***String.clearAllResults,
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $isShowingClearAllResultsConfirmationDialog
***REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED***Button(String.clearAllResults, role: .destructive) {
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***updateViewpoint(to: extent)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Button(String.deleteButtonLabel, role: .destructive) {
***REMOVED******REMOVED******REMOVED******REMOVED***if let startingPoint = selectedStartingPoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.deleteStartingPoint(startingPoint)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***externalStartingPoints.removeAll { $0 == startingPoint ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.font(.title3)
***REMOVED******REMOVED***.catalystPadding()
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewModel.pendingTrace.startingPoints
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.first(where: { $0 == selectedStartingPoint ***REMOVED***)?
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.utilityElement?.assetType.terminalConfiguration?.terminals ?? [],
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***id: \.self
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text($0.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
#if !os(visionOS)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.blue)
#endif
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Section(String.attributesSectionTitle) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(Array(selectedStartingPoint!.geoElement.attributes.sorted(by: { $0.key < $1.key***REMOVED***)), id: \.key) { item in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
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
***REMOVED******REMOVED***/   - mapViewProxy: The proxy to provide access to map view operations.
***REMOVED******REMOVED***/   - startingPoints: An optional list of programmatically provided starting points. This
***REMOVED******REMOVED***/   property will not modify interactively added starting points.
***REMOVED***public init(
***REMOVED******REMOVED***graphicsOverlay: Binding<GraphicsOverlay>,
***REMOVED******REMOVED***map: Map,
***REMOVED******REMOVED***mapPoint: Binding<Point?>,
***REMOVED******REMOVED***mapViewProxy: MapViewProxy,
***REMOVED******REMOVED***startingPoints: Binding<[UtilityNetworkTraceStartingPoint]> = .constant([])
***REMOVED***) {
***REMOVED******REMOVED***self.mapViewProxy = mapViewProxy
***REMOVED******REMOVED***_activeDetent = .constant(nil)
***REMOVED******REMOVED***_mapPoint = mapPoint
***REMOVED******REMOVED***_graphicsOverlay = graphicsOverlay
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
***REMOVED******REMOVED***/ Updates the viewpoint to the provided extent. If a map view proxy is provided, the update is
***REMOVED******REMOVED***/ animated. Otherwise the bound viewpoint is set directly.
***REMOVED******REMOVED***/ - Parameter extent: The new extent to be shown.
***REMOVED***func updateViewpoint(to extent: Envelope) {
***REMOVED******REMOVED***let newViewpoint = Viewpoint(boundingGeometry: extent)
***REMOVED******REMOVED***if let mapViewProxy {
***REMOVED******REMOVED******REMOVED***Task { await mapViewProxy.setViewpoint(newViewpoint, duration: nil) ***REMOVED***
***REMOVED***
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
***REMOVED******REMOVED***.onChange(of: mapPoint) {
***REMOVED******REMOVED******REMOVED***guard isFocused(traceCreationActivity: .addingStartingPoints),
***REMOVED******REMOVED******REMOVED******REMOVED***  let mapPoint = mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED***  let mapViewProxy = mapViewProxy else {
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***currentActivity = .creatingTrace(.viewingStartingPoints)
***REMOVED******REMOVED******REMOVED***activeDetent = .half
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***await viewModel.addStartingPoints(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***mapPoint: mapPoint,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: mapViewProxy
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.onChange(of: externalStartingPoints) {
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
***REMOVED******REMOVED******REMOVED***localized: "Trace \(index+1, specifier: "%1$lld") of \(viewModel.completedTraces.count, specifier: "%2$lld")",
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
***REMOVED***private func makeBackButton(title: String, action: @escaping () -> Void) -> some View {
***REMOVED******REMOVED***Button(title, systemImage: "chevron.backward", action: action)
***REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
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
***REMOVED***static var addNewButtonLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Add New",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A button to add new utility trace starting points."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var advancedOptionsHeaderLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Advanced Options",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A section header for advanced options."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var attributesSectionTitle: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Attributes",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to the attributes of a geo element."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var cancelStartingPointSelection: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Cancel Starting Point Selection",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to cancel the starting point selection operation."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var clearAllResults: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Clear All Results",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A directive to clear all of the completed utility network traces."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var clearAllResultsMessage: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "All the trace inputs and results will be lost.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A message describing the outcome of clearing all utility network trace results."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var colorLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Color",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to the color used to display utility trace result graphics."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var deleteAllStartingPoints: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Delete All Starting Points",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button used to delete all starting points on a pending utility network trace."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var deleteAllStartingPointsQuestion: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Delete all starting points?",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "The title of the dialogue confirming deletion of all points."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var deleteButtonLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Delete",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button used to delete a utility network trace input component or result."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Title for the feature results section
***REMOVED***static var featureResultsTitle: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Feature Results",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED***A label in reference to utility elements returned as results of a utility network
***REMOVED******REMOVED******REMOVED******REMOVED***trace operation.
***REMOVED******REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var fractionAlongEdgeSectionTitle: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Fraction Along Edge",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to a fractional distance along an edge style utility network element."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var functionResultsSectionTitle: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Function Results",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED***A label in reference to function outputs returned as results of a utility network
***REMOVED******REMOVED******REMOVED******REMOVED***trace operation.
***REMOVED******REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var modePickerTitle: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Mode",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "The mode in which the utility network trace tool is being used (either creating traces or viewing traces)."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var nameLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Name",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to the user defined name for an individual utility network trace."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var networkSectionLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Network",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to a specific utility network."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var newTraceOptionLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "New Trace",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to show new utility network trace configuration options."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var noConfigurationsAvailable: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "No configurations available.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A statement that no utility trace configurations are available."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var resultsOptionLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Results",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to show utility network trace results."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for button to select a utility network.
***REMOVED***static var selectNetwork: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Select Network",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for button to select a utility network."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for button to select a utility network trace configuration.
***REMOVED***static var selectTraceConfiguration: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Select Trace Configuration",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for button to select a utility network trace configuration."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Title for the starting points section
***REMOVED***static var startingPointsTitle: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Starting Points",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED******REMOVED***A label in reference to the utility elements chosen as starting points for a utility
***REMOVED******REMOVED******REMOVED******REMOVED***network trace operation.
***REMOVED******REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var terminalConfigurationPickerTitle: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Terminal Configuration",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to the chosen terminal configuration of a utility network element."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var traceButtonLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Trace",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to begin a utility network trace operation."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var traceConfigurationSectionLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Trace Configuration",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label in reference to a utility network trace configuration."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var unnamedAssetType: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Unnamed Asset Type",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label to use in place of a utility element asset type name."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var zoomToButtonLabel: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Zoom To",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A button to change the map to the extent of the selected trace."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***static var zoomToResult: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Zoom To Result",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A user option specifying that a map should automatically change to show completed trace results."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

public extension UtilityNetworkTrace /* Deprecated */ {
***REMOVED******REMOVED***/ A graphical interface to run pre-configured traces on a map's utility networks.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - graphicsOverlay: The graphics overlay to hold generated starting point and trace graphics.
***REMOVED******REMOVED***/   - map: The map containing the utility network(s).
***REMOVED******REMOVED***/   - mapPoint: Acts as the point at which newly selected starting point graphics will be created.
***REMOVED******REMOVED***/   - screenPoint: Acts as the point of identification for items tapped in the utility network.
***REMOVED******REMOVED***/   - mapViewProxy: The proxy to provide access to map view operations.
***REMOVED******REMOVED***/   - viewpoint: Allows the utility network trace tool to update the parent map view's viewpoint.
***REMOVED******REMOVED***/   - startingPoints: An optional list of programmatically provided starting points. This
***REMOVED******REMOVED***/   property will not modify interactively added starting points.
***REMOVED******REMOVED***/ - Attention: Deprecated at 200.7.
***REMOVED***@available(*, deprecated, message: "Use 'init(graphicsOverlay:map:mapPoint:mapViewProxy:startingPoints:)' instead.")
***REMOVED***init(
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
***REMOVED******REMOVED***_mapPoint = mapPoint
***REMOVED******REMOVED***_graphicsOverlay = graphicsOverlay
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

private extension Text {
***REMOVED***static func makeResultsLabel(_ results: Int) -> Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***"^[\(results) Results](inflect: true)",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label indicating the number of results of a utility network trace."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
