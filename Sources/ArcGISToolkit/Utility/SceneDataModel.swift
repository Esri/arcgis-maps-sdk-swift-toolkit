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

/// A data model class containing a Scene.
public class SceneDataModel: ObservableObject {
    /// The `Scene` used for display in a `SceneView`.
    @Published public var scene: ArcGIS.Scene
    
    /// Creates a `SceneDataModel`.
    /// - Parameter scene: The `Scene` used for display.
    public init(scene: ArcGIS.Scene) {
        self.scene = scene
    }
}
