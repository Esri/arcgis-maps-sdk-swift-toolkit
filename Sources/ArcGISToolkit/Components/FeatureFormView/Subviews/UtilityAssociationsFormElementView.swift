***REMOVED*** Copyright 2025 Esri
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

***REMOVED***/ <#Description#>
struct UtilityAssociationsFormElementView: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@EnvironmentObject private var formViewModel: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@State private var associationsFilterResults = [UtilityAssociationsFilterResult]()
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let element: UtilityAssociationsFormElement
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***FeatureFormGroupedContentView(content: associationsFilterResults.compactMap {
***REMOVED******REMOVED******REMOVED***if $0.resultCount > 0 {
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityAssociationsFilterResultListRowView(utilityAssociationsFilterResult: $0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(formViewModel)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***nil
***REMOVED******REMOVED***
***REMOVED***)
***REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED***if let results = try? await element.associationsFilterResults {
***REMOVED******REMOVED******REMOVED******REMOVED***associationsFilterResults = results
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ <#Description#>
private struct UtilityAssociationGroupResultView: View {
***REMOVED***@Environment(\.formChangedAction) var formChangedAction
***REMOVED***
***REMOVED***@Environment(\.setAlertContinuation) var setAlertContinuation
***REMOVED***
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject private var formViewModel: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@EnvironmentObject private var navigationLayerModel: NavigationLayerModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let utilityAssociationGroupResult: UtilityAssociationGroupResult
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***List(utilityAssociationGroupResult.associationResults, id: \.associatedFeature.globalID) { utilityAssociationResult in
***REMOVED******REMOVED******REMOVED***UtilityAssociationResultView(
***REMOVED******REMOVED******REMOVED******REMOVED***selectionAction: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let navigationAction: () -> Void = {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***navigationLayerModel.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***InternalFeatureFormView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm: FeatureForm(feature: utilityAssociationResult.associatedFeature)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if formViewModel.featureForm.hasEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***setAlertContinuation?(true, navigationAction)
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***navigationAction()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED***result: utilityAssociationResult
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED*** This view is considered the tail end of a navigable FeatureForm.
***REMOVED******REMOVED******REMOVED******REMOVED*** When a user is backing out of a navigation path, this view
***REMOVED******REMOVED******REMOVED******REMOVED*** appearing is considered a change to the presented FeatureForm.
***REMOVED******REMOVED******REMOVED***formChangedAction?(formViewModel.featureForm)
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ <#Description#>
private struct UtilityAssociationsFilterResultListRowView: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@EnvironmentObject private var formViewModel: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@EnvironmentObject private var navigationLayerModel: NavigationLayerModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let utilityAssociationsFilterResult: UtilityAssociationsFilterResult
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***let listRowTitle = "\(utilityAssociationsFilterResult.filter.title)".capitalized
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***navigationLayerModel.push {
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityAssociationsFilterResultView(utilityAssociationsFilterResult: utilityAssociationsFilterResult)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationLayerTitle(listRowTitle, subtitle: formViewModel.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(formViewModel)
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(listRowTitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !utilityAssociationsFilterResult.filter.description.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(utilityAssociationsFilterResult.filter.description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(utilityAssociationsFilterResult.resultCount.formatted())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.right")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.contentShape(.rect)
***REMOVED***
***REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED***
***REMOVED***

***REMOVED***/ <#Description#>
private struct UtilityAssociationsFilterResultView: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@EnvironmentObject private var formViewModel: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***@EnvironmentObject private var navigationLayerModel: NavigationLayerModel
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let utilityAssociationsFilterResult: UtilityAssociationsFilterResult
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***List(utilityAssociationsFilterResult.groupResults, id: \.name) { utilityAssociationGroupResult in
***REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED***navigationLayerModel.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UtilityAssociationGroupResultView(utilityAssociationGroupResult: utilityAssociationGroupResult)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationLayerTitle(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***utilityAssociationGroupResult.name,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***subtitle: utilityAssociationsFilterResult.filter.title
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(formViewModel)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(utilityAssociationGroupResult.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.primary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(utilityAssociationGroupResult.associationResults.count.formatted())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.right")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ <#Description#>
private struct UtilityAssociationResultView: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let selectionAction: (() -> Void)
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let result: UtilityAssociationResult
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***selectionAction()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if let icon {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***icon
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let containmentIsVisible {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Containment Visible: \(containmentIsVisible)".capitalized)
***REMOVED******REMOVED******REMOVED******REMOVED*** else if let fractionAlongEdge {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(fractionAlongEdge.formatted(.percent))
***REMOVED******REMOVED******REMOVED******REMOVED*** else if let terminalName {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Terminal: \(terminalName)")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(2.5)
***REMOVED******REMOVED******REMOVED******REMOVED***.background(Color(uiColor: .systemBackground))
***REMOVED******REMOVED******REMOVED******REMOVED***.cornerRadius(5)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension UtilityAssociationResult {
***REMOVED******REMOVED***/ The utility element for the association.
***REMOVED***var associatedElement: UtilityElement {
***REMOVED******REMOVED***if associatedFeature.globalID == association.toElement.globalID {
***REMOVED******REMOVED******REMOVED***association.toElement
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***association.fromElement
***REMOVED***
***REMOVED***
***REMOVED***

private extension UtilityAssociationResultView {
***REMOVED******REMOVED***/ A Boolean value indicating whether the containment is visible if result represents a containment association.
***REMOVED***var containmentIsVisible: Bool? {
***REMOVED******REMOVED***guard (result.association.toElement.globalID == result.associatedElement.globalID) else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***switch result.association.kind {
***REMOVED******REMOVED***case .containment:
***REMOVED******REMOVED******REMOVED***return result.association.containmentIsVisible
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A description for the result.
***REMOVED***var description: String {
***REMOVED******REMOVED***if let table = result.associatedFeature.table as? ArcGISFeatureTable,
***REMOVED******REMOVED***   let description = table.featureFormDefinition?.description {
***REMOVED******REMOVED******REMOVED***description
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***result.associatedElement.assetGroup.name
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The relative location along a non-spatial edge where the junction represented via the association is
***REMOVED******REMOVED***/ (logically) located.
***REMOVED***var fractionAlongEdge: Double? {
***REMOVED******REMOVED***switch result.association.kind {
***REMOVED******REMOVED***case .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityMidspan, .junctionEdgeObjectConnectivityToSide:
***REMOVED******REMOVED******REMOVED***if result.associatedElement.networkSource.kind == .edge {
***REMOVED******REMOVED******REMOVED******REMOVED***result.association.fractionAlongEdge
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An icon representing the association.
***REMOVED***var icon: Image? {
***REMOVED******REMOVED***let imageName: String? = switch result.association.kind {
***REMOVED******REMOVED***case .junctionEdgeObjectConnectivityMidspan:
***REMOVED******REMOVED******REMOVED***"connection-middle"
***REMOVED******REMOVED***case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityToSide:
***REMOVED******REMOVED******REMOVED***if result.associatedFeature.globalID == result.association.fromElement.globalID {
***REMOVED******REMOVED******REMOVED******REMOVED***"connection-end-left"
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***"connection-end-right"
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***nil
***REMOVED***
***REMOVED******REMOVED***return imageName != nil ? Image(imageName!, bundle: .toolkitModule) : nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The UtilityTerminal of the associated utility network feature.
***REMOVED***var terminalName: String? {
***REMOVED******REMOVED***switch result.association.kind {
***REMOVED******REMOVED***case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityMidspan, .junctionEdgeObjectConnectivityToSide:
***REMOVED******REMOVED******REMOVED***if result.associatedElement.networkSource.kind == .junction {
***REMOVED******REMOVED******REMOVED******REMOVED***result.associatedElement.terminal?.name
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***nil
***REMOVED******REMOVED***
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***nil
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A title for the result.
***REMOVED***var title: String {
***REMOVED******REMOVED***if let table = result.associatedFeature.table as? ArcGISFeatureTable,
***REMOVED******REMOVED***   let title = table.featureFormDefinition?.title {
***REMOVED******REMOVED******REMOVED***title
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***"\(result.associatedElement.assetGroup.name) - \(result.associatedElement.objectID)"
***REMOVED***
***REMOVED***
***REMOVED***
