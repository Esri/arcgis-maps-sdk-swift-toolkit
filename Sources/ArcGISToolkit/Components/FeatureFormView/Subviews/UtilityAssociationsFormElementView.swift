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
***REMOVED******REMOVED******REMOVED***try? await element.fetchAssociationsFilterResults()
***REMOVED******REMOVED******REMOVED***associationsFilterResults = element.associationsFilterResults
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
***REMOVED******REMOVED******REMOVED***if let currentFeatureGlobalID = formViewModel.featureForm.feature.globalID {
***REMOVED******REMOVED******REMOVED******REMOVED***let associatedElement = utilityAssociationResult.association.displayedElement(for: currentFeatureGlobalID)
***REMOVED******REMOVED******REMOVED******REMOVED***let title: String = {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let formDefinitionTitle = associatedElement.networkSource.featureTable.featureFormDefinition?.title {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***formDefinitionTitle
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"\(associatedElement.assetGroup.name) - \(associatedElement.objectID)"
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***()
***REMOVED******REMOVED******REMOVED******REMOVED***let connection: UtilityAssociationView.Association.Connection? = switch utilityAssociationResult.association.kind {
***REMOVED******REMOVED******REMOVED******REMOVED***case .junctionEdgeObjectConnectivityMidspan:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.middle
***REMOVED******REMOVED******REMOVED******REMOVED***case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityToSide:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***currentFeatureGlobalID == utilityAssociationResult.association.fromElement.globalID ? .left : .right
***REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***nil
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityAssociationView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***association: UtilityAssociationView.Association(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***connectionPoint: connection,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***description: nil,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fractionAlongEdge: utilityAssociationResult.association.fractionAlongEdge,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***name: title,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***selectionAction: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let navigationAction: () -> Void = {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***navigationLayerModel.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***InternalFeatureFormView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***featureForm: FeatureForm(feature: utilityAssociationResult.associatedFeature)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if formViewModel.featureForm.hasEdits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***setAlertContinuation?(true, navigationAction)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***navigationAction()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***terminalName: associatedElement.terminal?.name
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
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
***REMOVED******REMOVED***let listRowTitle = "\(utilityAssociationsFilterResult.filter.filterType)".capitalized
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***navigationLayerModel.push {
***REMOVED******REMOVED******REMOVED******REMOVED***UtilityAssociationsFilterResultView(utilityAssociationsFilterResult: utilityAssociationsFilterResult)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationLayerTitle(formViewModel.title, subtitle: listRowTitle)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(formViewModel)
***REMOVED******REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Text(listRowTitle)
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Text(utilityAssociationsFilterResult.resultCount.formatted())
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.right")
***REMOVED******REMOVED***
***REMOVED***
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
***REMOVED******REMOVED******REMOVED***Button(utilityAssociationGroupResult.name) {
***REMOVED******REMOVED******REMOVED******REMOVED***navigationLayerModel.push {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UtilityAssociationGroupResultView(utilityAssociationGroupResult: utilityAssociationGroupResult)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.navigationLayerTitle(formViewModel.title, subtitle: utilityAssociationGroupResult.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.environmentObject(formViewModel)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ <#Description#>
private struct UtilityAssociationView: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***var association: Association
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***association.selectionAction()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if let connection = association.connectionPoint {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let image: String = switch connection {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .left:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"connection-end-left"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .middle:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"connection-middle"
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case .right:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***"connection-end-right"
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(image, bundle: .toolkitModule)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(association.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let description = association.description {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let percent = association.fractionAlongEdge {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(percent.formatted(.percent))
***REMOVED******REMOVED******REMOVED******REMOVED*** else if let terminal = association.terminalName {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("Terminal: \(terminal)")
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

private extension UtilityAssociation {
***REMOVED******REMOVED***/ Determines whether to show the `fromElement` or `toElement`.
***REMOVED******REMOVED***/ - Parameter id: <#id description#>
***REMOVED******REMOVED***/ - Returns: <#description#>
***REMOVED***func displayedElement(for id: UUID) -> UtilityElement {
***REMOVED******REMOVED***if id == toElement.globalID {
***REMOVED******REMOVED******REMOVED***fromElement
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***toElement
***REMOVED***
***REMOVED***
***REMOVED***

private extension UtilityAssociationView {
***REMOVED***struct Association {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***enum Connection {
***REMOVED******REMOVED******REMOVED***case left
***REMOVED******REMOVED******REMOVED***case middle
***REMOVED******REMOVED******REMOVED***case right
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let connectionPoint: Connection?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let description: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let fractionAlongEdge: Double?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let selectionAction: (() -> Void)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let terminalName: String?
***REMOVED***
***REMOVED***
