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

// TODO: Add discard edits alert for navigation back button
struct CreatedFeaturesList: View {
    let featureFormItems: [FeatureFormItem]
    
    @Environment(\.isPresented) private var isPresented
    @Environment(\.navigationPath) private var navigationPath
    
    @State private var isDiscardingEdits = false
    @State private var validationErrorsAlertIsPresented = false
    
    private enum NavigationType {
        case back, close
    }
    @State private var navigationType: NavigationType?
    
    private var validationErrorCount: Int {
        featureFormItems.reduce(0) { $0 + $1.validationErrorCount }
    }
    
    var body: some View {
        List(featureFormItems, id: \.self) { formItem in
            NavigationLink(value: formItem) {
                HStack {
                    TemplatePickerItemLabel(item: formItem.templateItem)
                    if formItem.validationErrorCount > 0 {
                        Spacer()
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle(.red)
                    }
                }
            }
            // Removed to work around bug where validation errors appear when opening feature form.
            //            .task {
            //                for await validationErrors in formItem.form.$validationErrors {
            //                    formItem.validationErrorCount = validationErrors.count
            //                }
            //            }
        }
        .navigationDestination(for: FeatureFormItem.self) { formItem in
            FeatureFormView(root: formItem.form)
                .onAppear {
                    var featureFormItems = featureFormItems
                    featureFormItems.removeAll(where: { $0 == formItem })
                    unselectFeatures(in: featureFormItems)
                }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Back", systemImage: "chevron.backward") {
                    navigationType = .back
                    isDiscardingEdits = true
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create", systemImage: "checkmark") {
                    if validationErrorCount > 0 {
                        navigationType = .close
                        validationErrorsAlertIsPresented = true
                    } else {
                        unselectFeatures(in: featureFormItems)
                        isPresented?.wrappedValue = false
                    }
                }
                .tint(.accentColor)
            }
        }
        .alert("Validation Errors", isPresented: $validationErrorsAlertIsPresented) {
            Button("Discard Edits", role: .destructive) { isDiscardingEdits = true }
            Button("Continue Editing", role: .cancel) { navigationType = nil }
        } message: {
            Text("You have ^[\(validationErrorCount) error](inflect: true) that must be fixed before saving.")
        }
        .task(id: isDiscardingEdits) {
            guard isDiscardingEdits else { return }
            
            await deleteFeatures(in: featureFormItems)
            unselectFeatures(in: featureFormItems)
            
            switch navigationType {
            case .back: navigationPath?.wrappedValue.removeLast()
            case .close: isPresented?.wrappedValue = false
            case nil: break
            }
        }
        .disabled(isDiscardingEdits)
        .overlay {
            if isDiscardingEdits, #available(iOS 26.0, *) {
                ProgressView("Discarding Edits")
                    .padding()
                    .glassEffect()
                    .shadow(radius: 1)
            }
        }
        .navigationTitle("Create Features")
        .onChange(of: featureFormItems, initial: true) { oldValue, newValue in
            unselectFeatures(in: featureFormItems)
            selectFeatures(in: featureFormItems)
        }
        .task(id: featureFormItems) {
            await withTaskGroup { group in
                for formItem in featureFormItems {
                    group.addTask { try? await formItem.templateItem.loadImage() }
                }
            }
        }
        .onChange(of: isPresented?.wrappedValue) {
            guard let isPresented, !isPresented.wrappedValue else { return }
            unselectFeatures(in: featureFormItems)
        }
    }
    
    private func deleteFeatures(in featureFormItems: [FeatureFormItem]) async {
        await withTaskGroup { group in
            for formItem in featureFormItems {
                group.addTask { @Sendable in
                    do {
                        let feature = formItem.form.feature
                        try await feature.load()
                        
                        guard let table = feature.table else { return }
                        try await table.load()
                        try await table.delete(feature)
                    } catch {
                        print("Error deleting feature: \(error)")
                    }
                }
            }
        }
    }
    
    private func selectFeatures(in featureFormItems: [FeatureFormItem]) {
        for formItem in featureFormItems {
            let feature = formItem.form.feature
            feature.featureLayer?.selectFeature(feature)
        }
    }
    
    private func unselectFeatures(in featureFormItems: [FeatureFormItem]) {
        for formItem in featureFormItems {
            let feature = formItem.form.feature
            feature.featureLayer?.unselectFeature(feature)
        }
    }
}
