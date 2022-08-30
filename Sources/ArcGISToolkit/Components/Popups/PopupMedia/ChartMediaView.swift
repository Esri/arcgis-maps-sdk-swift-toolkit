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

import SwiftUI
import ArcGIS

/// A view displaying chart popup media.
struct ChartMediaView: View {
    /// The popup media to display.
    let popupMedia: PopupMedia
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Image(systemName: "chart.bar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text("Charts coming soon!")
            }
            RoundedRectangle(cornerRadius: 8)
                .stroke(.black, lineWidth: 1)
        }
    }
}
