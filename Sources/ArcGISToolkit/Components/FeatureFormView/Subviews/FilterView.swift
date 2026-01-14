//
//  SwiftUIView.swift
//  arcgis-maps-sdk-swift-toolkit
//
//  Created by mark1113 on 1/8/26.
//

import ArcGIS
import SwiftUI

struct FilterView: View {
    @Environment(FilterViewModel.self) private var model
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    ForEach(model.fieldFilters, id: \.self) { filter in
                        FieldView(fieldFilter: filter)
                            .frame(minHeight: 200)
                            .padding()
                    }
                    Button {
                        let newFilter = FieldFilter()
                        model.fieldFilters.append(newFilter)
                        
                    } label: {
                        Image(systemName: "plus")
                            .bold()
                            .imageScale(.large)
                            .padding(8)
                    }
                    .id("plusButton")
                    .buttonBorderShape(.circle)
                    .buttonStyle(.borderedProminent)
                    .shadow(radius: 8)
                }
                .onChange(of: model.fieldFilters) {
                    // Scroll to the last message when messages change
                    if let lastFilter = model.fieldFilters.last {
                        print("onChangeOf model.fieldFilters")
                        // Why doesn't this work??
                        proxy.scrollTo(lastFilter, anchor: .bottom)
                    }
                }
            }
            Spacer()
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        cancelButton
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        applyButton
                    }
                }
        }
    }
    
    var cancelButton: some View {
        Button {
            //            signOut()
        } label: {
            Text("Cancel")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        //        .disabled(isSigningOut)
    }
    
    var applyButton: some View {
        Button {
            //            dismiss()
        } label: {
            Text("Apply")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        //        .disabled(isSigningOut)
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
                operation: UtilityNetworkAttributeComparison.Operator.equal,
                value: 1
            ),
            FieldFilter(
                field: Field(
                    type: .text,
                    name: ".text",
                    alias: "Text"
                ),
                operation: UtilityNetworkAttributeComparison.Operator.notEqual,
                value: "Bob"
            )
        ]
    }()
    let model = FilterViewModel(fieldFilters: filters)
    FilterView()
        .environment(model)
}

private struct FieldView: View {
    @Environment(FilterViewModel.self) private var model
    @State private var selectedField: Field?
    @State private var fieldFilter: FieldFilter
    @State private var selectedCondition: UtilityNetworkAttributeComparison.Operator
    
    private var conditions: [UtilityNetworkAttributeComparison.Operator] = {
        return [.equal, .notEqual]
    }()
    
    init(fieldFilter: FieldFilter) {
        self.fieldFilter = fieldFilter
        selectedField = fieldFilter.field
        selectedCondition = fieldFilter.operation
    }
    
    var body: some View {
        List {
            // Field
            if model.fields.isEmpty {
                HStack {
                    Text("Field")
                    Spacer()
                    Text(selectedField?.title() ?? "None")
                }
            } else {
                HStack {
                    Picker("Fields", selection: $selectedField) {
                        Text("a field")
                        ForEach(model.fields, id: \.self) { field in
                            Text(field.title()).tag(field.title() as String?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
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
        .listStyle(.insetGrouped)
        .scrollDisabled(true)
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
