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

#if os(iOS)
import SwiftUI

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
extension WorldScaleSceneView {
    /// A view that allows the user to calibrate the heading of the scene view camera controller.
    struct CalibrationView: View {
        @Bindable var calibration: Calibration
        /// A Boolean value that indicates if the user is presenting the calibration view.
        @Binding var isPresented: Bool
        
        /// A number format style for signed values with their fractional component removed.
        private let numberFormat = FloatingPointFormatStyle<Double>.number
            .precision(.fractionLength(1))
            .sign(strategy: .always(includingZero: false))
        
        /// The total heading correction measurement in degrees.
        private var totalHeadingCorrectionMeasurement: Measurement<UnitAngle> {
            Measurement<UnitAngle>(value: calibration.totalHeadingCorrection, unit: .degrees)
        }
        
        /// The total elevation correction measurement in meters.
        private var totalElevationCorrectionMeasurement: Measurement<UnitLength> {
            Measurement<UnitLength>(value: calibration.totalElevationCorrection, unit: .meters)
        }
        
        var body: some View {
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text(calibrationLabel)
                        .lineLimit(1)
                    Spacer()
                    XButton(.dismiss) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .layoutPriority(1)
                }
                .font(.title)
                .padding(.bottom)
                headingSlider
                Divider()
                elevationSlider
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(.rect(cornerRadius: 15))
            .frame(maxWidth: 430)
            .padding()
        }
        
        @ViewBuilder
        var headingSlider: some View {
            VStack {
                HStack {
                    Stepper() {
                        HStack {
                            Text(headingLabel)
                                .font(.body.smallCaps())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(totalHeadingCorrectionMeasurement, format: .measurement(width: .narrow, numberFormatStyle: numberFormat))
                            Spacer()
                        }
                    } onIncrement: {
                        calibration.proposeHeadingCorrection(1)
                    } onDecrement: {
                        calibration.proposeHeadingCorrection(-1)
                    }
                }
                Joyslider()
                    .onChanged { delta in
                        calibration.proposeHeadingCorrection(delta)
                    }
            }
        }
        
        @ViewBuilder
        var elevationSlider: some View {
            VStack {
                HStack {
                    Stepper() {
                        HStack {
                            Text(elevationLabel)
                                .font(.body.smallCaps())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(totalElevationCorrectionMeasurement, format: .measurement(width: .abbreviated, usage: .asProvided, numberFormatStyle: numberFormat))
                            Spacer()
                        }
                    } onIncrement: {
                        calibration.proposeElevationCorrection(1)
                    } onDecrement: {
                        calibration.proposeElevationCorrection(-1)
                    }
                }
                Joyslider()
                    .onChanged { delta in
                        calibration.proposeElevationCorrection(delta)
                    }
            }
        }
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
private extension WorldScaleSceneView.CalibrationView {
    var calibrationLabel: String {
        String(
            localized: "Calibration",
            bundle: .toolkitModule,
            comment: """
                 A label for the calibration view used to calibrate the camera
                 for the AR experience.
                 """
        )
    }
    var headingLabel: String {
        String(
            localized: "heading",
            bundle: .toolkitModule,
            comment: """
                 A label for the slider that adjusts the camera heading for the
                 AR experience.
                 """
        )
    }
    var elevationLabel: String {
        String(
            localized: "elevation",
            bundle: .toolkitModule,
            comment: """
                 A label for the slider that adjusts the camera elevation for the
                 AR experience.
                 """
        )
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
#Preview {
    @Previewable @State var isPresented = true
    WorldScaleSceneView<AppleWorldTracking>.CalibrationView(
        calibration: Calibration(),
        isPresented: $isPresented
    )
}
#endif
