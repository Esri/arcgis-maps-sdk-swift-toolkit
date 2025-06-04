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

/// A view containing a text field and controls for searching.
///
/// This view mimics the appearance of `View.searchable(text:placement:prompt:)`
/// but does not require the use of a `NavigationStack`.
struct SearchBar: View {
    /// A binding to the text to display and edit in the search field.
    @Binding var text: String
    
    /// The prompt of the search field which provides users with guidance on what to search for.
    let prompt: String
    
    /// A Boolean value indicating whether the text field is focused.
    @FocusState private var textFieldIsFocused: Bool
    
    /// A Boolean value indicating whether the cancel button is showing.
    ///
    /// This is needed instead of `textFieldIsFocused` directly, so
    /// that the button will animate when appearing.
    @State private var cancelButtonIsPresented = false
    
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                let promptView = Text(prompt)
                    .foregroundStyle(Color(.systemGray))
                TextField(text: $text, prompt: promptView) {
                    Text(
                        "Search Query",
                        bundle: .toolkitModule,
                        comment: "A label in reference to a search query entered by the user."
                    )
                }
                .autocorrectionDisabled()
                .focused($textFieldIsFocused)
                .onChange(of: textFieldIsFocused, initial: true) {
                    withAnimation {
                        cancelButtonIsPresented = textFieldIsFocused
                    }
                }
            }
            .padding(7)
            .background(Color(.tertiarySystemFill))
            .clipShape(.rect(cornerRadius: 8))
            .overlay(alignment: .trailing) {
                if !text.isEmpty {
                    Button("Clear", systemImage: "multiply.circle.fill") {
                        text = ""
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
                    .padding(5)
                }
            }
            .animation(.default, value: text.isEmpty)
            
            if cancelButtonIsPresented {
                Button.cancel {
                    textFieldIsFocused = false
                    text = ""
                }
                .transition(.opacity.combined(with: .move(edge: .trailing)))
            }
        }
        .onDisappear {
            textFieldIsFocused = false
        }
    }
}

#Preview {
    @Previewable @State var text = ""
    
    SearchBar(text: $text, prompt: "Search")
}
