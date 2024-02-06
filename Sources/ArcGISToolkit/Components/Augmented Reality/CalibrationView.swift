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
        /// A number format style for signed values with their fractional component removed.
        private let numberFormat = FloatingPointFormatStyle<Double>.number
            .precision(.fractionLength(0))
            .sign(strategy: .always(includingZero: false))
        
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
                            Text(heading, format: numberFormat) + Text("°")
                            Spacer()
                        }
                    } onIncrement: {
                        heading = (heading + 1).clamped(to: -180...180)
                    } onDecrement: {
                        heading = (heading - 1).clamped(to: -180...180)
                    }
                }
                Joyslider()
                    .onChanged { delta in
                        heading = (heading + delta).clamped(to: -180...180)
                    }
                    .onEnded {
                        // Round the value now that it stopped changing.
                        heading = heading.rounded()
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
                            Text(elevationDelta, format: numberFormat) + Text(" m")
                            Spacer()
                        }
                    } onIncrement: {
                        elevation += 1
                    } onDecrement: {
                        elevation -= 1
                    }
                }
                Joyslider()
                    .onChanged { delta in
                        elevation += delta
                    }
                    .onEnded {
                        // Round the value now that it stopped changing.
                        elevation = elevation.rounded()
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
