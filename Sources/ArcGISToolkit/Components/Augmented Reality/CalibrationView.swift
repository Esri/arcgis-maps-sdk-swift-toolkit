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
        /// The camera controller heading.
        @Binding var heading: Double
        /// The camera controller elevation.
        @Binding var elevation: Double
        /// A Boolean value that indicates if the user is calibrating.
        @Binding var isCalibrating: Bool
        /// The initial camera controller elevation.
        @Binding var initialElevation: Double
        /// The elevation delta value after calibrating.
        @State private var elevationDelta = 0.0
        
        var body: some View {
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text("Calibration")
                        .font(.title)
                        .lineLimit(1)
                    Spacer()
                    dismissButton
                        .layoutPriority(1)
                }
                .padding(.bottom)
                headingSlider
                Divider()
                elevationSlider
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .frame(maxWidth: 430)
            .padding()
        }
        
        @ViewBuilder
        var headingSlider: some View {
            VStack {
                HStack {
                    Stepper() {
                        HStack {
                            Text("Heading")
                                .font(.body.smallCaps())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(heading.isLess(than: 0) || heading.rounded().isZero ? "" : "+") +
                            Text(heading, format: .number.precision(.fractionLength(0)))
                            + Text("°")
                            Spacer()
                        }
                    } onIncrement: {
                        heading += 1
                    } onDecrement: {
                        heading -= 1
                    }
                }
                JoystickSliderView()
                    .onSliderDeltaValueChanged { delta in
                        heading += delta
                    }
            }
        }
        
        @ViewBuilder
        var elevationSlider: some View {
            VStack {
                HStack {
                    Stepper() {
                        HStack {
                            Text("Elevation")
                                .font(.body.smallCaps())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(elevationDelta.isLess(than: 0) || elevationDelta.rounded().isZero ? "" : "+") +
                            Text(elevationDelta, format: .number.precision(.fractionLength(0)))
                            + Text(" m")
                            Spacer()
                        }
                    } onIncrement: {
                        elevation += 1
                    } onDecrement: {
                        elevation -= 1
                    }
                }
                JoystickSliderView()
                    .onSliderDeltaValueChanged { delta in
                        elevation += delta
                    }
            }
            .onChange(of: elevation) { elevation in
                elevationDelta =  elevation - initialElevation
            }
            .onAppear {
                elevationDelta =  elevation - initialElevation
            }
        }
        
        @ViewBuilder
        var dismissButton: some View {
            Button {
                withAnimation {
                    isCalibrating = false
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
    }
}

/// A view for a joystick style slider.
private struct JoystickSliderView: View {
    /// The slider value.
    @State private var value = 0.0
    /// The timer for the "joystick" behavior.
    @State private var timer: Timer?
    /// The delta amount based on the slider value.
    private var joystickDelta: Double {
        Double(signOf: value, magnitudeOf: value * value / 25)
    }
    /// User defined action to be performed when the slider delta value changes.
    var sliderDeltaValueChangedAction: ((Double) -> Void)? = nil
    
    var body: some View {
        Slider(value: $value, in: -10...10) { editingChanged in
            if !editingChanged {
                timer?.invalidate()
                timer = nil
                value = 0.0
            }
        }
        .onChange(of: value) { value in
            guard timer == nil else { return }
            // Start a timer when slider is active.
            let timer = Timer(timeInterval: 0.1, repeats: true) { _ in
                if let onSliderDeltaValueChanged = sliderDeltaValueChangedAction {
                    // Returns the joystick slider delta value.
                    onSliderDeltaValueChanged(joystickDelta)
                }
            }
            self.timer = timer
            // Add the timer to the main run loop.
            RunLoop.main.add(timer, forMode: .default)
        }
    }
    
    /// Sets an action to perform when the slider delta value changes.
    /// - Parameter action: The action to perform when the slider delta value has changed.
    func onSliderDeltaValueChanged(
        perform action: @escaping (Double) -> Void
    ) -> JoystickSliderView {
        var copy = self
        copy.sliderDeltaValueChangedAction = action
        return copy
    }
}
