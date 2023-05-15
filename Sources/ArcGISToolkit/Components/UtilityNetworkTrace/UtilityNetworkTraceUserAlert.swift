// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI

/// A user presentable alert.
struct UtilityNetworkTraceUserAlert {
    /// Title of the alert.
    var title: String = String(localized: "Error", bundle: .module)
    
    /// Description of the alert.
    var description: String
    
    /// An additional action to be taken on the alert.
    var button: Button<Text>?
}

extension UtilityNetworkTraceUserAlert {
    static var startingLocationNotDefined: Self {
        .init(
            description: String(
                localized: "Please set at least 1 starting location.",
                bundle: .module
            )
        )
    }
    
    static var startingLocationsNotDefined: Self {
        .init(
            description: String(
                localized: "Please set at least 2 starting locations.",
                bundle: .module
            )
        )
    }
    
    static var duplicateStartingPoint: Self {
        .init(
            title: String(
                localized: "Failed to set starting point",
                bundle: .module
            ),
            description: String(
                localized: "Duplicate starting points cannot be added.",
                bundle: .module
            )
        )
    }
    
    static var noTraceTypesFound: Self {
        .init(
            description: String(
                localized: "No trace types found.",
                bundle: .module
            )
        )
    }
    
    static var noUtilityNetworksFound: Self {
        .init(
            description: String(
                localized: "No utility networks found.",
                bundle: .module
            )
        )
    }
    
    static var unableToIdentifyElement: Self {
        .init(
            description: String(
                localized: "Element could not be identified.",
                bundle: .module
            )
        )
    }
}
