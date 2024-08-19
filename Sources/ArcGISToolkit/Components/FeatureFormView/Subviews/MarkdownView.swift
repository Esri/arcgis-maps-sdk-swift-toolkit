***REMOVED*** Copyright 2024 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Markdown
***REMOVED***

struct MarkdownView: View {
***REMOVED***let markdown: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***makeDocumentView(Document(parsing: markdown))
***REMOVED***
***REMOVED***
***REMOVED***func makeDocumentView(_ document: Document) -> some View {
***REMOVED******REMOVED***Text(document.format())
***REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED***var walker = Walker()
***REMOVED******REMOVED******REMOVED******REMOVED***walker.visitDocument(document)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***struct Walker: MarkupWalker {
***REMOVED******REMOVED***func visitBlockQuote(_ blockQuote: BlockQuote) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitBlockDirective(_ blockDirective: BlockDirective) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitCodeBlock(_ codeBlock: CodeBlock) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitCustomBlock(_ customBlock: CustomBlock) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitCustomInline(_ customInline: CustomInline) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitEmphasis(_ emphasis: Emphasis) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitHeading(_ heading: Heading) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitHTMLBlock(_ html: HTMLBlock) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitImage(_ image: Markdown.Image) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitInlineAttributes(_ attributes: InlineAttributes) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitInlineCode(_ inlineCode: InlineCode) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitInlineHTML(_ inlineHTML: InlineHTML) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitLineBreak(_ lineBreak: LineBreak) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitLink(_ link: Markdown.Link) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitListItem(_ listItem: ListItem) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitOrderedList(_ orderedList: OrderedList) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***mutating func visitParagraph(_ paragraph: Paragraph) -> () {
***REMOVED******REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED******REMOVED******REMOVED***defaultVisit(paragraph)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitSoftBreak(_ softBreak: SoftBreak) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitStrikethrough(_ strikethrough: Strikethrough) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitStrong(_ strong: Strong) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitSymbolLink(_ symbolLink: SymbolLink) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitTable(_ table: Markdown.Table) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitTableBody(_ tableBody: Markdown.Table.Body) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitTableCell(_ tableCell: Markdown.Table.Cell) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitTableHead(_ tableHead: Markdown.Table.Head) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitTableRow(_ tableRow: Markdown.Table.Row) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitText(_ text: Markdown.Text) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitThematicBreak(_ thematicBreak: ThematicBreak) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func visitUnorderedList(_ unorderedList: UnorderedList) -> () {
***REMOVED******REMOVED******REMOVED***print(#function)
***REMOVED***
***REMOVED***
***REMOVED***
