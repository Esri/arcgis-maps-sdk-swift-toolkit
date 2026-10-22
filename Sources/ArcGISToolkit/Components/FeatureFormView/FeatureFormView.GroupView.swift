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

extension FeatureFormView {
    /// <#Description#>
    public struct GroupView: View {
        @Environment(FeatureFormView.Model.self) var featureFormViewModel
        
        public var body: some View {
            if let selectedID = featureFormViewModel.selectedID {
                form(id: selectedID)
            } else {
                menu
            }
        }
    }
}

extension FeatureFormView.GroupView /* Group views */ {
    /// <#Description#>
    /// - Parameter id: <#id description#>
    @ViewBuilder
    func form(id: UUID) -> some View {
        if let stackModel = featureFormViewModel.stackModel(for: id) {
            FeatureFormView.StackView(model: stackModel)
        }
    }
    
    /// <#Description#>
    @ViewBuilder
    var menu: some View {
        NavigationStack {
            List {
                if featureFormViewModel.formCount == 0 {
                    ContentUnavailableView {
                        Text(
                            "No forms",
                            bundle: .toolkitModule,
                            comment: ""
                        )
                    }
                } else {
                    ForEach(featureFormViewModel.activeForms, id: \.feature.globalID) { form in
                        LabeledContent {
                            Button {
                                featureFormViewModel.select(form: form, clearHistory: true)
                            } label: {
                                HStack {
                                    Text(form.title)
                                    Spacer()
                                    if form.hasEdits {
                                        Label {
                                            Text(
                                                "Unsaved Edits",
                                                bundle: .toolkitModule,
                                                comment: ""
                                            )
                                        } icon: {
                                            Image(systemName: "pencil")
                                        }
                                        .labelStyle(.iconOnly)
                                    }
                                }
                            }
                            .badge(form.elementValidationErrors.count)
                            .badgeProminence(.increased)
                            .foregroundStyle(.primary)
                        } label: {
                            FeatureSymbolView(feature: form.feature)
                        }
                    }
                    .id(featureFormViewModel.selectedID)
                }
            }
            .navigationTitle(
                "Editing ^[\(featureFormViewModel.activeFormCount) features](inflect: true)"
            )
            .toolbar {
                let hasEdits = featureFormViewModel.formsWithEdits.contains(where: { $0.value })
                if featureFormViewModel.isPresented != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            if hasEdits {
                                // TODO: Warn before close.
                            }
                            featureFormViewModel.isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        featureFormViewModel.finishEditing()
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .disabled(!hasEdits)
                }
            }
        }
    }
}

struct FeatureFormGroupViewPreview: View {
    let model: FeatureFormView.Model?
    @Binding var isPresented: Bool
    var body: some View {
        if let model {
            FeatureFormView(model: model, isPresented: $isPresented)
        }
    }
}

// The task on the ProgressView is problematic in Xcode 26.4.1 (Swift 6.3)
#if swift(>=6.4)
#Preview {
    @Previewable @State var map: Map?
    @Previewable @State var model: FeatureFormView.Model?
    @Previewable @State var loadResult: Result<Void, Error>?
    @Previewable @State var isPresented = true
    
    switch loadResult {
    case .success:
        MapView(map: map!)
            .sheet(isPresented: $isPresented) {
                FeatureFormGroupViewPreview(model: model, isPresented: $isPresented)
            }
    case .failure(let failure):
        ContentUnavailableView {
            Text(failure.localizedDescription)
        }
    case nil:
        ProgressView()
            .task {
                loadResult = await Result {
                    let credential = try await TokenCredential.credential(
                        for: URL(string: "https://sampleserver7.arcgisonline.com/portal/sharing/rest")!,
                        username: "viewer01",
                        password: "I68VGU^nMurF"
                    )
                    ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(credential)
                    map = Map(url: URL(string: "https://maps.arcgis.com/home/item.html?id=471eb0bf37074b1fbb972b1da70fb310")!)
                    try await map?.load()
                    for utilityNetwork in map?.utilityNetworks ?? [] {
                        try await utilityNetwork.load()
                    }
                    let layer = map?.operationalLayers.first
                    try await layer?.load()
                    let groupLayer = layer as? GroupLayer
                    let featureLayer = groupLayer?.layers.first { layer in
                        layer.name == "Electric Distribution Assembly"
                    } as? FeatureLayer
                    let featureTable = featureLayer?.featureTable as? ArcGISFeatureTable
                    try await featureTable?.load()
                    let queryParameters = QueryParameters()
                    queryParameters.addObjectIDs([1, 2, 3])
                    let featureQueryResult = try await featureTable?.queryFeatures(using: queryParameters)
                    let features = featureQueryResult?.features().compactMap { $0 as? ArcGISFeature }
                    let forms: [FeatureForm] = features?.map { FeatureForm(feature: $0) } ?? []
                    model = .init(forms: forms)
                }
            }
    }
}
#endif
