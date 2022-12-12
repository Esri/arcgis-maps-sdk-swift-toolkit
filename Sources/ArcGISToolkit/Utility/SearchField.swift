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

/// A custom view implementing a SearchField. It contains a search button, text field, delete text button,
/// and a button to allow users to hide/show the search results list.
public struct SearchField: View {
    /// Creates a `SearchField`.
    /// - Parameters:
    ///   - query: The current search query.
    ///   - prompt: The default placeholder displayed when `currentQuery` is empty.
    ///   - isResultsButtonHidden: The visibility of the button used to toggle visibility of the results list.
    ///   - isResultListHidden: Binding allowing the user to toggle the visibility of the results list.
    public init(
        query: Binding<String>,
        prompt: String = "",
        isResultsButtonHidden: Bool = false,
        isResultListHidden: Binding<Bool>? = nil
    ) {
        self.query = query
        self.prompt = prompt
        self.isResultsButtonHidden = isResultsButtonHidden
        self.isResultListHidden = isResultListHidden
    }
    
    /// The current search query.
    private var query: Binding<String>
    
    /// The default placeholder displayed when `currentQuery` is empty.
    private let prompt: String
    
    /// The visibility of the button used to toggle visibility of the results list.
    private let isResultsButtonHidden: Bool
    
    /// Binding allowing the user to toggle the visibility of the results list.
    private var isResultListHidden: Binding<Bool>?
    
    public var body: some View {
        HStack {
            // Search icon
            Image(systemName: "magnifyingglass.circle.fill")
                .foregroundColor(Color.secondary)
            
            // Search text field
            TextField(
                "Search Query",
                text: query,
                prompt: Text(prompt)
            )
            
            // Delete text button
            if !query.wrappedValue.isEmpty {
                Button {
                    query.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.secondary)
                }
            }
            
            // Show Results button
            if !isResultsButtonHidden {
                Button {
                    isResultListHidden?.wrappedValue.toggle()
                } label: {
                    Image(
                        systemName: (isResultListHidden?.wrappedValue ?? false) ?
                        "chevron.down" :
                            "chevron.up"
                    )
                        .foregroundColor(Color.secondary)
                }
            }
        }
        .esriBorder()
    }
}
