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

/// A `Compass` (alias North arrow) shows where north is in a `MapView`.
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
    
    /// An action to perform when the compass is tapped. Note if `mapViewProxy` is non-`nil`
    /// this will not be invoked.
    private var action: (() -> Void)?

    /// Creates a compass with a heading based on compass directions (0° indicates a direction
    /// toward true North, 90° indicates a direction toward true East, etc.).
    /// - Parameters:
    ///   - heading: The heading of the compass.
    ///   - mapViewProxy: The proxy to provide access to map view operations.
    init(
        heading: Double,
        mapViewProxy: MapViewProxy? = nil
    ) {
        self.heading = heading
        self.mapViewProxy = mapViewProxy
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
                .onChange(of: heading) { newHeading in
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
                .accessibilityLabel("Compass, heading \(Int(heading.rounded())) degrees \(CompassDirection(heading).rawValue)")
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
    ///   - mapViewProxy: The proxy to provide access to map view operations. If `mapViewProxy`
    ///   is non-`nil`, the proxy will be used to set the rotation to `.zero` when the compass is
    ///   tapped on. Otherwise, the `action` will be called (set using the `action` view modifier).
    init(
        rotation: Double?,
        mapViewProxy: MapViewProxy? = nil
    ) {
        let heading: Double
        if let rotation {
            heading = rotation.isZero ? .zero : 360 - rotation
        } else {
            heading = .nan
        }
        self.init(heading: heading, mapViewProxy: mapViewProxy)
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
    func autoHideDisabled(_ disable: Bool = true) -> some View {
        var copy = self
        copy.autoHide = !disable
        return copy
    }
    
    /// An action to perform when the compass is tapped. If `mapViewProxy` is non-`nil`,
    /// then this will have no affect.
    func action(_ action: @escaping () -> Void) -> some View {
        var copy = self
        copy.action = action
        return copy
    }
}
