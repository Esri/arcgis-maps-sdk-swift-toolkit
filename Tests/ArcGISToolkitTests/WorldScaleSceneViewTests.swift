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

#if os(iOS) && !targetEnvironment(macCatalyst)
import ArcGIS
@testable import ArcGISToolkit
import SwiftUI
import Testing

@MainActor struct WorldScaleSceneViewTests {
    @available(*, deprecated)
    @Test func calibrationViewIsHidden() {
        let view = makeAppleWorldScaleSceneView(mode: .worldTracking)
        #expect(view.calibrationViewIsHidden == false)
        let modifiedView = view.calibrationViewHidden(true)
        #expect(modifiedView.calibrationViewIsHidden == true)
    }
    
    @available(*, deprecated)
    @Test func calibrationButtonAlignment() {
        let view = makeAppleWorldScaleSceneView(mode: .worldTracking)
        #expect(view.calibrationButtonAlignment == .bottom)
        let modifiedView = view.calibrationButtonAlignment(.bottomLeading)
        #expect(modifiedView.calibrationButtonAlignment == .bottomLeading)
    }
}

extension WorldScaleSceneViewTests /* Deprecated */ {
    @available(*, deprecated)
    @Test(arguments: [1_000.0, nil])
    func initWithClippingDistance(_ clippingDistance: Double?) {
        let view = WorldScaleSceneView(clippingDistance: clippingDistance) { _ in
            SceneView(scene: Scene())
        }
        #expect(view.clippingDistance == clippingDistance)
    }
    
    @available(*, deprecated)
    @Test(arguments: AppleWorldTracking.Mode.allCases)
    func initWithTrackingMode(_ trackingMode: AppleWorldTracking.Mode) {
        let view = WorldScaleSceneView(trackingMode: trackingMode) { _ in
            SceneView(scene: Scene())
        }
        #expect(view.trackingMode == trackingMode)
    }
}

private extension WorldScaleSceneViewTests {
    func makeAppleWorldScaleSceneView(
        mode: AppleWorldTracking.Mode
    ) -> WorldScaleSceneView<AppleWorldTracking> {
        return .init(provider: AppleWorldTracking(mode: .worldTracking)) { context in
            AppleWorldTrackingCameraFeedView(context: context)
        } sceneView: { _ in
            SceneView(scene: Scene())
        }
    }
}
#endif
