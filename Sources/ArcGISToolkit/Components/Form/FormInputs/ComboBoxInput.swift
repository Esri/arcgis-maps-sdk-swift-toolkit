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

struct ComboBoxInput: View {
    @Environment(\.formElementPadding) var elementPadding
    
    private var featureForm: FeatureForm?
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: ComboBoxFormInput
    
    @State private var value: Bool?
    
    enum Flavor: String, CaseIterable, Identifiable {
        case chocolate, vanilla, strawberry
        var id: Self { self }
    }
    
    @State private var selectedName: String?
    
    /// Creates a view for a Switch input.
    /// - Parameters:
    ///   - featureForm: The feature form containing the input.
    ///   - element: The field's parent element.
    ///   - input: The input configuration of the field.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: ComboBoxFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.input = input
    }
    
    var body: some View {
        VStack {
            FormElementHeader(element: element)
                .padding([.top], elementPadding)
            
            // Need to figure out $selectedValue, given that codedValue.code is an "Object"
            // CodedValue is equatable and hashable, so maybe that's enough??
            Picker("element.label", selection: $selectedName) {
                Text("coded values go here")
//                ForEach(element.codedValues) { codedValue in
//                    Text(codedValue.name)
//                        .tag(codedValue.code)
//                }
            }
//                Picker("Flavor", selection: $selectedFlavor) {
//                    Text("Chocolate").tag(Flavor.chocolate)
//                    Text("Vanilla").tag(Flavor.vanilla)
//                    Text("Strawberry").tag(Flavor.strawberry)
//                }
            .pickerStyle(.menu)
            
            footer
        }
        .padding([.bottom], elementPadding)
        .onAppear {
            //            if let value = element.value {  // returns name for CodedValues
            //                switchState = (value == input.onValue.name)
            //            }
            if let codedValue = featureForm?.feature.attributes[element.fieldName] as? CodedValue {
                selectedName = codedValue.name
            }
        }
        .onChange(of: selectedName) { newValue in
//            let codedValue = element.codedValues.first { $0.name == newValue }
//            // element.updateValue(codedValue)
//            featureForm?.feature.setAttributeValue(codedValue, forKey: element.fieldName)
        }
    }
    
    /// The message shown below the date editor and viewer.
    @ViewBuilder var footer: some View {
        Text(element.description)
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}
