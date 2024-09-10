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
        content.resolve()
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
        var isContinuousText = true
        var containsBreak = false
        children.forEach {
            let child = visit($0)
            if let text = child.text {
                combinedText = combinedText + text
                isContinuousText = true
            } else {
                isContinuousText = false
                if isContinuousText {
                    results.append(.text(combinedText))
                }
                combinedText = SwiftUI.Text("")
                results.append(child)
                containsBreak = true
            }
        }
        if isContinuousText && !containsBreak {
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
        visitChildren(codeBlock.children)
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
        .text(Text("\(#function)"))
    }
    
    mutating func visitLink(_ link: Markdown.Link) -> MarkdownResult {
        if let destination = link.destination, let url = URL(string: destination) {
            .other(
                AnyView(
                    Link(destination: url) {
                        AnyView(visitChildren(link.children).resolve())
                    }
                )
            )
        } else {
            .other(AnyView(visitChildren(link.children).resolve()))
        }
    }
    
    mutating func visitOrderedList(_ orderedList: OrderedList) -> MarkdownResult {
        .text(Text("\(#function)"))
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
        .text(SwiftUI.Text(text.plainText))
    }
    
    mutating func visitUnorderedList(_ unorderedList: UnorderedList) -> MarkdownResult {
        .text(Text("\(#function)"))
    }
}

//private extension Color {
//    static var codeBackground: Self {
//        .gray.opacity(0.5)
//    }
//}

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

//private extension ListItem {
//    var depth: Int {
//        var current = parent
//        while current != nil {
//            if let container = current as? ListItemContainer {
//                return container.depth
//            }
//            current = current?.parent
//        }
//        return 0
//    }
//    
//    var includeLineBreak: Bool {
//        (parent is OrderedList || parent is UnorderedList)
//        && (indexInParent > 0 || depth > 0)
//    }
//}

//private extension ListItemContainer {
//    var depth: Int {
//        var index = 0
//        var current = parent
//        while current != nil {
//            if current is ListItemContainer {
//                index += 1
//            }
//            current = current!.parent
//        }
//        return index
//    }
//}

#Preview {
    MarkdownView(markdown: """
    *Emphasis*
    
    # Heading 1
    ## Heading 2
    ### Heading 3
    
    `Inline code`
    
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
