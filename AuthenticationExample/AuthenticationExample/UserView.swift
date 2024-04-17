// Copyright 2022 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

/// A view that displays details of a portal user.
struct UserView: View {
    /// The user to display the details for.
    let user: PortalUser
    
    var body: some View {
        VStack {
            Group {
                if let thumbnail = user.thumbnail {
                    LoadableImageView(loadableImage: thumbnail)
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle")
                        .resizable()
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 100, alignment: .center)
            .padding(.bottom)
            ScrollView {
                VStack(spacing: 12) {
                    UserAttributeView(title: "Name", detail: user.fullName)
                    UserAttributeView(title: "Username", detail: user.username)
                    UserAttributeView(title: "Email", detail: user.email)
                    if !user.organizationID.isEmpty {
                        UserAttributeView(title: "Organization ID", detail: user.organizationID)
                    }
                    if let created = user.creationDate {
                        UserAttributeView(title: "Created", detail: created.formatted())
                    } else if let modified = user.modificationDate {
                        UserAttributeView(title: "Modified", detail: modified.formatted())
                    }
                    if let role = user.role {
                        UserAttributeView(title: "Role", detail: role.description)
                    }
                    if let units = user.units {
                        UserAttributeView(title: "Units", detail: units.description)
                    }
                    if let access = user.access {
                        UserAttributeView(title: "Access", detail: access.description)
                    }
                    UserAttributeListView(title: "Tags", details: user.tags)
                    UserAttributeListView(title: "Privileges", details: user.privileges)
                }
            }
        }
    }
}

extension PortalUser.Role: CustomStringConvertible {
    public var description: String {
        switch self {
        case .user:
            return "User"
        case .admin:
            return "Admin"
        case .publisher:
            return "Publisher"
        @unknown default:
            fatalError("Unknown PortalUser.Role")
        }
    }
}

/// A view that displays user attributes where the detail is a single string.
struct UserAttributeView: View {
    /// The attribute title.
    let title: String
    
    /// The attribute detail.
    let detail: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .lineLimit(1)
                .foregroundColor(.secondary)
                .font(.footnote)
            Text(detail)
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A view that displays user attributes where the details are numerous.
struct UserAttributeListView: View {
    /// The attribute title.
    let title: String
    
    /// The attribute details.
    let details: [CustomStringConvertible]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .lineLimit(1)
                .foregroundColor(.secondary)
                .font(.footnote)
            Text(details.map(\.description).joined(separator: "\r"))
                .font(.caption)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
