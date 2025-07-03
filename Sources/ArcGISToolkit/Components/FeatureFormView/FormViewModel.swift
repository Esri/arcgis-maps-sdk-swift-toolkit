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

@MainActor class FormViewModel: ObservableObject {
    /// The current focused element, if one exists.
    @Published var focusedElement: FormElement? {
        didSet {
            if let focusedElement, !previouslyFocusedElements.contains(focusedElement) {
                previouslyFocusedElements.append(focusedElement)
            }
        }
    }
    
    /// The set of all elements which previously held focus.
    @Published var previouslyFocusedElements = [FormElement]()
    
    /// The list of visible form elements.
    @Published var visibleElements = [FormElement]()
    
    /// The expression evaluation task.
    private var evaluateTask: Task<Void, Never>?
    
    /// The feature form.
    private(set) var featureForm: FeatureForm
    
    /// The visibility tasks group.
    private var isVisibleTask: Task<Void, Never>?
    
    /// Initializes a form view model.
    /// - Parameter featureForm: The feature form defining the editing experience.
    init(featureForm: FeatureForm) {
        self.featureForm = featureForm
    }
    
    deinit {
        evaluateTask?.cancel()
        isVisibleTask?.cancel()
    }
    
    /// Kick off tasks to monitor `isVisible` for each element.
    private func initializeIsVisibleTasks() {
        isVisibleTask = Task.detached { [unowned self] in
            await withTaskGroup(of: Void.self) { group in
                for element in await self.featureForm.elements {
                    group.addTask {
                        for await _ in element.$isVisible {
                            guard !Task.isCancelled else { return }
                            await self.updateVisibleElements()
                        }
                    }
                }
            }
        }
    }
    
    /// A detached task observing visibility changes.
    private func updateVisibleElements() {
        visibleElements = featureForm.elements.filter { $0.isVisible }
    }
    
    /// Performs an initial evaluation of all form expressions.
    func initialEvaluation() async {
        _ = try? await featureForm.evaluateExpressions()
        initializeIsVisibleTasks()
    }
    
    /// Performs an evaluation of all form expressions.
    func evaluateExpressions() {
        evaluateTask?.cancel()
        evaluateTask = Task {
            _ = try? await featureForm.evaluateExpressions()
        }
    }
    
    /// Updates the value of a field in the feature associated with the given
    /// field form element to the given value. Expressions are then evaluated
    /// when the update is not suppressed.
    ///
    /// The update is suppressed when the provided value matches the element's
    /// current value. This can happen when edits are discarded and the element
    /// receives the original value and attempts to send it back to core.
    /// - Parameters:
    ///   - element: The field form element to update.
    ///   - value: The new value of the element.
    func updateValueAndEvaluateExpressions(_ element: FieldFormElement, _ value: (any Sendable)?) {
        if element.input is ComboBoxFormInput || element.input is RadioButtonsFormInput {
            guard element.formattedValue != (value as? CodedValue)?.name else { return }
            element.updateValue((value as? CodedValue)?.code)
        } else if element.input is DateTimePickerFormInput {
            guard element.value as? Date != value as? Date else { return }
            element.updateValue(value)
        } else if element.input is SwitchFormInput {
            guard let isOn = value as? Bool,
                  let switchInput = element.input as? SwitchFormInput,
                  (isOn && element.formattedValue == switchInput.offValue.name)
                    || (!isOn && element.formattedValue == switchInput.onValue.name) else { return }
            element.updateValue(isOn ? switchInput.onValue.code : switchInput.offValue.code)
        } else if element.input.supportsKeyboard {
            guard let stringValue = value as? String,
                  element.formattedValue != stringValue else { return }
            element.convertAndUpdateValue(stringValue)
        }
        evaluateExpressions()
    }
}
