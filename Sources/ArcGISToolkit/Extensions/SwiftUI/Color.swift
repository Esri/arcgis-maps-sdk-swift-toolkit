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

extension Color {
    /// Initializes a new color with RGB integer values.
    /// - Precondition: `red`, `green` and `blue` are values between 0 and 255 inclusive.
    init(red: Int, green: Int, blue: Int) {
        let validRange = 0...255
        precondition(validRange.contains(red))
        precondition(validRange.contains(green))
        precondition(validRange.contains(blue))
        self.init(
            red: Double(red)/255,
            green: Double(green)/255,
            blue: Double(blue)/255
        )
    }
}
