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
import ArcGISToolkit
import Foundation
import Observation

@MainActor
@Observable
final class BuildingExplorerTestViewModel {
    /// The scene to be displayed.
    let scene = Scene(url: URL(string: "https://www.arcgis.com/home/item.html?id=b7c387d599a84a50aafaece5ca139d44")!)!
    /// A Boolean indicating if the building explorer is visible.
    var explorerIsVisible = true
    /// The items to show in the building explorer.
    var items: [BuildingExplorerItem] = []
    /// The selected item in the building explorer.
    var selection: BuildingExplorerItem?
}
