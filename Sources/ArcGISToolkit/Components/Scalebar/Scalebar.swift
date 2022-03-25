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
    @State private var displayLength: CGFloat = .zero
    
    @State private var displayUnit: LinearUnit? = nil
    
    /// The vertical amount of space used by the scalebar.
    @State private var height: Double = 50
    
    @State private var mapLengthString: String = "none"
    
    @Binding private var unitsPerPoint: Double?
    
    private var alignment: ScalebarAlignment
    
    private var alternateFillColor = Color.black
    
    private var fillColor = Color(uiColor: .lightGray).opacity(0.5)
    
    private var font: Font
    
    private var geodeticCurveType: GeometryEngine.GeodeticCurveType = .geodesic
    
    private var lineColor = Color.white
    
    private var shadowColor = Color(uiColor: .black).opacity(0.65)
    
    private var spatialReference: SpatialReference?
    
    private var style: ScalebarStyle
    
    private var targetWidth: Double
    
    private var textColor = Color.black
    
    private var textShadowColor = Color.white
    
    /// Unit of measure in use.
    private var units: ScalebarUnits
    
    /// Allows a user to toggle geodetic calculations.
    private var useGeodeticCalculations: Bool
    
    /// Acts as a data provider of the current scale.
    private var viewpoint: Viewpoint?
    
    /// Acts as a data provider of the current scale.
    private var visibleArea: Polygon?
    
    @State private var finalLengthWidth: Double = .zero
    
    public init(
        _ alignment: ScalebarAlignment = .left,
        _ spatialReference: SpatialReference? = .wgs84,
        _ style: ScalebarStyle = .alternatingBar,
        _ targetWidth: Double,
        _ unitsPerPoint: Binding<Double?>,
        _ viewpoint: Viewpoint?,
        _ visibleArea: Polygon?,
        
        font: Font = .system(size: 9.0, weight: .semibold),
        
        units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
        useGeodeticCalculations: Bool = true
    ) {
        self.targetWidth = targetWidth
        self.viewpoint = viewpoint
        self.visibleArea = visibleArea
        
        self.alignment = alignment
        self.font = font
        self.spatialReference = spatialReference
        self.style = style
        self.units = units
        
        self.useGeodeticCalculations = useGeodeticCalculations
        
        self._unitsPerPoint = unitsPerPoint
    }
    
    public var body: some View {
        Group {
            if style == .alternatingBar {
                alternatingBarView
            } else {
                barView
            }
        }
        .onChange(of: visibleArea) { _ in
            updateScaleDisplay()
        }
        .onAppear {
            updateScaleDisplay()
        }
        .onSizeChange {
            height = $0.height
        }
        .frame(
            width: displayLength,
            height: height
        )
//        .border(.red)
    }
    
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
    
    private func updateScaleDisplay() {
        guard let scale = viewpoint?.targetScale else {
            return
        }
        guard minScale <= 0 || scale < minScale else {
            return
        }
        guard let unitsPerPoint = unitsPerPoint else {
            return
        }
        guard let visibleArea = visibleArea else {
            return
        }
        guard let sr = spatialReference else {
            return
        }
        let totalWidthAvailable = targetWidth
        
        // TODO: - Removal of hardcoded sample renderer property (~16 - 2) derived from sample renderer
        let maxLength =  totalWidthAvailable - 16.30243742465973 - 2
        
        let lineMapLength: Double
        let displayUnit: LinearUnit
        let mapCenter = visibleArea.extent.center
        let displayLength: CGFloat
        
        if useGeodeticCalculations || spatialReference?.unit is AngularUnit {
            let maxLengthPlanar = unitsPerPoint * Double(maxLength)
            let p1 = Point(
                x: mapCenter.x - (maxLengthPlanar * 0.5),
                y: mapCenter.y,
                spatialReference: sr
            )
            let p2 = Point(
                x: mapCenter.x + (maxLengthPlanar * 0.5),
                y: mapCenter.y,
                spatialReference: sr
            )
            let polyline = Polyline(
                points: [p1, p2], spatialReference: spatialReference
            )
            let baseUnits = units.baseUnits()
            let maxLengthGeodetic = GeometryEngine.geodeticLength(
                of: polyline,
                lengthUnit: baseUnits,
                curveType: geodeticCurveType
            )
            let roundNumberDistance = units.closestDistanceWithoutGoingOver(
                to: maxLengthGeodetic,
                units: baseUnits
            )
            let planarToGeodeticFactor = maxLengthPlanar / maxLengthGeodetic
            displayLength = CGFloat( (roundNumberDistance * planarToGeodeticFactor) / unitsPerPoint )
            displayUnit = units.linearUnitsForDistance(distance: roundNumberDistance)
            lineMapLength = baseUnits.convert(to: displayUnit, value: roundNumberDistance)
        } else {
            guard let srUnit = sr.unit as? LinearUnit else {
                return
            }
            let unitsPerPoint = unitsPerPoint
            let baseUnits = units.baseUnits()
            let lenAvail = srUnit.convert(
                to: baseUnits,
                value: unitsPerPoint * Double(maxLength)
            )
            let closestLen = units.closestDistanceWithoutGoingOver(
                to: lenAvail,
                units: baseUnits
            )
            displayLength = CGFloat(
                baseUnits.convert(to: srUnit, value: closestLen) / unitsPerPoint)
            displayUnit = units.linearUnitsForDistance(distance: closestLen)
            lineMapLength = baseUnits.convert(
                to: displayUnit,
                value: closestLen
            )
        }
        
        guard displayLength.isFinite, !displayLength.isNaN else {
            return
        }
        
        self.displayLength = displayLength
        
        self.displayUnit = displayUnit
        
        mapLengthString = Scalebar.numberFormatter.string(from: NSNumber(value: lineMapLength)) ?? ""
    }
}

extension Scalebar {
    var alternatingBarView: some View {
        VStack(spacing: 2) {
            Rectangle()
                .fill(.gray)
                .border(
                    .white,
                    width: 1.5
                )
                .frame(
                    width: displayLength,
                    height: 7,
                    alignment: .leading
                )
                .shadow(
                    color: Color(uiColor: .lightGray),
                    radius: 1
                )
            HStack {
                Text("0")
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\(mapLengthString) \(displayUnit?.abbreviation ?? "")")
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
                    .onSizeChange {
                        finalLengthWidth = $0.width
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .offset(x: finalLengthWidth / 2)
            }
        }
    }
    
    var barView: some View {
        VStack(spacing: 2) {
            Rectangle()
                .fill(.gray)
                .border(
                    .white,
                    width: 1.5
                )
                .frame(
                    width: displayLength,
                    height: 7,
                    alignment: .leading
                )
                .shadow(
                    color: Color(uiColor: .lightGray),
                    radius: 1
                )
            HStack {
                Text("\(mapLengthString) \(displayUnit?.abbreviation ?? "")")
                    .font(.system(size: 10))
                    .fontWeight(.semibold)
                    .onSizeChange {
                        finalLengthWidth = $0.width
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}


// - TODO: Temporary as another PR in-flight contains this extension.
extension View {
    /// Returns a new `View` that allows a parent `View` to be informed of a child view's size.
    /// - Parameter perform: The closure to be executed when the content size of the receiver
    /// changes.
    /// - Returns: A new `View`.
    func onSizeChange(perform: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .preference(
                        key: SizePreferenceKey.self, value: geometry.size
                    )
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: perform)
    }

}

// - TODO: Temporary as another PR in-flight contains this extension.
/// A `PreferenceKey` that specifies a size.
struct SizePreferenceKey: PreferenceKey {
    static let defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
