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

/// A view that displays a `UtilityAssociationResult` and performs an action
/// when it is tapped.
struct UtilityAssociationResultButton: View {
    /// The model for the navigation layer.
    @Environment(NavigationLayerModel.self) private var navigationLayerModel
    
    /// The title describing the utility association result.
    private let title: String
    
    /// The utility association result to display.
    private let result: UtilityAssociationResult
    
    /// The action to perform when the user triggers the button.
    private let action: () -> Void
    
    /// Creates a `UtilityAssociationResultButton`.
    /// - Parameters:
    ///   - title: A title describing the utility association result.
    ///   - result: A utility association result to display.
    ///   - action: The action to perform when the user triggers the button.
    init(_ title: String, result: UtilityAssociationResult, action: @escaping () -> Void) {
        self.title = title
        self.result = result
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = result.association.kind.icon {
                    icon
                }
                VStack(alignment: .leading) {
                    Text(title)
                    if let description = result.details {
                        Text(description)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .contentShape(.rect)
        }
    }
}

private extension UtilityAssociationResult {
    /// The utility element which is the associated feature.
    private var associatedElement: UtilityElement {
        associatedFeatureIsToElement ?  association.toElement : association.fromElement
    }
    
    /// A Boolean value indicating whether the `associatedFeature` global ID
    /// matches the `toElement` global ID.
    private var associatedFeatureIsToElement: Bool {
        associatedFeature.globalID == association.toElement.globalID
    }
    
    /// The details describing the result's association.
    var details: String? {
        switch association.kind {
        case .connectivity, .junctionEdgeObjectConnectivityFromSide, .junctionEdgeObjectConnectivityToSide:
            associatedElement.terminal?.name
        case .containment:
            associatedFeatureIsToElement
            ? "Containment Visible: \(association.containmentIsVisible)".capitalized
            : nil
        case .junctionEdgeObjectConnectivityMidspan:
            associatedFeatureIsToElement && association.toElement.networkSource.kind == .edge
            ? association.fractionAlongEdge.formatted(.percent)
            : associatedElement.terminal?.name
        default:
            nil
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
