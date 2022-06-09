// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License./

import SwiftUI

/// A "Handle" view for resizeable containers.
struct Handle: View {
    /// The color of the handle.
    var color: Color
    
    var body: some View {
        RoundedRectangle(cornerRadius: 4.0)
            .foregroundColor(color)
            .frame(width: 100, height: 8.0)
    }
}

extension Color {
    static var defaultHandleColor: Color { .secondary }
    static var activeHandleColor: Color { .primary }
}

