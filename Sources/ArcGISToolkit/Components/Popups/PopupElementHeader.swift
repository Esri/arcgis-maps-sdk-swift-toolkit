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

/// A view displaying a title and description of a `PopupElement`.
struct PopupElementHeader: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading) {
            // Text views with empty text still take up some vertical space in
            // a view, so conditionally check for an empty title and description.
            if !title.isEmpty {
                Text(title)
                    .multilineTextAlignment(.leading)
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            
            if !description.isEmpty {
                Text(description)
                    .multilineTextAlignment(.leading)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding([.bottom], 4)
    }
}
