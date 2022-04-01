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
    /// The view model used by the `Scalebar`.
    @StateObject
    internal var viewModel: ScalebarViewModel
    
    /// The vertical amount of space used by the scalebar.
    @State private var height: Double = 50
    
    @State internal var finalLengthWidth: Double = .zero
    
    private var alignment: ScalebarAlignment
    
    internal var lineColor = Color.white
    
    internal var fillColor1 = Color.black
    
    internal var fillColor2 = Color(uiColor: .lightGray).opacity(0.5)
    
    internal var shadowColor = Color(uiColor: .black).opacity(0.65)
    internal var shadowRadius = 1.0
    
    internal var lineWidth = 3.0
    
    internal var lineFrameHeight = 6.0
    
    internal var barFrameHeight = 10.0
    
    internal var lineCornerRadius = 2.5
    
    private var style: ScalebarStyle
    
    private var textColor = Color.black
    
    var textShadowColor = Color.white
    
    /// Acts as a data provider of the current scale.
    private var viewpoint: Binding<Viewpoint?>
    
    /// Acts as a data provider of the current scale.
    private var visibleArea: Binding<Polygon?>
    
    public init(
        alignment: Alignment,
        _ spatialReference: SpatialReference? = .wgs84,
        _ style: ScalebarStyle = .alternatingBar,
        _ targetWidth: Double,
        _ unitsPerPoint: Binding<Double?>,
        _ viewpoint: Binding<Viewpoint?>,
        _ visibleArea: Binding<Polygon?>,
        units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
        useGeodeticCalculations: Bool = true
    ) {
        self.viewpoint = viewpoint
        self.visibleArea = visibleArea
        
        switch alignment {
        case .topTrailing, .trailing, .bottomTrailing:
            self.alignment = .right
        case .top, .center, .bottom:
            self.alignment = .center
        default:
            self.alignment = .left
        }
        
        self.style = style
        
        _viewModel = StateObject(
            wrappedValue: ScalebarViewModel(
                spatialReference,
                targetWidth,
                units,
                unitsPerPoint,
                useGeodeticCalculations,
                viewpoint,
                visibleArea
            )
        )
    }
    
    public var body: some View {
        Group {
            switch style {
            case .alternatingBar:
                alternatingBarStyleRender
            case .bar:
                barStyleRender
            case .dualUnitLine:
                dualUnitLineStyleRender
            case .graduatedLine:
                graduatedLineStyleRender
            case .line:
                lineStyleRender
            }
        }
        .onChange(of: visibleArea.wrappedValue) {
            viewModel.visibleAreaSubject.send($0)
        }
        .onSizeChange {
            height = $0.height
        }
        .frame(
            width: $viewModel.displayLength.wrappedValue,
            height: height
        )
    }
    
    internal static var font: (Font: Font, UIFont: UIFont) {
        let size = 10.0
        let uiFont = UIFont.systemFont(
            ofSize: size,
            weight: .semibold
        )
        let font = Font(uiFont as CTFont)
        return (font, uiFont)
    }
    
    /// The spacing between labels and the scalebar.
    internal static let labelYPad: CGFloat = 2.0
    
    internal static let labelXPad: CGFloat = 4.0
    internal static let tickHeight: CGFloat = 6.0
    internal static let tick2Height: CGFloat = 4.5
    internal static let notchHeight: CGFloat = 6.0
    internal static var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.minimumFractionDigits = 0
        return numberFormatter
    }()
    
    internal static let lineCap = CGLineCap.round
    
    internal var fontHeight: CGFloat = 0
    internal var zeroStringWidth: CGFloat = 0
    internal var maxRightUnitsPad: CGFloat = 0
    
    /// Set a minScale if you only want the scalebar to appear when you reach a large enough scale maybe
    ///  something like 10_000_000. This could be useful because the scalebar is really only accurate for
    ///  the center of the map on smaller scales (when zoomed way out). A minScale of 0 means it will
    ///  always be visible
    private let minScale: Double = 0
}

