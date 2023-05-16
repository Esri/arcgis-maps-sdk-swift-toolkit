// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS

extension LinearUnit {
    /// A localized abbreviation of this unit.
    ///
    /// - Note: Only feet, kilometers, meters and miles are translated at this time.
    var localizedAbbreviation: String {
        switch self {
        case .feet:
            return .init(
                localized: "ft",
                bundle: .module,
                comment: "Abbreviation of 'feet'."
            )
        case .kilometers:
            return .init(
                localized: "km",
                bundle: .module,
                comment: "Abbreviation of 'kilometers'."
            )
        case .meters:
            return .init(
                localized: "m",
                bundle: .module,
                comment: "Abbreviation of 'meters'."
            )
        case .miles:
            return .init(
                localized: "mi",
                bundle: .module,
                comment: "Abbreviation of 'miles'."
            )
        default:
            return ""
        }
    }
}
