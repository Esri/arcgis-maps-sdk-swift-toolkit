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
public class FormViewModel: ObservableObject {
    /// The geodatabase which holds the table and feature being edited in the form.
    @Published private var database: ServiceGeodatabase? = nil
    
    /// The featured being edited in the form.
    @Published private(set) var feature: ArcGISFeature? = nil
    
    /// The service feature table which holds the feature being edited in the form.
    @Published private var table: ServiceFeatureTable? = nil
    
    /// The structure of the form.
    @Published var formDefinition: FeatureFormDefinition? = nil
    
    /// The structure of the form.
    public var featureForm: FeatureForm? {
        didSet {
            featureForm?.elements.forEach { element in
                tasks.append(
                    Task.detached { [unowned self] in
                        for await _ in element.$isVisible {
                            //                print("isRequired changed: \(isRequired) for \(element.label)")
                            await MainActor.run {
                                visibleElements = featureForm!.elements.filter { $0.isVisible }
//                                visibleElements.removeAll()
//                                visibleElements.append(contentsOf: featureForm!.elements.filter { $0.isVisible })
                                print("visibleElements.count: \(visibleElements.count)")
                                //        print("isRequired: \(isRequired); self.isRequired: \(isRequired == nil ? element.isRequired : isRequired) for \(element.label)")
                            }
                        }
                    }
                )
            }
        }
    }

    /// The structure of the form.
    public var formElements = [FormElement]() {
        didSet {
            print("formElements: \(formElements)")
//            clearTasks()
            print("model.formElements.didSet")
            Task {
                await MainActor.run {
                    visibleElements.removeAll()
                    visibleElements.append(contentsOf: formElements.filter { $0.isVisible })
                }
//                formElements.forEach { element in
//                    tasks.append(
//                        Task.detached { [unowned self] in
//                            for await isVisible in element.$isVisible {
//                                print("isVisible changed: \(isVisible) for \(element.label)")
//                                await MainActor.run {
//                                    visibleElements.removeAll()
//                                    visibleElements.append(contentsOf: formElements.filter { $0.isVisible })
//                                    print("visibleElements: \(visibleElements)")
//                                }
//                            }
//                        })
//                }
            }
        }
    }

    /// The name of the current focused field, if one exists.
    @Published var focusedFieldName: String?
    
    @Published var visibleElements = [FormElement]()
    
    private var tasks = [Task<Void, Never>]()
    
    var evalutateTask: Task<Void, Never>? = nil

    deinit {
        clearTasks()
    }
    
    /// Cancels and removes tasks.
    private func clearTasks() {
        tasks.forEach { task in
            task.cancel()
        }
        tasks.removeAll()
    }

    /// Initializes a form view model.
    public init() {}
    
    //    public func monitorIsVisible() async {

//        await withTaskGroup(of: Void.self) { group in
//            for element in featureForm.elements {
//                group.addTask {
//                    for await isVisible in $0.$isVisible {
//                        elements = featureForm.elements.filter { $0.isVisible }
//                    }
//                }
//            }
//        }
//    }

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
    
    public func outputIsVisible(featureForm: FeatureForm) {
        featureForm.elements.forEach { element in
            print("element: \(element.label) isVisible = \(element.isVisible)")
        }
    }
}
