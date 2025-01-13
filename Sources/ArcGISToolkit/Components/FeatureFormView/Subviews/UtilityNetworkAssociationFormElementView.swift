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

struct UtilityNetworkAssociationFormElementView: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let description: String
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let groups: [Group]
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let title: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***Label {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED*** icon: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "point.3.filled.connected.trianglepath.dotted")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED***ForEach(groups) { group in
***REMOVED******REMOVED******REMOVED******REMOVED***Section {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***GroupView(group: group)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension UtilityNetworkAssociationFormElementView {
***REMOVED***struct Association: Identifiable {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let description: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let icon: UIImage?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***let object: ArcGISFeature
***REMOVED******REMOVED***
***REMOVED******REMOVED***let imageGenerationAction: (() async -> UIImage?)?
***REMOVED***
***REMOVED***
***REMOVED***struct AssociationView: View {
***REMOVED******REMOVED******REMOVED***/ The view model for the form.
***REMOVED******REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED***var association: Association
***REMOVED******REMOVED***
***REMOVED******REMOVED***@State private var fallbackIcon: UIImage?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED***if let image = association.icon {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED*** else if let fallbackIcon {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: fallbackIcon)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(association.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let description = association.description {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***model.selectedAssociation = association.object
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.right")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.task {
***REMOVED******REMOVED******REMOVED******REMOVED***if association.icon == nil,
***REMOVED******REMOVED******REMOVED******REMOVED***   let imageGenerationAction = association.imageGenerationAction,
***REMOVED******REMOVED******REMOVED******REMOVED***   let icon = await imageGenerationAction() {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fallbackIcon = icon
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct Group: Identifiable {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let associations: [Association]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let description: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED***
***REMOVED***
***REMOVED***struct GroupView: View {
***REMOVED******REMOVED***let group: Group
***REMOVED******REMOVED***
***REMOVED******REMOVED***@State private var isExpanded = true
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***DisclosureGroup(isExpanded: $isExpanded) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(group.associations) { association in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AssociationView(association: association)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(.leading)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(group.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let description = group.description {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
