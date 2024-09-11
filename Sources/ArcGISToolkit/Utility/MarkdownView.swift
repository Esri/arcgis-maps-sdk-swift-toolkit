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
***REMOVED***/  - Code Block
***REMOVED***/  - Emphasis
***REMOVED***/  - Heading
***REMOVED***/***REMOVED***Horizontal Rule
***REMOVED***/  - Image
***REMOVED***/  - Inline Code
***REMOVED***/  - Link
***REMOVED***/  - Ordered List
***REMOVED***/  - Strikethrough
***REMOVED***/  - Unordered List
struct MarkdownView: View {
***REMOVED***let markdown: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***let document = Document(parsing: markdown)
***REMOVED******REMOVED***var visitor = Visitor()
***REMOVED******REMOVED***let content = visitor.visitDocument(document)
***REMOVED******REMOVED***VStack { content.resolve() ***REMOVED***
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
***REMOVED***static let listIndentation: CGFloat = 10
***REMOVED***
***REMOVED***mutating func defaultVisit(_ markup: any Markdown.Markup) -> Result {
***REMOVED******REMOVED***visit(markup)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitChildren(_ children: MarkupChildren) -> Result {
***REMOVED******REMOVED***var results = [Result]()
***REMOVED******REMOVED***var combinedText = SwiftUI.Text("")
***REMOVED******REMOVED***var isPureText = false
***REMOVED******REMOVED***var containsBreak = false
***REMOVED******REMOVED***children.forEach {
***REMOVED******REMOVED******REMOVED***let child = visit($0)
***REMOVED******REMOVED******REMOVED***if let text = child.text {
***REMOVED******REMOVED******REMOVED******REMOVED***combinedText = combinedText + text
***REMOVED******REMOVED******REMOVED******REMOVED***isPureText = true
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***containsBreak = true
***REMOVED******REMOVED******REMOVED******REMOVED***if isPureText {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***results.append(.text(combinedText))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***combinedText = SwiftUI.Text("")
***REMOVED******REMOVED******REMOVED******REMOVED***isPureText = false
***REMOVED******REMOVED******REMOVED******REMOVED***results.append(child)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***if isPureText && !containsBreak {
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
***REMOVED***mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
***REMOVED******REMOVED***var attributedString = AttributedString(codeBlock.code.dropLast())
***REMOVED******REMOVED***attributedString.font = Font.system(.body).monospaced()
***REMOVED******REMOVED***return .other(
***REMOVED******REMOVED******REMOVED***AnyView (
***REMOVED******REMOVED******REMOVED******REMOVED***SwiftUI.Text(attributedString)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.background(Color.codeBackground)
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitDocument(_ document: Document) -> Result {
***REMOVED******REMOVED***visitChildren(document.children)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
***REMOVED******REMOVED***let children = visitChildren(emphasis.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .text(text.italic())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitHeading(_ heading: Heading) -> Result {
***REMOVED******REMOVED***let children = visitChildren(heading.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .other(
***REMOVED******REMOVED******REMOVED******REMOVED***AnyView(text.font(Font.fontForHeading(level: heading.level)).padding(.bottom))
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitImage(_ image: Markdown.Image) -> MarkdownResult {
***REMOVED******REMOVED***if let source = image.source, let url = URL(string: source) {
***REMOVED******REMOVED******REMOVED***return .other(
***REMOVED******REMOVED******REMOVED******REMOVED***AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***AsyncImage(url: url) { image in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***image
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.scaledToFit()
***REMOVED******REMOVED******REMOVED******REMOVED*** placeholder: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***SwiftUI.Text(image.plainText)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .text(SwiftUI.Text(image.plainText))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
***REMOVED******REMOVED***var attributedString = AttributedString(inlineCode.code)
***REMOVED******REMOVED***attributedString.font = Font.system(.body).monospaced()
***REMOVED******REMOVED***attributedString.backgroundColor = Color.codeBackground
***REMOVED******REMOVED***return .text(SwiftUI.Text(attributedString))
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitLineBreak(_ lineBreak: LineBreak) -> Result {
***REMOVED******REMOVED***.text(SwiftUI.Text("\n"))
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitLink(_ link: Markdown.Link) -> Result {
***REMOVED******REMOVED***visitChildren(link.children)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitListItem(_ listItem: ListItem) -> Result {
***REMOVED******REMOVED***visitChildren(listItem.children)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
***REMOVED******REMOVED***var results = [Result]()
***REMOVED******REMOVED***orderedList.listItems.forEach { listItem in
***REMOVED******REMOVED******REMOVED***let result = visit(listItem)
***REMOVED******REMOVED******REMOVED***results.append(result)
***REMOVED***
***REMOVED******REMOVED***return .other(
***REMOVED******REMOVED******REMOVED***AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(results.indices, id: \.self) { index in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .firstTextBaseline) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text((index + 1).description) + Text(".")
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***results[index].resolve()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CGFloat(orderedList.depth + 1) * Visitor.listIndentation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
***REMOVED******REMOVED***let children = visitChildren(paragraph.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***if paragraph.isInList {
***REMOVED******REMOVED******REMOVED******REMOVED***return .text(text)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***return .text(text + SwiftUI.Text("\n"))
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
***REMOVED******REMOVED***let children = visitChildren(strikethrough.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .text(text.strikethrough())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitStrong(_ strong: Strong) -> Result {
***REMOVED******REMOVED***let children = visitChildren(strong.children)
***REMOVED******REMOVED***if let text = children.text {
***REMOVED******REMOVED******REMOVED***return .text(text.bold())
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return children
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitText(_ text: Markdown.Text) -> Result {
***REMOVED******REMOVED***if let link = text.linkAncestor {
***REMOVED******REMOVED******REMOVED***let wrappedLink = "[\(text.plainText)](\(link.destination ?? ""))"
***REMOVED******REMOVED******REMOVED***return .text(SwiftUI.Text(.init(wrappedLink)))
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .text(SwiftUI.Text(text.plainText))
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> Result {
***REMOVED******REMOVED***.other(AnyView(Divider()))
***REMOVED***
***REMOVED***
***REMOVED***mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
***REMOVED******REMOVED***var results = [Result]()
***REMOVED******REMOVED***unorderedList.listItems.forEach { listItem in
***REMOVED******REMOVED******REMOVED***let result = visit(listItem)
***REMOVED******REMOVED******REMOVED***results.append(result)
***REMOVED***
***REMOVED******REMOVED***return .other(
***REMOVED******REMOVED******REMOVED***AnyView(
***REMOVED******REMOVED******REMOVED******REMOVED***ForEach(results.indices, id: \.self) { index in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***HStack(alignment: .firstTextBaseline) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***switch unorderedList.depth {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case 0:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Circle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case 1:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Circle().stroke()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***case 2:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Rectangle().stroke()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.frame(width: 8, height: 8)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***results[index].resolve()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.leading,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***CGFloat(unorderedList.depth + 1) * Visitor.listIndentation
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
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

private extension ListItemContainer {
***REMOVED***var depth: Int {
***REMOVED******REMOVED***var index = 0
***REMOVED******REMOVED***var current = parent
***REMOVED******REMOVED***while current != nil {
***REMOVED******REMOVED******REMOVED***if current is ListItemContainer {
***REMOVED******REMOVED******REMOVED******REMOVED***index += 1
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***current = current?.parent
***REMOVED***
***REMOVED******REMOVED***return index
***REMOVED***
***REMOVED***

private extension Markdown.Text {
***REMOVED***var linkAncestor: Markdown.Link? {
***REMOVED******REMOVED***var current: Markup? = self
***REMOVED******REMOVED***while current != nil {
***REMOVED******REMOVED******REMOVED***if let link = current as? Markdown.Link {
***REMOVED******REMOVED******REMOVED******REMOVED***return link
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***current = current?.parent
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED***

private extension Markup {
***REMOVED***var isInList: Bool {
***REMOVED******REMOVED***var current = parent
***REMOVED******REMOVED***while current != nil {
***REMOVED******REMOVED******REMOVED***if current is ListItemContainer {
***REMOVED******REMOVED******REMOVED******REMOVED***return true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***current = current?.parent
***REMOVED***
***REMOVED******REMOVED***return false
***REMOVED***
***REMOVED***

#Preview {
***REMOVED***ScrollView {
***REMOVED******REMOVED***MarkdownView(markdown: """
***REMOVED******REMOVED****Emphasis*
***REMOVED******REMOVED***
***REMOVED******REMOVED***# Heading 1
***REMOVED******REMOVED***## Heading 2
***REMOVED******REMOVED***### Heading 3
***REMOVED******REMOVED***#### [Heading 4 as a ***~link~***](www.esri.com)
***REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***```
***REMOVED******REMOVED***func showCodeBlock() {
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***```
***REMOVED******REMOVED***
***REMOVED******REMOVED***`Code`
***REMOVED******REMOVED***
***REMOVED******REMOVED***Sentence with `inline code`.
***REMOVED******REMOVED***
***REMOVED******REMOVED***[Link](https:***REMOVED***www.esri.com)
***REMOVED******REMOVED***
***REMOVED******REMOVED***1. 1st item
***REMOVED******REMOVED***1. 2nd item
***REMOVED******REMOVED***1. 3rd item
***REMOVED******REMOVED***   1. 4th item
***REMOVED******REMOVED******REMOVED***  1. 5th item
***REMOVED******REMOVED******REMOVED***  1. 6th item
***REMOVED******REMOVED***
***REMOVED******REMOVED***~Strikethrough~
***REMOVED******REMOVED***
***REMOVED******REMOVED*****Bold with _italic_ and ~_italic_ strikethrough~.**
***REMOVED******REMOVED***
***REMOVED******REMOVED***- 1st item
***REMOVED******REMOVED***- 2nd item
***REMOVED******REMOVED***- 3rd item
***REMOVED******REMOVED***  - 4th item
***REMOVED******REMOVED******REMOVED***- 5th item
***REMOVED******REMOVED******REMOVED***- 6th item
***REMOVED******REMOVED***
***REMOVED******REMOVED***![Esri](https:***REMOVED***www.esri.com/content/dam/esrisites/en-us/newsroom/media-relations/assets-and-guidelines/assets/b-roll-card-1.jpg)
***REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
