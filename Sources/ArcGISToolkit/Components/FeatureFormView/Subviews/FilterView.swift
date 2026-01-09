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
        ForEach(model.fieldFilters, id: \.self) { filter in
            FieldView(fieldFilter: filter)
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
        .buttonBorderShape(.circle)
        .buttonStyle(.borderedProminent)
        .shadow(radius: 8)
        Spacer()
    }
}

#Preview {
    ArcGISEnvironment.apiKey = .development    let tableURL = URL(string: "https://services5.arcgis.com/N82JbI5EYtAkuUKU/arcgis/rest/services/Earthquake/FeatureServer/0")!
    let table = ServiceFeatureTable(url: tableURL)
    let model = FilterViewModel(featureTable: table)
    FilterView()
        .environment(model)
}

private struct FieldView: View {
    @Environment(FilterViewModel.self) private var model
    @State private var selectedField: Field?
    private var fieldFilter: FieldFilter?

    init(fieldFilter: FieldFilter) {
        self.fieldFilter = fieldFilter
        selectedField = fieldFilter.field
    }

    var body: some View {
        // List of table fields
        Picker("Fields", selection: $selectedField) {
            Text("a field")
            ForEach(model.fields, id: \.self) { field in
                Text(field.title()).tag(field.title() as String?)
            }
        }
        .pickerStyle(MenuPickerStyle()) // You can change this to WheelPickerStyle() if you prefer

        // List of operators
        // Value for field
    }
}

extension Field {
    func title() -> String {
        alias.isEmpty ? name : alias
    }
}

extension Field: Equatable {
    public static func == (lhs: ArcGIS.Field, rhs: ArcGIS.Field) -> Bool {
        lhs.toJSON() == rhs.toJSON()
    }
}

extension Field: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(toJSON())
    }
}

//#Preview {
//    FieldView()
//}
