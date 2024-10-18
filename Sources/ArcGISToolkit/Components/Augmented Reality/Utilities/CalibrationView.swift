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

/// A view model that stores state information for the calibration.
@MainActor
class WorldScaleCalibrationViewModel: ObservableObject {
    /// The total heading correction.
    @Published
    private(set) var totalHeadingCorrection: Double = 0
    
    /// The total elevation correction.
    @Published
    private(set) var totalElevationCorrection: Double = 0
    
    /// The camera controller for which corrections will be applied.
    let cameraController = TransformationMatrixCameraController()
    
    /// Creates a calibration view model.
    init() {
        cameraController.translationFactor = 1
    }
    
    /// Proposes a heading correction.
    /// This will limit the total heading correction to -180...180.
    fileprivate func propose(headingCorrection: Double) {
        let newTotalHeadingCorrection = (totalHeadingCorrection + headingCorrection)
            .clamped(to: -180...180)
        let allowedHeadingCorrection = newTotalHeadingCorrection - totalHeadingCorrection
        totalHeadingCorrection = newTotalHeadingCorrection
        
        // Update camera controller.
        let originCamera = cameraController.originCamera
        cameraController.originCamera = originCamera.rotatedTo(
            heading: originCamera.heading + allowedHeadingCorrection,
            pitch: originCamera.pitch,
            roll: originCamera.roll
        )
    }
    
    /// Proposes an elevation correction.
    fileprivate func propose(elevationCorrection: Double) {
        totalElevationCorrection += elevationCorrection
        
        // Update camera controller.
        cameraController.originCamera = cameraController.originCamera.elevated(by: elevationCorrection)
    }
}

@available(visionOS, unavailable)
extension WorldScaleSceneView {
    /// A view that allows the user to calibrate the heading of the scene view camera controller.
    struct CalibrationView: View {
        @ObservedObject
        var viewModel: WorldScaleCalibrationViewModel
        
        /// A Boolean value that indicates if the user is presenting the calibration view.
        @Binding
        var isPresented: Bool
        
        /// A number format style for signed values with their fractional component removed.
        private let numberFormat = FloatingPointFormatStyle<Double>.number
            .precision(.fractionLength(1))
            .sign(strategy: .always(includingZero: false))
        
        /// The total heading correction measurement in degrees.
        private var totalHeadingCorrectionMeasurement: Measurement<UnitAngle> {
            Measurement<UnitAngle>(value: viewModel.totalHeadingCorrection, unit: .degrees)
        }
        
        /// The total elevation correction measurement in meters.
        private var totalElevationCorrectionMeasurement: Measurement<UnitLength> {
            Measurement<UnitLength>(value: viewModel.totalElevationCorrection, unit: .meters)
        }
        
        var body: some View {
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Text(calibrationLabel)
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
                            Text(headingLabel)
                                .font(.body.smallCaps())
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(totalHeadingCorrectionMeasurement, format: .measurement(width: .narrow, numberFormatStyle: numberFormat))
                            Spacer()
                        }
                    } onIncrement: {
                        viewModel.propose(headingCorrection: 1)
                    } onDecrement: {
                        viewModel.propose(headingCorrection: -1)
                    }
                }
                Joyslider()
                    .onChanged { delta in
                        viewModel.propose(headingCorrection: delta)
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
                        viewModel.propose(elevationCorrection: 1)
                    } onDecrement: {
                        viewModel.propose(elevationCorrection: -1)
                    }
                }
                Joyslider()
                    .onChanged { delta in
                        viewModel.propose(elevationCorrection: delta)
                    }
            }
        }
        
        @ViewBuilder
        var dismissButton: some View {
            Button {
                withAnimation {
                    isPresented = false
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
