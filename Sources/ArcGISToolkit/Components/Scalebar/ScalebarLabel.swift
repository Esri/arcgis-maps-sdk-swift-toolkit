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

/// Models a label displayed along the edge of a scalebar
@available(visionOS, unavailable)
struct ScalebarLabel {
    /// The number of the label with the leftmost label ("0") starting at -1.
    let index: Int
    
    /// The horizontal offset of this label.
    let xOffset: CGFloat
    
    /// The text to be displayed by this label.
    let text: String
    
    /// The vertical offset of this label.
    static var yOffset: CGFloat {
        return Scalebar.fontHeight / 2.0
    }
}
