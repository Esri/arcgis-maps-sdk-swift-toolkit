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
        @ObservedObject var viewModel: ViewModel
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
        
        init(viewModel: ViewModel) {
            self.viewModel = viewModel
        }
        
        var body: some View {
            Button {
                viewModel.isCalibrating = true
                setBasemapOpacity(0.5)
            } label: {
                Text("Calibrate")
            }
            .popover(isPresented: $viewModel.isCalibrating) {
                VStack {
                    Text("Heading: \(viewModel.calibrationHeading?.rounded(.towardZero) ?? viewModel.cameraController.originCamera.heading.rounded(.towardZero), format: .number)")
                    
                    HStack {
                        Button {
                            let heading = viewModel.cameraController.originCamera.heading - 1
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
                            let heading = viewModel.cameraController.originCamera.heading + 1
                            updateHeading(heading)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                    VStack {
                        Text("Elevation: \(viewModel.calibrationElevation?.rounded(.towardZero) ?? viewModel.cameraController.originCamera.location.z?.rounded(.towardZero) ?? 0, format: .number)")
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
                    guard !viewModel.isCalibrating else { return }
                    withAnimation(.easeInOut) {
                        setBasemapOpacity(0)
                    }
                }
                .frame(minWidth: 250, maxWidth: UIScreen.main.bounds.width/3)
                .padding()
            }
            .esriBorder()
            .padding([.horizontal], 10)
            .padding([.vertical], 10)
        }
        
        /// Sets the basemap base layers with the given opacity.
        /// - Parameter opacity: The opacity of the layer.
        private func setBasemapOpacity(_ opacity: Float) {
            guard let basemap = viewModel.scene.basemap else { return }
            basemap.baseLayers.forEach { $0.opacity = opacity }
        }
        
        /// Updates the heading of the scene view camera controller.
        /// - Parameter heading: The camera heading.
        private func updateHeading(_ heading: Double) {
            viewModel.cameraController.originCamera = viewModel.cameraController.originCamera.rotatedTo(
                heading: heading,
                pitch: viewModel.cameraController.originCamera.pitch,
                roll: viewModel.cameraController.originCamera.roll
            )
            viewModel.calibrationHeading = heading
        }
        
        /// Rotates the heading of the scene view camera controller by the heading delta in degrees.
        /// - Parameter headingDelta: The heading delta in degrees.
        private func rotateHeading(_ headingDelta: Double) {
            let newHeading = viewModel.cameraController.originCamera.heading + headingDelta
            viewModel.cameraController.originCamera = viewModel.cameraController.originCamera.rotatedTo(
                heading: newHeading,
                pitch: viewModel.cameraController.originCamera.pitch,
                roll: viewModel.cameraController.originCamera.roll
            )
            viewModel.calibrationHeading = newHeading
        }
        
        /// Elevates the scene view camera controller by the elevation delta.
        /// - Parameter elevationDelta: The elevation delta.
        private func updateElevation(_ elevationDelta: Double) {
            viewModel.cameraController.originCamera = viewModel.cameraController.originCamera.elevated(by: elevationDelta)
            if let elevation = viewModel.cameraController.originCamera.location.z {
                viewModel.calibrationElevation = elevation
            }
        }
    }
}
