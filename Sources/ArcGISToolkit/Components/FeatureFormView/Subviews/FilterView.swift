// Copyright 2026 Esri
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

/// A view allowing the user to assemble a list of `FieldFilter` objects used to filter a list of features.
struct FilterView: View {
    /// The model used by the view.
    @Bindable var model: FilterViewModel
    /// A Boolean value indicating whether an alert is presented stating that there are changes that need to be saved or discarded. 
    @State private var alertIsPresented = false
    
    /// The index of the filter with a focused text field.
    @FocusState private var focusedTextField: Int?
    
    /// The client-specified action to perform when the `Apply` button is tapped. There is no `Cancel` action
    /// as cancelling simply resets the list of `FieldFilter` objects.
    var onApplyAction: (() -> Void)?
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                if model.fieldFilters.isEmpty {
                    ContentUnavailableView {
                        Label {
                            Text(
                                "No conditions added",
                                bundle: .toolkitModule,
                                comment: "A label indicating no field filtering conditions have been added."
                            )
                            .font(.title3)
                            .fontWeight(.bold)
                            Text(
                                "Show features that meet all the conditions",
                                bundle: .toolkitModule,
                                comment: "A label indicating the intended outcome of using the filter view."
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom)
                        } icon: {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.largeTitle)
                                .foregroundStyle(.gray)
                                .padding()
                        }
                    } actions: {
                        AddButton(focusedField: $focusedTextField, useBorderedStyle: true)
                    }
                } else {
                    List {
                        ForEach(model.fieldFilters, id: \.id) { filter in
                            if let index = model.fieldFilters.firstIndex(of: filter) {
                                Section {
                                    FieldView(
                                        fieldFilter: filter,
                                        focusedField: $focusedTextField,
                                        index: index
                                    )
                                } header: {
                                    HStack {
                                        Text(
                                            String(
                                                localized: "Condition \(index + 1)",
                                                bundle: .toolkitModule,
                                                comment: "A label for a control representing a condition and position index used to filter fields in a table."
                                            )
                                        )
                                        Spacer()
                                        Menu {
                                            // Duplicate the current filter.
                                            duplicateButton(filter)
                                            // Delete the current filter.
                                            deleteButton(filter)
                                        } label: {
                                            Label {
                                                Text(
                                                    "Condition \(index + 1) Options",
                                                    bundle: .toolkitModule,
                                                    comment: "A label for button to a open a menu with options for a condition used to filter fields in a table."
                                                )
                                            } icon: {
                                                Image(systemName: "ellipsis.circle")
                                                    .imageScale(.large)
                                                    .tint(.secondary)
                                            }
                                            .labelStyle(.iconOnly)
                                        }
                                    }
                                }
                            }
                        }
                        .onDelete { offsets in
                            withAnimation {
                                model.fieldFilters.remove(atOffsets: offsets)
                            }
                        }
                    }
                    .onChange(of: model.fieldFilters) { oldValue, newValue in
                        // Scroll to the last filter when a filter is added.
                        // For delete, do nothing.
                        if oldValue.count < newValue.count,
                           let lastFieldFilter = model.fieldFilters.last {
                            withAnimation {
                                proxy.scrollTo(lastFieldFilter.id, anchor: .top)
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        AddButton(focusedField: $focusedTextField)
                            .padding()
                        Spacer()
                    }
                }
            }
            Spacer()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        DismissButton(kind: .cancel) {
                            if model.hasChanges {
                                alertIsPresented = true
                            } else {
                                model.cancel()
                            }
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        DismissButton(kind: .confirm) {
                            model.apply()
                            if let onApplyAction {
                                onApplyAction()
                            }
                        }
                    }
                }
        }
        .environment(model)
        .background(Color(.systemGroupedBackground))
        .alert(
            Text(
                "Filters have not been applied",
                bundle: .toolkitModule,
                comment: "A notice used when closing the view that the filters have not been applied/saved."
            ),
            isPresented: $alertIsPresented
        ) {
            Button(role: .destructive) {
                model.cancel()
            } label: {
                Text.discardEdits
            }
        } message: {
            Text(
                "Are you sure you want to discard the changes?",
                bundle: .toolkitModule,
                comment: "A question asking for confirmation to discard changes."
            )
        }
    }
    
    /// Creates a `Button` that deletes the specified `FieldFilter`.
    /// - Parameter filter: The `FieldFilter` to delete.
    /// - Returns: The delete `Button`.
    private func deleteButton(_ filter: FieldFilter) -> Button<some View> {
        Button.delete {
            if let index = model.fieldFilters.firstIndex(of: filter) {
                focusedTextField = nil
                model.fieldFilters.remove(at: index)
            }
        }
    }
    
    /// Creates a `Button` that duplicates the specified `FieldFilter`.
    /// - Parameter filter: The `FieldFilter` to duplicate.
    /// - Returns: The duplicate `Button`.
    private func duplicateButton(_ filter: FieldFilter) -> Button<some View> {
        Button {
            if let index = model.fieldFilters.firstIndex(of: filter) {
                let newFilter = filter.copy()
                focusedTextField = nil
                withAnimation {
                    model.fieldFilters.insert(newFilter, at: index + 1)
                }
            }
        } label: {
            Label {
                Text(
                    "Duplicate",
                    bundle: .toolkitModule,
                    comment: "A label for a button to duplicate a field filter."
                )
            } icon: {
                Image(systemName: "document.on.document")
            }
        }
    }
}

#Preview {
    let fields: [Field] = [
        Field(type: .int32, name: "fieldOne", alias: "One", length: 30, isNullable: false),
        Field(type: .int32, name: "fieldTwo", alias: "Two", length: 30, isNullable: false),
        Field(type: .int32, name: "fieldThree", alias: "Three", length: 30, isNullable: false)
    ]
    let model = FilterViewModel()
    
    FilterView(model: model)
        .onAppear {
            model.setFields(fields)
        }
}

/// A button that adds a `FieldFilter` to the current  list of `FieldFilter` objects.
private struct AddButton: View {
    /// The index of the filter with a focused text field.
    let focusedField: FocusState<Int?>.Binding
    /// A Boolean value indicating whether to draw the button with a border style.
    let useBorderedStyle: Bool
    
    /// Creates an `AddButton`, alternately displaying it with a border style.
    /// - Parameter focusedField: The index of the filter with a focused text field.
    /// - Parameter useBorderedStyle: A Boolean value indicating whether to draw the button with a border style.
    init(focusedField: FocusState<Int?>.Binding, useBorderedStyle: Bool = false) {
        self.focusedField = focusedField
        self.useBorderedStyle = useBorderedStyle
    }
    
    @Environment(FilterViewModel.self) private var model
    var body: some View {
        Button {
            withAnimation {
                let newFilter = FieldFilter(field: model.fields.first ?? Field(type: .blob, name: "Empty", alias: "Empty"))
                focusedField.wrappedValue = nil
                model.fieldFilters.append(newFilter)
            }
        } label: {
            HStack {
                Image(systemName: "plus")
                    .modify {
                        if useBorderedStyle {
                            $0.imageScale(.large)
                                .padding(4)
                        } else {
                            $0.foregroundColor(.white)
                                .padding(4)
                                .background(Circle().fill(Color.blue))
                        }
                    }
                Text(
                    "Add Condition",
                    bundle: .toolkitModule,
                    comment: "A label for a button to add a new field filtering condition."
                )
                .modify {
                    if useBorderedStyle {
                        $0.padding(.trailing)
                    }
                }
            }
            .bold()
        }
        .id("AddButton")
        .modify {
            if useBorderedStyle {
                $0.buttonBorderShape(.automatic)
                    .buttonStyle(.borderedProminent)
                    .shadow(radius: 8)
            }
        }
    }
}

/// A view representing a single `FieldFilter`, with options to select a field and condition/operation, and to set a value for the operation.
private struct FieldView: View {
    /// The model used by the view.
    @Environment(FilterViewModel.self) private var model
    
    /// The `FieldFilter` represented by the view.
    @State private var fieldFilter: FieldFilter
    
    /// The list of conditions/operations the user is allowed to choose from.
    @State private var conditions = [FilterOperator]()
    
    /// The index of the filter with a focused text field.
    let focusedField: FocusState<Int?>.Binding
    
    /// The index of this field in the set of fields in the filter.
    let index: Int
    
    init(fieldFilter: FieldFilter, focusedField: FocusState<Int?>.Binding, index: Int) {
        self.fieldFilter = fieldFilter
        self.focusedField = focusedField
        self.index = index
    }
    
    var body: some View {
        Group {
            // Field
            if model.fields.isEmpty {
                HStack {
                    Text.field
                    Spacer()
                    Text(fieldFilter.field.title)
                }
            } else {
                HStack {
                    Picker(selection: $fieldFilter.selectedFieldName) {
                        ForEach(model.fields, id: \.name) { field in
                            Text(field.title)
                        }
                    } label: {
                        Text.field
                    }
                    .pickerStyle(.menu)
                    .tint(.primary)
                    .onChange(of: fieldFilter.selectedFieldName) {
                        guard let field = model.field(named: fieldFilter.selectedFieldName) else { return }
                        fieldFilter.field = field
                        conditions = fieldFilter.supportedConditions
                    }
                }
            }
            
            // Condition
            HStack {
                Picker(selection: $fieldFilter.condition) {
                    ForEach(conditions, id: \.self) { condition in
                        condition.displayName
                    }
                } label: {
                    Text(
                        "Condition",
                        bundle: .toolkitModule,
                        comment: "A label for a control to pick a condition to filter fields in a table against."
                    )
                }
                .pickerStyle(.menu)
                .tint(.primary)
            }
            .onAppear {
                conditions = fieldFilter.supportedConditions
            }
            
            // Value
            if !fieldFilter.condition.isUnary {
                if [FieldType.date, .dateOnly].contains(fieldFilter.field.type) {
                    DatePicker(
                        selection: $fieldFilter.dateValue,
                        displayedComponents: fieldFilter.field.type == .date ? [.date, .hourAndMinute] : [.date]
                    ) {
                        Text.value
                    }
                } else if let domain = fieldFilter.field.domain as? CodedValueDomain {
                    Picker(selection: $fieldFilter.codedValue) {
                        ForEach(domain.codedValues, id: \.self) {
                            Text($0.name)
                                .tag($0)
                        }
                    } label: {
                        Text.value
                    }
                } else {
                    HStack {
                        Text.value
                        Spacer()
                        TextField(
                            text: $fieldFilter.value,
                            prompt: Text(
                                "Enter a value",
                                bundle: .toolkitModule,
                                comment: "A prompt for a text field to enter a value."
                            ),
                            label: {
                                Text.value
                            }
                        )
                        .multilineTextAlignment(.trailing)
                        .keyboardType(keyboardType)
                        .focused(focusedField, equals: index)
                        .frame(alignment: .trailing)
#if os(iOS)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                if UIDevice.current.userInterfaceIdiom == .phone, (fieldFilter.field.type?.isNumeric ?? false) {
                                    // Known SwiftUI issue: This button is known to sometimes not appear.
                                    positiveNegativeButton
                                    Spacer()
                                }
                            }
                        }
#endif
                    }
                }
            }
        }
        .id(fieldFilter.id)
    }
    
    /// The button that allows a user to switch the numeric value between positive and negative.
    var positiveNegativeButton: some View {
        Button(positiveNegativeButtonLabel, systemImage: "plus.forwardslash.minus") {
            if let value = Int(fieldFilter.value) {
                fieldFilter.value = String(value * -1)
            } else if let value = Float(fieldFilter.value) {
                fieldFilter.value = String(value * -1)
            } else if let value = Double(fieldFilter.value) {
                fieldFilter.value = String(value * -1)
            }
        }
        .labelStyle(.iconOnly)
        .tint(.blue)
    }
}

extension FieldView {
    /// The keyboard type to use depending on where the input is numeric and decimal.
    var keyboardType: UIKeyboardType {
        guard let fieldType = fieldFilter.field.type else { return .default }
        
        return if fieldType.isNumeric || fieldType == .oid {
#if os(visionOS)
            // On visionOS, the `positiveNegativeButton` is not available.
            // Show the keyboard instead so the user can manually enter a negative number.
            .numbersAndPunctuation
#else
            if fieldType.isFloatingPoint { .decimalPad } else { .numberPad }
#endif
        } else {
            .default
        }
    }
}

extension Field {
    /// Determines the display title for the `Field`.
    /// - Returns: A string representing the display title for the `Field`.
    var title: String {
        alias.isEmpty ? name : alias
    }
}

private extension FieldView {
    var positiveNegativeButtonLabel: String {
        .init(
            localized: "Toggle Sign",
            bundle: .toolkitModule,
            comment: "A label for a button that toggles a numeric value between negative and positive sign."
        )
    }
}
