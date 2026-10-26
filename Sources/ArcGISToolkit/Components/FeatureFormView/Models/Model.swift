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
    /// - Since: 300.2
    @MainActor @Observable
    final class Model {
        /// The visibility of the Save button.
        public var saveButtonVisibility: Visibility = .automatic
        /// The visibility of validation errors in the form(s).
        public var validationErrorVisibility = ValidationErrorVisibility.automatic
        
        /// A Boolean value that determines whether the view is presented.
        var isPresented: Bool?
        
        /// The user-provided closure to perform when a new feature form is shown in the navigation stack.
        ///
        /// Supports deprecated modifier ``FeatureFormView/onFeatureFormChanged(perform:)``.
        var onFeatureFormChanged: ((FeatureForm) -> Void)?
        
        /// The user-provided closure to perform when a ``EditingEvent`` occurs.
        ///
        /// Supports deprecated modifier ``FeatureFormView/onFormEditingEvent(perform:)``.
        var onFormEditingEventAction: ((EditingEvent) -> Void)?
        
        /// <#Description#>
        init(group: FeatureFormGroup) {
            self.group = group
            self.formCount = group.forms.count
            
            // If the group has a single form, select it.
            if !multiFormModeIsActive, let first = group.forms.first {
                select(form: first)
            }
        }
        
        /// Initializes a model for the view, creating a `FeatureFormGroup` with the provided
        /// forms.
        /// - Parameter forms: The initial set of forms to be edited in the view.
        public convenience init?(forms: [FeatureForm] = []) {
            guard let group = FeatureFormGroup(forms: forms) else { return nil }
            self.init(group: group)
        }
        
        /// <#Description#>
        private let group: FeatureFormGroup
        
        /// <#Description#>
        var canGoBack: Bool {
            backStack.count > 0
        }
        
        /// The number of forms being edited in the view.
        ///
        /// This is the number of forms the model was initialized with,
        /// plus/minus any added/removed programmatically via the model,
        /// and plus any forms that have been interactively opened _and edited_ via
        /// utility association elements.
        var activeFormCount: Int {
            activeForms.count
        }
        
        /// <#Description#>
        public var formCount: Int
        
        /// <#Description#>
        private(set) var selectedID: UUID? {
            didSet {
                guard let selectedForm else { return }
                onFeatureFormChanged?(selectedForm)
            }
        }
        
        /// <#Description#>
        var activeForms: [FeatureForm] {
            return ids.compactMap { id in
                let form = form(for: id)
                guard let globalID = form?.feature.globalID,
                      let formModel = formModel(for: globalID) else { return nil }
                if (!formModel.createdViaUtilityAssociation || formModel.hasEdits) {
                    return form
                } else {
                    return nil
                }
            }
        }
        
        /// <#Description#>
        var selectedIndex: Int {
            if let selectedID {
                ids.firstIndex(of: selectedID) ?? -1
            } else {
                -1
            }
        }
        
        var multiFormModeIsActive: Bool {
            activeFormCount > 1
        }
        
        /// <#Description#>
        public var ids: [UUID] {
            group.forms.compactMap { $0.feature.globalID }
        }
        
        /// <#Description#>
        public var selectedForm: FeatureForm? {
            guard let selectedID else { return nil }
            return form(for: selectedID) ?? nil
        }
        
        /// An error thrown from finish editing.
        var finishEditingError: (any Error)?
        
        /// <#Description#>
        var alertForUnsavedEditsIsPresented = false
        
        /// <#Description#>
        var alertForValidationErrorsIsPresented = false
        
        /// Form view models, keyed by feature global IDs.
        private var formModels: [UUID: FeatureFormView.FormModel] = [:]
        
        /// The internally managed validation error visibility.
        private var validationErrorVisibilityInternal = FeatureFormView.ValidationErrorVisibility.automatic
        
        /// <#Description#>
        private var backStack = [UUID]()
        
        /// <#Description#>
        /// - Parameters:
        ///   - form: <#form description#>
        ///   - select: <#select description#>
        ///   - recordAsBrowsed: <#recordAsBrowsed description#>
        func add(form: FeatureForm, select: Bool = false, recordAsBrowsed: Bool = false) {
            defer {
                formCount = group.forms.count
                
                // Select the form, if directed, or if no form is already selected.
                if select || selectedID == nil {
                    self.select(form: form)
                }
            }
            
            guard let id = form.feature.globalID else {
                Logger.featureFormView.warning("The feature cannot be added because the its global ID is not available.")
                return
            }
            
            guard !ids.contains(id) else {
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
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        /// - Parameter select: <#select description#>
        public func add(form: FeatureForm, select: Bool = false) {
            add(form: form, select: select, recordAsBrowsed: false)
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
        /// - Since: 300.2
        public func setGeometryEditStatus(
            for feature: ArcGISFeature,
            status: GeometryStatus?
        ) {
            guard let id = feature.globalID else { return }
            formModel(for: id)?.geometryStatus = status
        }
        
        /// <#Description#>
        /// - Parameter ignoreEdits: A Boolean value indicating if the user should be
        /// warned of unsaved edits before discarding.
        @diagnose(DeprecatedDeclaration, as: ignored)
        public func discard(ignoreEdits: Bool = false) {
            let discard = {
                Task {
                    do {
                        try await self.group.discardEdits()
                        self.reportEditingEvent(.discarded)
                    } catch {
                        self.finishEditingError = error
                        self.reportEditingEvent(.failed(error))
                    }
                    if self.isPresented != nil {
                        self.isPresented = false
                    }
                }
            }
            if groupHasEdits && !ignoreEdits {
                alertForUnsavedEditsIsPresented = true
            } else {
                _ = discard()
            }
        }
        
        /// <#Description#>
        var isSaving = false
        
        /// <#Description#>
        private let (editingEventStream, editingEventStreamContinuation) = AsyncStream.makeStream(of: EditingEvent.self)
        
        /// <#Description#>
        public var editingEvents: AsyncStream<EditingEvent> {
            editingEventStream
        }
        
        /// <#Description#>
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
        
        private var saveTask: Task<Void, Never>?
        
        isolated deinit {
            editingEventStreamContinuation.finish()
            saveTask?.cancel()
        }
        
        /// <#Description#>
        public func save() {
            saveTask = Task {
                guard !isSaving else { return }
                isSaving = true
                defer { isSaving = false }
                
                do {
                    reportEditingEvent(.willSave)
                    
                    let evaluationErrors = try await group.evaluateExpressions()
                    if let firstEvaluationError = evaluationErrors.first?.error {
                        throw firstEvaluationError
                    }
                    
                    try Task.checkCancellation()
                    
                    guard !groupHasErrors else {
                        alertForValidationErrorsIsPresented = true
                        validationErrorVisibilityInternal = .visible
                        reportEditingEvent(.failed(SaveError.validationErrors))
                        return
                    }
                    
                    try await group.finishEditing()
                    reportEditingEvent(.saved)
                } catch {
                    finishEditingError = error
                    reportEditingEvent(.failed(error))
                }
            }
        }
        
        /// <#Description#>
        func navigateBack() {
            guard canGoBack else {
                Logger.featureFormView.warning("Cannot navigate backwards without history.")
                return
            }
            let top = backStack.removeLast()
            guard let form = form(for: top) else {
                Logger.featureFormView.warning("No ID for back navigation.")
                return
            }
            select(form: form, recordNavigation: false)
        }
        
        /// Unsets the active form.
        /// - Parameter clearBackStack: A Boolean value indicating whether the navigation
        /// history should also be cleared.
        public func clearSelection(clearBackStack: Bool = true) {
            guard let selectedID else { return }
            backStack.append(selectedID)
            self.selectedID = nil
            if clearBackStack {
                backStack.removeAll()
            }
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        public func remove(form: FeatureForm) {
            defer { formCount = group.forms.count }
            group.forms.forEach { _form in
                if form.feature.globalID == _form.feature.globalID {
                    try? group.removeForm(_form)
                }
            }
            backStack.removeAll { id in
                form.feature.globalID == id
            }
            if selectedID == form.feature.globalID, canGoBack {
                let top = backStack.removeLast()
                if let form = self.form(for: top) {
                    select(form: form)
                }
            }
        }
        
        /// <#Description#>
        /// - Parameter id: <#id description#>
        /// - Returns: <#description#>
        public func form(for id: UUID) -> FeatureForm? {
            group.forms.first { $0.feature.globalID == id } ?? nil
        }
        
        /// <#Description#>
        /// - Parameter globalID: <#globalID description#>
        /// - Returns: <#description#>
        func formModel(for globalID: UUID) -> FeatureFormView.FormModel? {
            if let model = formModels[globalID] {
                return model
            } else if let form = form(for: globalID) {
                let newModel = addFormModel(form)
                return newModel
            } else {
                return nil
            }
        }
        
        /// Creates a new `FormModel` and adds it to the set of models.
        /// - Parameters:
        ///   - form: <#form description#>
        ///   - isAssociation: <#isAssociation description#>
        /// - Returns: The new model.
        func addFormModel(_ form: FeatureForm, isAssociation: Bool = false) -> FormModel? {
            guard let globalID = form.feature.globalID else {
                Logger.featureFormView.error("Couldn't get GlobalID to make FormModel.")
                return nil
            }
            let newModel = FeatureFormView.FormModel(featureForm: form, createdViaUtilityAssociation: isAssociation)
            formModels[globalID] = newModel
            return newModel
        }
        
        /// <#Description#>
        /// - Parameters:
        ///   - form: <#feature description#>
        ///   - recordNavigation: <#recordNavigation description#>
        public func select(form: FeatureForm, recordNavigation: Bool = true, clearHistory: Bool = false) {
            guard form.feature.globalID != selectedID else { return }
            if recordNavigation, let selectedID {
                backStack.append(selectedID)
            }
            if clearHistory {
                backStack.removeAll()
            }
            selectedID = form.feature.globalID
        }
        
        var selectedModel: FormModel? {
            guard let selectedID else { return nil }
            return formModel(for: selectedID)
        }
        
        /// <#Description#>
        var allValidationErrorsAreVisible: Bool {
            groupHasErrors
            && (
                validationErrorVisibility == .visible
                || validationErrorVisibilityInternal == .visible
            )
            ? true
            : false
        }
        
        /// A Boolean value indicating whether the Back button in the toolbar should be shown.
        var showBackButton: Bool {
            guard let selectedModel else { return false }
            let selectedFormsPathIsEmpty = selectedModel.navigationPath.isEmpty
            return (selectedFormsPathIsEmpty && canGoBack)
            || !selectedFormsPathIsEmpty
        }
        
        /// A Boolean value indicating whether the Dismiss button in the toolbar should be shown.
        var showDismissButton: Bool {
            isPresented != nil
            && (!multiFormModeIsActive || selectedForm == nil)
        }
        
        /// A Boolean value indicating whether the Group Menu button in the toolbar should be shown.
        var showGroupMenuButton: Bool {
            multiFormModeIsActive
            && selectedForm != nil
        }
        
        /// A Boolean value indicating if the invalid geometry toolbar item should be shown.
        var showInvalidGeometryBadge: Bool {
            guard let selectedID,
                  let formModel = formModel(for: selectedID) else { return false }
            let hasInvalidGeometry = formModel.geometryStatus == .invalid
            return allValidationErrorsAreVisible &&
            hasInvalidGeometry
        }
        
        /// A Boolean value indicating whether the Save button in the toolbar should be shown.
        var showSaveButton: Bool {
            saveButtonVisibility != .hidden
            && (selectedForm == nil || !multiFormModeIsActive)
        }
        
        /// <#Description#>
        func goBack() {
            guard let selectedModel else { return }
            if selectedModel.navigationPath.isEmpty, canGoBack {
                // Back into the previous visited form in the group.
                navigateBack()
            } else if !selectedModel.navigationPath.isEmpty {
                // Back into the previous view in the current form's navigation path.
                selectedModel.navigationPath.removeLast()
            }
        }
        
        /// <#Description#>
        var totalErrorCount: Int {
            formModels.values.map({ $0.errorCount }).reduce(0, +)
        }
        
        func editStatusForForm(featureID id: UUID) -> Bool {
            formModel(for: id)?.hasAttributeOrGeometryEdits ?? false
        }
        
        func totalErrorCountForForm(featureID id: UUID) -> Int {
            formModel(for: id)?.errorCount ?? 0
        }
        
        /// A Boolean value indicating if the group has any forms with edits.
        var groupHasEdits: Bool {
            formModels.contains(where: { $0.value.hasAttributeOrGeometryEdits })
        }
        
        /// A Boolean value indicating if the group has any forms with validation errors.
        var groupHasErrors: Bool {
            totalErrorCount > 0
        }
    }
}
