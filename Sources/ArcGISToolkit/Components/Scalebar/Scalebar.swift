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

/// Displays the current scale on-screen
public struct Scalebar: View {
    // - MARK: Internal/Private vars
    
    /// The vertical amount of space used by the scalebar.
    @State private var height: Double?
    
    /// Controls the current opacity of the scalebar.
    @State var opacity: Double
    
    /// The view model used by the `Scalebar`.
    @StateObject var viewModel: ScalebarViewModel
    
    /// The font used by the scalebar, available in both `Font` and `UIFont` types.
    static var font: (font: Font, uiFont: UIFont) {
        let size = 9.0
        let uiFont = UIFont.systemFont(
            ofSize: size,
            weight: .semibold
        )
        let font = Font(uiFont as CTFont)
        return (font, uiFont)
    }
    
    /// The rendering height of the scalebar font.
    static var fontHeight: Double {
        return "".size(withAttributes: [.font: Scalebar.font.uiFont]).height
    }
    
    /// Acts as a data provider of the current scale.
    private var viewpoint: Binding<Viewpoint?>
    
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
        spatialReference: Binding<SpatialReference?>,
        style: ScalebarStyle = .alternatingBar,
        units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
        unitsPerPoint: Binding<Double?>,
        useGeodeticCalculations: Bool = true,
        viewpoint: Binding<Viewpoint?>
    ) {
        self.opacity = settings.autoHide ? .zero : 1
        self.settings = settings
        self.style = style
        self.viewpoint = viewpoint
        
        _viewModel = StateObject(
            wrappedValue: ScalebarViewModel(
                maxWidth,
                minScale,
                spatialReference,
                style,
                units,
                unitsPerPoint,
                useGeodeticCalculations,
                viewpoint.wrappedValue
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
        .onChange(of: viewpoint.wrappedValue) {
            viewModel.viewpointSubject.send($0)
            if settings.autoHide {
                withAnimation {
                    opacity = 1
                }
                withAnimation(.default.delay(settings.autoHideDelay)) {
                    opacity = .zero
                }
            }
        }
        .onSizeChange {
            height = $0.height
        }
        .frame(
            width: $viewModel.displayLength.wrappedValue,
            height: height ?? .zero
        )
        .environment(\.scalebarSettings, settings)
    }
}
