// Copyright 2023 Esri.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
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
    @State private var isExpanded: Bool
    
    /// The list of visible group elements.
    @State private  var visibleElements = [FormElement]()
    
    /// The group form element.
    @State private var element: GroupFormElement
    
    /// The group of visibility tasks.
    @State private var isVisibleTasks = [Task<Void, Never>]()
    
    /// The method to build an element in the group.
    private let viewCreator: (FieldFormElement) -> Content
    
    /// Filters the group's elements by visibility.
    private func updateVisibleElements() {
        visibleElements = element.formElements.filter { $0.isVisible }
    }
    
    /// - Creates a view for a group form element and manages the visibility of the elements within
    /// the group.
    /// - Parameters:
    ///   - element: The group form element.
    ///   - viewCreator: The method to build an element in the group.
    init(element: GroupFormElement, viewCreator: @escaping (FieldFormElement) -> Content) {
        self.element = element
        self.isExpanded = element.initialState != .collapsed
        self.viewCreator = viewCreator
    }
    
    var body: some View {
        DisclosureGroup(self.element.label, isExpanded: $isExpanded) {
            ForEach(visibleElements, id: \.label) { formElement in
                if let element = formElement as? FieldFormElement {
                    viewCreator(element)
                }
            }
        }
        .onAppear {
            element.formElements.forEach { element in
                let newTask = Task.detached { [self] in
                    for await _ in element.$isVisible {
                        await MainActor.run {
                            self.updateVisibleElements()
                        }
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
