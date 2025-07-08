// Copyright 2023 Esri
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

///  A selected site, facility, or level.
public enum FloorFilterSelection: Hashable, Sendable {
    /// A selected site.
    case site(FloorSite)
    /// A selected facility.
    case facility(FloorFacility)
    /// A selected level.
    case level(FloorLevel)
}

public extension FloorFilterSelection {
    /// The selected site.
    var site: FloorSite? {
        switch self {
        case .site(let site):
            return site
        case .facility(let facility):
            return facility.site
        case .level(let level):
            return level.facility?.site
        }
    }
    
    /// The selected facility.
    var facility: FloorFacility? {
        switch self {
        case .facility(let facility):
            return facility
        case .level(let level):
            return level.facility
        default:
            return nil
        }
    }
    
    /// The selected level.
    var level: FloorLevel? {
        if case let .level(level) = self {
            return level
        } else {
            return nil
        }
    }
}
