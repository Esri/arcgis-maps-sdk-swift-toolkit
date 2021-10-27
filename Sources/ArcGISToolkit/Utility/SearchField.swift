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
struct SearchField: View {
    /// The default placeholder displayed when `currentQuery` is empty.
    let defaultPlaceholder: String

    /// The current search query.
    var currentQuery: Binding<String>

    /// The visibility of the `showResults` button.
    let isShowResultsHidden: Bool

    /// Binding allowing the user to toggle the visibility of the results list.
    var showResults: Binding<Bool>?
    
    /// The handler executed when the user submits a search, either via the `TextField`
    /// or the Search button.
    var onCommit: () -> Void
    
    /// Creates a new SearchField
    /// - Parameters:
    ///   - defaultPlaceholder: The default placeholder displayed when `currentQuery`
    ///   is empty.
    ///   - currentQuery: The current search query.
    ///   - isShowResultsHidden: The visibility of the `showResults` button.
    ///   - showResults: Binding allowing the user to toggle the visibility of the results list.
    ///   - onCommit: The handler executed when the user submits a search, either via the
    ///   `TextField`or the Search button.
    internal init(
        defaultPlaceholder: String = "",
        currentQuery: Binding<String>,
        isShowResultsHidden: Bool = true,
        showResults: Binding<Bool>? = nil,
        onCommit: @escaping () -> Void = { }
    ) {
        self.defaultPlaceholder = defaultPlaceholder
        self.currentQuery = currentQuery
        self.isShowResultsHidden = isShowResultsHidden
        self.showResults = showResults
        self.onCommit = onCommit
    }
    
    var body: some View {
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
                defaultPlaceholder,
                text: currentQuery
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
