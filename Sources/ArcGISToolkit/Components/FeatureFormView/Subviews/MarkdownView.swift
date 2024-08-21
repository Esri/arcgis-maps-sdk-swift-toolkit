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
***REMOVED***let listIndentation = 15.0
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***let document = Document(parsing: markdown)
***REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED***ForEach(Array(document.children), id: \.indexInParent) {
***REMOVED******REMOVED******REMOVED******REMOVED***viewFor($0)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func viewFor(_ markup: Markup) -> some View {
***REMOVED******REMOVED***switch markup {
***REMOVED******REMOVED***case let markup as CodeBlock:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as Heading:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as InlineCode:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as Emphasis:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as Markdown.Link:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as ListItem:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as OrderedList:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as UnorderedList:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as Paragraph:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as Strong:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as Strikethrough:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as Markdown.Text:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***case let markup as Markdown.ThematicBreak:
***REMOVED******REMOVED******REMOVED***AnyView(viewFor(markup))
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***AnyView(unsupportedViewFor(markup))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func unsupportedViewFor(_ markup: Markup) -> some View {
***REMOVED******REMOVED***Text("\(type(of: markup))")
***REMOVED******REMOVED******REMOVED***.foregroundStyle(.red)
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ thematicBreak: ThematicBreak) -> some View {
***REMOVED******REMOVED***Divider()
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ markupChildren: MarkupChildren) -> some View {
***REMOVED******REMOVED***ForEach(Array(markupChildren), id: \.indexInParent) {
***REMOVED******REMOVED******REMOVED***viewFor($0)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ codeBlock: CodeBlock) -> some View {
***REMOVED******REMOVED***Text(codeBlock.codeDroppingTrailingNewline)
***REMOVED******REMOVED******REMOVED***.codeStyle()
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ emphasis: Emphasis) -> some View {
***REMOVED******REMOVED***viewFor(emphasis.children)
***REMOVED******REMOVED******REMOVED***.italic()
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ heading: Heading) -> some View {
***REMOVED******REMOVED***Text(heading.plainText)
***REMOVED******REMOVED******REMOVED***.font(fontForHeading(level: heading.level))
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ inlineCode: InlineCode) -> some View {
***REMOVED******REMOVED***Text(inlineCode.code)
***REMOVED******REMOVED******REMOVED***.codeStyle()
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ link: Markdown.Link) -> some View {
***REMOVED******REMOVED***Text("[\(link.plainText)](\(link.destination!))")
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func viewFor(_ listItem: ListItem) -> some View {
***REMOVED******REMOVED***let ordered = listItem.parent is OrderedList
***REMOVED******REMOVED***ForEach(Array(listItem.children), id: \.indexInParent) { child in
***REMOVED******REMOVED******REMOVED***if child is ListItemContainer {
***REMOVED******REMOVED******REMOVED******REMOVED***viewFor(child)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if ordered {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(listItem.indexInParent + 1, format: .number) + Text(".")
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text("*")
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***viewFor(child)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ orderedList: OrderedList) -> some View {
***REMOVED******REMOVED***viewFor(orderedList.children)
***REMOVED******REMOVED******REMOVED***.padding(.leading, CGFloat(orderedList.depth) * listIndentation)
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ strikethrough: Strikethrough) -> some View {
***REMOVED******REMOVED***viewFor(strikethrough.children)
***REMOVED******REMOVED******REMOVED***.strikethrough()
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ strong: Strong) -> some View {
***REMOVED******REMOVED***viewFor(strong.children)
***REMOVED******REMOVED******REMOVED***.bold()
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ text: Markdown.Text) -> some View {
***REMOVED******REMOVED***Text(text.string)
***REMOVED***
***REMOVED***
***REMOVED***func viewFor(_ unorderedList: UnorderedList) -> some View {
***REMOVED******REMOVED***viewFor(unorderedList.children)
***REMOVED******REMOVED******REMOVED***.padding(.leading, CGFloat(unorderedList.depth) * listIndentation)
***REMOVED***
***REMOVED***
***REMOVED***@ViewBuilder
***REMOVED***func viewFor(_ paragraph: Paragraph) -> some View {
***REMOVED******REMOVED***ForEach(Array(paragraph.children), id: \.indexInParent) {
***REMOVED******REMOVED******REMOVED***viewFor($0)
***REMOVED***
***REMOVED***
***REMOVED***

private extension View {
***REMOVED***func fontForHeading(level: Int) -> Font {
***REMOVED******REMOVED***switch level {
***REMOVED******REMOVED***case 1: .largeTitle
***REMOVED******REMOVED***case 2: .title
***REMOVED******REMOVED***case 3: .title2
***REMOVED******REMOVED***case 4: .title3
***REMOVED******REMOVED***default: .body
***REMOVED***
***REMOVED***
***REMOVED***

private extension Markdown.CodeBlock {
***REMOVED***var codeDroppingTrailingNewline: String {
***REMOVED******REMOVED***var copy = code
***REMOVED******REMOVED***copy.removeLast()
***REMOVED******REMOVED***return copy
***REMOVED***
***REMOVED***

private extension SwiftUI.Text {
***REMOVED***func codeStyle() -> some View {
***REMOVED******REMOVED***modifier(CodeStyle())
***REMOVED***
***REMOVED***

private struct CodeStyle: ViewModifier {
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.monospaced()
***REMOVED******REMOVED******REMOVED***.background(.tertiary)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
