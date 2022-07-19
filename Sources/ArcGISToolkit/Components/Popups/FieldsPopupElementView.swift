// Copyright 2022 Esri.

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
    
    var body: some View {
        PopupElementHeader(
            title: popupElement.title.isEmpty ? "Fields" : popupElement.title,
            description: popupElement.description
        )
        FieldsGrid(fields: displayFields)
    }
    
    /// A view displaying a grid of labels and values.
    struct FieldsGrid: View {
        let fields: [DisplayField]
        var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 1)
        
        var body: some View {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(fields) { field in
                    VStack(alignment: .leading) {
                        Text(field.label)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding([.top], 6)
                        FormattedValueText(formattedValue: field.formattedValue)
                            .padding([.bottom], -2)
                        Divider()
                    }
                    .lineLimit(1)
                    .background(Color.clear)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
    
    /// A view for dispaying a formatted value.
    struct FormattedValueText: View {
        /// The String to display.
        let formattedValue: String
        /// The URL of the label if the label is an "http" string.
        var url: URL? {
            formattedValue.lowercased().starts(with: "http") ? URL(string: formattedValue) : nil
        }
        
        var body: some View {
            Group {
                if let url = url,
                   let link = "[View](\(url.absoluteString))"{
                    Text(.init(link))
                } else {
                    Text(formattedValue)
                }
            }
        }
    }
}

/// A convenience type for displaying labels and values in a grid.
struct DisplayField: Hashable {
    let label: String
    let formattedValue: String
    let id = UUID()
}

extension DisplayField: Identifiable {}
