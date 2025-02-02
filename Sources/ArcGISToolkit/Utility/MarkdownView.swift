// Copyright 2024 Esri
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

internal import Markdown

/// Rendered Markdown text content.
///
/// Supports the following Markdown tags:
///  - Code Block
///  - Emphasis
///  - Heading
///  - Horizontal Rule
///  - Image
///  - Inline Code
///  - Link
///  - Ordered List
///  - Strikethrough
///  - Unordered List
struct MarkdownView: View {
    let markdown: String
    
    var body: some View {
        let document = Document(parsing: markdown)
        var visitor = Visitor()
        let content = visitor.visitDocument(document)
        VStack { content.resolve() }
    }
}

enum MarkdownResult {
    case other(AnyView)
    case text(SwiftUI.Text)
    
    var text: SwiftUI.Text? {
        switch self {
        case .other(_):
            return nil
        case .text(let text):
            return text
        }
    }
    
    func resolve() -> AnyView {
        switch self {
        case .text(let text):
            return AnyView(text)
        case .other(let view):
            return view
        }
    }
}

struct Visitor: MarkupVisitor {
    typealias Result = MarkdownResult
    
    static let listIndentation: CGFloat = 10
    
    mutating func defaultVisit(_ markup: any Markdown.Markup) -> Result {
        visit(markup)
    }
    
    mutating func visitChildren(_ children: MarkupChildren) -> Result {
        var results = [Result]()
        var combinedText = SwiftUI.Text(verbatim: "")
        var isPureText = false
        var containsBreak = false
        children.forEach {
            let child = visit($0)
            if let text = child.text {
                combinedText = combinedText + text
                isPureText = true
            } else {
                containsBreak = true
                if isPureText {
                    results.append(.text(combinedText))
                }
                combinedText = SwiftUI.Text(verbatim: "")
                isPureText = false
                results.append(child)
            }
        }
        if isPureText && !containsBreak {
            return .text(combinedText)
        } else {
            results.append(.text(combinedText))
        }
        return .other(
            AnyView(
                VStack(alignment: .leading) {
                    ForEach(results.indices, id: \.self) { index in
                        results[index].resolve()
                    }
                }
            )
        )
    }
    
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> Result {
        var attributedString = AttributedString(codeBlock.code.dropLast())
        attributedString.font = Font.system(.body).monospaced()
        return .other(
            AnyView (
                SwiftUI.Text(attributedString)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.codeBackground)
            )
        )
    }
    
    mutating func visitDocument(_ document: Document) -> Result {
        visitChildren(document.children)
    }
    
    mutating func visitEmphasis(_ emphasis: Emphasis) -> Result {
        let children = visitChildren(emphasis.children)
        if let text = children.text {
            return .text(text.italic())
        } else {
            return children
        }
    }
    
    mutating func visitHeading(_ heading: Heading) -> Result {
        let children = visitChildren(heading.children)
        if let text = children.text {
            return .other(
                AnyView(text.font(Font.fontForHeading(level: heading.level)).padding(.bottom))
            )
        } else {
            return children
        }
    }
    
    mutating func visitImage(_ image: Markdown.Image) -> MarkdownResult {
        if let source = image.source, let url = URL(string: source) {
            return .other(
                AnyView(
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        SwiftUI.Text(image.plainText)
                    }
                )
            )
        } else {
            return .text(SwiftUI.Text(image.plainText))
        }
    }
    
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> Result {
        var attributedString = AttributedString(inlineCode.code)
        attributedString.font = Font.system(.body).monospaced()
        attributedString.backgroundColor = Color.codeBackground
        return .text(SwiftUI.Text(attributedString))
    }
    
    mutating func visitLineBreak(_ lineBreak: LineBreak) -> Result {
        .text(SwiftUI.Text(verbatim: "\n"))
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> Result {
        visitChildren(link.children)
    }
    
    mutating func visitListItem(_ listItem: ListItem) -> Result {
        visitChildren(listItem.children)
    }
    
    mutating func visitOrderedList(_ orderedList: OrderedList) -> Result {
        var results = [Result]()
        orderedList.listItems.forEach { listItem in
            let result = visit(listItem)
            results.append(result)
        }
        return .other(
            AnyView(
                ForEach(results.indices, id: \.self) { index in
                    HStack(alignment: .firstTextBaseline) {
                        Text((index + 1).description) + Text(verbatim: ".")
                        results[index].resolve()
                    }
                    .padding(
                        .leading,
                        CGFloat(orderedList.depth + 1) * Visitor.listIndentation
                    )
                }
            )
        )
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        let children = visitChildren(paragraph.children)
        if let text = children.text {
            if paragraph.isInList {
                return .text(text)
            } else {
                return .text(text + SwiftUI.Text(verbatim: "\n"))
            }
        } else {
            return children
        }
    }
    
    /// - Note: Because all Markup elements are rendered into a `VStack` there's no need to insert an
    /// additional line break.
    mutating func visitSoftBreak(_ softBreak: SoftBreak) -> MarkdownResult {
        .other(AnyView(EmptyView()))
    }
    
    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> Result {
        let children = visitChildren(strikethrough.children)
        if let text = children.text {
            return .text(text.strikethrough())
        } else {
            return children
        }
    }
    
    mutating func visitStrong(_ strong: Strong) -> Result {
        let children = visitChildren(strong.children)
        if let text = children.text {
            return .text(text.bold())
        } else {
            return children
        }
    }
    
    mutating func visitText(_ text: Markdown.Text) -> Result {
        if let link = text.linkAncestor, let destination = link.destination {
            return .other(AnyView(Link(text.plainText, destination: URL(string: destination)!)))
        } else {
            return .text(SwiftUI.Text(text.plainText))
        }
    }
    
    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> Result {
        .other(AnyView(Divider()))
    }
    
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> Result {
        var results = [Result]()
        unorderedList.listItems.forEach { listItem in
            let result = visit(listItem)
            results.append(result)
        }
        return .other(
            AnyView(
                ForEach(results.indices, id: \.self) { index in
                    HStack(alignment: .firstTextBaseline) {
                        Group {
                            switch unorderedList.depth {
                            case 0:
                                Circle()
                            case 1:
                                Circle().stroke()
                            case 2:
                                Rectangle()
                            default:
                                Rectangle().stroke()
                            }
                        }
                        .frame(width: 8, height: 8)
                        results[index].resolve()
                    }
                    .padding(
                        .leading,
                        CGFloat(unorderedList.depth + 1) * Visitor.listIndentation
                    )
                }
            )
        )
    }
}

private extension Color {
    static var codeBackground: Self {
        .gray.opacity(0.5)
    }
}

private extension Font {
    static func fontForHeading(level: Int) -> Self {
        switch level {
        case 1: .largeTitle.bold()
        case 2: .title.bold()
        case 3: .title2.bold()
        case 4: .title3.bold()
        case 5: .headline.bold()
        case 6: .subheadline.bold()
        default: .body
        }
    }
}

private extension ListItemContainer {
    var depth: Int {
        var index = 0
        var current = parent
        while current != nil {
            if current is ListItemContainer {
                index += 1
            }
            current = current?.parent
        }
        return index
    }
}

private extension Markdown.Text {
    var linkAncestor: Markdown.Link? {
        var current: Markup? = self
        while current != nil {
            if let link = current as? Markdown.Link {
                return link
            } else {
                current = current?.parent
            }
        }
        return nil
    }
}

private extension Markup {
    var isInList: Bool {
        var current = parent
        while current != nil {
            if current is ListItemContainer {
                return true
            }
            current = current?.parent
        }
        return false
    }
}

extension Visitor {
    func visitUnsupportedElement(_ markup: Markup) -> Result {
        .other(AnyView(EmptyView()))
    }
    
    mutating func visitBlockDirective(_ blockDirective: BlockDirective) -> MarkdownResult {
        visitUnsupportedElement(blockDirective)
    }
    
    mutating func visitBlockQuote(_ blockQuote: BlockQuote) -> MarkdownResult {
        visitUnsupportedElement(blockQuote)
    }
    
    mutating func visitCustomBlock(_ customBlock: CustomBlock) -> MarkdownResult {
        visitUnsupportedElement(customBlock)
    }
    
    mutating func visitCustomInline(_ customInline: CustomInline) -> MarkdownResult {
        visitUnsupportedElement(customInline)
    }
    mutating func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) -> MarkdownResult {
        visitUnsupportedElement(doxygenParam)
    }
    
    mutating func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) -> MarkdownResult {
        visitUnsupportedElement(doxygenReturns)
    }
    
    mutating func visitHTMLBlock(_ html: HTMLBlock) -> MarkdownResult {
        visitUnsupportedElement(html)
    }
    
    mutating func visitInlineAttributes(_ attributes: InlineAttributes) -> MarkdownResult {
        visitUnsupportedElement(attributes)
    }
    
    mutating func visitInlineHTML(_ inlineHTML: InlineHTML) -> MarkdownResult {
        visitUnsupportedElement(inlineHTML)
    }
    
    mutating func visitSymbolLink(_ symbolLink: SymbolLink) -> MarkdownResult {
        visitUnsupportedElement(symbolLink)
    }
    
    mutating func visitTable(_ table: Markdown.Table) -> MarkdownResult {
        visitUnsupportedElement(table)
    }
    
    mutating func visitTableBody(_ tableBody: Markdown.Table.Body) -> MarkdownResult {
        visitUnsupportedElement(tableBody)
    }
    
    mutating func visitTableCell(_ tableCell: Markdown.Table.Cell) -> MarkdownResult {
        visitUnsupportedElement(tableCell)
    }
    
    mutating func visitTableHead(_ tableHead: Markdown.Table.Head) -> MarkdownResult {
        visitUnsupportedElement(tableHead)
    }
    
    mutating func visitTableRow(_ tableRow: Markdown.Table.Row) -> MarkdownResult {
        visitUnsupportedElement(tableRow)
    }
}

#Preview {
    ScrollView {
        MarkdownView(markdown: """
        *Emphasis*
        
        Soft\nBreak
        
        # Heading 1
        ## Heading 2
        ### Heading 3
        #### [Heading 4 as a ***~link~***](www.esri.com)
        ##### Heading 5
        ###### Heading 6
        
        ```
        func showCodeBlock() {
        
        }
        ```
        
        `Code`
        
        Sentence with `inline code`.
        
        [Link](https://www.esri.com)
        
        1. 1st item
        1. 2nd item
        1. 3rd item
           1. 4th item
              1. 5th item
              1. 6th item
        
        ~Strikethrough~
        
        ---
        
        **Bold with _italic_ and ~_italic_ strikethrough~.**
        
        - 1st item
        - 2nd item
        - 3rd item
          - 4th item
            - 5th item
            - 6th item
        
        ![Esri](https://www.esri.com/content/dam/esrisites/en-us/newsroom/media-relations/assets-and-guidelines/assets/b-roll-card-1.jpg)
        """
        )
    }
}
