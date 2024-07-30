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

import SwiftUI
import ArcGIS

extension FloorFacility {
    /// - Returns: The default level for the facility, which is the level with vertical order 0.
    var defaultLevel: FloorLevel? {
        levels.first(where: { $0.verticalOrder == .zero })
    }
}

extension ArcGIS.FloorFacility: Swift.Equatable {
    public static func == (lhs: FloorFacility, rhs: FloorFacility) -> Bool {
        lhs.id == rhs.id
    }
}

extension ArcGIS.FloorFacility: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
