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
import SwiftUI

/// - Since: 200.2
public class FormInputModel: ObservableObject {
    @Published var isRequired: Bool
    @Published var isEditable: Bool
    @Published var value: String

    private var element: FieldFormElement
    
    private var tasks = [Task<Void, Never>]()
    
    deinit {
        clearTasks()
    }
    
    /// Initializes a form view model.
    public init(fieldFormElement: FieldFormElement) {
        element = fieldFormElement
        isRequired = element.isRequired
        isEditable = element.isEditable
        value = element.value

        // Kick off tasks to monitor autoPan, locations, and satellites.
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
    
    /// A detached task observing location display autoPan changes.
    private var observeIsRequiredTask: Task<Void, Never> {
        Task.detached { [unowned self] in
            for await isRequired in element.$isRequired {
//                print("isRequired changed: \(isRequired) for \(element.label)")
                await MainActor.run {
                    self.isRequired = isRequired
                }
            }
        }
    }
    
    /// A detached task observing location display autoPan changes.
    private var observeIsEditableTask: Task<Void, Never> {
        Task.detached { [unowned self] in
            for await isEditable in element.$isEditable {
//                print("isEditable changed: \(isEditable) (oldvalue: \(element.isEditable)) for \(element.label)")
                await MainActor.run {
                    self.isEditable = isEditable
                }
            }
        }
    }
    
    /// A detached task observing location display autoPan changes.
    private var observeValueTask: Task<Void, Never> {
        Task.detached { [unowned self] in
            for await value in element.$value {
//                print("value changed: \(value) for \(element.label)")
                await MainActor.run {
                    self.value = value
                }
            }
        }
    }
}
