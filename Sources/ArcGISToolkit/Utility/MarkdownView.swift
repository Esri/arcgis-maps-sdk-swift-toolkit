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

***REMOVED***/ Rendered Markdown text content.
***REMOVED***/
***REMOVED***/ Supports the following Markdown tags:
***REMOVED***/  - Inline code
***REMOVED***/  - Emphasis
***REMOVED***/  - Links
***REMOVED***/  - Ordered lists
***REMOVED***/  - Unordered lists
***REMOVED***/  - Strikethrough
struct MarkdownView: View {
***REMOVED***let markdown: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***let document = Document(parsing: markdown)
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***ForEach(Array(document.children), id: \.indexInParent) { markup in
***REMOVED******REMOVED******REMOVED******REMOVED***Text(stringFor(markup))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ emphasis: Emphasis) -> AttributedString {
***REMOVED******REMOVED***var attributedString = stringFor(emphasis.children)
***REMOVED******REMOVED***if let currentFont = attributedString.font {
***REMOVED******REMOVED******REMOVED***attributedString.font = currentFont.italic()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***attributedString.font = Font.system(.body).italic()
***REMOVED***
***REMOVED******REMOVED***return attributedString
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ heading: Heading) -> AttributedString {
***REMOVED******REMOVED***var attributedString = AttributedString(heading.plainText)
***REMOVED******REMOVED***attributedString.font = Font.fontForHeading(level: heading.level)
***REMOVED******REMOVED***return attributedString
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ image: Markdown.Image) -> AttributedString {
***REMOVED******REMOVED***.init(image.plainText)
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ inlineCode: InlineCode) -> AttributedString {
***REMOVED******REMOVED***var attributedString = AttributedString(inlineCode.code)
***REMOVED******REMOVED***attributedString.font = Font.system(.body).monospaced()
***REMOVED******REMOVED***attributedString.backgroundColor = Color.codeBackground
***REMOVED******REMOVED***return attributedString
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ link: Markdown.Link) -> AttributedString {
***REMOVED******REMOVED***var attributedString = stringFor(link.children)
***REMOVED******REMOVED***attributedString.link = URL(string: link.destination ?? "")
***REMOVED******REMOVED***return attributedString
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ listItem: ListItem) -> AttributedString {
***REMOVED******REMOVED***let isInOrderedList = listItem.parent is OrderedList
***REMOVED******REMOVED***var output = AttributedString()
***REMOVED******REMOVED***listItem.children.forEach { child in
***REMOVED******REMOVED******REMOVED***if child is ListItemContainer {
***REMOVED******REMOVED******REMOVED******REMOVED***()
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***output.append(AttributedString("\n"))
***REMOVED******REMOVED******REMOVED******REMOVED***output.append(AttributedString(String(repeating: "\t", count: listItem.depth)))
***REMOVED******REMOVED******REMOVED******REMOVED***if isInOrderedList {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***output.append(AttributedString("\(listItem.indexInParent + 1). "))
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch listItem.depth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case 0: output.append(AttributedString("•"))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case 1: output.append(AttributedString("⚬"))
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default: output.append(AttributedString("▪︎︎"))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***output.append(stringFor(listItem.children))
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***return output
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ markup: Markup) -> AttributedString {
***REMOVED******REMOVED***switch markup {
***REMOVED******REMOVED***case let markup as Emphasis:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as Heading:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as Markdown.Image:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as InlineCode:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as Markdown.Link:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as ListItem:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as OrderedList:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as Paragraph:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as Strikethrough:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as Strong:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as Markdown.Text:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***case let markup as UnorderedList:
***REMOVED******REMOVED******REMOVED***stringFor(markup)
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***AttributedString()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ markupChildren: MarkupChildren) -> AttributedString {
***REMOVED******REMOVED***var attributedString = AttributedString()
***REMOVED******REMOVED***markupChildren.forEach { markup in
***REMOVED******REMOVED******REMOVED***attributedString.append(stringFor(markup))
***REMOVED***
***REMOVED******REMOVED***return attributedString
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ orderedList: OrderedList) -> AttributedString {
***REMOVED******REMOVED***stringFor(orderedList.children)
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ paragraph: Paragraph) -> AttributedString {
***REMOVED******REMOVED***stringFor(paragraph.children)
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ strikethrough: Strikethrough) -> AttributedString {
***REMOVED******REMOVED***var attributedString = stringFor(strikethrough.children)
***REMOVED******REMOVED***attributedString.strikethroughStyle = .single
***REMOVED******REMOVED***return attributedString
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ strong: Strong) -> AttributedString {
***REMOVED******REMOVED***var attributedString = stringFor(strong.children)
***REMOVED******REMOVED***if let currentFont = attributedString.font {
***REMOVED******REMOVED******REMOVED***attributedString.font = currentFont.bold()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***attributedString.font = Font.system(.body).bold()
***REMOVED***
***REMOVED******REMOVED***return attributedString
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ text: Markdown.Text) -> AttributedString {
***REMOVED******REMOVED***.init(text.string)
***REMOVED***
***REMOVED***
***REMOVED***func stringFor(_ unorderedList: UnorderedList) -> AttributedString {
***REMOVED******REMOVED***stringFor(unorderedList.children)
***REMOVED***
***REMOVED***

private extension Color {
***REMOVED***static var codeBackground: Self {
***REMOVED******REMOVED***.gray.opacity(0.5)
***REMOVED***
***REMOVED***

private extension Font {
***REMOVED***static func fontForHeading(level: Int) -> Self {
***REMOVED******REMOVED***switch level {
***REMOVED******REMOVED***case 1: .largeTitle
***REMOVED******REMOVED***case 2: .title
***REMOVED******REMOVED***case 3: .title2
***REMOVED******REMOVED***case 4: .title3
***REMOVED******REMOVED***default: .body
***REMOVED***
***REMOVED***
***REMOVED***

private extension ListItem {
***REMOVED***var depth: Int {
***REMOVED******REMOVED***var current = parent
***REMOVED******REMOVED***while current != nil {
***REMOVED******REMOVED******REMOVED***if let container = current as? ListItemContainer {
***REMOVED******REMOVED******REMOVED******REMOVED***return container.depth
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***current = current?.parent
***REMOVED***
***REMOVED******REMOVED***return 0
***REMOVED***
***REMOVED***

private extension ListItemContainer {
***REMOVED***var depth: Int {
***REMOVED******REMOVED***var index = 0
***REMOVED******REMOVED***var current = parent
***REMOVED******REMOVED***while current != nil {
***REMOVED******REMOVED******REMOVED***if current is ListItemContainer {
***REMOVED******REMOVED******REMOVED******REMOVED***index += 1
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***current = current!.parent
***REMOVED***
***REMOVED******REMOVED***return index
***REMOVED***
***REMOVED***

***REMOVED***#Preview {
***REMOVED******REMOVED***ScrollView {
***REMOVED******REMOVED******REMOVED***MarkdownView(markdown: "This is `Markdown`")
***REMOVED******REMOVED***
***REMOVED******REMOVED***
