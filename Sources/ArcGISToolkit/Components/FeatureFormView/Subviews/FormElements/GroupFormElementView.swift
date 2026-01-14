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
        // Using the header of an empty Section ensures that consecutive collapsed
        // GroupFormElements have spacing consistent with other form elements.
        Section {} header: {
            label
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
        
        // GroupFormElement content is placed outside the Section above for the
        // following reasons:
        // 1. Avoids indentation introduced by components like a DisclosureGroup.
        // 2. Avoids unwanted impacts on appearance from nested Sections.
        // 3. Avoids the header receiving a pill-shaped background.
        if isExpanded {
            ForEach(visibleElements, id: \.self) { element in
                Section {
                    viewCreator(element)
                } header: {
                    FormElementHeader(element: element)
                } footer: {
                    FormElementFooter(element: element)
                }
                .textCase(nil)
            }
        }
    }
    
    /// The label for the group element.
    private var label: some View {
        Button {
            withAnimation {
                isExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Text(element.label)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .fontWeight(.bold)
                        .foregroundStyle(.tertiary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                if !element.description.isEmpty {
                    Text(element.description)
                        .accessibilityIdentifier("\(element.label) Description")
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .textCase(nil)
    }
    
    /// The list of visible group elements.
    private var visibleElements: [FormElement] {
        element
            .elements
            .filter { elementVisibility[$0] == true }
    }
}
