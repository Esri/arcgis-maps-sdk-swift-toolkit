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
                    .foregroundStyle(.secondary)
                makeAttributedText(with: field.formattedValue)
                    .padding([.bottom], -1)
            }
            .background(Color.clear)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        
        /// Makes text with clickable links.
        /// - Parameter string: A string that may contain hyperlinks and or phone numbers.
        /// - Returns: Text where hyperlinks and phone numbers have been converted into interactive links.
        private func makeAttributedText(with string: String) -> Text {
            let detector = DataDetector()
            let links = detector.detect(in: string)
            var attributed = AttributedString(string)
            for phone in links ?? [] {
                if let range = Range(phone.range, in: attributed) {
                    attributed[range].link = phone.url
                    attributed[range].foregroundColor = .blue
                    attributed[range].underlineStyle = .single
                }
            }
            return Text(attributed)
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
