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

/// Represents the center of the spinning needle at the center of the compass.
struct NeedleCenter: View {
    var body: some View {
        Circle()
            .scale(0.25)
            .foregroundColor(Color.bronze)
    }
}

private extension Color {
    /// The bronze color of the center of the compass needle.
    static let bronze = Color(red: 241, green: 169, blue: 59)
}
