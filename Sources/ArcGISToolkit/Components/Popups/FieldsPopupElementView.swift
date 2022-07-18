***REMOVED*** Copyright 2022 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
***REMOVED***

***REMOVED***/ A view displaying a `FieldsPopupElement`.
struct FieldsPopupElementView: View {
***REMOVED******REMOVED***/ Creates a new `FieldsPopupElementView`.
***REMOVED******REMOVED***/ - Parameter popupElement: The `FieldsPopupElement`.
***REMOVED***init(popupElement: FieldsPopupElement) {
***REMOVED******REMOVED***self.popupElement = popupElement
***REMOVED******REMOVED***self.displayFields = zip(popupElement.labels, popupElement.formattedValues).map {
***REMOVED******REMOVED******REMOVED***DisplayField(label: $0, formattedValue: $1)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The `PopupElement` to display.
***REMOVED***private var popupElement: FieldsPopupElement
***REMOVED***
***REMOVED******REMOVED***/ The labels and values to display, as an array of `DisplayField`s.
***REMOVED***private let displayFields: [DisplayField]
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***PopupElementHeader(
***REMOVED******REMOVED******REMOVED***title: popupElement.title,
***REMOVED******REMOVED******REMOVED***description: popupElement.description
***REMOVED******REMOVED***)
***REMOVED******REMOVED***FieldsGrid(fields: displayFields)
***REMOVED******REMOVED******REMOVED***.font(.footnote)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view displaying a grid of labels and values.
***REMOVED***struct FieldsGrid: View {
***REMOVED******REMOVED***let fields: [DisplayField]
***REMOVED******REMOVED***
***REMOVED******REMOVED***var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 0), count: 2)
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***LazyVGrid(columns: columns, spacing: 0) {
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(Array(fields.enumerated()), id: \.element) { index, element in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***GridCell(label: element.label, rowIndex: index)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***GridCell(label: element.formattedValue, rowIndex: index)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A view for dispaying text in a grid.
***REMOVED***struct GridCell: View {
***REMOVED******REMOVED******REMOVED***/ The String to display.
***REMOVED******REMOVED***let label: String
***REMOVED******REMOVED******REMOVED***/ The index of the row the view is in.
***REMOVED******REMOVED***let rowIndex: Int
***REMOVED******REMOVED******REMOVED***/ The URL off the label if the label is an "http" string.
***REMOVED******REMOVED***var url: URL? {
***REMOVED******REMOVED******REMOVED***label.lowercased().starts(with: "http") ? URL(string: label) : nil
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED******REMOVED*** Using a single space in place of an empty label allows the height
***REMOVED******REMOVED******REMOVED******REMOVED*** of an empty cell to be calculated the same as a non-empty cell.
***REMOVED******REMOVED******REMOVED***Text(url != nil ? "View" : (label.isEmpty ? " " : label))
***REMOVED******REMOVED******REMOVED******REMOVED***.underline(url != nil)
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor(url != nil ? Color(UIColor.link) : .primary)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(6)
***REMOVED******REMOVED******REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let url = url {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIApplication.shared.open(url)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.background(rowIndex % 2 != 1 ? Color.secondary.opacity(0.5) : Color.clear)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A convenience type for displaying labels and values in a grid.
***REMOVED***struct DisplayField: Hashable {
***REMOVED******REMOVED***let label: String
***REMOVED******REMOVED***let formattedValue: String
***REMOVED***
***REMOVED***
