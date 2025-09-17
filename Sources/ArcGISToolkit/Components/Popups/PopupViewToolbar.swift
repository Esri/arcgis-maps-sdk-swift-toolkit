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

extension View {
    /// Populates the toolbar with items used by the `PopupView`.
    func popupViewToolbar() -> some View {
        modifier(PopupViewToolbar())
    }
}

/// A view modifier that populates the content's toolbar with items used by the `PopupView`.
private struct PopupViewToolbar: ViewModifier {
    /// A binding to a Boolean value that determines whether a popup view is presented.
    @Environment(\.isPresented) private var isPresented
    @Environment(\.toolbarContent) private var toolbarContent
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                if let isPresented {
                    ToolbarItem(placement: .topBarTrailing) {
                        XButton(.dismiss) {
                            isPresented.wrappedValue = false
                        }
                        .font(.headline)
                    }
                }
                if let toolbarContent {
                    ToolbarItemGroup(placement: .bottomBar) {
                        AnyView(toolbarContent)
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .popupViewToolbar()
    }
}
