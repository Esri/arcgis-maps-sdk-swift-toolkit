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
        
        var body: some View {
            VStack {
                Text("Heading: \(viewModel.calibrationHeading?.rounded(.towardZero) ?? viewModel.cameraController.originCamera.heading.rounded(.towardZero), format: .number)")
                
                HStack {
                    Button {
                        rotateHeading(by: -1)
                    } label: {
                        Image(systemName: "minus")
                            .imageScale(.large)
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
                        let timer = Timer(timeInterval: 0.1, repeats: true) { _ in
                            rotateHeading(by: joystickHeadingDelta)
                        }
                        headingTimer = timer
                        // Add the timer to the main run loop.
                        RunLoop.main.add(timer, forMode: .default)
                    }
                    
                    Button {
                        rotateHeading(by: 1)
                    } label: {
                        Image(systemName: "plus")
                            .imageScale(.large)
                    }
                }
                VStack {
                    Text("Elevation: \(viewModel.calibrationElevation?.rounded(.towardZero) ?? viewModel.cameraController.originCamera.location.z?.rounded(.towardZero) ?? 0, format: .number) m")
                    HStack {
                        Button {
                            updateElevation(by: -1)
                        } label: {
                            Image(systemName: "minus")
                                .imageScale(.large)
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
                            let timer = Timer(timeInterval: 0.1, repeats: true) { _ in
                                updateElevation(by: joystickElevationDelta)
                            }
                            elevationTimer = timer
                            // Add the timer to the main run loop.
                            RunLoop.main.add(timer, forMode: .default)
                        }
                        Button {
                            updateElevation(by: 1)
                        } label: {
                            Image(systemName: "plus")
                                .imageScale(.large)
                        }
                    }
                }
            }
            .overlay(alignment: .topTrailing) {
                HStack {
                    Spacer()
                    Button {
                        viewModel.isCalibrating = false
                        viewModel.setBasemapOpacity(0)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                            .imageScale(.large)
                    }
                    .buttonStyle(.plain)
                    .frame(alignment: .topTrailing)
                    .padding()
                }
                .padding(.trailing, -20)
                .padding(.top, -30)
            }
            .frame(maxWidth: 350)
            .padding()
            .padding(.top, 10)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding()
        }
        
        /// Rotates the heading of the scene view camera controller by the heading delta in degrees.
        /// - Parameter headingDelta: The heading delta in degrees.
        private func rotateHeading(by headingDelta: Double) {
            let originCamera = viewModel.cameraController.originCamera
            let newHeading = originCamera.heading + headingDelta
            viewModel.cameraController.originCamera = originCamera.rotatedTo(
                heading: newHeading,
                pitch: originCamera.pitch,
                roll: originCamera.roll
            )
            viewModel.calibrationHeading = newHeading
        }
        
        /// Elevates the scene view camera controller by the elevation delta.
        /// - Parameter elevationDelta: The elevation delta.
        private func updateElevation(by elevationDelta: Double) {
            viewModel.cameraController.originCamera = viewModel.cameraController.originCamera.elevated(by: elevationDelta)
            if let elevation = viewModel.cameraController.originCamera.location.z {
                viewModel.calibrationElevation = elevation
            }
        }
    }
}
