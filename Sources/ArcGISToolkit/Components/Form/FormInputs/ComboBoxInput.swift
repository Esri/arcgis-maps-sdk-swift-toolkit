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
    
    /// The set of options in the combo box.
    @State private var codedValues = [CodedValue]()
    
    /// A Boolean value indicating if the combo box picker is presented.
    @State private var isPresented = false
    
    /// The phrase to use when filtering by coded value name.
    @State private var filterPhrase = ""
    
    /// The selected option.
    @State private var selectedValue: CodedValue?
    
    /// The parent form interface.
    private var featureForm: FeatureForm?
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: ComboBoxFormInput
    
    /// Creates a view for a combo box input.
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
        VStack(alignment: .leading) {
            FormElementHeader(element: element)
                .padding([.top], elementPadding)
            
            HStack {
                Text(selectedValue?.name ?? "No value")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(selectedValue != nil ? .primary : .secondary)
                
                if selectedValue == nil {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.secondary)
                } else {
                    ClearButton { selectedValue = nil }
                        .accessibilityIdentifier("\(element.label) Clear Button")
                }
            }
            .formTextInputStyle()
            .sheet(isPresented: $isPresented) {
                picker
            }
            .onTapGesture {
                 isPresented = true
            }
            
            footer
        }
        .padding([.bottom], elementPadding)
        .onAppear {
            codedValues = featureForm!.codedValues(fieldName: element.fieldName)
            selectedValue = codedValues.first { $0.name == element.value }
        }
        .onChange(of: selectedValue) { newValue in
            featureForm?.feature.setAttributeValue(newValue?.code, forKey: element.fieldName)
        }
    }
    
    /// The message shown below the picker.
    @ViewBuilder var footer: some View {
        Text(element.description)
            .font(.footnote)
            .foregroundColor(.secondary)
    }
    
    /// The view that allows the user to filter and select coded values by name.
    var picker: some View {
        NavigationView {
            VStack {
                Text(element.description)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                List(codedValues, id: \.self) { codedValue in
                    HStack {
                        Button(codedValue.name) {
                            selectedValue = codedValue
                        }
                        Spacer()
                        if codedValue == selectedValue {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                    }
                }
                .listStyle(.plain)
                .searchable(text: $filterPhrase, placement: .navigationBarDrawer, prompt: "Filter")
                .navigationTitle(element.label)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            isPresented = false
                        } label: {
                            Text("Done")
                                .bold()
                        }
                    }
                }
            }
        }
    }
}

extension CodedValue: Equatable {
    /// - Note: Equatable conformance added temporarily in lieu of finalized API.
    public static func == (lhs: CodedValue, rhs: CodedValue) -> Bool {
        lhs.name == rhs.name
    }
}

extension CodedValue: Hashable {
    /// - Note: Hashable conformance added temporarily in lieu of finalized API.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

extension FeatureForm {
    /// - Note: This property added temporarily in lieu of finalized API.
    func codedValues(fieldName: String) -> [CodedValue] {
        if let field = feature.table?.field(named: fieldName),
           let domain = field.domain as? CodedValueDomain {
            return domain.codedValues
        } else {
            return []
        }
    }
}
