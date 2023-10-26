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
import Combine
import SwiftUI

/// A model for a group element in a form.
///
/// - Since: 200.3
class GroupElementModel: ObservableObject {
    /// The group of visibility tasks.
    private var isVisibleTasks = [Task<Void, Never>]()
    
    /// The list of visible form elements.
    @Published var visibleElements = [FormElement]()
    
    @Binding var isExpanded: Bool
    
    private let groupElement: GroupFormElement
    
    init(groupElement: GroupFormElement) {
        self.groupElement = groupElement
        _isExpanded = .init(get: { groupElement.initialState != .collapsed }, set: { _ in })
        initializeIsVisibleTasks()
    }
    
    /// Cancels and removes tasks.
    private func clearIsVisibleTasks() {
        isVisibleTasks.forEach { task in
            task.cancel()
        }
        isVisibleTasks.removeAll()
    }
    
    /// A detached task observing visibility changes.
    private func updateVisibleElements() {
        visibleElements = groupElement.formElements.filter { $0.isVisible }
    }
    
    func initializeIsVisibleTasks() {
        clearIsVisibleTasks()
        
        // Kick off tasks to monitor isVisible for each element.
        groupElement.formElements.forEach { element in
            let newTask = Task.detached { [unowned self] in
                for await _ in element.$isVisible {
                    await MainActor.run {
                        self.updateVisibleElements()
                    }
                }
            }
            isVisibleTasks.append(newTask)
        }
    }
}
