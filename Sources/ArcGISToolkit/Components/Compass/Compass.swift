// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import SwiftUI

/// A Compass (alias North arrow) shows where north is in a MapView or SceneView.
public struct Compass: View {
    /// The view model for the compass.
    @ObservedObject
    var viewModel: CompassViewModel

    /// Controls the visibility of the compass.
    @State
    private var opacity = 0.0

    public init(
        viewpoint: Binding<Viewpoint>,
        size: Double = 30.0,
        autoHide: Bool = true
    ) {
        self.viewModel = CompassViewModel(
            viewpoint: viewpoint,
            size: size,
            autoHide: autoHide)
    }

    public var body: some View {
        ZStack {
            CompassBody()
            Needle()
                .rotationEffect(
                    Angle(degrees: viewModel.viewpoint.adjustedRotation)
                )
        }
        .frame(width: viewModel.width, height: viewModel.height)
        .opacity(opacity)
        .onTapGesture { viewModel.resetHeading() }
        .onChange(of: viewModel.viewpoint) { _ in
            withAnimation(.default.delay(viewModel.hidden ? 0.25 : 0)) {
                opacity = viewModel.hidden ? 0 : 1
            }
        }
        .accessibilityLabel(viewModel.viewpoint.heading)
    }
}
