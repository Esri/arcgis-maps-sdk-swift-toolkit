// Copyright 2024 Esri
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

import ARKit
import SwiftUI
import ArcGIS

extension WorldScaleGeoTrackingSceneView {
    /// A view that allows the user to calibrate the heading of the scene view camera controller.
    struct CalibrationView: View {
        let scene: ArcGIS.Scene
        /// The camera controller that will be set on the scene view.
        @State private var cameraController: TransformationMatrixCameraController
        /// A Boolean value that indicates if the AR experince is being calibrated.
        @State private var isCalibrating = false
        /// The calibrated camera heading.
        @State private var calibrationHeading: Double?
        /// The calibrated camera elevation.
        @State private var calibrationElevation: Double?
        /// The slider value for the camera heading.
        @State private var headingSliderValue = 0.0
        /// The slider value for the camera elevation.
        @State private var elevationSliderValue = 0.0
        /// The elevation timer for the "joystick" behavior.
        @State private var headingTimer: Timer?
        /// The heading timer for the "joystick" behavior.
        @State private var elevationTimer: Timer?
        /// The heading delta amount based on the heading slider value.
        private var joystickHeadingDelta: Double {
            Double(signOf: headingSliderValue, magnitudeOf: headingSliderValue * headingSliderValue / 25)
        }
        /// The elevation delta amount based on the elevation slider value.
        private var joystickElevationDelta: Double {
            Double(signOf: elevationSliderValue, magnitudeOf: elevationSliderValue * elevationSliderValue / 100)
        }
        
        init(
            scene: ArcGIS.Scene,
            cameraController: TransformationMatrixCameraController,
            isCalibrating: Bool,
            calibrationHeading: Double?,
            calibrationElevation: Double?
        ) {
            self.scene = scene
            self.cameraController = cameraController
            self.isCalibrating = isCalibrating
            self.calibrationHeading = calibrationHeading
            self.calibrationElevation = calibrationElevation
        }
        
        var body: some View {
            Button {
                isCalibrating = true
                setBasemapOpacity(0.5)
            } label: {
                Text("Calibrate")
            }
            .popover(isPresented: $isCalibrating) {
                VStack {
                    Text("Heading: \(calibrationHeading?.rounded(.towardZero) ?? cameraController.originCamera.heading.rounded(.towardZero), format: .number)")
                    
                    HStack {
                        Button {
                            let heading = cameraController.originCamera.heading - 1
                            updateHeading(heading)
                        } label: {
                            Image(systemName: "minus")
                        }
                        Slider(value: $headingSliderValue, in: -10...10) { editingChanged in
                            if !editingChanged {
                                headingTimer?.invalidate()
                                headingTimer = nil
                                headingSliderValue = 0.0
                            }
                        }
                        .onChange(of: headingSliderValue) { heading in
                            
                            guard headingTimer == nil else { return }
                            // Create a timer which rotates the camera when fired.
                            let timer = Timer(timeInterval: 0.1, repeats: true) { [self] (_) in
                                rotateHeading(joystickHeadingDelta)
                            }
                            headingTimer = timer
                            // Add the timer to the main run loop.
                            RunLoop.main.add(timer, forMode: .default)
                        }
                        
                        Button {
                            let heading = cameraController.originCamera.heading + 1
                            updateHeading(heading)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    VStack {
                        Text("Elevation: \(calibrationElevation?.rounded(.towardZero) ?? cameraController.originCamera.location.z?.rounded(.towardZero) ?? 0, format: .number)")
                        HStack {
                            Button {
                                updateElevation(-1)
                            } label: {
                                Image(systemName: "minus")
                            }
                            Slider(value: $elevationSliderValue, in: -20...20) { editingChanged in
                                if !editingChanged {
                                    elevationTimer?.invalidate()
                                    elevationTimer = nil
                                    elevationSliderValue = 0.0
                                }
                            }
                            .onChange(of: elevationSliderValue) { elevation in
                                
                                guard elevationTimer == nil else { return }
                                // Create a timer which rotates the camera when fired.
                                let timer = Timer(timeInterval: 0.1, repeats: true) { [self] (_) in
                                    updateElevation(joystickElevationDelta)
                                }
                                elevationTimer = timer
                                // Add the timer to the main run loop.
                                RunLoop.main.add(timer, forMode: .default)
                            }
                            Button {
                                updateElevation(1)
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }
                .onDisappear {
                    guard !isCalibrating else { return }
                    withAnimation(.easeInOut) {
                        setBasemapOpacity(0)
                    }
                }
                .frame(minWidth: 200, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .padding()
            }
        }
        
        /// Sets the basemap base layers with the given opacity.
        /// - Parameter opacity: The opacity of the layer.
        private func setBasemapOpacity(_ opacity: Float) {
            guard let basemap = scene.basemap else { return }
            basemap.baseLayers.forEach { $0.opacity = opacity }
        }
        
        /// Updates the heading of the scene view camera controller.
        /// - Parameter heading: The camera heading.
        private func updateHeading(_ heading: Double) {
            cameraController.originCamera = cameraController.originCamera.rotatedTo(
                heading: heading,
                pitch: cameraController.originCamera.pitch,
                roll: cameraController.originCamera.roll
            )
            calibrationHeading = heading
        }
        
        /// Rotates the heading of the scene view camera controller by the heading delta in degrees.
        /// - Parameter headingDelta: The heading delta in degrees.
        private func rotateHeading(_ headingDelta: Double) {
            let newHeading = cameraController.originCamera.heading + headingDelta
            cameraController.originCamera = cameraController.originCamera.rotatedTo(
                heading: newHeading,
                pitch: cameraController.originCamera.pitch,
                roll: cameraController.originCamera.roll
            )
            calibrationHeading = newHeading
        }
        
        /// Elevates the scene view camera controller by the elevation delta.
        /// - Parameter elevationDelta: The elevation delta.
        private func updateElevation(_ elevationDelta: Double) {
            cameraController.originCamera = cameraController.originCamera.elevated(by: elevationDelta)
            if let elevation = cameraController.originCamera.location.z {
                calibrationElevation = elevation
            }
        }
    }
}
