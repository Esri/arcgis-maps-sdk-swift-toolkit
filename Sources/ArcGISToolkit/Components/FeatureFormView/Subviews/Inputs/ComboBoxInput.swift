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
    /// The view model for the form.
    @Environment(EmbeddedFeatureFormViewModel.self) private var embeddedFeatureFormViewModel
    
    /// The phrase to use when filtering by coded value name.
    @State private var filterPhrase = ""
    /// A Boolean value indicating if the combo box picker is presented.
    @State private var isPresented = false
    /// A Boolean value indicating whether a value for the input is required.
    @State private var isRequired = false
    /// The selected value.
    @State private var selectedValue: ComboBoxValue? = nil
    
    /// The element the input belongs to.
    private let element: FieldFormElement
    /// The text used to represent a `nil` value.
    private let noValueLabel: String
    /// The display state value for `nil` value options.
    private let noValueOption: FormInputNoValueOption
    
    /// A subset of coded values with names containing `filterPhrase` or all of the coded values
    /// if `filterPhrase` is empty.
    var matchingValues: [CodedValue] {
        guard !filterPhrase.isEmpty else {
            return element.codedValues
        }
        return element.codedValues
            .filter { $0.name.localizedStandardContains(filterPhrase) }
    }
    
    /// Creates a view for a combo box input.
    /// - Parameters:
    ///   - element: The input's parent element.
    init(element: FieldFormElement) {
        precondition(
            element.input is ComboBoxFormInput,
            "\(Self.self).\(#function) element's input must be \(ComboBoxFormInput.self)."
        )
        self.element = element
        let input = element.input as! ComboBoxFormInput
        self.noValueLabel = input.noValueLabel
        self.noValueOption = input.noValueOption
    }
    
    /// Creates a view for a combo box input.
    /// - Parameters:
    ///   - element: The input's parent element.
    ///   - noValueLabel: The text used to represent a `nil` value.
    ///   - noValueOption: The display state value for `nil` value options.
    init(element: FieldFormElement, noValueLabel: String, noValueOption: FormInputNoValueOption) {
        self.element = element
        self.noValueLabel = noValueLabel
        self.noValueOption = noValueOption
    }
    
    var body: some View {
        Button {
            embeddedFeatureFormViewModel.focusedElement = element
            isPresented = true
        } label: {
            HStack {
                Text(displayedValue)
                    .accessibilityIdentifier("\(element.label) Combo Box Value")
                Spacer()
                if selectedValue?.codedValue != nil, !isRequired {
                    // Only show clear button if we have a value
                    // and we're not required. (i.e., Don't show clear if
                    // the field is required.)
                    XButton(.clear) {
                        embeddedFeatureFormViewModel.focusedElement = element
                        defer { embeddedFeatureFormViewModel.focusedElement = nil }
                        updateValueAndEvaluateExpressions(nil)
                    }
                    .accessibilityIdentifier("\(element.label) Clear Button")
                    .buttonStyle(.plain)
                } else {
                    // Otherwise, always show chevron.
                    Image(systemName: "chevron.right")
                        .accessibilityIdentifier("\(element.label) Options Button")
                }
            }
            .foregroundStyle(selectedValue != .none ? .primary : .secondary)
            .tint(.primary)
        }
        .onIsRequiredChange(of: element) { newIsRequired in
            isRequired = newIsRequired
        }
        .onValueChange(of: element) { newValue, newFormattedValue in
            if let currentValue = element.codedValues.first(where: {
                $0.name == newFormattedValue
            }) {
                selectedValue = .coded(currentValue)
            } else if newValue != nil {
                selectedValue = .unsupported(newFormattedValue)
            } else {
                selectedValue = .none
            }
        }
        .sheet(isPresented: $isPresented) {
            makePicker()
        }
    }
}

extension ComboBoxInput {
    var displayedValue: String {
        switch selectedValue {
        case .coded(let codedValue):
            codedValue.name
        case .unsupported(let string):
            string
        case .none:
            placeholderValue
        }
    }
    
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
        case (_, _):
            return ""
        }
    }
    
    
    /// The view that allows the user to filter and select coded values by name.
    ///
    /// Adds navigation context to support toolbar items and other visual elements in the picker.
    private func makePicker() -> some View {
        NavigationStack {
            List {
                Section(element.description) {
                    Picker(element.description, selection: $selectedValue) {
                        if !element.isRequired, noValueOption == .show {
                            Text(noValueLabel.isEmpty ? String.noValue : noValueLabel)
                                .foregroundStyle(.secondary)
                                .tag(nil as ComboBoxValue?)
                        }
                        ForEach(matchingValues, id: \.self) { codedValue in
                            Text(codedValue.name)
                                .tag(ComboBoxValue.coded(codedValue))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
                .textCase(.none)
                if let unsupportedValue = selectedValue?.unsupportedValue {
                    Section {
                        Picker(selection: $selectedValue) {
                            Text(unsupportedValue)
                                .italic()
                                .tag(ComboBoxValue.unsupported(unsupportedValue))
                        } label: {
                            Text.unsupportedValue
                        }
                        .labelsHidden()
                        .pickerStyle(.inline)
                    } header: {
                        Text.unsupportedValue
                    }
                    .accessibilityIdentifier("\(element.label) Unsupported Value Section")
                    .textCase(.none)
                }
            }
            .searchable(text: $filterPhrase, placement: .navigationBarDrawer, prompt: .filter)
            .navigationTitle(element.label)
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedValue) {
                guard case let .coded(value) = selectedValue else { return }
                updateValueAndEvaluateExpressions(value)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isPresented = false
                    } label: {
                        Text.done
                            .fontWeight(.semibold)
#if !os(visionOS)
                            .foregroundStyle(Color.accentColor)
#endif
                    }
#if !os(visionOS)
                    .buttonStyle(.plain)
#endif
                }
            }
        }
    }
    
    private func updateValueAndEvaluateExpressions(_ value: CodedValue?) {
        guard value?.name != element.formattedValue else { return }
        element.updateValue(value?.code)
        embeddedFeatureFormViewModel.evaluateExpressions()
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
    
    static var unsupportedValue: Self {
        .init(
            "Unsupported Value",
            bundle: .toolkitModule,
            comment: "A label for a section in a list of possible values that contains a single value outside the list of valid values."
        )
    }
}

extension ArcGIS.CodedValue: Swift.Equatable {
    public static func == (lhs: CodedValue, rhs: CodedValue) -> Bool {
        lhs.name == rhs.name
    }
}

extension ArcGIS.CodedValue: Swift.Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

private enum ComboBoxValue: Equatable {
    case coded(CodedValue)
    /// The element's current (but unsupported) value.
    ///
    /// If the element has a value not in its domain, it has an unsupported value. This unsupported value is
    /// present until the user selects a value within the element's domain.
    case unsupported(String)
    
    var codedValue: CodedValue? {
        switch self {
        case .coded(let codedValue):
            codedValue
        default:
            nil
        }
    }
    
    var unsupportedValue: String? {
        switch self {
        case .unsupported(let string):
            string
        default:
            nil
        }
    }
}

extension ComboBoxValue: Hashable {}
