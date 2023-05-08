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
import ArcGIS

/// A very basic data model class containing a Map. Since a `Map` is not an observable object,
/// clients can use `MapDataModel` as an example of how you would store a map in a data model
/// class. The class inherits from `ObservableObject` and the `Map` is defined as a @Published
/// property. This allows SwiftUI views to be updated automatically when a new map is set on the model.
/// Being stored in the model also prevents the map from continually being created during redraws.
/// The data model class would be expanded upon in client code to contain other properties required
/// for the model.
class MapDataModel: ObservableObject {
    /// The `Map` used for display in a `MapView`.
    @Published var map: Map
    
    /// Creates a `MapDataModel`.
    /// - Parameter map: The `Map` used for display.
    init(map: Map) {
        self.map = map
    }
}
