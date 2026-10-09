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
    @MainActor @Observable
    class Model {
        /// A Boolean value that determines whether the view is presented.
        var isPresented: Bool?
        
        /// The visibility of the "save" and "discard" buttons.
        var editingButtonsVisibility: Visibility = .automatic
        /// A Boolean which declares whether navigation to forms for features associated via utility association
        /// form elements is disabled.
        var navigationIsDisabled = false
        /// The user-provided closure to perform when a new feature form is shown in the navigation stack.
        var onFeatureFormChanged: ((FeatureForm) -> Void)?
        /// The user-provided closure to perform when a ``EditingEvent`` occurs.
        var onFormEditingEventAction: FormEditingEventAction?
        /// The developer configurable validation error visibility.
        var validationErrorVisibilityExternal = ValidationErrorVisibility.automatic
        /// An action to run before finishing editing.
        ///
        /// If the action throws an error, `finishEditing` should not be
        /// called.
        var willFinishEditingAction: (() throws -> Void)?
        
        /// <#Description#>
        init(group: FeatureFormGroup? = nil) {
            self.group = group
        }
        
        /// Initializes a model for the view, creating a `FeatureFormGroup` with the provided
        /// forms.
        /// - Parameter forms: The initial set of forms to be edited in the view.
        public convenience init(forms: [FeatureForm]) {
            self.init(group: .init(forms: forms))
        }
        
        /// <#Description#>
        let group: FeatureFormGroup?
        
        /// <#Description#>
        var canGoBack: Bool {
            backStack.count > 0
        }
        
        /// <#Description#>
        public var count: Int? {
            group?.forms.count == ids.count ? group?.forms.count : -1
        }
        
        /// <#Description#>
        private(set) var selectedID: UUID?
        
        /// <#Description#>
        var selectedIndex: Int {
            if let selectedID {
                ids.firstIndex(of: selectedID) ?? -1
            } else {
                -1
            }
        }
        
        /// <#Description#>
        var ids: [UUID] {
            (group?.forms ?? []).compactMap { $0.feature.globalID }
        }
        
        /// <#Description#>
        var selectedForm: FeatureForm? {
            if let selectedID {
                form(for: selectedID) ?? nil
            } else {
                nil
            }
        }
        
        /// <#Description#>
        private var backStack = [UUID]()
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        /// - Parameter select: <#select description#>
        public func add(form: FeatureForm, select: Bool = false) {
            guard let id = form.feature.globalID else {
                Logger.featureFormGroupView.warning("The feature cannot be added because the its global ID is not available.")
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
                Logger.featureFormGroupView.info("Feature \(id.description) is already added.")
                return
            }
            group?.add(form)
        }
        
        public func debugLog() {
            print("Selected:", selectedID ?? "None")
            print("Can Go Back:", canGoBack)
            print("Back Stack \(backStack.count)")
            backStack.forEach { item in
                print("\t", item)
            }
            print("Forms With Errors \(formsWithErrors.count)")
            formsWithErrors.forEach { id in
                print("\t", id)
            }
            print("Browser Forms With Edits \(formsWithEdits.filter({$0.value}).count)")
            formsWithEdits.forEach { id in
                print("\t", id.key, id.value)
            }
            print("Browser Forms With Errors \(formsWithErrors.filter({$0.value > 0}).count)")
            formsWithErrors.forEach { id in
                print("\t", id, id.value)
            }
            print("--- End Debug Print ---")
        }
        
        /// <#Description#>
        func discardEdits() {
            Task {
                await group?.discardEdits()
            }
        }
        
        /// <#Description#>
        func finishEditing() {
            Task {
                await group?.finishEditing()
            }
        }
        
        /// <#Description#>
        func navigateBack() {
            guard canGoBack else {
                Logger.featureFormGroupView.warning("Cannot navigate backwards without history.")
                return
            }
            let top = backStack.removeFirst()
            guard let form = form(for: top) else {
                Logger.featureFormGroupView.warning("No ID for back navigation.")
                return
            }
            select(form: form, recordNavigation: false)
        }
        
        public func clearSelection() {
            selectedID = nil
            backStack.removeAll()
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        public func remove(form: FeatureForm) {
            group?.forms.forEach { _form in
                if form.feature.globalID == _form.feature.globalID {
                    group?.remove(_form)
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
            group?.forms.first { $0.feature.globalID == id } ?? nil
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
        public func selectNext() {
            guard ids.count > 1 else { return }
            guard selectedIndex >= 0 else { return }
            let nextIndex: Int
            if selectedIndex == ids.count - 1 {
                // Jump to start
                nextIndex = 0
            } else {
                nextIndex = selectedIndex + 1
            }
            guard let nextForm = group?.forms[nextIndex] else { return }
            select(form: nextForm, clearHistory: true)
        }
        
        /// <#Description#>
        public func selectPrevious() {
            guard ids.count > 1 else { return }
            guard selectedIndex >= 0 else { return }
            let previousIndex: Int
            if selectedIndex == 0 {
                // Jump to end
                previousIndex = ids.count - 1
            } else {
                previousIndex = selectedIndex - 1
            }
            guard let previousForm = group?.forms[previousIndex] else { return }
            select(form: previousForm, clearHistory: true)
        }
            
        private(set) var formsWithEdits = [UUID: Bool]()
        
        private(set) var formsWithErrors = [UUID: Int]()
        
        func monitorEdits() async {
            Logger.featureFormGroupView.info("Starting edit monitoring.")
            await withTaskGroup { taskGroup in
                for form in group?.forms ?? [] {
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
        
        func monitorErrors() async {
            Logger.featureFormGroupView.info("Starting error monitoring.")
            await withTaskGroup { taskGroup in
                for form in group?.forms ?? [] {
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
