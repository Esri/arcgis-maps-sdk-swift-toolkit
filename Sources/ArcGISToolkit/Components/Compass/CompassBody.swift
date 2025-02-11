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

import SwiftUI

/// Represents the circular housing which encompasses the spinning needle at the center of the compass.
struct CompassBody: View {
    var body: some View {
        GeometryReader { geometry in
            let borderWidth = geometry.size.width * 0.025
            Circle()
                .inset(by: borderWidth / 2.0)
                .stroke(lineWidth: borderWidth)
                .foregroundStyle(Color.outline)
                .background {
                    Circle()
                        .foregroundStyle(Color.fill)
                }
        }
    }
}

private extension Color {
    /// The background color of the compass housing.
    static let fill = Color(red: 228, green: 240, blue: 244)
    
    /// The outline color of the compass housing.
    static let outline = Color(red: 127, green: 127, blue: 127)
}
