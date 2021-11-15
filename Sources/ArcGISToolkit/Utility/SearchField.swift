// Copyright 2021 Esri.

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

/// A custom view implementing a SearchField.  It contains a search button, text field, delete text button,
/// and a button to allow users to hide/show the search results list.
public struct SearchField: View {
    /// The current search query.
    public var currentQuery: Binding<String>

    /// The default placeholder displayed when `currentQuery` is empty.
    public var defaultPlaceholder: String = ""

    /// The visibility of the `showResults` button.
    public var isShowResultsHidden: Bool = true

    /// Binding allowing the user to toggle the visibility of the results list.
    public var showResults: Binding<Bool>? = nil
    
    /// The handler executed when the user submits a search, either via the `TextField`
    /// or the Search button.
    public var onCommit: () -> Void = { }
    
    public var body: some View {
        HStack {
            // Search button
            Button {
                onCommit()
            } label: {
                Image(systemName: "magnifyingglass.circle.fill")
                    .foregroundColor(Color(uiColor: .opaqueSeparator))
            }
            
            // Search text field
            TextField(
                "Search Query",
                text: currentQuery,
                prompt: Text(defaultPlaceholder)
            )
                .onSubmit { onCommit() }
            
            // Delete text button
            if !currentQuery.wrappedValue.isEmpty {
                Button {
                    currentQuery.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.opaqueSeparator))
                }
            }
            
            // Show Results button
            if !isShowResultsHidden {
                Button {
                    showResults?.wrappedValue.toggle()
                } label: {
                    Image(systemName: "eye")
                        .symbolVariant(!(showResults?.wrappedValue ?? false) ? .none : .slash)
                        .symbolVariant(.fill)
                        .foregroundColor(Color(.opaqueSeparator))
                }
            }
        }
        .esriBorder()
    }
}
