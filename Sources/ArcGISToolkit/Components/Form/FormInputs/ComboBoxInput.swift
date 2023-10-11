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

/// A view for numerical value input.
///
/// This is the preferable input type for long lists of coded value domains.
struct ComboBoxInput: View {
    @Environment(\.formElementPadding) var elementPadding
    
    /// The model for the ancestral form view.
    @EnvironmentObject var model: FormViewModel
    
    /// The set of options in the combo box.
    @State private var codedValues = [CodedValue]()
    
    /// A Boolean value indicating if the combo box picker is presented.
    @State private var isPresented = false
    
    /// The phrase to use when filtering by coded value name.
    @State private var filterPhrase = ""
    
    /// A Boolean value indicating whether a value is required but missing.
    @State private var requiredValueMissing = false
    
    /// The selected option.
    @State private var selectedValue: CodedValue?
    
    /// The feature form containing the input.
    private var featureForm: FeatureForm?
    
    /// The input's parent element.
    private let element: FieldFormElement
    
    /// The text used to represent a `nil` value.
    private let noValueLabel: String
    
    /// The display state value for `nil` value options.
    private let noValueOption: FormInputNoValueOption
    
    /// The model for the input.
    @StateObject var inputModel: FormInputModel
    
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
    ///   - element: The input's parent element.
    ///   - input: The input configuration of the view.
    init(featureForm: FeatureForm?, element: FieldFormElement, input: ComboBoxFormInput) {
        self.featureForm = featureForm
        self.element = element
        self.noValueLabel = input.noValueLabel
        self.noValueOption = input.noValueOption
        
        _inputModel = StateObject(
            wrappedValue: FormInputModel(fieldFormElement: element)
        )
    }
    
    /// Creates a view for a combo box input.
    /// - Parameters:
    ///   - featureForm: The feature form containing the input.
    ///   - element: The input's parent element.
    ///   - noValueLabel: The text used to represent a `nil` value.
    ///   - noValueOption: The display state value for `nil` value options.
    init(featureForm: FeatureForm?, element: FieldFormElement, noValueLabel: String, noValueOption: FormInputNoValueOption) {
        self.featureForm = featureForm
        self.element = element
        self.noValueLabel = noValueLabel
        self.noValueOption = noValueOption
        
        _inputModel = StateObject(
            wrappedValue: FormInputModel(fieldFormElement: element)
        )
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            InputHeader(label: element.label, isRequired: inputModel.isRequired)
                .padding([.top], elementPadding)
            
            HStack {
                Text(selectedValue?.name ?? placeholderValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(selectedValue != nil ? .primary : .secondary)
                    .accessibilityIdentifier("\(element.label) Value")
                if selectedValue == nil {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.secondary)
                        .accessibilityIdentifier("\(element.label) Options Button")
                } else if !inputModel.isRequired && inputModel.isEditable  {
                    ClearButton { selectedValue = nil }
                        .accessibilityIdentifier("\(element.label) Clear Button")
                }
            }
            .formInputStyle()
            // Pass `matchingValues` via a capture list so that the sheet receives up-to-date values.
            .sheet(isPresented: $isPresented) { [matchingValues] in
                makePicker(for: matchingValues)
            }
            .onTapGesture {
                isPresented = true
            }
            
            InputFooter(element: element, requiredValueMissing: requiredValueMissing)
        }
        .padding([.bottom], elementPadding)
        .onAppear {
            codedValues = featureForm!.codedValues(fieldName: element.fieldName)
            selectedValue = codedValues.first { $0.name == element.value }
        }
        .onChange(of: selectedValue) { newValue in
            guard newValue?.name != inputModel.value else {
                return
            }

            requiredValueMissing = element.isRequired && newValue == nil
            featureForm?.feature.setAttributeValue(newValue?.code, forKey: element.fieldName)
            model.evaluateExpressions()
        }
        .onChange(of: inputModel.value) { newValue in
            let codedValues = featureForm!.codedValues(fieldName: element.fieldName)
            selectedValue = codedValues.first { $0.name == newValue }
        }
    }
    
    /// The view that allows the user to filter and select coded values by name.
    ///
    /// Adds navigation context to support toolbar items and other visual elements in the picker.
    /// - Note `NavigationView` is deprecated after iOS 17.0.
    func makePicker(for values: [CodedValue]) -> some View {
        let picker = {
            VStack {
                Text(element.description)
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Divider()
                List {
                    if !element.isRequired {
                        if noValueOption == .show {
                            HStack {
                                Button {
                                    selectedValue = nil
                                } label: {
                                    Text(noValueLabel.isEmpty ? String.noValue : noValueLabel)
                                        .italic()
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if selectedValue == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                    }
                    ForEach(values, id: \.self) { codedValue in
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
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        
        if #available(iOS 16, macCatalyst 16, *) {
            return NavigationStack {
                picker()
            }
        } else {
            return NavigationView {
                picker()
            }
        }
    }
}

extension ComboBoxInput {
    /// The placeholder value to display.
    var placeholderValue: String {
        guard !element.isRequired else {
            return .enterValue
        }
        switch (noValueOption, noValueLabel.isEmpty) {
        case (.show, true):
            return .noValue
        case (.show, false):
            return noValueLabel
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
