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
import SwiftUI

extension UtilityAssociation.Kind {
    /// A localized label for the association kind.
    var name: Text {
        switch self {
        case .attachment:
            Text(
                "Attachment",
                bundle: .toolkitModule,
                comment: #"A label for the "Attachment" utility association kind."#
            )
        case .connectivity:
            Text(
                "Connectivity",
                bundle: .toolkitModule,
                comment: #"A label for the "Connectivity" utility association kind."#
            )
        case .containment:
            Text(
                "Containment",
                bundle: .toolkitModule,
                comment: #"A label for the "Containment" utility association kind."#
            )
        case .junctionEdgeObjectConnectivityFromSide:
            Text(
                "Junction Edge Object Connectivity From Side",
                bundle: .toolkitModule,
                comment: #"A label for the "Junction Edge Object Connectivity From Side" utility association kind."#
            )
        case .junctionEdgeObjectConnectivityMidspan:
            Text(
                "Junction Edge Object Connectivity Midspan",
                bundle: .toolkitModule,
                comment: #"A label for the "Junction Edge Object Connectivity Midspan" utility association kind."#
            )
        case .junctionEdgeObjectConnectivityToSide:
            Text(
                "Junction Edge Object Connectivity To Side",
                bundle: .toolkitModule,
                comment: #"A label for the "Junction Edge Object Connectivity To Side" utility association kind."#
            )
        @unknown default:
            Text(
                LocalizedStringResource(
                    "utility-association-unknown-label",
                    defaultValue: "Unknown",
                    bundle: .toolkit,
                    comment: "A label for an unknown utility association kind."
                )
            )
        }
    }
}
