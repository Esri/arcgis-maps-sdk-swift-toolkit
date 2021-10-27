//
//  SwiftUIView.swift
//  
//
//  Created by Mark Dostal on 10/27/21.
//

import SwiftUI

struct SearchField: View {
    let defaultPlaceholder: String
    var currentQuery: Binding<String>
    let isShowResultsHidden: Bool
    var showResults: Binding<Bool>
    var onSubmit: () -> Void = {}

    internal init(
        defaultPlaceholder: String = "",
        currentQuery: Binding<String>,
        isShowResultsHidden: Bool,
        showResults: Binding<Bool>,
        onSubmit: @escaping () -> Void = {}
    ) {
        self.defaultPlaceholder = defaultPlaceholder
        self.currentQuery = currentQuery
        self.isShowResultsHidden = isShowResultsHidden
        self.showResults = showResults
        self.onSubmit = onSubmit
    }
    
    var body: some View {
        HStack {
            // Search button
            Button(
                action: onSubmit,
                label: {
                    Image(systemName: "magnifyingglass.circle.fill")
                        .foregroundColor(Color(uiColor: .opaqueSeparator))
                }
            )

            // Search text field
            TextField(
                defaultPlaceholder,
                text: currentQuery
            )
                .onSubmit { onSubmit() }

            // Delete text button
            if !currentQuery.wrappedValue.isEmpty {
                Button(
                    action: { currentQuery.wrappedValue = "" },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.opaqueSeparator))
                    }
                )
            }

            // Show Results button
            if !isShowResultsHidden {
                Button(
                    action: { showResults.wrappedValue.toggle() },
                    label: {
                        Image(systemName: "eye")
                            .symbolVariant(!showResults.wrappedValue ? .none : .slash)
                            .symbolVariant(.fill)
                            .foregroundColor(Color(.opaqueSeparator))
                    }
                )
            }
        }
        .esriBorder()
    }
}
