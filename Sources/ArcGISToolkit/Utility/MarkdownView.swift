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

***REMOVED***

internal import Markdown

***REMOVED***/ Rendered Markdown text content.
***REMOVED***/
***REMOVED***/ Supports the following Markdown tags:
***REMOVED***/  - Emphasis
***REMOVED***/  - Heading
***REMOVED***/  - Inline code
***REMOVED***/  - Links
***REMOVED***/  - Ordered lists
***REMOVED***/  - Strikethrough
***REMOVED***/  - Unordered lists
struct MarkdownView: View {
***REMOVED***let markdown: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***let document = Document(parsing: markdown)
***REMOVED******REMOVED***var visitor = Visitor()
***REMOVED******REMOVED***let content = visitor.visitDocument(document)
***REMOVED******REMOVED***content.resolve()
***REMOVED***
***REMOVED***

enum MarkdownResult {
***REMOVED***case other(AnyView)
***REMOVED***case text(SwiftUI.Text)
***REMOVED***
***REMOVED***var text: SwiftUI.Text? {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .other(_):
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED******REMOVED***case .text(let text):
***REMOVED******REMOVED******REMOVED***return text
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func resolve() -> AnyView {
***REMOVED******REMOVED***switch self {
***REMOVED******REMOVED***case .text(let text):
***REMOVED******REMOVED******REMOVED***return AnyView(text)
***REMOVED******REMOVED***case .other(let view):
***REMOVED******REMOVED******REMOVED***return view
***REMOVED***
***REMOVED***
***REMOVED***

struct Visitor: MarkupVisitor {
***REMOVED***typealias Result = MarkdownResult
***REMOVED***
***REMOVED***mutating func defaultVisit(_ markup: any Markdown.Markup) -> Result {
***REMOVED******REMOVED***visit(markup)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitChildren(_ children: MarkupChildren) -> Result {
***REMOVED******REMOVED***var results = [Result]()
***REMOVED******REMOVED***var combinedText = SwiftUI.Text("")
***REMOVED******REMOVED***var isContinuousText = true
***REMOVED******REMOVED***var containsBreak = false
***REMOVED******REMOVED***children.forEach {
***REMOVED******REMOVED******REMOVED***let child = visit($0)
***REMOVED******REMOVED******REMOVED***if let text = child.text {
***REMOVED******REMOVED******REMOVED******REMOVED***combinedText = combinedText + text
***REMOVED******REMOVED******REMOVED******REMOVED***isContinuousText = true
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***isContinuousText = false
***REMOVED******REMOVED******REMOVED******REMOVED***if isContinuousText {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***results.append(.text(combinedText))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***combinedText = SwiftUI.Text("")
***REMOVED******REMOVED******REMOVED******REMOVED***results.append(child)
***REMOVED******REMOVED******REMOVED******REMOVED***containsBreak = true
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***if isContinuousText && !containsBreak {
***REMOVED******REMOVED******REMOVED***return .text(combinedText)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***results.append(.text(combinedText))
***REMOVED***
***REMOVED******REMOVED***return .other(
***REMOVED******REMOVED******REMOVED***AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED***VStack(alignment: .leading) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***ForEach(results.indices, id: \.self) { index in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***results[index].resolve()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownResult {
***REMOVED******REMOVED***visitChildren(codeBlock.children)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitDocument(_ document: Document) -> Result {
***REMOVED******REMOVED***visitChildren(document.children)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitEmphasis(_ emphasis: Emphasis) -> MarkdownResult {
***REMOVED******REMOVED***let children = visitChildren(emphasis.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .text(text.italic())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitHeading(_ heading: Heading) -> MarkdownResult {
***REMOVED******REMOVED***let children = visitChildren(heading.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .other(
***REMOVED******REMOVED******REMOVED******REMOVED***AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***(text + Text("\n")).font(Font.fontForHeading(level: heading.level))
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitInlineCode(_ inlineCode: InlineCode) -> MarkdownResult {
***REMOVED******REMOVED***.text(Text("\(#function)"))
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitLink(_ link: Markdown.Link) -> MarkdownResult {
***REMOVED******REMOVED***if let destination = link.destination, let url = URL(string: destination) {
***REMOVED******REMOVED******REMOVED***.other(
***REMOVED******REMOVED******REMOVED******REMOVED***AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Link(destination: url) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AnyView(visitChildren(link.children).resolve())
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***.other(AnyView(visitChildren(link.children).resolve()))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitOrderedList(_ orderedList: OrderedList) -> MarkdownResult {
***REMOVED******REMOVED***.text(Text("\(#function)"))
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
***REMOVED******REMOVED***let children = visitChildren(paragraph.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .text(text + SwiftUI.Text("\n"))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> MarkdownResult {
***REMOVED******REMOVED***let children = visitChildren(strikethrough.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .text(text.strikethrough())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitStrong(_ strong: Strong) -> MarkdownResult {
***REMOVED******REMOVED***let children = visitChildren(strong.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .text(text.bold())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitText(_ text: Markdown.Text) -> Result {
***REMOVED******REMOVED***.text(SwiftUI.Text(text.plainText))
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownResult {
***REMOVED******REMOVED***.text(Text("\(#function)"))
***REMOVED***
***REMOVED***

***REMOVED***private extension Color {
***REMOVED******REMOVED***static var codeBackground: Self {
***REMOVED******REMOVED******REMOVED***.gray.opacity(0.5)
***REMOVED******REMOVED***
***REMOVED******REMOVED***

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

***REMOVED***private extension ListItem {
***REMOVED******REMOVED***var depth: Int {
***REMOVED******REMOVED******REMOVED***var current = parent
***REMOVED******REMOVED******REMOVED***while current != nil {
***REMOVED******REMOVED******REMOVED******REMOVED***if let container = current as? ListItemContainer {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return container.depth
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***current = current?.parent
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return 0
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var includeLineBreak: Bool {
***REMOVED******REMOVED******REMOVED***(parent is OrderedList || parent is UnorderedList)
***REMOVED******REMOVED******REMOVED***&& (indexInParent > 0 || depth > 0)
***REMOVED******REMOVED***
***REMOVED******REMOVED***

***REMOVED***private extension ListItemContainer {
***REMOVED******REMOVED***var depth: Int {
***REMOVED******REMOVED******REMOVED***var index = 0
***REMOVED******REMOVED******REMOVED***var current = parent
***REMOVED******REMOVED******REMOVED***while current != nil {
***REMOVED******REMOVED******REMOVED******REMOVED***if current is ListItemContainer {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***index += 1
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***current = current!.parent
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return index
***REMOVED******REMOVED***
***REMOVED******REMOVED***

#Preview {
***REMOVED***MarkdownView(markdown: """
***REMOVED****Emphasis*
***REMOVED***
***REMOVED***# Heading 1
***REMOVED***## Heading 2
***REMOVED***### Heading 3
***REMOVED***
***REMOVED***`Inline code`
***REMOVED***
***REMOVED***[Link](https:***REMOVED***www.esri.com)
***REMOVED***
***REMOVED***1. 1st item
***REMOVED***1. 2nd item
***REMOVED***1. 3rd item
***REMOVED***   1. 4th item
***REMOVED******REMOVED***  1. 5th item
***REMOVED******REMOVED***  1. 6th item
***REMOVED***
***REMOVED***~Strikethrough~
***REMOVED***
***REMOVED*****Bold with _italic_ and ~_italic_ strikethrough~.**
***REMOVED***
***REMOVED***- 1st item
***REMOVED***- 2nd item
***REMOVED***- 3rd item
***REMOVED***  - 4th item
***REMOVED******REMOVED***- 5th item
***REMOVED******REMOVED***- 6th item
***REMOVED***"""
***REMOVED***)
***REMOVED***
