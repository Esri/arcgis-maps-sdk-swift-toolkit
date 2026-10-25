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
import Foundation
import Observation

private import os

extension FeatureFormView {
    @MainActor @Observable
    final class FormModel {
        /// The models for fetching association filter results for each utility associations form element in the form.
        var associationsFilterResultsModels: [UtilityAssociationsFormElement: AssociationsFilterResultsModel] = [:]
        
        /// The phrase used to filter which elements are visible when running UI tests.
        var elementFilterPhrase = ""
        
        /// The current focused element, if one exists.
        var focusedElement: FormElement? {
            didSet {
                if let focusedElement, !previouslyFocusedElements.contains(focusedElement) {
                    previouslyFocusedElements.append(focusedElement)
                }
            }
        }
        
        /// A Boolean value indicating whether the associated form has edits.
        var hasEdits = false {
            didSet {
                if !hasEdits {
                    previouslyFocusedElements.removeAll()
                    evaluateExpressions()
                }
            }
        }
        
        /// A Boolean value indicating whether the feature has either attribute or geometry edits.
        var hasAttributeOrGeometryEdits: Bool {
            hasEdits || geometryStatus != .none
        }
        
        /// The number of element validation errors on the form.
        var elementErrorCount: Int = 0
        
        /// The status of underlying feature's geometry.
        var geometryStatus: GeometryStatus?
        
        /// The combined error count of the form's element validation errors and geometry status.
        var errorCount: Int {
            elementErrorCount
            + (geometryStatus == .invalid ? 1 : 0)
        }
        
        /// The navigation path for the destinations this form can open.
        var navigationPath: [FeatureFormView.NavigationPathItem] = []
        
        /// The set of all elements which previously held focus.
        var previouslyFocusedElements = [FormElement]()
        
        /// The underlying form's dynamic title.
        var title: String
        
        /// The list of visible form elements.
        var visibleElements: [FormElement] {
            var elements = featureForm
                .elements
                .filter { elementVisibility[$0, default: false] }
            if let attachmentsElement = featureForm.defaultAttachmentsElement {
                elements.append(attachmentsElement)
            }
            return elementFilterPhrase.isEmpty
            ? elements
            : elements.filter {
                $0.label.localizedCaseInsensitiveContains(elementFilterPhrase)
            }
        }
        
        /// A dictionary of each form element and whether or not it is visible.
        private var elementVisibility: [FormElement: Bool] = [:]
        
        /// The feature form.
        let featureForm: FeatureForm
        
        /// A Boolean value indicating whether the underlying form was added to the group as a
        /// result of browsing utility associations.
        let createdViaUtilityAssociation: Bool
        
        /// The expression evaluation task.
        @ObservationIgnored
        private var evaluateTask: Task<Void, Never>?
        
        /// The group of visibility tasks.
        @ObservationIgnored
        private var visibilityTask: Task<Void, Never>?
        
        /// A task to monitor whether the form has edits.
        @ObservationIgnored
        private var monitorEditsTask: Task<Void, Never>?
        
        /// A task to monitor the form's title.
        @ObservationIgnored
        private var monitorTitleTask: Task<Void, Never>?
        
        /// A task to monitor whether the form's element validation error count.
        @ObservationIgnored
        private var monitorErrorsTask: Task<Void, Never>?
        
        /// Initializes a form view model.
        /// - Parameter featureForm: The feature form defining the editing experience.
        /// - Parameter createdViaUtilityAssociation: The model is created as a result
        /// of browsing utility associations.
        init(featureForm: FeatureForm, createdViaUtilityAssociation: Bool = false) {
            self.createdViaUtilityAssociation = createdViaUtilityAssociation
            self.featureForm = featureForm
            self.title = featureForm.title
            
            evaluateExpressions()
            monitorEdits()
            monitorErrors()
            monitorTitle()
            monitorVisibility()
        }
        
        deinit {
            evaluateTask?.cancel()
            monitorEditsTask?.cancel()
            monitorErrorsTask?.cancel()
            monitorTitleTask?.cancel()
            visibilityTask?.cancel()
        }
        
        /// Performs an evaluation of all form expressions.
        func evaluateExpressions() {
            evaluateTask?.cancel()
            evaluateTask = Task {
                if let errors = try? await featureForm.evaluateExpressions(), !errors.isEmpty {
                    for evaluationError in errors {
                        Logger.featureFormView.error(
                            "Error evaluating expression: \(evaluationError.error.localizedDescription)"
                        )
                    }
                }
            }
        }
        
        /// Monitors whether the form has edits.
        private func monitorEdits() {
            monitorEditsTask = Task { [weak self] in
                guard !Task.isCancelled, let featureForm = self?.featureForm else { return }
                for await hasEdits in featureForm.$hasEdits.dropFirst() {
                    self?.hasEdits = hasEdits
                }
            }
        }
        
        /// Monitors the form's element validation errors.
        private func monitorErrors() {
            monitorErrorsTask = Task {
                for await errors in featureForm.$elementValidationErrors {
                    elementErrorCount = errors.count
                }
            }
        }
        
        /// Monitors the form's streamed title.
        private func monitorTitle() {
            monitorTitleTask = Task {
                for await title in featureForm.$title {
                    self.title = title
                }
            }
        }
        
        /// Monitors the visibility of each element in the form.
        private func monitorVisibility() {
            visibilityTask = Task { [weak self] in
                await withTaskGroup { group in
                    for element in self?.featureForm.elements ?? [] {
                        group.addTask { @MainActor @Sendable [weak self] in
                            for await isVisible in element.$isVisible {
                                guard !Task.isCancelled else { return }
                                self?.elementVisibility[element] = isVisible
                            }
                        }
                    }
                }
            }
        }
    }
}
