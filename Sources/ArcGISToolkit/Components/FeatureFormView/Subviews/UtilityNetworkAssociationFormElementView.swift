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
***REMOVED******REMOVED******REMOVED***ForEach(associationKindGroups) { group in
***REMOVED******REMOVED******REMOVED******REMOVED***AssociationKindGroupView(associationKindGroup: group)
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
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED***
***REMOVED***
***REMOVED***struct AssociationView: View {
***REMOVED******REMOVED***var association: Association
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***HStack {
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "chevron.right")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.plain)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption2)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(.leading)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct AssociationKindGroup: Identifiable {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let networkSourceGroups: [NetworkSourceGroup]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED***
***REMOVED***
***REMOVED***struct AssociationKindGroupView: View {
***REMOVED******REMOVED***let associationKindGroup: AssociationKindGroup
***REMOVED******REMOVED***
***REMOVED******REMOVED***@State private var isExpanded = false
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***DisclosureGroup(isExpanded: $isExpanded) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(associationKindGroup.networkSourceGroups) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***NetworkSourceGroupView(networkSourceGroup: $0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(associationKindGroup.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(associationKindGroup.networkSourceGroups.map({ $0.associations.count ***REMOVED***).count.formatted())
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct NetworkSourceGroup: Identifiable {
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let associations: [Association]
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let id = UUID()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***/ <#Description#>
***REMOVED******REMOVED***let name: String
***REMOVED***
***REMOVED***
***REMOVED***struct NetworkSourceGroupView: View {
***REMOVED******REMOVED***let networkSourceGroup:  NetworkSourceGroup
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***DisclosureGroup {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(networkSourceGroup.associations) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AssociationView(association: $0)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(networkSourceGroup.name)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(networkSourceGroup.associations.count.formatted())
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.padding(.leading)
***REMOVED***
***REMOVED***
***REMOVED***
