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
struct GroupView<Content>: View where Content: View {
    /// A Boolean value indicating whether the group is expanded or collapsed.
    @State private var isExpanded = false
    
    /// The group of visibility tasks.
    @State private var isVisibleTasks = [Task<Void, Never>]()
    
    /// The list of visible group elements.
    @State private var visibleElements = [FormElement]()
    
    /// The group form element.
    let element: GroupFormElement
    
    /// The closure to perform to build an element in the group.
    let viewCreator: (FormElement) -> Content
    
    /// Filters the group's elements by visibility.
    private func updateVisibleElements() {
        visibleElements = element.elements.filter { $0.isVisible }
    }
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            ForEach(visibleElements, id: \.self) { element in
                viewCreator(element)
            }
        } label: {
            Header(element: element)
        }
        .onAppear {
            isExpanded = element.initialState == .expanded
            for element in element.elements {
                let newTask = Task { @MainActor [self] in
                    for await _ in element.$isVisible {
                        self.updateVisibleElements()
                    }
                }
                isVisibleTasks.append(newTask)
            }
        }
        .onDisappear {
            isVisibleTasks.forEach { task in
                task.cancel()
            }
            isVisibleTasks.removeAll()
        }
    }
}

extension GroupView {
    /// A view displaying a label and description of a `GroupFormElement`.
    struct Header: View {
        let element: GroupFormElement
        
        var body: some View {
            VStack(alignment: .leading) {
                // Text views with empty text still take up some vertical space in
                // a view, so conditionally check for an empty title and description.
                if !element.label.isEmpty {
                    Text(element.label)
                        .accessibilityIdentifier("\(element.label)")
                        .multilineTextAlignment(.leading)
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                
                if !element.description.isEmpty {
                    Text(element.description)
                        .accessibilityIdentifier("\(element.label) Description")
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
#if targetEnvironment(macCatalyst)
            .padding(.leading, 4)
#endif
        }
    }
}
