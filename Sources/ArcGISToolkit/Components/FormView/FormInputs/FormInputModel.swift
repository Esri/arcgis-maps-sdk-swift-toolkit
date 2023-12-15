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
import Combine
import SwiftUI

/// A model for an input in a form.
///
/// - Since: 200.4
@MainActor class FormInputModel: ObservableObject {
    /// A Boolean value indicating whether a value in the input is required.
    @Published var isRequired: Bool
    
    /// A Boolean value indicating whether a value in the input is editable.
    @Published var isEditable: Bool
    
    /// The value of the input.
    @Published var value: Any?
    
    /// The formatted value of the input.
    @Published var formattedValue: String
    
    private var element: FieldFormElement
    
    private var observationTask: Task<Void, Never>?

    deinit {
        observationTask?.cancel()
    }
    
    /// Initializes a form input model.
    init(fieldFormElement: FieldFormElement) {
        element = fieldFormElement
        isRequired = element.isRequired
        isEditable = element.isEditable
        value = element.value
        formattedValue = element.formattedValue
        
        // Kick off tasks to monitor required, editable and value.
        observationTask = Task {
            await withTaskGroup(of: Void.self) { group in
                // Observe isRequired changes.
                group.addTask { [unowned self] in
                    for await isRequired in await element.$isRequired {
                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            self.isRequired = isRequired
                        }
                    }
                }
                // Observe isEditable changes.
                group.addTask { [unowned self] in
                    for await isEditable in await element.$isEditable {
                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            self.isEditable = isEditable
                        }
                    }
                }
                // Observe value changes.
                group.addTask { [unowned self] in
                    for await value in await element.$value {
                        guard !Task.isCancelled else { return }
                        await MainActor.run {
                            self.value = value
                            self.formattedValue = element.formattedValue
                        }
                    }
                }
            }
        }
    }
}
