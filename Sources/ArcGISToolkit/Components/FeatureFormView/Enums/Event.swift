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
import Foundation

public extension FeatureFormView {
    /// Represents events that occur during the component's lifecycle.
    /// - Since: 300.3
    enum Event: @unchecked Sendable {
        /// Indicates that the user has discarded their edits.
        case discarded
        /// Indicates the active form or the navigation path for the active form has changed.
        ///
        /// Forms with `UtilityAssociationsFormElement`s have multiple possible
        /// navigation destinations.
        case navigationChanged(NavigationPathItem)
        /// Indicates that the user has saved their edits.
        case saved
        /// Indicates that saving failed.
        case saveFailed(any Error)
        /// Indicates that the user has tapped on an option to visualize a feature on the map.
        case showOnMapRequested(ArcGISFeature)
        /// Indicates that the user has started an attempt to save their edits.
        case willSave
    }
}

extension FeatureFormView.Event: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return switch (lhs, rhs) {
        case (.discarded, .discarded), (.saved, .saved), (.willSave, .willSave):
            true
        case let (.saveFailed(lhsError), .saveFailed(rhsError)):
            (lhsError as NSError).isEqual(rhsError as NSError)
        case let (.navigationChanged(lhsPathItem), .navigationChanged(rhsPathItem)):
            lhsPathItem == rhsPathItem
        case let (.showOnMapRequested(lhsFeature), .showOnMapRequested(rhsFeature)):
            lhsFeature === rhsFeature
        default:
            false
        }
    }
}
