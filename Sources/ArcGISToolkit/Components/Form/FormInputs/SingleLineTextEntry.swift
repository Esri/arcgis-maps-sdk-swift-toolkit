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

import FormsPlugin
import SwiftUI
import ArcGIS

/// A view for single line text entry.
struct SingleLineTextEntry: View {
    var readOnly = false
    
    @Environment(\.formElementPadding) var elementPadding
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// A Boolean value indicating whether or not the field is focused.
    @FocusState private var isFocused: Bool
    
//    /// The current text value.
//    @State private var text = ""
    
    /// The form element that corresponds to this text field.
    private let element: FieldFeatureFormElement
    @StateObject private var inputModel: TextFormInputModel

    /// A `TextBoxFeatureFormInput` which acts as a configuration.
    private let input: TextBoxFeatureFormInput
    
    /// Creates a view for single line text entry.
    /// - Parameters:
    ///   - element: The form element that corresponds to this text field.
    ///   - input: A `TextBoxFeatureFormInput` which acts as a configuration.
    init(element: FieldFeatureFormElement, input: TextBoxFeatureFormInput, updateMe: Bool = false) {
        self.element = element
        self.input = input
        
        _inputModel = StateObject(
            wrappedValue: TextFormInputModel(element: element, updateMe: updateMe)
        )
        
//        model.inputModels.append(inputModel)
    }
    
    /// - Bug: Focus detection works as of Xcode 14.3.1 but is broken as of Xcode 15 Beta 2.
    /// [More info](https://openradar.appspot.com/FB12432084)
    var body: some View {
        FormElementHeader(element: inputModel.element)
            .padding([.top], elementPadding)
        // `MultiLineTextEntry` uses secondary foreground color so it's applied here for consistency.
        Group {
            if inputModel.isEditable {
                HStack {
                    TextField(inputModel.element.label, text: $inputModel.text, prompt: Text(inputModel.element.hint ?? "").foregroundColor(.secondary))
                        .focused($isFocused)
                    if isFocused && !inputModel.text.isEmpty {
                        ClearButton { inputModel.text.removeAll() }
                    }
                }
            } else {
                Text(inputModel.text)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .formTextEntryStyle()
        TextEntryFooter(
            currentLength: inputModel.text.count,
            isFocused: isFocused,
            element: inputModel.element,
            input: input
        )
        .padding([.bottom], elementPadding)
        .onAppear {
            inputModel.text = model.feature?.attributes[element.fieldName] as? String ?? ""
            model.inputModels.append(inputModel)
        }
        .onChange(of: inputModel.text) { newValue in
            guard !inputModel.updateMe else { return }
            model.feature?.setAttributeValue(newValue, forKey: element.fieldName)
            inputModel.evaluateExpressions(model: model)
        }
    }
}

class InputModel {
}

class TextFormInputModel: ObservableObject {
    let element: FieldFeatureFormElement
    
    var updateMe: Bool
    
    @Published var isEditable = true
    @Published var isVisible = true
    @Published var isRequired = true
    @Published var text: String = ""
    
    private var evaluateTask: Task<Void, Never>?

    init(
        element: FieldFeatureFormElement,
        updateMe: Bool = false
    ) {
        self.element = element
        self.isEditable = !updateMe
        self.updateMe = updateMe
        
        // Will be replaced with `FieldFormElement.value`
        text = "temp" //element.value
    }
    
    @MainActor
    func update(/* stuff to update goes here, somehow ex*/ ) {
        // Will be replaced with `FieldFormElement.value`
        text = String.randomString(length: 8)
    }
    
    func evaluateExpressions(model: FormViewModel) {
        evaluateTask?.cancel()
        evaluateTask = Task {
            await model.evaluateExpressions()
        }
    }
}

extension String {
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
//
//class TextBoxInputModel: ObservableObject {
//    /// The form element that corresponds to this text field.
//    let element: FieldFeatureFormElement
//
//    /// The featured being edited in the form.
////    @Published private(set) var feature: ArcGISFeature?
//
//    var readOnly: Bool
//
//    private var evaluateTask: Task<Void, Never>?
//
//    /// The current text value.
//    @Published var text = ""
//
//    init(
//        element: FieldFeatureFormElement,
//        readOnly: Bool
//    ) {
//        self.element = element
//        self.readOnly = readOnly
//
//        // Will be replaced with `FieldFormElement.value`
//        text = "temp"
//    }
//
//    @MainActor
//    func update() {
//        // Will be replaced with `FieldFormElement.value`
//        if readOnly {
//            text = randomString(length: 8)
//        }
//    }
//
//    func randomString(length: Int) -> String {
//        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//        return String((0..<length).map{ _ in letters.randomElement()! })
//    }
//
////TODO: Figure out why the task isn't cancelling, but only appearing to cancel the "sleep" bit...
//    func evaluateExpressions(model: FormViewModel) {
//        evaluateTask?.cancel()
//        print("task cancelled:\(evaluateTask)")
//        evaluateTask = Task {
//            print("model.evaluateExpression(); readonly = \(readOnly)")
////            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
////            sleep(2)
//            await model.evaluateExpressions()
//            print("Task post-evaluateExpressions: \(evaluateTask)")
//        }
//        print("task created:\(evaluateTask)")
//    }
//}


/*
 - Cannot depend on "value" property in API to update UI
 - Need @Published/@State property to allow UI to update when "value" changes
 - "value" is initialized with "value" from API
 - When an expression is run which will change the underlying value, need to "update" value, which allows UI to update
 
 
 */
