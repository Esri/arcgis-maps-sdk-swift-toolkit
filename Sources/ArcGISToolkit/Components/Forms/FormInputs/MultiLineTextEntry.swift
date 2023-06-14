// Copyright 2023 Esri.

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

/// A view for text entry spanning multiple lines.
///
/// Includes UI for easy keyboard dismissal upon completion.
struct MultiLineTextEntry: View {
    @State private var text: String = ""
    
    @FocusState var isActive: Bool
    
    public var body: some View {
        TextEditor(text: $text)
            .padding(1.5)
            .border(.gray.opacity(0.2))
            .cornerRadius(5)
            .focused($isActive)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if isActive {
                        Spacer()
                        Button {
                            isActive.toggle()
                        } label: {
                            Text("Done", bundle: .module, comment: "Dismisses a keyboard.")
                        }
                    }
                }
            }
    }
}
