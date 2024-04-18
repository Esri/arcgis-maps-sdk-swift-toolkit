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

***REMOVED***/ A view that displays details of a portal user.
struct UserView: View {
***REMOVED******REMOVED***/ The user to display the details for.
***REMOVED***let user: PortalUser
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED***if let thumbnail = user.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***LoadableImageView(loadableImage: thumbnail)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 100, height: 100, alignment: .center)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.clipShape(Circle())
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: "person.circle")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.frame(width: 100, height: 100, alignment: .center)
***REMOVED******REMOVED******REMOVED***.padding(.bottom)
***REMOVED******REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(spacing: 12) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Name", detail: user.fullName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Username", detail: user.username)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Email", detail: user.email)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if !user.organizationID.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Organization ID", detail: user.organizationID)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let created = user.creationDate {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Created", detail: created.formatted())
***REMOVED******REMOVED******REMOVED******REMOVED*** else if let modified = user.modificationDate {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Modified", detail: modified.formatted())
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let role = user.role {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Role", detail: role.description)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let units = user.units {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Units", detail: units.description)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let access = user.access {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeView(title: "Access", detail: access.description)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeListView(title: "Tags", details: user.tags)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UserAttributeListView(title: "Privileges", details: user.privileges)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

extension PortalUser.Role: CustomStringConvertible {
***REMOVED***public var description: String {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .user:
***REMOVED******REMOVED******REMOVED***return "User"
***REMOVED******REMOVED***case .admin:
***REMOVED******REMOVED******REMOVED***return "Admin"
***REMOVED******REMOVED***case .publisher:
***REMOVED******REMOVED******REMOVED***return "Publisher"
***REMOVED******REMOVED***@unknown default:
***REMOVED******REMOVED******REMOVED***fatalError("Unknown PortalUser.Role")
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED***/ A view that displays user attributes where the detail is a single string.
struct UserAttributeView: View {
***REMOVED******REMOVED***/ The attribute title.
***REMOVED***let title: String
***REMOVED***
***REMOVED******REMOVED***/ The attribute detail.
***REMOVED***let detail: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading, spacing: 2) {
***REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED***Text(detail)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED***
***REMOVED***

***REMOVED***/ A view that displays user attributes where the details are numerous.
struct UserAttributeListView: View {
***REMOVED******REMOVED***/ The attribute title.
***REMOVED***let title: String
***REMOVED***
***REMOVED******REMOVED***/ The attribute details.
***REMOVED***let details: [CustomStringConvertible]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack(alignment: .leading, spacing: 2) {
***REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(.secondary)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED******REMOVED******REMOVED***Text(details.map(\.description).joined(separator: "\r"))
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.caption)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED***
***REMOVED***
