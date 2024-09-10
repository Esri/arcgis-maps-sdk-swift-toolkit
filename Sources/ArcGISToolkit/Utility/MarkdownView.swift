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
///  - Emphasis
///  - Heading
///  - Inline code
///  - Links
///  - Ordered lists
///  - Strikethrough
///  - Unordered lists
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
    
    mutating func defaultVisit(_ markup: any Markdown.Markup) -> Result {
        visit(markup)
    }
    
    mutating func visitChildren(_ children: MarkupChildren) -> Result {
        var results = [Result]()
        var combinedText = SwiftUI.Text("")
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
                combinedText = SwiftUI.Text("")
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
    
    mutating func visitCodeBlock(_ codeBlock: CodeBlock) -> MarkdownResult {
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
    
    mutating func visitEmphasis(_ emphasis: Emphasis) -> MarkdownResult {
        let children = visitChildren(emphasis.children)
        if let text = children.text {
            return .text(text.italic())
        } else {
            return children
        }
    }
    
    mutating func visitHeading(_ heading: Heading) -> MarkdownResult {
        let children = visitChildren(heading.children)
        if let text = children.text {
            return .other(
                AnyView(
                    (text + Text("\n")).font(Font.fontForHeading(level: heading.level))
                )
            )
        } else {
            return children
        }
    }
    
    mutating func visitInlineCode(_ inlineCode: InlineCode) -> MarkdownResult {
        var attributedString = AttributedString(inlineCode.code)
        attributedString.font = Font.system(.body).monospaced()
        attributedString.backgroundColor = Color.codeBackground
        return .text(SwiftUI.Text(attributedString))
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> MarkdownResult {
        visitChildren(link.children)
    }
    
    mutating func visitListItem(_ listItem: ListItem) -> MarkdownResult {
        visitChildren(listItem.children)
    }
    
    mutating func visitOrderedList(_ orderedList: OrderedList) -> MarkdownResult {
        var results = [Result]()
        orderedList.listItems.forEach { listItem in
            let result = visit(listItem)
            results.append(result)
        }
        return .other(
            AnyView(
                ForEach(results.indices, id: \.self) { index in
                    HStack(alignment: .firstTextBaseline) {
                        Text((index + 1).description) + Text(".")
                        results[index].resolve()
                    }
                    .padding(.leading, CGFloat((orderedList.depth + 1) * 20))
                }
            )
        )
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> Result {
        let children = visitChildren(paragraph.children)
        if let text = children.text {
            return .text(text + SwiftUI.Text("\n"))
        } else {
            return children
        }
    }
    
    mutating func visitStrikethrough(_ strikethrough: Strikethrough) -> MarkdownResult {
        let children = visitChildren(strikethrough.children)
        if let text = children.text {
            return .text(text.strikethrough())
        } else {
            return children
        }
    }
    
    mutating func visitStrong(_ strong: Strong) -> MarkdownResult {
        let children = visitChildren(strong.children)
        if let text = children.text {
            return .text(text.bold())
        } else {
            return children
        }
    }
    
    mutating func visitText(_ text: Markdown.Text) -> Result {
        if let link = text.linkAncestor {
            let wrappedLink = "[\(text.plainText)](\(link.destination ?? ""))"
            return .text(SwiftUI.Text(.init(wrappedLink)))
        } else {
            return .text(SwiftUI.Text(text.plainText))
        }
    }
    
    mutating func visitThematicBreak(_ thematicBreak: ThematicBreak) -> MarkdownResult {
        .other(AnyView(Divider()))
    }
    
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownResult {
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
                                Circle().fill(.clear).border(.black)
                            case 2:
                                Rectangle()
                            default:
                                Rectangle().fill(.clear).border(.black)
                            }
                        }
                        .frame(width: 8, height: 8)
                        results[index].resolve()
                    }
                    .padding(.leading, CGFloat((unorderedList.depth + 1) * 20))
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
        case 1: .largeTitle
        case 2: .title
        case 3: .title2
        case 4: .title3
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

#Preview {
    MarkdownView(markdown: """
    *Emphasis*
    
    # Heading 1
    ## Heading 2
    ### Heading 3
    #### [Heading 4 as a ***~link~***](www.esri.com)
    
    
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
    
    **Bold with _italic_ and ~_italic_ strikethrough~.**
    
    - 1st item
    - 2nd item
    - 3rd item
      - 4th item
        - 5th item
        - 6th item
    """
    )
}
