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
    
    var body: some View {
        makeDocumentView(Document(parsing: markdown))
    }
    
    func makeDocumentView(_ document: Document) -> some View {
        Text(document.format())
            .onAppear {
                var walker = Walker()
                walker.visitDocument(document)
            }
    }
    
    struct Walker: MarkupWalker {
        func visitBlockQuote(_ blockQuote: BlockQuote) -> () {
            print(#function)
        }
        
        func visitBlockDirective(_ blockDirective: BlockDirective) -> () {
            print(#function)
        }
        
        func visitCodeBlock(_ codeBlock: CodeBlock) -> () {
            print(#function)
        }
        
        func visitCustomBlock(_ customBlock: CustomBlock) -> () {
            print(#function)
        }
        
        func visitCustomInline(_ customInline: CustomInline) -> () {
            print(#function)
        }
        
        func visitDoxygenParameter(_ doxygenParam: DoxygenParameter) -> () {
            print(#function)
        }
        
        func visitDoxygenReturns(_ doxygenReturns: DoxygenReturns) -> () {
            print(#function)
        }
        
        func visitEmphasis(_ emphasis: Emphasis) -> () {
            print(#function)
        }
        
        func visitHeading(_ heading: Heading) -> () {
            print(#function)
        }
        
        func visitHTMLBlock(_ html: HTMLBlock) -> () {
            print(#function)
        }
        
        func visitImage(_ image: Markdown.Image) -> () {
            print(#function)
        }
        
        func visitInlineAttributes(_ attributes: InlineAttributes) -> () {
            print(#function)
        }
        
        func visitInlineCode(_ inlineCode: InlineCode) -> () {
            print(#function)
        }
        
        func visitInlineHTML(_ inlineHTML: InlineHTML) -> () {
            print(#function)
        }
        
        func visitLineBreak(_ lineBreak: LineBreak) -> () {
            print(#function)
        }
        
        func visitLink(_ link: Markdown.Link) -> () {
            print(#function)
        }
        
        func visitListItem(_ listItem: ListItem) -> () {
            print(#function)
        }
        
        func visitOrderedList(_ orderedList: OrderedList) -> () {
            print(#function)
        }
        
        mutating func visitParagraph(_ paragraph: Paragraph) -> () {
//            print(#function)
            defaultVisit(paragraph)
        }
        
        func visitSoftBreak(_ softBreak: SoftBreak) -> () {
            print(#function)
        }
        
        func visitStrikethrough(_ strikethrough: Strikethrough) -> () {
            print(#function)
        }
        
        func visitStrong(_ strong: Strong) -> () {
            print(#function)
        }
        
        func visitSymbolLink(_ symbolLink: SymbolLink) -> () {
            print(#function)
        }
        
        func visitTable(_ table: Markdown.Table) -> () {
            print(#function)
        }
        
        func visitTableBody(_ tableBody: Markdown.Table.Body) -> () {
            print(#function)
        }
        
        func visitTableCell(_ tableCell: Markdown.Table.Cell) -> () {
            print(#function)
        }
        
        func visitTableHead(_ tableHead: Markdown.Table.Head) -> () {
            print(#function)
        }
        
        func visitTableRow(_ tableRow: Markdown.Table.Row) -> () {
            print(#function)
        }
        
        func visitText(_ text: Markdown.Text) -> () {
            print(#function)
        }
        
        func visitThematicBreak(_ thematicBreak: ThematicBreak) -> () {
            print(#function)
        }
        
        func visitUnorderedList(_ unorderedList: UnorderedList) -> () {
            print(#function)
        }
    }
}
