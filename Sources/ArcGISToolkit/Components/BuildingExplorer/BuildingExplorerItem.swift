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
import Observation

/// An item that can be shown in the ``BuildingExplorer``.
///- Since: 300.0
@MainActor
@Observable
public final class BuildingExplorerItem {
    /// The building scene layer for this item.
    public let layer: BuildingSceneLayer
    /// The level that is selected for this item.
    public internal(set) var level = ""
    /// The phase that is selected for this item.
    public internal(set) var phase = ""
    
    init(layer: BuildingSceneLayer) { self.layer = layer }
}

extension BuildingExplorerItem: @MainActor Equatable {
    public static func == (lhs: BuildingExplorerItem, rhs: BuildingExplorerItem) -> Bool {
        lhs.layer === rhs.layer
    }
}
