// Copyright 2025 Esri
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
import Foundation

extension UtilityAssociationsFilter.Kind {
    /// A localized label for the associations filter kind.
    var label: LocalizedStringResource {
        switch self {
        case .attachment:
                .init(
                    "utility-associations-filter-attachment-label",
                    defaultValue: "Attachment",
                    bundle: .toolkit,
                    comment: #"A label for the "Attachment" utility associations filter kind."#
                )
        case .connectivity:
                .init(
                    "utility-associations-filter-connectivity-label",
                    defaultValue: "Connectivity",
                    bundle: .toolkit,
                    comment: #"A label for the "Connectivity" utility associations filter kind."#
                )
        case .container:
                .init(
                    "Container",
                    bundle: .toolkit,
                    comment: #"A label for the "Container" utility associations filter kind."#
                )
        case .content:
                .init(
                    "Content",
                    bundle: .toolkit,
                    comment: #"A label for the "Content" utility associations filter kind."#
                )
        case .structure:
                .init(
                    "Structure",
                    bundle: .toolkit,
                    comment: #"A label for the "Structure" utility associations filter kind."#
                )
        @unknown default:
                .init(
                    "utility-associations-filter-unknown-label",
                    defaultValue: "Unknown",
                    bundle: .toolkit,
                    comment: "A label for an unknown utility associations filter kind."
                )
        }
    }
}
