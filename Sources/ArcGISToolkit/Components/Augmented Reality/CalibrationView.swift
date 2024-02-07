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
import Combine

extension WorldScaleGeoTrackingSceneView {
    /// A view model that stores state information for the calibration.
    @MainActor
    class CalibrationViewModel: ObservableObject {
        /// The total heading correction.
        @Published
        private(set) var totalHeadingCorrection: Double = 0
        
        /// The total elevation correction.
        @Published
        private(set) var totalElevationCorrection: Double = 0

        // A subject for the heading corrections to publish as they come in.
        private var headingSubject = PassthroughSubject<Double, Never>()
        
        // A subject for the elevation corrections to publish as they come in.
        private var elevationSubject = PassthroughSubject<Double, Never>()
        
        /// The heading corrections.
        var headingCorrections: AnyPublisher<Double, Never> {
            headingSubject.eraseToAnyPublisher()
        }
        
        /// The elevation corrections.
        var elevationCorrections: AnyPublisher<Double, Never> {
            elevationSubject.eraseToAnyPublisher()
        }
        
        /// Proposes a heading correction.
        /// This will limit the total heading correction to -180...180.
        fileprivate func propose(headingCorrection: Double) {
            let newTotalHeadingCorrection = (totalHeadingCorrection + headingCorrection)
                .clamped(to: -180...180)
            let allowedHeadingCorrection = newTotalHeadingCorrection - totalHeadingCorrection
            totalHeadingCorrection = newTotalHeadingCorrection
            headingSubject.send(allowedHeadingCorrection)
        }
        
        /// Proposes an elevation correction.
        fileprivate func propose(elevationCorrection: Double) {
            totalElevationCorrection += elevationCorrection
            elevationSubject.send(elevationCorrection)
        }
    }
}
    
extension WorldScaleGeoTrackingSceneView {
    /// A view that allows the user to calibrate the heading of the scene view camera controller.
    struct CalibrationView: View {
        @ObservedObject
        var viewModel: CalibrationViewModel
        
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
                            Text("Elevation")
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
