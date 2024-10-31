// Copyright 2022 Esri
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
import ArcGIS

/// A view displaying a `FieldsPopupElement`.
struct FieldsPopupElementView: View {
    /// Creates a new `FieldsPopupElementView`.
    /// - Parameter popupElement: The `FieldsPopupElement`.
    init(popupElement: FieldsPopupElement) {
        self.popupElement = popupElement
        self.displayFields = zip(popupElement.labels, popupElement.formattedValues).map {
            DisplayField(label: $0, formattedValue: $1)
        }
    }
    
    /// The `PopupElement` to display.
    private var popupElement: FieldsPopupElement
    
    /// The labels and values to display, as an array of `DisplayField`s.
    private let displayFields: [DisplayField]
    
    @State var isExpanded: Bool = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(displayFields) { field in
                FieldRow(field: field)
            }
        } label: {
            PopupElementHeader(
                title: popupElement.displayTitle,
                description: popupElement.description
            )
            .catalystPadding(4)
        }
        .disclosureGroupPadding()
    }
    
    /// A view for displaying a `DisplayField`.
    private struct FieldRow: View {
        var field: DisplayField
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(field.label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                FormattedValueText(formattedValue: field.formattedValue)
                    .padding([.bottom], -1)
            }
            .background(Color.clear)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    /// A view for displaying a formatted value.
    private struct FormattedValueText: View {
        /// The String to display.
        let formattedValue: String
        
        var body: some View {
            if formattedValue.lowercased().starts(with: "http"),
               let url = URL(string: formattedValue) {
                Link("View", destination: url)
                    .buttonStyle(.bordered)
            } else {
                Text(formattedValue)
            }
        }
    }
}

/// A convenience type for displaying labels and values in a grid.
private struct DisplayField: Hashable, Identifiable {
    let label: String
    let formattedValue: String
    let id = UUID()
}

private extension FieldsPopupElement {
    /// Provides a default title to display if `title` is empty.
    var displayTitle: String {
        title.isEmpty ? String(
            localized: "Fields",
            bundle: .toolkitModule,
            comment: "A label in reference to fields in a set of data contained in a popup."
        ) : title
    }
}
