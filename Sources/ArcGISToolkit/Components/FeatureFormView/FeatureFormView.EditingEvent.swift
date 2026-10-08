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

public extension FeatureFormView {
    /// Represents events that occur during the form editing lifecycle.
    /// These events notify you when the user has performed an action within the form.
    /// - Since: 200.8
    enum EditingEvent {
        /// Indicates that the user has discarded their edits.
        /// - Parameter willNavigate: A Boolean value indicating whether the view will navigate after discarding.
        case discardedEdits(willNavigate: Bool)
        /// The view presented in the view changed.
        /// - Since: 300.0
        case navigationChanged(NavigationPathItem)
        /// Indicates that the user has saved their edits.
        /// - Parameter willNavigate: A Boolean value indicating whether the view will navigate after saving.
        case savedEdits(willNavigate: Bool)
        /// Indicates that the user has tapped on an option to visualize a feature on the map.
        /// - Since: 300.0
        case showOnMapRequested(ArcGISFeature)
    }
}
