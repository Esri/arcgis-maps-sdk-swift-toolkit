// Copyright 2026 Esri
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

internal import os

public extension FeatureFormView {
    /// A model for the ``FeatureFormView`` component.
    /// - Since: 300.3
    @MainActor @Observable
    final class Model {
        // MARK: Public members
        
        /// Initializes a model for the view, creating a `FeatureFormGroup` with the provided
        /// forms.
        /// - Parameter forms: The initial set of forms to be edited in the view.
        public convenience init?(forms: [FeatureForm] = []) {
            guard let group = FeatureFormGroup(forms: forms) else { return nil }
            self.init(group: group)
        }
        
        /// Initializes a model for the view, creating a a `FeatureFormGroup` with a shared
        /// template feature set.
        ///
        /// The members of a `FeatureFormGroup` are not editable when it is created with a
        /// shared template feature creation set.
        /// - Parameter featureCreationSet: The set to create the underlying
        /// `FeatureFormGroup` with.
        public convenience init?(
            featureCreationSet: SharedTemplateFeatureCreationSet
        ) {
            fatalError("Not implemented.")
//            guard let group = FeatureFormGroup(
//                featureCreationSet: featureCreationSet
//            ) else { return nil }
//            self.init(group: group)
        }
        
        /// Adds a `FeatureForm` to the underlying `FeatureFormGroup`
        /// - Parameter form: The new form to be added to the group.
        /// - Parameter select: A Boolean value indicating whether the added form should
        /// become the ``FeatureFormView/Model/selectedForm``.
        public func add(form: FeatureForm, select: Bool = false) {
            guard group.isEditable else { return }
            add(form: form, select: select, recordAsBrowsed: false)
        }
        
        /// Sets the provided form as the ``FeatureFormView/Model/selectedForm``.
        /// - Parameter form: The form to select.
        /// - Parameter clearHistory: A Boolean value indicating whether the selection
        /// should reset   the back stack.
        public func select(form: FeatureForm, clearHistory: Bool = false) {
            guard let globalID = form.feature.globalID else { return }
            if let model = formModel(id: globalID) {
                self.select(model: model, clearHistory: clearHistory)
            }
        }
        
        /// Sets the edit status for the geometry on the provided feature.
        ///
        /// When ``FeatureFormView/GeometryStatus/invalid`` or
        /// ``FeatureFormView/GeometryStatus/valid`` are provided the component
        /// considers the feature edited. If `.none` the component considers the feature
        /// not-edited.
        /// - Parameters:
        ///   - feature: The feature to update the geometry edit status for.
        ///   - status: The status of the in-memory feature's geometry.
        /// - Since: 300.3
        public func setGeometryEditStatus(
            for feature: ArcGISFeature,
            status: GeometryStatus?
        ) {
            guard let id = feature.globalID else { return }
            formModel(id: id)?.geometryStatus = status
        }
        
        /// A stream of ``FeatureFormView/EditingEvent``s.
        public var editingEvents: AsyncStream<EditingEvent> {
            editingEventStream
        }
        
        /// The forms being edited in the underlying `FeatureFormGroup`.
        public var forms: [FeatureForm] {
            formModels.values.compactMap { formModel in
                if (
                    !formModel.createdViaUtilityAssociation
                    || formModel.hasAttributeOrGeometryEdits
                ) {
                    return formModel.featureForm
                } else {
                    return nil
                }
            }
        }
        
        /// The form selected in the component.
        ///
        /// `nil` when no form is selected and the group menu is showing.
        public var selectedForm: FeatureForm? {
            guard let selectedModel else { return nil }
            return selectedModel.featureForm
        }
        
        /// The visibility of validation errors in the form(s).
        public var validationErrorVisibility = ValidationErrorVisibility.automatic
        
        // MARK: Internal members
        
        isolated deinit {
            editingEventStreamContinuation.finish()
            taskForDiscarding?.cancel()
            taskForInitialEvaluation?.cancel()
            taskForSaving?.cancel()
        }
        
        /// Adds a `FeatureForm` to the group.
        /// - Parameters:
        ///   - form: The new form to be added to the group.
        ///   - select: A Boolean value indicating whether the added form should become the
        ///   ``FeatureFormView/Model/selectedForm``.
        ///   - recordAsBrowsed: A Boolean value indicating whether the add is happening as
        ///   a result of browsing utility associations in a form.
        func add(form: FeatureForm, select: Bool = false, recordAsBrowsed: Bool = false) {
            defer {
                formCount = group.forms.count
                
                // Select the form, if directed, or if no form is already selected.
                if select || selectedModel == nil {
                    self.select(form: form)
                }
            }
            
            guard let id = form.feature.globalID else {
                Logger.featureFormView.warning("The feature cannot be added because the its global ID is not available.")
                return
            }
            
            guard !formModels.keys.contains(id) else {
                Logger.featureFormView.info("Feature \(id.description) is already added.")
                return
            }
            
            do {
                try group.addForm(form)
                _ = addFormModel(form, isAssociation: recordAsBrowsed)
            } catch {
                Logger.featureFormView.error("Error adding form. \(error.localizedDescription)")
            }
        }
        
        /// Unsets the active form.
        /// - Parameter clearBackStack: A Boolean value indicating whether the navigation
        /// history should also be cleared.
        func clearSelection(clearBackStack: Bool = true) {
            guard let selectedModel else { return }
            backStack.append(selectedModel)
            self.selectedModel = nil
            if clearBackStack {
                backStack.removeAll()
            }
        }
        
        /// Discards the edits on all forms in underlying group and closes the component is a
        /// presentation binding was provided.
        /// - Parameter ignoreEdits: A Boolean value indicating if the user should be
        /// warned of unsaved edits before discarding.
        func discard(ignoreEdits: Bool = false) {
            let discard = { [weak self] in
                self?.taskForDiscarding?.cancel()
                self?.taskForDiscarding = Task {
                    do {
                        try await self?.group.discardEdits()
                        self?.reportEditingEvent(.discarded)
                    } catch {
                        self?.finishOrDiscardError = error
                        self?.reportEditingEvent(.failed(error))
                    }
                    if self?.isPresented != nil {
                        self?.isPresented = false
                    }
                }
            }
            if groupHasEdits && !ignoreEdits {
                alertForUnsavedEditsIsPresented = true
            } else {
                _ = discard()
            }
        }
        
        /// Returns a  form model for a form in the group with a feature with a matching global ID.
        ///
        /// If no such model exists in the set of form models but the form is in the group a new
        /// model created and added to the set before being returned.
        /// - Parameter globalID: The global ID of a feature.
        /// - Returns: The matching form model.
        func formModel(id globalID: UUID) -> FeatureFormView.FormModel? {
            if let model = formModels[globalID] {
                return model
            } else if let groupMember = group.forms.first(
                where: { $0.feature.globalID == globalID }
            ) {
                let newModel = addFormModel(groupMember)
                return newModel
            } else {
                return nil
            }
        }
        
        /// Returns the user to the previous ``FeatureFormView/Model/selectedForm>`` if
        /// they are at the root of the current form's navigation stack, otherwise removes the top
        /// item from the current form's navigation stack.
        func navigateBack() {
            guard let selectedModel else { return }
            if selectedModel.navigationPath.isEmpty, canGoBack {
                // Back into the previous visited form in the group.
                popBackStack()
            } else if !selectedModel.navigationPath.isEmpty {
                // Back into the previous view in the current form's navigation path.
                selectedModel.navigationPath.removeLast()
            }
        }
        
        /// Multiplexes ``FeatureFormView/EditingEvent``s to
        /// ``FeatureFormView/Model/editingEvents`` and
        /// ``FeatureFormView/onFormEditingEvent(perform:)``.
        func reportEditingEvent(_ event: EditingEvent) {
            /// Delivers editing events to the deprecated
            /// ``FeatureFormView/onFormEditingEvent(perform:)`` modifier.
            @diagnose(DeprecatedDeclaration, as: ignored)
            func deliverToCallback() {
                guard let callBack = onFormEditingEventAction else { return }
                var effectiveEvent = event
                switch event {
                case .failed, .willSave:
                    // New event types aren't delivered to a deprecated channel.
                    return
                case .navigationChanged, .showOnMapRequested:
                    // Existing events are let through unchanged.
                    break
                case .discarded:
                    // Discarded is converted to a deprecated equivalent.
                    effectiveEvent = .discardedEdits(willNavigate: false)
                case .saved:
                    // Saved is converted to a deprecated equivalent.
                    effectiveEvent = .savedEdits(willNavigate: false)
                case .discardedEdits, .savedEdits:
                    // Deprecated events won't be reported.
                    fatalError("A deprecated event type was reported.")
                }
                callBack(effectiveEvent)
            }
            deliverToCallback()
            editingEventStreamContinuation.yield(event)
        }
        
        /// Finishes editing the underlying group of feature forms after first evaluating
        /// expressions and confirming there are no attribute errors or invalid geometries.
        func save() {
            taskForSaving = Task {
                guard !isSaving else { return }
                isSaving = true
                defer { isSaving = false }
                
                reportEditingEvent(.willSave)
                
                await evaluateExpressions()
                
                guard !Task.isCancelled else { return }
                
                guard !groupHasErrors else {
                    alertForValidationErrorsIsPresented = true
                    validationErrorVisibilityInternal = .visible
                    reportEditingEvent(.failed(SaveError.validationErrors))
                    return
                }
                
                do {
                    try await group.finishEditing()
                    reportEditingEvent(.saved)
                } catch {
                    finishOrDiscardError = error
                    reportEditingEvent(.failed(SaveError.finishEditing))
                    return
                }
            }
        }
        
        /// Reports the total error count for a feature form with a underlying feature with a
        /// matching global ID.
        ///
        /// The count is the number of element validation errors on the matching form plus one if
        /// the underlying feature's geometry has been reported invalid.
        /// - Parameter globalID: The global ID of a feature.
        /// - Returns: The error count for the indicated form.
        func totalErrorCountForForm(id globalID: UUID) -> Int {
            formModel(id: globalID)?.errorCount ?? 0
        }
        
        /// A Boolean value indicating whether the alert for unsaved edits is presented.
        var alertForUnsavedEditsIsPresented = false
        
        /// A Boolean value indicating whether the alert for validation errors is presented.
        var alertForValidationErrorsIsPresented = false
        
        /// A Boolean value indicating whether all validation errors on all forms in the group are
        /// visible.
        var allValidationErrorsAreVisible: Bool {
            groupHasErrors
            && (
                validationErrorVisibility == .visible
                || validationErrorVisibilityInternal == .visible
            )
            ? true
            : false
        }
        
        /// A Boolean value indicating whether the back stack is empty and there is a previous
        /// selected form to re-select.
        var canGoBack: Bool {
            backStack.count > 0
        }
        
        /// A Boolean value indicating if the group has any forms with edits.
        var groupHasEdits: Bool {
            formModels.contains(where: { $0.value.hasAttributeOrGeometryEdits })
        }
        
        /// A Boolean value indicating if the group has any forms with validation errors.
        var groupHasErrors: Bool {
            totalErrorCount > 0
        }
        
        /// A Boolean value that determines whether the view is presented.
        var isPresented: Bool?
        
        /// A Boolean value indicating whether a save is in progress.
        private(set) var isSaving = false
        
        /// A Boolean value indicating whether the underlying group has multiple forms with
        /// edits.
        var multiFormModeIsActive: Bool {
            forms.count > 1
        }
        
        /// The user-provided closure to perform when a new feature form is shown in the
        /// navigation stack.
        ///
        /// Supports deprecated modifier
        /// ``FeatureFormView/onFeatureFormChanged(perform:)``.
        var onFeatureFormChanged: ((FeatureForm) -> Void)?
        
        /// The user-provided closure to perform when a ``EditingEvent`` occurs.
        ///
        /// Supports deprecated modifier
        /// ``FeatureFormView/onFormEditingEvent(perform:)``.
        var onFormEditingEventAction: ((EditingEvent) -> Void)?
        
        /// The model for the selected form.
        var selectedModel: FormModel? {
            didSet {
                guard let selectedModel else { return }
                onFeatureFormChanged?(selectedModel.featureForm)
                selectedModel.evaluateExpressions()
            }
        }
        
        /// The total error count of all forms within the group factoring in the
        /// ``FeatureFormView/GeometryStatus`` of each underlying feature.
        var totalErrorCount: Int {
            formModels.values.map({ $0.errorCount }).reduce(0, +)
        }
        
        // MARK: Private members
        
        /// Creates a new instance of this model and performs initial expression evaluation.
        private init(group: FeatureFormGroup) {
            self.group = group
            self.formCount = group.forms.count
            
            // If the group has a single form, select it.
            if group.forms.count == 1, let onlyForm = group.forms.first {
                select(form: onlyForm)
            }
            
            taskForInitialEvaluation = Task {
                await evaluateExpressions()
            }
        }
        
        /// Creates a new `FormModel` and adds it to the set of models.
        /// - Parameters:
        ///   - form: The form to create a new model for.
        ///   - isAssociation: A Boolean value indicating if the form is being added as a
        ///   result of browsing utility associations.
        /// - Returns: The new model.
        private func addFormModel(
            _ form: FeatureForm,
            isAssociation: Bool = false
        ) -> FormModel? {
            guard let globalID = form.feature.globalID else {
                Logger.featureFormView.error("Couldn't get GlobalID to make FormModel.")
                return nil
            }
            let newModel = FeatureFormView.FormModel(
                featureForm: form,
                createdViaUtilityAssociation: isAssociation
            )
            formModels[globalID] = newModel
            return newModel
        }
        
        /// Asynchronously evaluates all form expressions in all the feature forms in the group.
        private func evaluateExpressions() async {
            let expressionsEvaluationErrors = try? await group.evaluateExpressions()
            if !(expressionsEvaluationErrors?.isEmpty ?? true) {
                Logger.featureFormView.warning("Expression evaluation error: \(expressionsEvaluationErrors.debugDescription)")
            }
        }
        
        /// Removes the top of `backStack` and selects it.
        private func popBackStack() {
            guard canGoBack else {
                Logger.featureFormView.warning("Cannot navigate backwards without history.")
                return
            }
            let top = backStack.removeLast()
            select(model: top, recordNavigation: false)
        }
        
        /// Selects the provided form.
        /// - Parameters:
        ///   - form: The form to select.
        ///   - recordNavigation: A Boolean value indicating whether the selection should
        ///   be tracked in the back stack.
        ///   - clearHistory: A Boolean value indicating whether the selection should reset
        ///   the back stack.
        func select(
            model: FormModel,
            recordNavigation: Bool = true,
            clearHistory: Bool = false
        ) {
            guard model.featureGlobalID != selectedModel?.featureGlobalID else { return }
            if recordNavigation, let selectedModel {
                backStack.append(selectedModel)
            }
            if clearHistory {
                backStack.removeAll()
            }
            selectedModel = model
        }
        
        /// The navigation history of forms in the underlying group.
        ///
        /// As utility associations are browsed and new forms are added to the group this
        /// maintains the order allowing the user to back all the way to the original form if
        /// desired.
        private var backStack = [FormModel]()
        
        /// The async stream of editing events.
        private let (editingEventStream, editingEventStreamContinuation) = AsyncStream.makeStream(of: EditingEvent.self)
        
        /// An error thrown when finishing or discarding edits.
        var finishOrDiscardError: (any Error)?
        
        /// The count of forms in the underlying group. This includes forms in the group added
        /// during association browsing irrespective of whether they've been edited or not.
        private var formCount: Int
        
        /// Form view models, keyed by feature global IDs.
        private var formModels: [UUID: FeatureFormView.FormModel] = [:]
        
        /// The underlying feature form group.
        private let group: FeatureFormGroup
        
        /// The task for discarding edits.
        @ObservationIgnored
        private var taskForDiscarding: Task<Void, Never>?
        
        /// The task for initial expression evaluation.
        @ObservationIgnored
        private var taskForInitialEvaluation: Task<Void, Never>?
        
        /// The task for saving.
        @ObservationIgnored
        private var taskForSaving: Task<Void, Never>?
        
        /// The internally managed validation error visibility.
        private var validationErrorVisibilityInternal = FeatureFormView.ValidationErrorVisibility.automatic
    }
}

private extension FeatureFormGroup {
    /// A Boolean value indicating whether forms can be added or removed from the underlying
    /// `FeatureFormGroup`.
    ///
    /// - Warning: This property is for prototype purposes only and will be provided by the SDK.
    var isEditable: Bool {
        true
    }
}
