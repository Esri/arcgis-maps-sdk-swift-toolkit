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
                FormattedValueText(formattedValue: field.formattedValue)
                    .padding([.bottom], -1)
            }
            .background(Color.clear)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private struct FormattedValueText: View {
        
        let formattedValue: String
        private let detector = PopupValueDetector()
        
        var body: some View {
            switch detector.detect(in: formattedValue) {
                
            case .url(let url):
                Link(destination: url) {
                    Text(
                        "View",
                        bundle: .toolkitModule,
                        comment: "E.g. Open a hyperlink."
                    )
                }
#if os(visionOS)
                .buttonStyle(.bordered)
#else
                .buttonStyle(.borderless)
#endif
                
            case .phones(let phones):
                Text(phoneAttributedText(phones: phones))
                
            case .none:
                Text(formattedValue)
            }
        }
        
        private func phoneAttributedText(
            phones: [(url: URL, range: NSRange)]
        ) -> AttributedString {
            
            var attributed = AttributedString(formattedValue)
            
            for phone in phones {
                if let range = Range(phone.range, in: attributed) {
                    attributed[range].link = phone.url
                    attributed[range].foregroundColor = .blue
                    attributed[range].underlineStyle = .single
                }
            }
            
            return attributed
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

private struct PopupValueDetector {
    
    enum DetectedValue {
        case phones([(url: URL, range: NSRange)])
        case url(URL)
    }
    
    func detect(in text: String) -> DetectedValue? {
        /// URL detection
        if text.lowercased().starts(with: "http"),
           let url = URL(string: text) {
            return .url(url)
        }
        
        /// Phone number detection
        let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
        guard let detector = try? NSDataDetector(types: types.rawValue) else {
            return nil
        }
        
        let fullRange = NSRange(text.startIndex..., in: text)
        let matches = detector.matches(in: text, options: [], range: fullRange)
        
        let phones: [(URL, NSRange)] = matches.compactMap { match in
            guard let phone = match.phoneNumber else { return nil }
            
            let cleaned = phone
                .components(separatedBy: CharacterSet.decimalDigits.inverted)
                .joined()
            
            guard let url = URL(string: "tel:\(cleaned)") else { return nil }
            return (url, match.range)
        }
        
        return phones.isEmpty ? nil : .phones(phones)
    }
    
}
