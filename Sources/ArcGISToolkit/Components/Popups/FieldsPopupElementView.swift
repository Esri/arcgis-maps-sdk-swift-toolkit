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
            title: popupElement.title,
            description: popupElement.description
        )
        FieldsGrid(fields: displayFields)
            .font(.footnote)
    }
    
    /// A view displaying a grid of labels and values.
    struct FieldsGrid: View {
        let fields: [DisplayField]
        
        var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 2)
        var body: some View {
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(fields.enumerated()), id: \.element) { index, element in
                    GridCell(label: element.label, rowIndex: index)
                    GridCell(label: element.formattedValue, rowIndex: index)
                }
            }
        }
    }
    
    /// A view for dispaying text in a grid.
    struct GridCell: View {
        /// The String to display.
        let label: String
        /// The index of the row the view is in.
        let rowIndex: Int
        /// The URL off the label if the label is an "http" string.
        var url: URL? {
            label.lowercased().starts(with: "http") ? URL(string: label) : nil
        }
        
        var body: some View {
            Text(url != nil ? "View" : label)
                .underline(url != nil)
                .foregroundColor(url != nil ? Color(UIColor.link) : .primary)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(6)
                .onTapGesture {
                    if let url = url {
                        UIApplication.shared.open(url)
                    }
                }
                .background(rowIndex % 2 != 1 ? Color.secondary.opacity(0.5) : Color.clear)
        }
    }
    
    /// A convenience type for displaying labels and values in a grid.
    struct DisplayField: Hashable {
        let label: String
        let formattedValue: String
    }
}
