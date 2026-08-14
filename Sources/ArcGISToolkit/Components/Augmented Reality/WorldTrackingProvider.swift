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
import ARKit
import RealityKit
import SwiftUI

/// A type that provides AR world-tracking behavior.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public protocol WorldTrackingProvider {
    /// The type of the ARView used with this provider.
    associatedtype ARViewType: ARView
    
    /// The session provider that owns the AR session driven by this provider.
    @MainActor var arSessionProvider: ARSessionProvider<ARViewType> { get }
    
    /// The AR configuration used when running the provider's AR session.
    var arConfiguration: ARConfiguration { get }
    
    /// Starts this provider.
    @MainActor func start() async
    /// Stops this provider.
    @MainActor func stop()
    /// Resets this provider.
    @MainActor func reset()
    
    /// The type of the view that displays the camera feed for this provider.
    associatedtype CameraFeedView: View
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public extension WorldTrackingProvider {
    /// Runs the AR session using this provider's configuration.
    /// - Parameter options: The run options affecting how existing session
    /// state (if any) transitions to the new configuration..
    @MainActor func runARSession(options: ARSession.RunOptions = []) {
        arSessionProvider.session.run(arConfiguration, options: options)
    }
    
    /// Pauses the AR session.
    @MainActor func pauseARSession() {
        arSessionProvider.session.pause()
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public extension WorldTrackingProvider /* Default Implementations */ {
    @MainActor func reset() {
        runARSession(options: .resetTracking)
    }
}
#endif
