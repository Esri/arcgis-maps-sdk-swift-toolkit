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
    /// Represents events that occur during the form editing lifecycle. These events notify you
    /// when the user has performed an action within the component.
    /// - Since: 200.8
    enum EditingEvent {
        /// Indicates that edits failed to finish.
#warning("TODO: Finalize since version.")
        /// - Since: 300.2
        case failed(any Error)
        /// Indicates that the user has discarded their edits.
#warning("TODO: Finalize since version.")
        /// - Since: 300.2
        case finished
        /// Indicates that the user has discarded their edits.
#warning("TODO: Finalize since version.")
        /// - Since: 300.2
        case discarded
        /// Indicates the active form or the navigation path for the active form has changed.
        ///
        /// Forms with `UtilityAssociationsFormElement`s have multiple possible
        /// navigation destinations.
        /// - Since: 300.0
        case navigationChanged(NavigationPathItem)
        /// Indicates that the user has tapped on an option to visualize a feature on the map.
        /// - Since: 300.0
        case showOnMapRequested(ArcGISFeature)
        /// Indicates that the user has started an attempt to finish editing the form(s).
#warning("TODO: Finalize since version.")
        /// - Since: 300.2
        case willFinish
        
        // MARK: Deprecated cases
        
        /// Indicates that the user has discarded their edits.
        /// - Parameter willNavigate: A Boolean value indicating whether the view will
        /// navigate after discarding.
#warning("TODO: Finalize deprecation version.")
        /// - Note: Deprecated at 300.2 - discarding edits before navigation is no longer
        /// required. Replace this with 'discarded'.
        /// - Since: 200.8
        @available(*, deprecated, renamed: "FeatureFormView.EditingEvent.discarded")
        case discardedEdits(willNavigate: Bool)
        /// Indicates that the user has saved their edits.
        /// - Parameter willNavigate: A Boolean value indicating whether the view will
        /// navigate after saving.
#warning("TODO: Finalize deprecation version.")
        /// - Note: Deprecated at 300.2 - finishing edits before navigation is no longer
        /// required. Replace this with 'finished'.
        /// - Since: 200.8
        @available(*, deprecated, renamed: "FeatureFormView.EditingEvent.finished")
        case savedEdits(willNavigate: Bool)
    }
}
