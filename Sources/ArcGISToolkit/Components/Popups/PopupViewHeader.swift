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
    /// Adds a PopupView header to the view.
    /// - Parameter title: The title to display in the header.
    /// - Note: This can be removed once `PopupView.DeprecatedProperties` is removed.
    func popupViewHeader(title: String) -> some View {
        modifier(PopupViewHeaderModifier(title: title))
    }
}

/// A view modifier that adds a PopupView header to a view.
/// - Note: This can be removed once `PopupView.DeprecatedProperties` is removed.
private struct PopupViewHeaderModifier: ViewModifier {
    /// The title to display in the header.
    let title: String
    
    /// The properties used by the parent PopupView's deprecated members.
    @Environment(\.deprecatedProperties) private var deprecatedProperties
    
    /// A binding to a Boolean value that determines whether a popup view is presented.
    @Environment(\.isPresented) private var isPresented
    
    func body(content: Content) -> some View {
        if !deprecatedProperties.initializerWasUsed {
            content
                .popupViewToolbar()
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        } else if deprecatedProperties.headerVisibility != .hidden {
            VStack {
                HStack {
                    if !title.isEmpty {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    if deprecatedProperties.showCloseButton ?? (isPresented != nil) {
                        XButton(.dismiss) {
                            isPresented?.wrappedValue = false
                        }
#if !os(visionOS)
                        .font(.title)
                        .padding([.top, .bottom, .trailing], 4)
#endif
                    }
                }
                Divider()
                content
            }
        } else {
            content
        }
    }
}
