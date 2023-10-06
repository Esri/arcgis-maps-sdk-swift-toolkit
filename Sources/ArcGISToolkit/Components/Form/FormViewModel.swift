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

/// - Since: 200.2
public class FormViewModel: ObservableObject {
    /// The geodatabase which holds the table and feature being edited in the form.
    @Published private var database: ServiceGeodatabase?
    
    /// The featured being edited in the form.
    @Published private(set) var feature: ArcGISFeature?
    
    /// The service feature table which holds the feature being edited in the form.
    @Published private var table: ServiceFeatureTable?
    
    /// The feature form.
    @Published private var featureForm: FeatureForm?
    
    /// The name of the current focused field, if one exists.
    @Published var focusedFieldName: String?
    
    /// The expression evaluation task.
    var evaluateTask: Task<Void, Never>? = nil
    
    /// The group of visibility tasks.
    private var isVisibleTasks = [Task<Void, Never>]()
    
    /// The list of visible form elements.
    @Published var visibleElements = [FormElement]()
    
    /// Initializes a form view model.
    public init() {}
    
    /// Prepares the feature for editing in the form.
    /// - Parameter feature: The feature to be edited in the form.
    public func startEditing(_ feature: ArcGISFeature, featureForm: FeatureForm) {
        self.feature = feature
        self.featureForm = featureForm
        if let table = feature.table as? ServiceFeatureTable {
            self.database = table.serviceGeodatabase
            self.table = table
        }
    }
    
    deinit {
        clearIsVisibleTasks()
    }
    
    func initializeIsVisibleTasks() {
        guard let featureForm else { return }
        clearIsVisibleTasks()
        
        // Kick off tasks to monitor isVisible for each element.
        featureForm.elements.forEach { element in
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
    
    /// A detached task observing visibility changes.
    private func updateVisibleElements() {
        guard let featureForm else { return }
        visibleElements = featureForm.elements.filter { $0.isVisible }
    }
    
    /// Cancels and removes tasks.
    private func clearIsVisibleTasks() {
        isVisibleTasks.forEach { task in
            task.cancel()
        }
        isVisibleTasks.removeAll()
    }
    
    internal func evaluateExpressions() {
        evaluateTask?.cancel()
        evaluateTask = Task {
            try? await featureForm?.evaluateExpressions()
        }
    }
    
    /// Reverts any local edits that haven't yet been saved to service geodatabase.
    public func undoEdits() {
        print(#file, #function)
    }
    
    /// Submit the changes made to the form.
    public func submitChanges() async {
        guard let table, table.isEditable, let feature, let database else {
            print("A precondition to submit the changes wasn't met.")
            return
        }
        
        try? await table.update(feature)
        
        guard database.hasLocalEdits else {
            print("No submittable changes found.")
            return
        }
        
        let results = try? await database.applyEdits()
        
        if results?.first?.editResults.first?.didCompleteWithErrors ?? false {
            print("An error occurred while submitting the changes.")
        }
    }
}
