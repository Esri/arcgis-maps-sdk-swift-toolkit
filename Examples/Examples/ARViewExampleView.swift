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

import SwiftUI
import ArcGIS
import ArcGISToolkit

struct ARViewExampleView: View {
    private var scene: ArcGIS.Scene = {
        let scene = Scene(
            item: PortalItem(
                portal: .arcGISOnline(connection: .anonymous),
                id: PortalItem.ID("7558ee942b2547019f66885c44d4f0b1")!
            )
        )

        scene.initialViewpoint = Viewpoint(
            latitude: 37.8651,
            longitude: 119.5383,
            scale: 10
        )

        return scene
    }()

    private var cameraController: TransformationMatrixCameraController = {
        let controller = TransformationMatrixCameraController()
        controller.originCamera = Camera(
            lookingAt: Point(x: 4.4777, y: 51.9244, spatialReference: .wgs84),
            distance: 1_000,
            heading: 40,
            pitch: 90,
            roll: 0
        )
        
        controller.translationFactor = 3000
        controller.clippingDistance = 6000
        return controller
    }()

    var body: some View {
        RealityGeoView(
            scene: scene,
            cameraController: cameraController,
            trackingMode: .initial,
            renderVideoFeed: true
        )
    }
}
