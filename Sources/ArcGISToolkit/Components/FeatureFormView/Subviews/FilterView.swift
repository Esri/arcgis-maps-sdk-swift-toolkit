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

//TODO:
// - look at design and make sure FilterView matches that
// - what about ... button for delete? (Match design)


import ArcGIS
import SwiftUI

struct FilterView: View {
    @Environment(FilterViewModel.self) private var model
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                if model.fieldFilters.isEmpty {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.largeTitle)
                        .foregroundStyle(.gray)
                        .padding()
                    Text("No conditions added")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Show features that meet all the conditions")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom)
                    HStack {
                        Spacer()
                        AddButtonBordered()
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(model.fieldFilters, id: \.self) { filter in
                            Section {
                                FieldView(fieldFilter: filter)
                            } header: {
                                HStack {
                                    Text(filter.name)
                                    Spacer()
                                    Menu {
                                        // Duplicate the current filter
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
                        .onDelete(perform: { offsets in
                            withAnimation {
                                model.fieldFilters.remove(atOffsets: offsets)
                            }
                        })
                    }
                    .onChange(of: model.fieldFilters) {
                        // Scroll to the last message when messages change
                        if let lastFilter = model.fieldFilters.last {
                            print("onChangeOf model.fieldFilters")
                            // Why doesn't this work??
                            withAnimation {
                                proxy.scrollTo("plusButton", anchor: .bottom)
                            }
                        }
                    }
                    Spacer()
                    HStack {
                        AddButtonNoBorder()
                            .buttonStyle(.borderless)
                            .padding()
                        Spacer()
                    }
                }
            }
            Spacer()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        DismissButton(kind: .cancel){
                            model.cancel()
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        DismissButton(kind: .confirm){
                            model.apply()
                        }
                    }
                }
        }
    }
    
    private func deleteButton(_ filter: FieldFilter) -> Button<some View> {
        Button {
            if let index = model.fieldFilters.firstIndex(of: filter) {
                withAnimation {
                    model.fieldFilters.remove(at: index)
                }
            }
        } label: {
            Text("Delete")
            Image(systemName: "trash")
        }
    }

    private func duplicateButton(_ filter: FieldFilter) -> Button<some View> {
        Button {
            if let index = model.fieldFilters.firstIndex(of: filter) {
                let newFilter = filter.copy()
                withAnimation {
                    model.fieldFilters.insert(newFilter, at: index + 1)
                }
            }
        } label: {
            Text("Duplicate")
            Image(systemName: "document.on.document")
        }
    }
}

#Preview {
    let filters: [FieldFilter] = {
        [
            FieldFilter(
                field: Field(
                    type: .int32,
                    name: ".int32",
                    alias: "Int32"
                ),
                condition: UtilityNetworkAttributeComparison.Operator.equal,
                value: 1
            ),
            FieldFilter(
                field: Field(
                    type: .text,
                    name: ".text",
                    alias: "Text"
                ),
                condition: UtilityNetworkAttributeComparison.Operator.notEqual,
                value: "Bob"
            )
        ]
    }()
//    let model = FilterViewModel(fieldFilters: filters)
    let model = FilterViewModel(fieldFilters: [])
    FilterView()
        .environment(model)
}

private struct AddButtonBordered: View {
    @Environment(FilterViewModel.self) private var model
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    let newFilter = FieldFilter(field: model.fields.first ?? Field(type: .blob, name: "Empty", alias: "Empty"))
                    model.fieldFilters.append(newFilter)
                    print("field name:" + model.fieldFilters.last!.field.name)
                }
            } label: {
                HStack {
                    Image(systemName: "plus")
                        .imageScale(.large)
                        .padding(4)
                    Text("Add Condition")
                        .padding(.trailing)
                }
                .bold()
            }
            .id("plusButton")
            .buttonBorderShape(.automatic)
            .buttonStyle(.borderedProminent)
                .shadow(radius: 8)
        }
    }
}

private struct AddButtonNoBorder: View {
    @Environment(FilterViewModel.self) private var model
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    let newFilter = FieldFilter(field: model.fields.first ?? Field(type: .blob, name: "Empty", alias: "Empty"))
                    model.fieldFilters.append(newFilter)
                    print("field name:" + model.fieldFilters.last!.field.name)
                }
            } label: {
                HStack {
                    Image(systemName: "plus")
//                        .imageScale(.large)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Circle().fill(Color.blue))
                    Text("Add Condition")
                }
                .bold()
            }
            .id("plusButton")
        }
    }
}

private struct FieldView: View {
    @Environment(FilterViewModel.self) private var model
    @State private var selectedField: Field
    @State private var fieldFilter: FieldFilter
    @State private var selectedCondition: UtilityNetworkAttributeComparison.Operator
    
    private var conditions: [UtilityNetworkAttributeComparison.Operator] = {
        return [.equal, .notEqual]
    }()
    
    init(fieldFilter: FieldFilter) {
        self.fieldFilter = fieldFilter
        selectedField = fieldFilter.field
        selectedCondition = fieldFilter.condition
    }
    
    var body: some View {
        // Field
        if model.fields.isEmpty {
            HStack {
                Text("Field")
                Spacer()
                Text(selectedField.title())
            }
        } else {
            HStack {
                Picker("Fields", selection: $selectedField) {
                    ForEach(model.fields, id: \.self) { field in
                        Text(field.title())
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedField) {
                    fieldFilter.field = selectedField
                    print("selectedField: \(selectedField.title())")
                }
            }
        }

        // Condition
        HStack {
            Picker("Condition", selection: $selectedCondition) {
                ForEach(conditions, id: \.self) { condition in
                    condition.icon()
                        .tag(condition.title())
                }
            }
            .pickerStyle(MenuPickerStyle())
            .onChange(of: selectedCondition) {
                fieldFilter.condition = selectedCondition
            }
        }
        
        
        // Value
        HStack {
            Text("Value")
            Spacer()
            TextField(
                text: $fieldFilter.formattedValue,
                prompt: Text("Enter a value"),
                label: {
                    Label("Value", systemImage: "swift")
                }
            )
            .multilineTextAlignment(.trailing)
            .frame(alignment: .trailing)
        }
    }
}

extension Field {
    func title() -> String {
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

extension UtilityNetworkAttributeComparison.Operator {
    func icon() -> Image {
        switch self {
        case .equal:
            return Image(systemName: "equal")
        case .notEqual:
            return Image(systemName: "notequal")
        case .greaterThan,
                .greaterThanEqual,
                .lessThan,
                .lessThanEqual,
                .includesTheValues,
                .doesNotIncludeTheValues,
                .includesAny,
                .doesNotIncludeAny:
            return Image("circle.slash")
        }
    }
    
    func title() -> String {
        switch self {
        case .equal:
            return "Equal"
        case .notEqual:
            return "Not equal"
        case .greaterThan,
                .greaterThanEqual,
                .lessThan,
                .lessThanEqual,
                .includesTheValues,
                .doesNotIncludeTheValues,
                .includesAny,
                .doesNotIncludeAny:
            return "Not supported"
        }
    }
}

//#Preview {
//    FieldView()
//}
