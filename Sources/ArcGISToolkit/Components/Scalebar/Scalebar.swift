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
    /// Acts as a data provider of the current scale.
    private var scale: Double?

    /// Acts as a data provider of the current scale.
    private var viewpoint: Viewpoint?

    /// Acts as a data provider of the current scale.
    private var visibleArea: Polygon?

    public init(
        _ scale: Double?,
        _ viewpoint: Viewpoint?,
        _ visibleArea: Polygon?
    ) {
        self.scale = scale
        self.viewpoint = viewpoint
        self.visibleArea = visibleArea
    }

    public var body: some View {
        VStack {
            Text(scale?.description ?? "N/A")
            Text(viewpoint?.targetScale.description ?? "N/A")
            Text(visibleArea?.extent.width.description ?? "N/A")
        }
    }
}
