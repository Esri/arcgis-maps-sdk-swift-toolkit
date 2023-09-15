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
    
    /// The feature form containing the input.
    private var featureForm: FeatureForm?
    
    /// The field's parent element.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: ComboBoxFormInput
    
    /// A subset of coded values with names containing `filterPhrase` or all of the coded values
    /// if `filterPhrase` is empty.
    var matchingValues: [CodedValue] {
        guard !filterPhrase.isEmpty else {
            return codedValues
        }
        return codedValues
            .filter { $0.name.localizedStandardContains(filterPhrase) }
    }
    
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
                Text(selectedValue?.name ?? placeholderValue)
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
                pickerRoot
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
            guard let current = codedValues.first(where: { $0.name == element.value }),
                  current != newValue else {
                return
            }
            requiredValueMissing = element.isRequired && newValue == nil
            featureForm?.feature.setAttributeValue(newValue?.code, forKey: element.fieldName)
        }
    }
    
    /// The root of the picker view.
    ///
    /// Adds navigation context to support toolbar items and other visual elements in the picker.
    /// - Note `NavigationView` is deprecated after iOS 17.0.
    @ViewBuilder var pickerRoot: some View {
        if #available(iOS 16, macCatalyst 16, *) {
            NavigationStack {
                picker
            }
        } else {
            NavigationView {
                picker
            }
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
        VStack {
            Text(element.description)
                .foregroundColor(.secondary)
                .font(.subheadline)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            List {
                if element.value.isEmpty && !element.isRequired {
                    if input.noValueOption == .show {
                        HStack {
                            Button(input.noValueLabel.isEmpty ? String.noValue : input.noValueLabel) {
                                selectedValue = nil
                            }
                            Spacer()
                            if selectedValue == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                ForEach(matchingValues, id: \.self) { codedValue in
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
            }
            .listStyle(.plain)
            .searchable(text: $filterPhrase, placement: .navigationBarDrawer, prompt: .filter)
            .navigationTitle(element.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Text.done
                            .bold()
                    }
                }
            }
        }
    }
}

extension ComboBoxInput {
    // The placeholder value to display.
    var placeholderValue: String {
        guard !element.isRequired else {
            return .enterValue
        }
        switch (input.noValueOption, input.noValueLabel.isEmpty) {
        case (.show, true):
            return .noValue
        case (.show, false):
            return input.noValueLabel
        case (.hide, _):
            return ""
        }
    }
}

private extension String {
    /// A label for a combo box input that prompts the user to enter a value.
    static var enterValue: Self {
        .init(
            localized: "Enter Value",
            bundle: .toolkitModule,
            comment: "A label for a combo box input that prompts the user to enter a value."
        )
    }
}
    
private extension Text {
    /// A label for a text entry field that allows the user to filter a list of values by name.
    static var filter: Self {
        .init(
            "Filter",
            bundle: .toolkitModule,
            comment: "A label for a text entry field that allows the user to filter a list of values by name."
        )
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
