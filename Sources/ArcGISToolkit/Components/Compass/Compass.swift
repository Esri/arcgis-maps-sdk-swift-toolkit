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

public struct Compass: View {
    var autoHide: Bool

    @Binding var viewpoint: Viewpoint

    @State var opacity: Double

    @State public var height: Double

    @State public var width: Double

    private var heading: String {
        "Compass, heading "
        + Int(viewpoint.rotation.rounded()).description
        + " degrees "
        + Int(viewpoint.rotation.rounded()).asCardinalOrIntercardinal
    }

    public init(
        viewpoint: Binding<Viewpoint>,
        size: Double = 30.0,
        autoHide: Bool = true
    ) {
        self._viewpoint = viewpoint
        self.autoHide = autoHide
        height = size
        width = size
        opacity = viewpoint.wrappedValue.rotation.isZero ? 0 : 1
    }

    public var body: some View {
        ZStack {
            CompassBody()
            Needle()
                .rotationEffect(Angle(degrees: viewpoint.rotation))
        }
        .frame(width: width, height: height)
        .opacity(opacity)
        .onTapGesture {
            viewpoint = Viewpoint(
                center: viewpoint.targetGeometry.extent.center,
                scale: viewpoint.targetScale,
                rotation: 0.0
            )
        }
        .onChange(of: viewpoint, perform: { _ in
            let hide = viewpoint.rotation.isZero && autoHide
            withAnimation(.default.delay(hide ? 0.25 : 0)) {
                opacity = hide ? 0 : 1
            }
        })
        .accessibilityLabel(heading)
    }
}

extension Color {
    init(red: Int, green: Int, blue: Int) {
        self.init(
            red: Double(red)/255,
            green: Double(green)/255,
            blue: Double(blue)/255
        )
    }
}

extension Int {
    var asCardinalOrIntercardinal: String {
        switch self {
        case 0...22, 338...360: return "north"
        case 23...67: return "northeast"
        case 68...112: return "east"
        case 113...157: return "southeast"
        case 158...202: return "south"
        case 203...247: return "southwest"
        case 248...290: return "west"
        case 291...337: return "northwest"
        default: return ""
        }
    }
}
