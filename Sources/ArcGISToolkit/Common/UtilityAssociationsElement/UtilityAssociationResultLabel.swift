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

/// A view that displays the title, details, and icon of a `UtilityAssociationResult`.
struct UtilityAssociationResultLabel: View {
    /// The utility association result to display.
    let result: UtilityAssociationResult
    
    var body: some View {
        HStack {
            result.association.kind.icon
                .accessibilityIdentifier("Association Result Icon")
            
            VStack(alignment: .leading) {
                Text(result.title)
                    .lineLimit(4)
                    .truncationMode(.middle)
                if let details = result.details {
                    details
                        .accessibilityIdentifier("Association Result Description")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            result.fractionAlongEdge
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("Association Result")
    }
}

private extension UtilityAssociationResult {
    /// The details describing the result's association.
    var details: Text? {
        switch association.kind {
        case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityMidspan, .junctionEdgeObjectConnectivityToSide:
            if let terminal = associatedElement.terminal, !terminal.name.isEmpty {
                return Text(terminal.name)
            } else {
                return nil
            }
        case .containment:
            if associatedFeatureIsToElement {
                if association.containmentIsVisible {
                    return Text(
                        "Visible Content",
                        bundle: .toolkitModule,
                        comment:
                            """
                            A label indicating a utility association's 
                            containment is visible.
                            """
                    )
                } else {
                    return Text(
                        "Content",
                        bundle: .toolkitModule,
                        comment:
                            """
                            A label indicating a utility association's 
                            containment is not visible.
                            """
                    )
                }
            } else {
                return nil
            }
        default:
            return nil
        }
    }
    
    @ViewBuilder
    var fractionAlongEdge: Text? {
        if association.kind == .junctionEdgeObjectConnectivityMidspan {
            Text(association.fractionAlongEdge, format: .percent)
        }
    }
}

private extension UtilityAssociation.Kind {
    /// An icon representing the association kind.
    var icon: Image? {
        let imageName: String? = switch self {
        case .connectivity: "connection-to-connection"
        case .junctionEdgeObjectConnectivityFromSide: "connection-end-left"
        case .junctionEdgeObjectConnectivityMidspan: "connection-middle"
        case .junctionEdgeObjectConnectivityToSide: "connection-end-right"
        default: nil
        }
        return imageName.map { Image($0, bundle: .toolkitModule) }
    }
}
