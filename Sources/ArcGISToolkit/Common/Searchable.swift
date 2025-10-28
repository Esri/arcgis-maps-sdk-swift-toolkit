// Copyright 2025 Esri
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

/// An alternative to the searchable modifier.
///
/// A focused searchable on intermediate path items in a navigation stack has been found to corrupt
/// programatic back navigation. This view can be used as an alternative to the modifier.
/// - Bug: FB20395585
/// - SeeAlso: https://developer.apple.com/forums/thread/802221#802221021
struct Searchable: View {
    /// The text to display and edit.
    @Binding var text: String
    
    /// A view that describes the purpose of the text field.
    let label: Text
    /// A Text representing the prompt of the text field which provides users with guidance on what to type
    /// into the text field.
    let prompt: Text?
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField(
                text: $text,
                prompt: prompt ?? Text(
                    "Search",
                    bundle: .toolkitModule,
                    comment: """
                        A generic prompt for a search field where a more
                        specific prompt has not been provided.
                        """
                )
            ) {
                label
            }
            if !text.isEmpty {
                XButton(.clear) {
                    text.removeAll()
                }
            }
        }
    }
}
