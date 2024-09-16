// Copyright 2022 Esri
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

import ArcGIS
import SwiftUI

/// A `Compass` (alias North arrow) shows where north is in a `MapView` or `SceneView`.
///
/// ![image](https://user-images.githubusercontent.com/3998072/202810369-a0b82778-77d4-404e-bebf-1a84841fbb1b.png)
/// - Automatically hides when the rotation is zero.
/// - Can be configured to be always visible.
/// - Will reset the map/scene rotation to North when tapped on.
///
/// Whenever the map is not orientated North (non-zero bearing) the compass appears. When reset to
/// north, it disappears. The `automaticallyHides` view modifier allows you to disable the auto-hide
/// feature so that it is always displayed.
/// When the compass is tapped, the map orients back to north (zero bearing).
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [CompassExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/CompassExampleView.swift)
/// in the project. To learn more about using the `Compass` see the <doc:CompassTutorial>.
@preconcurrency
public struct Compass: View {
    /// The opacity of the compass.
    @State private var opacity: Double = .zero
    
    /// A Boolean value indicating whether  the compass should automatically
    /// hide/show itself when the heading is `0`.
    private var autoHide: Bool = true
    
    /// The heading of the compass in degrees.
    private var heading: Double
    
    /// The proxy to provide access to map view operations.
    private var mapViewProxy: MapViewProxy?
    
    /// The width and height of the compass.
    private var size: CGFloat = 44
    
    /// An action to perform when the compass is tapped.
    private var action: (() -> Void)?
    
    /// Creates a compass with a heading based on compass directions (0° indicates a direction
    /// toward true North, 90° indicates a direction toward true East, etc.).
    /// - Parameters:
    ///   - rotation: The rotation whose value determines the heading of the compass.
    ///   - mapViewProxy: The proxy to provide access to map view operations.
    ///   - action: The action to perform when the compass is tapped.
    init(
        rotation: Double?,
        mapViewProxy: MapViewProxy?,
        action: (() -> Void)?
    ) {
        let heading: Double
        if let rotation {
            heading = rotation.isZero ? .zero : 360 - rotation
        } else {
            heading = .nan
        }
        self.heading = heading
        self.mapViewProxy = mapViewProxy
        self.action = action
    }
    
    public var body: some View {
        if !heading.isNaN {
            CompassBody()
                .overlay {
                    Needle()
                        .rotationEffect(.degrees(heading))
                }
                .aspectRatio(1, contentMode: .fit)
                .opacity(opacity)
                .frame(width: size, height: size)
                .onAppear { opacity = shouldHide(forHeading: heading) ? 0 : 1 }
                .onChange(heading) { newHeading in
                    let newOpacity: Double = shouldHide(forHeading: newHeading) ? .zero : 1
                    guard opacity != newOpacity else { return }
                    withAnimation(.default.delay(shouldHide(forHeading: newHeading) ? 0.25 : 0)) {
                        opacity = newOpacity
                    }
                }
                .onTapGesture {
                    if let mapViewProxy {
                        Task { await mapViewProxy.setViewpointRotation(0) }
                    } else if let action {
                        action()
                    }
                }
                .accessibilityLabel(
                    String(
                        localized: "Compass, heading \(Int(heading.rounded())) degrees \(CompassDirection(heading).rawValue)",
                        bundle: .toolkitModule,
                        comment: """
                                 An compass description to be read by a screen reader describing the
                                 current heading. The first variable being a degree value and the
                                 second being a corresponding cardinal direction (north, northeast,
                                 east, etc.).
                                 """
                    )
                )
        }
    }
}

extension Compass {
    /// Returns a Boolean value indicating whether the compass should hide based on the
    /// provided heading and whether the compass has been configured to automatically hide.
    /// - Parameter heading: The heading used to determine if the compass should hide.
    /// - Returns: `true` if the compass should hide, `false` otherwise.
    func shouldHide(forHeading heading: Double) -> Bool {
        (heading.isZero || heading.isNaN) && autoHide
    }
}

public extension Compass {
    /// Creates a compass with a rotation (0° indicates a direction toward true North, 90° indicates
    /// a direction toward true West, etc.).
    /// - Parameters:
    ///   - rotation: The rotation whose value determines the heading of the compass.
    ///   - mapViewProxy: The proxy to provide access to map view operations.
    init(
        rotation: Double?,
        mapViewProxy: MapViewProxy
    ) {
        self.init(rotation: rotation, mapViewProxy: mapViewProxy, action: nil)
    }
    
    /// Creates a compass with a rotation (0° indicates a direction toward true North, 90° indicates
    /// a direction toward true West, etc.).
    /// - Parameters:
    ///   - rotation: The rotation whose value determines the heading of the compass.
    ///   - action: The action to perform when the compass is tapped.
    init(
        rotation: Double?,
        action: @escaping () -> Void
    ) {
        self.init(rotation: rotation, mapViewProxy: nil, action: action)
    }
    
    /// Define a custom size for the compass.
    /// - Parameter size: The width and height of the compass.
    func compassSize(size: CGFloat) -> Self {
        var copy = self
        copy.size = size
        return copy
    }
    
    /// Specifies whether the ``Compass`` should automatically hide when the heading is 0.
    /// - Parameter disable: A Boolean value indicating whether the compass should automatically
    /// hide/show itself when the heading is `0`.
    func autoHideDisabled(_ disable: Bool = true) -> Self {
        var copy = self
        copy.autoHide = !disable
        return copy
    }
}
