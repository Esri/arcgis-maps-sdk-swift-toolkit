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

#if os(iOS)
import ArcGIS
import Observation

/// A lightweight observable wrapper around an optional ArcGIS `Camera`.
///
/// This is useful when a SwiftUI view needs to observe changes to camera state
/// through the Observation system.
@Observable
final class CameraWrapper {
    /// The wrapped ArcGIS camera.
    let camera: Camera?
    
    /// Creates a wrapper for the provided camera.
    /// - Parameter camera: The ArcGIS camera to wrap.
    init(_ camera: Camera?) {
        self.camera = camera
    }
}
#endif
