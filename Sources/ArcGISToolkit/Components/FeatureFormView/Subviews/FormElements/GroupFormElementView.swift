// Copyright 2023 Esri
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

import ArcGIS
import SwiftUI

/// Displays a group form element and manages the visibility of the elements within the group.
struct GroupFormElementView<Content>: View where Content: View {
    /// The group form element.
    let element: GroupFormElement
    /// The closure to perform to build an element in the group.
    let viewCreator: (FormElement) -> Content
    
    /// A dictionary of each group element and whether or not it is visible.
    @State private var elementVisibility: [FormElement: Bool] = [:]
    /// A Boolean value indicating whether the group is expanded or collapsed.
    @State private var isExpanded = false
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(visibleElements, id: \.self) { element in
                Section {
                    viewCreator(element)
                } header: {
                    FormElementHeader(element: element)
                } footer: {
                    FormElementFooter(element: element)
                }
            }
        } label: {
            Label(element: element)
        }
        .onAppear {
            isExpanded = element.initialState == .expanded
        }
        .task {
            await withTaskGroup { group in
                for element in element.elements {
                    group.addTask { @MainActor @Sendable in
                        for await isVisible in element.$isVisible {
                            guard !Task.isCancelled else { return }
                            elementVisibility[element] = isVisible
                        }
                    }
                }
            }
        }
        // Tints the disclosure triangle.
        .inspectorTint(.blue)
    }
    
    /// The list of visible group elements.
    private var visibleElements: [FormElement] {
        element
            .elements
            .filter { elementVisibility[$0] == true }
    }
}

extension GroupFormElementView {
    /// A view displaying a label and description of a `GroupFormElement`.
    struct Label: View {
        let element: GroupFormElement
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(element.label)
                if !element.description.isEmpty {
                    Text(element.description)
                        .accessibilityIdentifier("\(element.label) Description")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .tint(.primary)
                }
            }
        }
    }
}
