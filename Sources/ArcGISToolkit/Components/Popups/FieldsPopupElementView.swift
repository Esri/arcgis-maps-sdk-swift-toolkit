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
        self.fields = zip(popupElement.labels, popupElement.formattedValues).map {
            DisplayField(label: $0, formattedValue: $1)
        }
    }

    /// The `PopupElement` to display.
    private var popupElement: FieldsPopupElement
    private let fields: [DisplayField]

    var body: some View {
        PopupElementHeader(
            title: popupElement.title,
            description: popupElement.description
        )
        FieldsList(fields: fields)
            .font(.footnote)
    }
    
    struct FieldsList: View {
        let fields: [DisplayField]
        
        var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
        var body: some View {
            LazyVGrid(columns: columns) {
                ForEach(Array(fields.enumerated()), id: \.element) { index, element in
                    GridCell(label: element.label, rowIndex: index)
                    GridCell(label: element.formattedValue, rowIndex: index)
                }
            }
        }
    }
    
    struct GridCell: View {
        let label: String
        let rowIndex: Int
        var url: URL? {
            label.lowercased().starts(with: "http") ? URL(string: label) : nil
        }
        
        var body: some View {
            Group {
                HStack {
                    Text(url != nil ? "View" : label)
                        .underline(url != nil)
                        .lineLimit(1)
                        .frame(maxWidth: .greatestFiniteMagnitude, alignment: .leading)
                        .foregroundColor(url != nil ? Color(UIColor.link) : .primary)
                        .onTapGesture {
                            if let url = url {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                }
                .padding([.leading, .trailing], 4)
                .padding([.top, .bottom], 6)
                .background(rowIndex % 2 != 1 ? Color.secondary: Color.clear)
            }
        }
    }

    struct DisplayField: Hashable {
        let label: String
        let formattedValue: String
    }
}
