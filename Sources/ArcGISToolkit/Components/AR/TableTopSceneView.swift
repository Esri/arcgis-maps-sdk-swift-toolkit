// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ARKit
import SwiftUI
import ArcGIS

/// A scene view that provides an augmented reality table top experience.
public struct TableTopSceneView: View {
    
    @State var map = Map(basemapStyle: .arcGISTopographic)
    
    /// Creates a table top scene view.
    /// - Parameters:
    ///   - anchorPoint: The location point of the ArcGIS Scene that is anchored on a physical surface.
    ///   - translationFactor: The translation factor that defines how much the scene view translates
    ///   as the device moves.
    ///   - clippingDistance: Determines the clipping distance in meters around the camera. A value
    ///   of `nil` means that no data will be clipped.
    ///   - sceneView: A closure that builds the scene view to be overlayed on top of the
    ///   augmented reality video feed.
    /// - Remark: The provided scene view will have certain properties overridden in order to
    /// be effectively viewed in augmented reality. Properties such as the camera controller,
    /// and view drawing mode.
    public init(
        anchorPoint: Point,
        translationFactor: Double,
        clippingDistance: Double?,
        @ViewBuilder sceneView: @escaping (SceneViewProxy) -> SceneView
    ) {
    }
    
    public var body: some View {
        ZStack {
            MapViewReader { proxy in
                BackgroundView()
                MapView(map: map)
                    .onAppear {
                        _ = proxy.wrapAroundIsEnabled
                    }
            }
        }
    }

    
    /// Sets the visibility of the coaching overlay view for the AR experince.
    /// - Parameter hidden: A Boolean value that indicates whether to hide the
    ///  coaching overlay view.
    public func coachingOverlayHidden(_ hidden: Bool) -> Self {
        self
        //var view = self
        //view.coachingOverlayIsHidden = hidden
        //return view
    }
}

struct BackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIButton {
        UIButton()
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator { init() {} }
}
