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

/// A provider-resolved camera pose for a world-scale scene.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public struct WorldScaleCameraPose {
    /// The geographic camera at the pose's origin.
    public let originCamera: Camera
    /// The transformation from the origin camera to the current camera.
    public let transformationMatrix: TransformationMatrix

    /// Creates a world-scale camera pose.
    /// - Parameters:
    ///   - originCamera: The geographic camera at the pose's origin.
    ///   - transformationMatrix: The transformation from the origin camera
    ///     to the current camera. Defaults to the identity transformation.
    public init(
        originCamera: Camera,
        transformationMatrix: TransformationMatrix = .identity
    ) {
        self.originCamera = originCamera
        self.transformationMatrix = transformationMatrix
    }
}
#endif
