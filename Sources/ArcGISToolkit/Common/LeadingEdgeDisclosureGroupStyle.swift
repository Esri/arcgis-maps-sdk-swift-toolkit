// Copyright 2025 Esri
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

/// A disclosure group style that places the disclosure arrow at the leading edge.
///
/// Use ``DisclosureGroupStyle/leadingEdge`` to construct this style.
struct LeadingEdgeDisclosureGroupStyle: DisclosureGroupStyle {
    let arrowColor: Color
    
    /// Creates a leading edge disclosure group style.
    /// - Parameter arrowColor: The color of the disclosure group arrow.
    init(arrowColor: Color = .accentColor) {
        self.arrowColor = arrowColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation {
                configuration.isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .firstTextBaseline) {
                Image(systemName: "chevron.right")
                    .foregroundColor(arrowColor)
                    .rotationEffect(.degrees(configuration.isExpanded ? 90 : 0))
                    .animation(
                        .easeInOut(duration: 0.3),
                        value: configuration.isExpanded
                    )
                configuration.label
                Spacer()
            }
            .contentShape(Rectangle())
            .alignmentGuide(.listRowSeparatorLeading) { dimensions in
                dimensions[.leading]
            }
        }
        .buttonStyle(.plain)
        if configuration.isExpanded {
            configuration.content
                .listRowInsets((.init(top: 0, leading: 50, bottom: 0, trailing: 0)))
        }
    }
}

#Preview {
    func makeDemoContent() -> some View {
        ForEach(1..<3) {
            Text($0.formatted())
        }
    }
    return List {
        Section {
            DisclosureGroup("\(AutomaticDisclosureGroupStyle.self)") {
                makeDemoContent()
            }
            .disclosureGroupStyle(.automatic)
        }
        Section {
            DisclosureGroup("\(LeadingEdgeDisclosureGroupStyle.self)") {
                makeDemoContent()
            }
            .disclosureGroupStyle(.leadingEdge)
        }
        Section {
            DisclosureGroup("\(LeadingEdgeDisclosureGroupStyle.self)") {
                makeDemoContent()
            }
            .disclosureGroupStyle(.leadingEdge(arrowColor: .secondary))
        }
    }
}
