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
    @EnvironmentObject var model: FormViewModel
    
    /// The phrase to use when filtering by coded value name.
    @State private var filterPhrase = ""
    
    /// A Boolean value indicating if the combo box picker is presented.
    @State private var isPresented = false
    
    /// A Boolean value indicating whether a value for the input is required.
    @State private var isRequired = false
    
    /// The selected option.
    @State private var selectedValue: CodedValue?
    
    /// The element's current (but unsupported) value.
    ///
    /// If the element has a value not in its domain, it has an unsupported value. This unsupported value is
    /// present until the user selects a value within the element's domain.
    @State private var unsupportedValue: String?
    
    /// The element's current value.
    @State private var value: Any?
    
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
        HStack {
            Text(unsupportedValue ?? selectedValue?.name ?? placeholderValue)
                .accessibilityIdentifier("\(element.label) Combo Box Value")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(selectedValue != nil ? .primary : .secondary)
            if selectedValue != nil, !isRequired {
                // Only show clear button if we have a value
                // and we're not required. (i.e., Don't show clear if
                // the field is required.)
                ClearButton {
                    model.focusedElement = element
                    defer { model.focusedElement = nil }
                    selectedValue = nil
                }
                .accessibilityIdentifier("\(element.label) Clear Button")
            } else {
                // Otherwise, always show list icon.
                Image(systemName: "list.bullet")
                    .accessibilityIdentifier("\(element.label) Options Button")
                    .foregroundColor(.secondary)
            }
        }
        .formInputStyle()
        .sheet(isPresented: $isPresented) {
            makePicker()
        }
        .onAppear {
            if let currentValue = element.codedValues.first(where: {
                $0.name == element.formattedValue
            }) {
                selectedValue = currentValue
            } else if !element.formattedValue.isEmpty {
                unsupportedValue = element.formattedValue
            }
        }
        .onTapGesture {
            model.focusedElement = element
            isPresented = true
        }
        .onChange(selectedValue) { selectedValue in
            unsupportedValue = nil
            element.updateValue(selectedValue?.code)
            model.evaluateExpressions()
        }
        .onValueChange(of: element) { newValue, newFormattedValue in
            value = newValue
            selectedValue = element.codedValues.first { $0.name == newFormattedValue }
        }
        .onIsRequiredChange(of: element) { newIsRequired in
            isRequired = newIsRequired
        }
    }
    
    /// The view that allows the user to filter and select coded values by name.
    ///
    /// Adds navigation context to support toolbar items and other visual elements in the picker.
    func makePicker() -> some View {
        NavigationStack {
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
                            makePickerRow(
                                label: noValueLabel.isEmpty ? String.noValue : noValueLabel,
                                selected: selectedValue == nil && unsupportedValue == nil
                            ) {
                                self.selectedValue = nil
                            }
                            .italic()
                            .foregroundStyle(.secondary)
                        }
                    }
                    ForEach(matchingValues, id: \.self) { codedValue in
                        makePickerRow(label: codedValue.name, selected: codedValue == selectedValue) {
                            self.selectedValue = codedValue
                        }
                    }
                    if let unsupportedValue {
                        Section {
                            makePickerRow(label: unsupportedValue, selected: true) { }
                                .italic()
                        } header: {
                            Text.unsupportedValue
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
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
    
    func makePickerRow(label: String, selected: Bool, action: @escaping () -> Void) -> some View {
        HStack {
            Button(label) { action() }
            Spacer()
            if selected {
                Image(systemName: "checkmark")
                    .foregroundColor(.accentColor)
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
        case (_, _):
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
