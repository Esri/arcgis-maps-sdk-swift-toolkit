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
    /// - Parameters:
    ///   - title: The text to display as the navigation title.
    ///   - subtitle: The text to display as the optional navigation subtitle.
    func popupViewToolbar(title: String, subtitle: String? = nil) -> some View {
        modifier(PopupViewToolbar(title: title, subtitle: subtitle))
    }
}

/// A view modifier that populates the content's toolbar with items used by the `PopupView`.
private struct PopupViewToolbar: ViewModifier {
    /// The visibility of the popup view's close button.
    @Environment(\.popupCloseButtonVisibility) private var closeButtonVisibility
    
    /// A binding to a Boolean value that determines whether a popup view is presented.
    @Environment(\.popupIsPresented) private var isPresented
    
    /// The text to display as the navigation title.
    let title: String
    
    /// The text to display as the optional navigation subtitle.
    let subtitle: String?
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(title)
                            .fontWeight(.semibold)
                            .font(subtitle != nil ? .subheadline : .headline)
                        
                        if let subtitle {
                            Text(subtitle)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                if closeButtonVisibility != .hidden {
                    ToolbarItem(placement: .topBarTrailing) {
                        XButton(.dismiss) {
                            isPresented?.wrappedValue = false
                        }
                        .font(.headline)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Title Only") {
    NavigationStack {
        Color.clear
            .popupViewToolbar(title: "Title")
    }
}

#Preview("Title and Subtitle") {
    NavigationStack {
        Color.clear
            .popupViewToolbar(title: "Title", subtitle: "Subtitle")
    }
}
