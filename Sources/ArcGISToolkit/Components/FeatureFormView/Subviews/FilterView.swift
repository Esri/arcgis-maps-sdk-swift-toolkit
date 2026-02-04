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

/// A view allowing the user to assembly a list of `FieldFilters` used to filter a list of features.
struct FilterView: View {
    /// The model used by the view.
    @Bindable var model: FilterViewModel
    
    /// The client-specified action to perform when the `Apply` button is tapped. There is no `cancel` action
    /// as cancelling simply resets the list of `FieldFilters`.
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
                        BorderedAddButton()
                    }
                } else {
                    List {
                        ForEach(model.fieldFilters, id: \.self) { filter in
                            Section {
                                FieldView(fieldFilter: filter)
                            } header: {
                                HStack {
                                    if let index = model.fieldFilters.firstIndex(of: filter) {
                                        Text(
                                            String(
                                                localized: "Condition \(index + 1)",
                                                bundle: .toolkitModule,
                                                comment: "A label for a control representing a condition and position index used to filter fields in a table."
                                            )
                                        )
                                    }
                                    Spacer()
                                    Menu {
                                        // Duplicate the current filter.
                                        duplicateButton(filter)
                                        // Delete the current filter.
                                        deleteButton(filter)
                                    } label: {
                                        Image(systemName: "ellipsis.circle")
                                            .imageScale(.large)
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
                                proxy.scrollTo(lastFieldFilter.id, anchor: .bottom)
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        NoBorderAddButton()
                            .buttonStyle(.borderless)
                            .padding()
                        Spacer()
                    }
                }
            }
            Spacer()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        DismissButton(kind: .cancel) {
                            model.cancel()
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
    }
    
    /// Creates a `Button` used to delete a `FieldFilter`.
    /// - Parameter filter: The `FieldFilter` to delete.
    /// - Returns: The delete `Button`.
    private func deleteButton(_ filter: FieldFilter) -> Button<some View> {
        Button(role: .destructive) {
            if let index = model.fieldFilters.firstIndex(of: filter) {
                model.fieldFilters.remove(at: index)
            }
        } label: {
            Label {
                Text(
                    "Delete",
                    bundle: .toolkitModule,
                    comment: "A label for a button to delete a field filter."
                )
            } icon: {
                Image(systemName: "trash")
            }
        }
    }
    
    /// Creates a `Button` used to duplicate a `FieldFilter`.
    /// - Parameter filter: The `FieldFilter` to duplicate.
    /// - Returns: The duplicate `Button`.
    private func duplicateButton(_ filter: FieldFilter) -> Button<some View> {
        Button {
            if let index = model.fieldFilters.firstIndex(of: filter) {
                let newFilter = filter.copy()
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

/// A button, with a border, used to add a `FieldFilter` to the list of current `FieldFilters`.
private struct BorderedAddButton: View {
    @Environment(FilterViewModel.self) private var model
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    let newFilter = FieldFilter(field: model.fields.first ?? Field(type: .blob, name: "Empty", alias: "Empty"))
/// A button to add a `FieldFilter` to the list of current `FieldFilters`.
private struct AddButton: View {
    let useBorderedStyle: Bool
    
    init(useBorderedStyle: Bool = false) {
        self.useBorderedStyle = useBorderedStyle
    }
    
    @Environment(FilterViewModel.self) private var model
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    let newFilter = FieldFilter(field: model.fields.first ?? Field(type: .blob, name: "Empty", alias: "Empty"))
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
}

/// A view representing a single `FieldFilter`, with options to select a field and condition/operation, and to set a value for the operation.
private struct FieldView: View {
    /// The model used by the view.
    @Environment(FilterViewModel.self) private var model
    
    /// The `FieldFilter` represented by the view.
    @State private var fieldFilter: FieldFilter
    
    /// The list of conditions/operations the user is allowed to choose from.
    @State private var conditions = [FilterOperator]()
    
    init(fieldFilter: FieldFilter) {
        self.fieldFilter = fieldFilter
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
                    Picker(selection: $fieldFilter.field) {
                        ForEach(model.fields, id: \.self) { field in
                            Text(field.title)
                        }
                    } label: {
                        Text.field
                    }
                    .pickerStyle(.menu)
                    .onChange(of: fieldFilter.field) {
                        conditions = fieldConditions()
                    }
                }
            }
            
            // Condition
            HStack {
                Picker(selection: $fieldFilter.condition) {
                    ForEach(conditions, id: \.self) { condition in
                        Text(condition.displayName)
                    }
                } label: {
                    Text(
                        "Condition",
                        bundle: .toolkitModule,
                        comment: "A label for a control to pick a condition to filter fields in a table against."
                    )
                }
                .pickerStyle(.menu)
            }
            .onAppear {
                conditions = fieldConditions()
            }
            
            // Value
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
                .frame(alignment: .trailing)
#if os(iOS)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        if UIDevice.current.userInterfaceIdiom == .phone, (fieldFilter.field.type?.isNumeric ?? false) {
                            // Known SwiftUI issue: This button is known to sometimes not appear. (See Apollo #1159)
                            positiveNegativeButton
                            Spacer()
                        }
                    }
                }
#endif
            }
        }
        .id(fieldFilter.id)
    }
    
    /// The button that allows a user to switch the numeric value between positive and negative.
    var positiveNegativeButton: some View {
        Button {
            if let value = Int(fieldFilter.value) {
                fieldFilter.value = String(value * -1)
            } else if let value = Float(fieldFilter.value) {
                fieldFilter.value = String(value * -1)
            } else if let value = Double(fieldFilter.value) {
                fieldFilter.value = String(value * -1)
            }
        } label: {
            Image(systemName: "plus.forwardslash.minus")
        }
        .tint(.blue)
    }
    
    /// Determines the conditions to display for the given `FieldFilter` field type.
    /// - Returns: A list of conditions appropriate for the given `FieldFilter` field type.
    private func fieldConditions() -> [FilterOperator] {
        (fieldFilter.field.type?.isNumeric ?? false) ? FilterOperator.numericFilterOperators() : FilterOperator.textFilterOperators(fieldFilter.field.isNullable)
    }
}

extension FieldView {
    /// The keyboard type to use depending on where the input is numeric and decimal.
    var keyboardType: UIKeyboardType {
        guard let fieldType = fieldFilter.field.type else { return .default }
        
        return if fieldType.isNumeric {
#if os(visionOS)
            // The 'positiveNegativeButton' doesn't show on visionOS
            // so we need to show this keyboard so the user can type
            // a negative number.
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

extension Field: @retroactive Equatable {
    public static func == (lhs: ArcGIS.Field, rhs: ArcGIS.Field) -> Bool {
        lhs.toJSON() == rhs.toJSON()
    }
}

extension Field: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(toJSON())
    }
}
