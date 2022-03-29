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
    private var viewModel: ScalebarViewModel
    
    /// The vertical amount of space used by the scalebar.
    @State private var height: Double = 50
    
    @State private var finalLengthWidth: Double = .zero
    
    private var alignment: ScalebarAlignment
    
    private var alternateFillColor = Color.black
    
    private var fillColor = Color(uiColor: .lightGray).opacity(0.5)
    
    private var font: Font
    
    private var lineColor = Color.white
    
    private var shadowColor = Color(uiColor: .black).opacity(0.65)
    
    private var style: ScalebarStyle
    
    private var textColor = Color.black
    
    private var textShadowColor = Color.white
    
    /// Acts as a data provider of the current scale.
    private var viewpoint: Binding<Viewpoint?>
    
    /// Acts as a data provider of the current scale.
    private var visibleArea: Binding<Polygon?>
    
    public init(
        alignment: ScalebarAlignment = .left,
        _ spatialReference: SpatialReference? = .wgs84,
        _ style: ScalebarStyle = .alternatingBar,
        _ targetWidth: Double,
        _ unitsPerPoint: Binding<Double?>,
        _ viewpoint: Binding<Viewpoint?>,
        _ visibleArea: Binding<Polygon?>,
        
        font: Font = .system(size: 10.0, weight: .semibold),
        
        units: ScalebarUnits = NSLocale.current.usesMetricSystem ? .metric : .imperial,
        useGeodeticCalculations: Bool = true
    ) {
        self.viewpoint = viewpoint
        self.visibleArea = visibleArea
        
        self.alignment = alignment
        self.font = font
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
            if style == .alternatingBar {
                alternatingBarView
            } else {
                barView
            }
        }
        .onChange(of: visibleArea.wrappedValue) {
            viewModel.subject.send($0)
        }
        .onSizeChange {
            height = $0.height
        }
        .frame(
            width: $viewModel.displayLength.wrappedValue,
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
                    width: $viewModel.displayLength.wrappedValue,
                    height: 7,
                    alignment: .leading
                )
                .shadow(
                    color: Color(uiColor: .lightGray),
                    radius: 1
                )
            HStack {
                Text("0")
                    .font(font)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("\($viewModel.mapLengthString.wrappedValue) \($viewModel.displayUnit.wrappedValue?.abbreviation ?? "")")
                    .font(font)
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
                    width: $viewModel.displayLength.wrappedValue,
                    height: 7,
                    alignment: .leading
                )
                .shadow(
                    color: Color(uiColor: .lightGray),
                    radius: 1
                )
            HStack {
                Text("\($viewModel.mapLengthString.wrappedValue) \($viewModel.displayUnit.wrappedValue?.abbreviation ?? "")")
                    .font(font)
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
