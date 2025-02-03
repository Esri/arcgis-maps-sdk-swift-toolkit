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

struct UtilityNetworkAssociationFormElementView: View {
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let description: String
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let associationKindGroups: [AssociationKindGroup]
***REMOVED***
***REMOVED******REMOVED***/ <#Description#>
***REMOVED***let title: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED*** TODO: InputHeader to replace following in final implementation --
***REMOVED******REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.subheadline)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** TODO: End InputHeader replacement section -----------------------
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** TODO: InputFooter to replace following in final implementation --
***REMOVED******REMOVED******REMOVED******REMOVED***/
***REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED*** TODO: End InputFooter replacement section -----------------------
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***FeatureFormGroupedContentView(
***REMOVED******REMOVED******REMOVED******REMOVED***content: associationKindGroups.map { group in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(value: group) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(group.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.primary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(group.networkSourceGroups.flatMap( { $0.associations.compactMap { $0 ***REMOVED*** ***REMOVED*** ).count.formatted())
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.right")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.contentShape(.rect)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***

extension UtilityNetworkAssociationFormElementView {
***REMOVED***struct Association: Identifiable {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let description: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let linkDestination: (any Hashable)?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let percentAlongEdge: Int?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let terminal: String?
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - description: <#description description#>
***REMOVED******REMOVED******REMOVED***/   - linkDestination: <#linkDestination description#>
***REMOVED******REMOVED******REMOVED***/   - name: <#name description#>
***REMOVED******REMOVED***init(description: String?, linkDestination: (any Hashable)?, name: String) {
***REMOVED******REMOVED******REMOVED***self.init(description: description, linkDestination: linkDestination, name: name, percentAlongEdge: nil, terminal: nil)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - description: <#description description#>
***REMOVED******REMOVED******REMOVED***/   - linkDestination: <#linkDestination description#>
***REMOVED******REMOVED******REMOVED***/   - name: <#name description#>
***REMOVED******REMOVED******REMOVED***/   - percentAlongEdge: <#percentAlongEdge description#>
***REMOVED******REMOVED***init(description: String?, linkDestination: (any Hashable)?, name: String, percentAlongEdge: Int) {
***REMOVED******REMOVED******REMOVED***self.init(description: description, linkDestination: linkDestination, name: name, percentAlongEdge: percentAlongEdge, terminal: nil)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED******REMOVED***/   - description: <#description description#>
***REMOVED******REMOVED******REMOVED***/   - linkDestination: <#linkDestination description#>
***REMOVED******REMOVED******REMOVED***/   - name: <#name description#>
***REMOVED******REMOVED******REMOVED***/   - terminal: <#terminal description#>
***REMOVED******REMOVED***init(description: String?, linkDestination: (any Hashable)?, name: String, terminal: String) {
***REMOVED******REMOVED******REMOVED***self.init(description: description, linkDestination: linkDestination, name: name, percentAlongEdge: nil, terminal: terminal)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***private init(description: String?, linkDestination: (any Hashable)?, name: String, percentAlongEdge: Int?, terminal: String?) {
***REMOVED******REMOVED******REMOVED***self.description = description
***REMOVED******REMOVED******REMOVED***self.linkDestination = linkDestination
***REMOVED******REMOVED******REMOVED***self.name = name
***REMOVED******REMOVED******REMOVED***self.percentAlongEdge = percentAlongEdge
***REMOVED******REMOVED******REMOVED***self.terminal = terminal
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AssociationView: View {
***REMOVED******REMOVED***var association: Association
***REMOVED******REMOVED***
***REMOVED******REMOVED***@State private var selectionTask: Task<Void, Never>?
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***NavigationLink(value: association.linkDestination!) {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(association.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let description = association.description {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(description)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED***.padding(.leading)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AssociationKindGroup: Equatable, Hashable, Identifiable {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let networkSourceGroups: [NetworkSourceGroup]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let presentingForm: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***static func == (lhs: UtilityNetworkAssociationFormElementView.AssociationKindGroup, rhs: UtilityNetworkAssociationFormElementView.AssociationKindGroup) -> Bool {
***REMOVED******REMOVED******REMOVED***lhs.name == rhs.name
***REMOVED******REMOVED******REMOVED***&& lhs.id == rhs.id
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED******REMOVED***hasher.combine(name)
***REMOVED******REMOVED******REMOVED***hasher.combine(id)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AssociationKindGroupView: View {
***REMOVED******REMOVED***let associationKindGroup: AssociationKindGroup
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***List(associationKindGroup.networkSourceGroups) { group in
***REMOVED******REMOVED******REMOVED******REMOVED***NavigationLink(value: group) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(group.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(group.associations.count.formatted())
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(Color(uiColor: .tertiarySystemFill))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.scrollContentBackground(.hidden)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct NetworkSourceGroup: Equatable, Hashable ,Identifiable {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let associations: [Association]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let presentingForm: String
***REMOVED******REMOVED***
***REMOVED******REMOVED***static func == (lhs: UtilityNetworkAssociationFormElementView.NetworkSourceGroup, rhs: UtilityNetworkAssociationFormElementView.NetworkSourceGroup) -> Bool {
***REMOVED******REMOVED******REMOVED***lhs.name == rhs.name
***REMOVED******REMOVED******REMOVED***&& lhs.id == rhs.id
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func hash(into hasher: inout Hasher) {
***REMOVED******REMOVED******REMOVED***hasher.combine(name)
***REMOVED******REMOVED******REMOVED***hasher.combine(id)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct NetworkSourceGroupView: View {
***REMOVED******REMOVED***let networkSourceGroup:  NetworkSourceGroup
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***List(networkSourceGroup.associations) {
***REMOVED******REMOVED******REMOVED******REMOVED***AssociationView(association: $0)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.listRowBackground(Color(uiColor: .tertiarySystemFill))
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.scrollContentBackground(.hidden)
***REMOVED***
***REMOVED***
***REMOVED***
