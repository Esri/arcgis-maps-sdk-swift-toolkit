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
        VStack(alignment: .leading) {
            ForEach(Array(document.children), id: \.indexInParent) { markup in
                Text(stringFor(markup))
            }
        }
    }
    
    func stringFor(_ emphasis: Emphasis) -> AttributedString {
        var attributedString = stringFor(emphasis.children)
        if let currentFont = attributedString.font {
            attributedString.font = currentFont.italic()
        } else {
            attributedString.font = Font.system(.body).italic()
        }
        return attributedString
    }
    
    func stringFor(_ heading: Heading) -> AttributedString {
        var attributedString = AttributedString(heading.plainText)
        attributedString.font = Font.fontForHeading(level: heading.level)
        return attributedString
    }
    
    func stringFor(_ image: Markdown.Image) -> AttributedString {
        .init(image.plainText)
    }
    
    func stringFor(_ inlineCode: InlineCode) -> AttributedString {
        var attributedString = AttributedString(inlineCode.code)
        attributedString.font = Font.system(.body).monospaced()
        attributedString.backgroundColor = Color.codeBackground
        return attributedString
    }
    
    func stringFor(_ link: Markdown.Link) -> AttributedString {
        var attributedString = stringFor(link.children)
        attributedString.link = URL(string: link.destination ?? "")
        return attributedString
    }
    
    func stringFor(_ listItem: ListItem) -> AttributedString {
        let isInOrderedList = listItem.parent is OrderedList
        var output = AttributedString()
        listItem.children.forEach { child in
            if !(child is ListItemContainer) {
                if listItem.includeLineBreak {
                    output.append(AttributedString("\n"))
                }
                output.append(AttributedString(String(repeating: "\t", count: listItem.depth)))
                if isInOrderedList {
                    output.append(AttributedString("\(listItem.indexInParent + 1). "))
                } else {
                    switch listItem.depth {
                    case 0: output.append(AttributedString("•"))
                    case 1: output.append(AttributedString("⚬"))
                    default: output.append(AttributedString("▪︎︎"))
                    }
                }
                output.append(stringFor(listItem.children))
            }
        }
        return output
    }
    
    func stringFor(_ markup: Markup) -> AttributedString {
        switch markup {
        case let markup as Emphasis:
            stringFor(markup)
        case let markup as Heading:
            stringFor(markup)
        case let markup as Markdown.Image:
            stringFor(markup)
        case let markup as InlineCode:
            stringFor(markup)
        case let markup as Markdown.Link:
            stringFor(markup)
        case let markup as ListItem:
            stringFor(markup)
        case let markup as OrderedList:
            stringFor(markup)
        case let markup as Paragraph:
            stringFor(markup)
        case let markup as Strikethrough:
            stringFor(markup)
        case let markup as Strong:
            stringFor(markup)
        case let markup as Markdown.Text:
            stringFor(markup)
        case let markup as UnorderedList:
            stringFor(markup)
        default:
            AttributedString()
        }
    }
    
    func stringFor(_ markupChildren: MarkupChildren) -> AttributedString {
        var attributedString = AttributedString()
        markupChildren.forEach { markup in
            attributedString.append(stringFor(markup))
        }
        return attributedString
    }
    
    func stringFor(_ orderedList: OrderedList) -> AttributedString {
        stringFor(orderedList.children)
    }
    
    func stringFor(_ paragraph: Paragraph) -> AttributedString {
        stringFor(paragraph.children)
    }
    
    func stringFor(_ strikethrough: Strikethrough) -> AttributedString {
        var attributedString = stringFor(strikethrough.children)
        attributedString.strikethroughStyle = .single
        return attributedString
    }
    
    func stringFor(_ strong: Strong) -> AttributedString {
        var attributedString = stringFor(strong.children)
        if let currentFont = attributedString.font {
            attributedString.font = currentFont.bold()
        } else {
            attributedString.font = Font.system(.body).bold()
        }
        return attributedString
    }
    
    func stringFor(_ text: Markdown.Text) -> AttributedString {
        .init(text.string)
    }
    
    func stringFor(_ unorderedList: UnorderedList) -> AttributedString {
        stringFor(unorderedList.children)
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

private extension ListItem {
    var depth: Int {
        var current = parent
        while current != nil {
            if let container = current as? ListItemContainer {
                return container.depth
            }
            current = current?.parent
        }
        return 0
    }
    
    var includeLineBreak: Bool {
        (parent is OrderedList || parent is UnorderedList)
        && (indexInParent > 0 || depth > 0)
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
            current = current!.parent
        }
        return index
    }
}

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
    
    func visitText(_ text: Markdown.Text) -> MarkdownResult {
        .text(SwiftUI.Text(text.plainText))
    }
    
    mutating func defaultVisit(_ markup: any Markdown.Markup) -> MarkdownResult {
        visit(markup)
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
    }
    
    mutating func visitDocument(_ document: Document) -> MarkdownResult {
        visit(document.child(at: 0)!)
    }
    
    mutating func visitParagraph(_ paragraph: Paragraph) -> MarkdownResult {
        visit(paragraph.child(at: 0)!)
    mutating func visitStrong(_ strong: Strong) -> MarkdownResult {
        let children = visitChildren(strong.children)
        if let text = children.text {
            return .text(text.bold())
        } else {
            return children
        }
    }
    
    }
}

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
