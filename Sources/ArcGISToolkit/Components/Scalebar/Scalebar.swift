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

/// A scalebar displays the representation of an accurate linear measurement on the map. It provides
/// a visual indication through which users can determine the size of features or the distance
/// between features on a map. A scale bar is a line or bar divided into parts. It is labeled with
/// its ground length, usually in multiples of map units, such as tens of kilometers or hundreds of
/// miles.
///
/// ![An image of a map with a Scalebar overlaid](https://user-images.githubusercontent.com/3998072/203605457-df6f845c-9245-4608-a61e-6d1e2e63a81b.png)
///
/// **Features**
///
/// - Can be configured to display as either a bar or line, with different styles for each.
/// - Can be configured with custom colors for fills, lines, shadows, and text.
/// - Can be configured to automatically hide after a pan or zoom operation.
/// - Displays both metric and imperial units.
///
/// **Behavior**
///
/// The scalebar uses geodetic calculations to provide accurate measurements for maps of any
/// spatial reference. The measurement is accurate for the center of the map extent being displayed.
/// This means at smaller scales (zoomed way out) you might find it somewhat inaccurate at the
/// extremes of the visible extent. As the map is panned and zoomed, the scalebar automatically
/// grows and shrinks and updates its measurement based on the new map extent.
///
/// **Associated Types**
///
/// Scalebar has the following associated types:
///
/// - ``ScalebarSettings``
/// - ``ScalebarStyle``
/// - ``ScalebarUnits``
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [ScalebarExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/ScalebarExampleView.swift) 
/// in the project. To learn more about using the `Scalebar` see the <doc:ScalebarTutorial>.
public struct Scalebar: View {
    // - MARK: Internal/Private vars
    
    /// A timer to allow for the scheduling of the auto-hide animation.
    @State private var autoHideTimer: Timer?
    
    /// The vertical amount of space used by the scalebar.
    @State private var height: Double?
    
    /// Controls the current opacity of the scalebar.
    @State private var opacity: Double
    
    /// The view model used by the `Scalebar`.
    @StateObject var viewModel: ScalebarViewModel
    
    /// The font used by the scalebar, available in both `Font` and `UIFont` types.
    nonisolated static var font: (font: Font, uiFont: UIFont) {
        let size = 9.0
        let uiFont = UIFont.systemFont(
            ofSize: size,
            weight: .semibold
        )
        let font = Font(uiFont as CTFont)
        return (font, uiFont)
    }
    
    /// The rendering height of the scalebar font.
    nonisolated static var fontHeight: Double {
        return "".size(withAttributes: [.font: Scalebar.font.uiFont]).height
    }
    
    /// The spatial reference to calculate the scale with.
    private var spatialReference: SpatialReference?
    
    /// The units per point to calculate the scale with.
    private var unitsPerPoint: Double?
    
    /// The viewpoint to calculate the scale with.
    private var viewpoint: Viewpoint?
    
    // - MARK: Internal/Private constants
    
    /// The frame height allotted to bar style scalebar renders.
    static let barFrameHeight = 10.0
    
    /// The spacing between labels and the scalebar.
    static let labelYPad: CGFloat = 2.0
    
    /// The required padding between scalebar labels.
    static let labelXPad: CGFloat = 4.0
    
    /// The line height allotted to line style scalebar renders.
    static let lineFrameHeight = 6.0
    
    /// The width of the prominent scalebar line.
    static let lineWidth: Double = 2.0
    
    /// Appearance settings.
    let settings: ScalebarSettings
    
    /// The render style for this `Scalebar`.
    private let style: ScalebarStyle
    
    // - MARK: Public methods/vars
    
    /// A scalebar displays the current map scale.
    /// - Parameters:
    ///   - maxWidth: The maximum screen width allotted to the scalebar.
    ///   - minScale: Set a minScale if you only want the scalebar to appear when you reach a large
    ///     enough scale maybe something like 10_000_000. This could be useful because the scalebar is
    ///     really only accurate for the center of the map on smaller scales (when zoomed way out). A
    ///     minScale of 0 means it will always be visible.
    ///   - settings: Appearance settings.
    ///   - spatialReference: The map's spatial reference.
    ///   - style: The visual appearance of the scalebar.
    ///   - units: The units to be displayed in the scalebar.
    ///   - unitsPerPoint: The current number of device independent pixels to map display units.
    ///   - useGeodeticCalculations: Set `false` to compute scale without a geodesic curve.
    ///   - viewpoint: The map's current viewpoint.
    public init(
        maxWidth: Double,
        minScale: Double = .zero,
        settings: ScalebarSettings = ScalebarSettings(),
        spatialReference: SpatialReference?,
        style: ScalebarStyle = .alternatingBar,
        units: ScalebarUnits = NSLocale.current.measurementSystem == .metric ? .metric : .imperial,
        unitsPerPoint: Double?,
        useGeodeticCalculations: Bool = true,
        viewpoint: Viewpoint?
    ) {
        _opacity = State(initialValue: settings.autoHide ? .zero : 1)
        self.settings = settings
        self.spatialReference = spatialReference
        self.style = style
        self.unitsPerPoint = unitsPerPoint
        self.viewpoint = viewpoint
        
        _viewModel = StateObject(
            wrappedValue: ScalebarViewModel(
                maxWidth,
                minScale,
                style,
                units,
                useGeodeticCalculations
            )
        )
    }
    
    public var body: some View {
        Group {
            switch style {
            case .alternatingBar:
                alternatingBarStyleRenderer
            case .bar:
                barStyleRenderer
            case .dualUnitLine:
                dualUnitLineStyleRenderer
            case .graduatedLine:
                graduatedLineStyleRenderer
            case .line:
                lineStyleRenderer
            }
        }
        .opacity(opacity)
        .onChange(spatialReference) { viewModel.update($0) }
        .onChange(unitsPerPoint) { viewModel.update($0) }
        .onChange(viewpoint) {
            viewModel.update($0)
            viewModel.updateScale()
            if settings.autoHide {
                if opacity != 1 {
                    withAnimation {
                        opacity = 1
                    }
                }
                autoHideTimer?.invalidate()
                autoHideTimer = Timer.scheduledTimer(
                    withTimeInterval: settings.autoHideDelay,
                    repeats: false
                ) { _ in
                    Task.detached { @MainActor in
                        withAnimation {
                            opacity = .zero
                        }
                    }
                }
            }
        }
        .onGeometryChange(for: CGRect.self) { proxy in
            proxy.frame(in: .global)
        } action: { newValue in
            height = newValue.height
        }
        .frame(
            width: $viewModel.displayLength.wrappedValue,
            height: height ?? .zero
        )
        .environment(\.scalebarSettings, settings)
    }
}
