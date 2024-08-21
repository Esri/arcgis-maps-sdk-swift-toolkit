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

import Markdown
import SwiftUI

struct MarkdownView: View {
    let markdown: String
    
    let listIndentation = 15.0
    
    var body: some View {
        let document = Document(parsing: markdown)
        VStack(alignment: .leading) {
            ForEach(Array(document.children), id: \.indexInParent) {
                viewFor($0)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func viewFor(_ markup: Markup) -> some View {
        switch markup {
        case let markup as CodeBlock:
            AnyView(viewFor(markup))
        case let markup as Heading:
            AnyView(viewFor(markup))
        case let markup as InlineCode:
            AnyView(viewFor(markup))
        case let markup as Emphasis:
            AnyView(viewFor(markup))
        case let markup as Markdown.Link:
            AnyView(viewFor(markup))
        case let markup as ListItem:
            AnyView(viewFor(markup))
        case let markup as OrderedList:
            AnyView(viewFor(markup))
        case let markup as UnorderedList:
            AnyView(viewFor(markup))
        case let markup as Paragraph:
            AnyView(viewFor(markup))
        case let markup as Strong:
            AnyView(viewFor(markup))
        case let markup as Strikethrough:
            AnyView(viewFor(markup))
        case let markup as Markdown.Text:
            AnyView(viewFor(markup))
        case let markup as Markdown.ThematicBreak:
            AnyView(viewFor(markup))
        default:
            AnyView(unsupportedViewFor(markup))
        }
    }
    
    func unsupportedViewFor(_ markup: Markup) -> some View {
        Text("\(type(of: markup))")
            .foregroundStyle(.red)
    }
    
    func viewFor(_ thematicBreak: ThematicBreak) -> some View {
        Divider()
    }
    
    func viewFor(_ markupChildren: MarkupChildren) -> some View {
        ForEach(Array(markupChildren), id: \.indexInParent) {
            viewFor($0)
        }
    }
    
    func viewFor(_ codeBlock: CodeBlock) -> some View {
        Text(codeBlock.codeDroppingTrailingNewline)
            .codeStyle()
    }
    
    func viewFor(_ emphasis: Emphasis) -> some View {
        viewFor(emphasis.children)
            .italic()
    }
    
    func viewFor(_ heading: Heading) -> some View {
        Text(heading.plainText)
            .font(fontForHeading(level: heading.level))
    }
    
    func viewFor(_ inlineCode: InlineCode) -> some View {
        Text(inlineCode.code)
            .codeStyle()
    }
    
    func viewFor(_ link: Markdown.Link) -> some View {
        Text("[\(link.plainText)](\(link.destination!))")
    }
    
    @ViewBuilder
    func viewFor(_ listItem: ListItem) -> some View {
        let ordered = listItem.parent is OrderedList
        ForEach(Array(listItem.children), id: \.indexInParent) { child in
            if child is ListItemContainer {
                viewFor(child)
            } else {
                HStack {
                    if ordered {
                        Text(listItem.indexInParent + 1, format: .number) + Text(".")
                    } else {
                        Text("*")
                    }
                    viewFor(child)
                }
            }
        }
    }
    
    func viewFor(_ orderedList: OrderedList) -> some View {
        viewFor(orderedList.children)
            .padding(.leading, CGFloat(orderedList.depth) * listIndentation)
    }
    
    func viewFor(_ strikethrough: Strikethrough) -> some View {
        viewFor(strikethrough.children)
            .strikethrough()
    }
    
    func viewFor(_ strong: Strong) -> some View {
        viewFor(strong.children)
            .bold()
    }
    
    func viewFor(_ text: Markdown.Text) -> some View {
        Text(text.string)
    }
    
    func viewFor(_ unorderedList: UnorderedList) -> some View {
        viewFor(unorderedList.children)
            .padding(.leading, CGFloat(unorderedList.depth) * listIndentation)
    }
    
    @ViewBuilder
    func viewFor(_ paragraph: Paragraph) -> some View {
        ForEach(Array(paragraph.children), id: \.indexInParent) {
            viewFor($0)
        }
    }
}

private extension View {
    func fontForHeading(level: Int) -> Font {
        switch level {
        case 1: .largeTitle
        case 2: .title
        case 3: .title2
        case 4: .title3
        default: .body
        }
    }
}

private extension Markdown.CodeBlock {
    var codeDroppingTrailingNewline: String {
        var copy = code
        copy.removeLast()
        return copy
    }
}

private extension SwiftUI.Text {
    func codeStyle() -> some View {
        modifier(CodeStyle())
    }
}

private struct CodeStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .monospaced()
            .background(.tertiary)
    }
}
        }
    }
}
