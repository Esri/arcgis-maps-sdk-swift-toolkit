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
        var onFeatureFormChanged: ((FeatureForm) -> Void)?
        /// The user-provided closure to perform when a ``EditingEvent`` occurs.
        var onFormEditingEventAction: FormEditingEventAction?
        
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
        private(set) var selectedID: UUID?
        
        /// <#Description#>
        var activeForms: [FeatureForm] {
            return ids.compactMap { id in
                let form = form(for: id)
                guard let globalID = form?.feature.globalID else { return nil }
                if (!browsedIDs.contains(globalID) || formsWithEdits[globalID, default: false]) {
                    return form
                } else {
                    return nil
                }
            }
        }
        
        /// The global IDs of the underlying feature for forms that have been opened via utility
        /// associations.
        var browsedIDs = Set<UUID>()
        
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
        var ids: [UUID] {
            group.forms.compactMap { $0.feature.globalID }
        }
        
        /// <#Description#>
        var selectedForm: FeatureForm? {
            if let selectedID {
                form(for: selectedID) ?? nil
            } else {
                nil
            }
        }
        
        /// An error thrown from finish editing.
        var finishEditingError: (any Error)?
        
        /// <#Description#>
        var navigationAlertInfo: (willNavigate: Bool, action: () -> Void)?
        
        /// Form view models, keyed by feature global IDs.
        private var formViewModels: [UUID: FeatureFormView.FormView.Model] = [:]
        
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
            defer { formCount = group.forms.count }
            guard let id = form.feature.globalID else {
                Logger.featureFormView.warning("The feature cannot be added because the its global ID is not available.")
                return
            }
            defer {
                // Select the form, if directed, or if not in list style and no
                // form is already selected, regardless of whether it's already
                // in the collection of managed forms.
                if select || selectedID == nil {
                    self.select(form: form)
                }
            }
            guard !ids.contains(id) else {
                let id: any CustomStringConvertible
                if let objectID = form.feature.objectID {
                    id = objectID
                } else if let globalID = form.feature.globalID {
                    id = globalID
                } else {
                    id = "?"
                }
                Logger.featureFormView.info("Feature \(id.description) is already added.")
                return
            }
            try? group.addForm(form)
            if recordAsBrowsed, !browsedIDs.contains(id) {
                browsedIDs.insert(id)
            }
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        /// - Parameter select: <#select description#>
        public func add(form: FeatureForm, select: Bool = false) {
            add(form: form, select: select, recordAsBrowsed: false)
        }
        
        /// <#Description#>
        @diagnose(DeprecatedDeclaration, as: ignored)
        public func discard() {
            let discard = {
                Task {
                    do {
                        try await self.group.discardEdits()
                        self.onFormEditingEventAction?(.discarded)
                        self.onFormEditingEventAction?(.discardedEdits(willNavigate: false))
                    } catch {
                        self.finishEditingError = error
                        self.onFormEditingEventAction?(.failed(error))
                    }
                    if self.isPresented != nil {
                        self.isPresented = false
                    }
                }
            }
            
            if groupHasErrors || groupHasEdits {
                validationErrorVisibilityInternal = .visible
                navigationAlertInfo = (false, {
                    _ = discard()
                })
            } else {
                _ = discard()
            }
        }
        
        /// <#Description#>
        @diagnose(DeprecatedDeclaration, as: ignored)
        public func save() {
            if !groupHasErrors {
                Task {
                    do {
                        onFormEditingEventAction?(.willSave)
                        let evaluationErrors = try await group.evaluateExpressions()
                        if let firstEvaluationError = evaluationErrors.first?.error {
                            throw firstEvaluationError
                        }
                        try await group.finishEditing()
                        onFormEditingEventAction?(.saved)
                        onFormEditingEventAction?(.savedEdits(willNavigate: false))
                    } catch {
                        finishEditingError = error
                        onFormEditingEventAction?(.failed(error))
                    }
                }
            } else {
                validationErrorVisibilityInternal = .visible
                navigationAlertInfo = (false, {})
            }
        }
        
        /// <#Description#>
        func navigateBack() {
            guard canGoBack else {
                Logger.featureFormView.warning("Cannot navigate backwards without history.")
                return
            }
            let top = backStack.removeFirst()
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
            backStack.insert(selectedID, at: 0)
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
                let top = backStack.removeFirst()
                if let form = self.form(for: top) {
                    select(form: form)
                }
            }
            selectedID = backStack.last
        }
        
        /// <#Description#>
        /// - Parameter id: <#id description#>
        /// - Returns: <#description#>
        public func form(for id: UUID) -> FeatureForm? {
            group.forms.first { $0.feature.globalID == id } ?? nil
        }
        
        func formModel(for globalID: UUID) -> FeatureFormView.FormView.Model? {
            if let model = formViewModels[globalID] {
                return model
            } else if let form = form(for: globalID) {
                let newModel = FeatureFormView.FormView.Model(featureForm: form)
                formViewModels[globalID] = newModel
                return newModel
            } else {
                return nil
            }
        }
        
        /// <#Description#>
        /// - Parameters:
        ///   - form: <#feature description#>
        ///   - recordNavigation: <#recordNavigation description#>
        public func select(form: FeatureForm, recordNavigation: Bool = true, clearHistory: Bool = false) {
            guard form.feature.globalID != selectedID else { return }
            if recordNavigation, let selectedID {
                backStack.insert(selectedID, at: 0)
            }
            if clearHistory {
                backStack.removeAll()
            }
            selectedID = form.feature.globalID
        }
        
        /// <#Description#>
        private(set) var formsWithEdits = [UUID: Bool]()
        
        /// <#Description#>
        private(set) var formsWithErrors = [UUID: Int]()
        
        var selectedModel: FormView.Model? {
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
            formsWithErrors.values.reduce(0, +)
        }
        
        /// A Boolean value indicating if the group has any forms with edits.
        var groupHasEdits: Bool {
            formsWithEdits.contains(where: { $0.value })
        }
        
        /// A Boolean value indicating if the group has any forms with validation errors.
        var groupHasErrors: Bool {
            totalErrorCount > 0
        }
        
        /// <#Description#>
        func monitorEdits() async {
            Logger.featureFormView.info("Starting edit monitoring.")
            await withTaskGroup { taskGroup in
                for form in group.forms {
                    taskGroup.addTask { @Sendable in
                        for await hasEdits in form.$hasEdits {
                            if let globalID = form.feature.globalID {
                                await MainActor.run {
                                    self.formsWithEdits[globalID] = hasEdits
                                }
                            }
                        }
                    }
                }
            }
        }
        
        /// <#Description#>
        func monitorErrors() async {
            Logger.featureFormView.info("Starting error monitoring.")
            await withTaskGroup { taskGroup in
                for form in group.forms {
                    taskGroup.addTask { @Sendable in
                        for await errors in form.$elementValidationErrors {
                            if let globalID = form.feature.globalID {
                                await MainActor.run {
                                    self.formsWithErrors[globalID] = errors.count
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
