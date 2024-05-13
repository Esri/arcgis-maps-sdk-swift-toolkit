// Copyright 2024 Esri
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

@testable import ArcGISToolkit
import SwiftUI

struct RepresentedUITextViewTestView: View {
    var body: some View {
        List {
            NavigationLink("TestInit", destination: TestInit())
            NavigationLink("TestInitWithActions", destination: TestInitWithActions())
        }
    }
}

extension RepresentedUITextViewTestView {
    struct TestInit: View {
        @State private var text = "World!"
        
        var body: some View {
            HStack(alignment: .center) {
                Text("Bound Value:")
                Text(text)
                    .accessibilityIdentifier("Bound Value")
            }
            RepresentedUITextView(text: $text)
                .accessibilityIdentifier("Text View")
        }
    }
    
    struct TestInitWithActions: View {
        @State private var text = "World!"
        
        @State private var endValue = ""
        
        @FocusState var isFocused
        
        var body: some View {
            HStack(alignment: .center) {
                Text("Bound Value:")
                Text(text)
                    .accessibilityIdentifier("Bound Value")
            }
            HStack(alignment: .center) {
                Text("End Value:")
                Text(endValue)
                    .accessibilityIdentifier("End Value")
            }
            Button("End Editing") {
                isFocused = false
            }
            .buttonStyle(.plain)
            RepresentedUITextView(initialText: text) { text in
                self.text = text
            } onTextViewDidEndEditing: { text in
                endValue = text
            }
            .accessibilityIdentifier("Text View")
            .focused($isFocused)
        }
    }
}
