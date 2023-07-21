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
import FormsPlugin
import SwiftUI

public class FormViewModel: ObservableObject {
    /// The geodatabase which holds the table and feature being edited in the form.
    @Published private var database: ServiceGeodatabase?
    
    /// The featured being edited in the form.
    @Published private(set) var feature: ArcGISFeature?
    
    /// The structure of the form.
    @Published var formDefinition: FeatureFormDefinition?
    
    /// The service feature table which holds the feature being edited in the form.
    @Published private var table: ServiceFeatureTable?
    
    var inputModels = [TextFormInputModel]()
    
    /// Initializes a form view model.
    public init() {}
    
    /// Prepares the feature for editing in the form.
    /// - Parameter feature: The feature to be edited in the form.
    public func startEditing(_ feature: ArcGISFeature) {
        self.feature = feature
        if let table = feature.table as? ServiceFeatureTable {
            self.database = table.serviceGeodatabase
            self.table = table
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
    
    func evaluateExpressions() async {
        // Dummy function to simulate a value changing in response to an
        // expression evalation.
        // The actual check here may be to compare the feature attribute
        // to the inputModel.text(maybe .value?) and if different, set
        // the new value on the model.
        // Update models with changed values
        try? await Task.sleep(nanoseconds: 5 * 100_000_000)
        if Task.isCancelled { return }

        inputModels.forEach { inputModel in
            if inputModel.updateMe {
                DispatchQueue.main.async {
                    inputModel.update()
                }
            }
        }
    }
}
