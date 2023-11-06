// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import Combine
import SwiftUI

/// A model for an input in a form.
///
/// - Since: 200.3
class FormInputModel: ObservableObject {
    /// A Boolean value indicating whether a value in the input is required.
    @Published var isRequired: Bool
    
    /// A Boolean value indicating whether a value in the input is editable.
    @Published var isEditable: Bool
    
    /// The value of the input.
    @Published var value: Any?
    
    /// The formatted value of the input.
    @Published var formattedValue: String
    
    private var element: FieldFormElement
    
    private var tasks = [Task<Void, Never>]()
    
    deinit {
        clearTasks()
    }
    
    /// Initializes a form input model.
    public init(fieldFormElement: FieldFormElement) {
        element = fieldFormElement
        isRequired = element.isRequired
        isEditable = element.isEditable
        value = element.value
        formattedValue = element.formattedValue
        
        // Kick off tasks to monitor required, editable and value.
        tasks.append(
            contentsOf: [
                observeIsRequiredTask,
                observeIsEditableTask,
                observeValueTask
            ]
        )
    }
    
    /// Cancels and removes tasks.
    private func clearTasks() {
        tasks.forEach { task in
            task.cancel()
        }
        tasks.removeAll()
    }
    
    /// A detached task observing changes in the required state.
    private var observeIsRequiredTask: Task<Void, Never> {
        Task.detached { [unowned self] in
            for await isRequired in element.$isRequired {
                await MainActor.run {
                    self.isRequired = isRequired
                }
            }
        }
    }
    
    /// A detached task observing changes in the editable state.
    private var observeIsEditableTask: Task<Void, Never> {
        Task.detached { [unowned self] in
            for await isEditable in element.$isEditable {
                await MainActor.run {
                    self.isEditable = isEditable
                }
            }
        }
    }
    
    /// A detached task observing changes in the value.
    private var observeValueTask: Task<Void, Never> {
        Task.detached { [unowned self] in
            for await value in element.$value {
                await MainActor.run {
                    self.value = value
                    self.formattedValue = element.formattedValue
                }
            }
        }
    }
}
