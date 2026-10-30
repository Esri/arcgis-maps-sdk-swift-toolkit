// Copyright 2026 Esri
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

extension ArcGISFeatureTable {
    /// The utility network to which this feature table belongs.
    var utilityNetwork: UtilityNetwork? {
        get async throws {
            return switch self {
            case let geodatabaseFeatureTable as GeodatabaseFeatureTable:
                try await geodatabaseFeatureTable._utilityNetwork
            case let serviceFeatureTable as ServiceFeatureTable:
                try await serviceFeatureTable._utilityNetwork
            default:
                nil
            }
        }
    }
}

private extension GeodatabaseFeatureTable {
    /// The utility network to which this geodatabase feature table belongs.
    var _utilityNetwork: UtilityNetwork? {
        get async throws {
            guard let geodatabase else { return nil }
            try await geodatabase.load()
            for utilityNetwork in geodatabase.utilityNetworks {
                try await utilityNetwork.load()
                if let definition = utilityNetwork.definition,
                   definition.networkSources.contains(where: { $0.featureTable === self }) {
                    return utilityNetwork
                }
            }
            return nil
        }
    }
}

private extension ServiceFeatureTable {
    /// The utility network to which this service feature table belongs.
    var _utilityNetwork: UtilityNetwork? {
        get async throws {
            guard let serviceGeodatabase else { return nil }
            try await serviceGeodatabase.load()
            return serviceGeodatabase.utilityNetwork
        }
    }
}
