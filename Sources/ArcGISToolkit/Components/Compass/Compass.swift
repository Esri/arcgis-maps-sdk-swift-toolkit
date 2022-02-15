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
    /// Determines if the compass should automatically hide/show itself when the parent view is oriented
    /// north.
    private let autoHide: Bool

    /// Indicates if the compass should be hidden or visible based on the current viewpoint rotation and
    /// autoHide preference.
    public var isHidden: Bool {
        viewpoint.rotation.isZero && autoHide
    }

    /// Controls the current opacity of the compass.
    @State
    private var opacity: Double

    /// Acts as link between the compass and the parent map or scene view.
    @Binding
    private(set) var viewpoint: Viewpoint

    /// Creates a `Compass`
    /// - Parameters:
    ///   - viewpoint: Acts a communication link between the MapView or SceneView and the compass.
    ///   - autoHide: Determines if the compass automatically hides itself when the MapView or
    ///   SceneView is oriented north.
    public init(
        viewpoint: Binding<Viewpoint>,
        autoHide: Bool = true
    ) {
        _viewpoint = viewpoint
        _opacity = State(initialValue: .zero)
        self.autoHide = autoHide
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                CompassBody()
                Needle()
                    .rotationEffect(
                        Angle(degrees: viewpoint.adjustedRotation)
                    )
            }
            .frame(
                width: min(geometry.size.width, geometry.size.height),
                height: min(geometry.size.width, geometry.size.height)
            )
        }
        .opacity(opacity)
        .onTapGesture { resetHeading() }
        .onChange(of: viewpoint) { _ in
            withAnimation(.default.delay(isHidden ? 0.25 : 0)) {
                opacity = isHidden ? 0 : 1
            }
        }
        .onAppear { opacity = isHidden ? 0 : 1 }
        .accessibilityLabel(viewpoint.heading)
    }

    /// Resets the viewpoints `rotation` to zero.
    func resetHeading() {
        self.viewpoint = Viewpoint(
            center: viewpoint.targetGeometry.extent.center,
            scale: viewpoint.targetScale,
            rotation: .zero
        )
    }
}

internal extension Viewpoint {
    /// The viewpoint's `rotation` adjusted to offset any rotation applied to the parent view.
    var adjustedRotation: Double {
        rotation.isZero ? .zero : 360 - rotation
    }

    /// A text description of the current heading, sutiable for accessibility voiceover.
    var heading: String {
        "Compass, heading "
        + Int(self.adjustedRotation.rounded()).description
        + " degrees "
        + CompassDirection(self.adjustedRotation).rawValue
    }
}
