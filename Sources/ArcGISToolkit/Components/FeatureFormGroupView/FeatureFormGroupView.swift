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

/// <#Description#>
@_spi(Experimental)
public struct FeatureFormGroupView: View {
    /// <#Description#>
    let model: Model
    
    /// <#Description#>
    /// - Parameter model: <#model description#>
    public init(model: Model) {
        self.model = model
    }
    
    public var body: some View {
        conditionalView
            .task(id: model.group.forms.count) {
                await model.monitorEdits()
            }
            .task(id: model.group.forms.count) {
                await model.monitorErrors()
            }
    }
}

extension FeatureFormGroupView /* Group views */ {
    /// <#Description#>
    @ViewBuilder
    var conditionalView: some View {
        if let selection = model.selectedID {
            formStack(selection: selection)
        } else {
            ContentUnavailableView {
                Text(
                    "No form is selected.",
                    bundle: .toolkitModule,
                    comment: "A label indicating no form is selected in the Feature Form Group."
                )
            }
        }
    }
    
    /// <#Description#>
    /// - Parameter id: <#id description#>
    @ViewBuilder
    func form(id: UUID) -> some View {
        if let form = model.form(for: id) {
            FeatureFormView(
                root: form,
                isPresented: Binding(
                    get: { true },
                    set: { _ in model.remove(form: form) }
                )
            )
            .editingButtons(.hidden)
            .environment(model)
        }
    }
    
    /// <#Description#>
    /// - Parameter selection: <#selection description#>
    /// - Returns: <#description#>
    /// - Note: We use a `ZStack` of `FeatureFormView`s over something like a `TabView`
    /// with `tabViewStyle(.page(indexDisplayMode: .never))` which causes view
    /// re-instantiation on selection change and results in loss of state.
    @ViewBuilder
    func formStack(selection: UUID) -> some View {
        ZStack {
            ForEach(model.ids, id: \.self) { id in
                form(id: id)
                    .allowsHitTesting(selection == id)
                    .opacity(selection == id ? 1 : 0)
            }
        }
    }
}

extension FeatureFormGroupView {
    /// Represents events that occur during the form editing lifecycle. These events notify you when the user has performed an action within a form in the group.
    public enum EditingEvent {
        /// Indicates that the user has discarded edits.
        case discardedEdits
        /// Indicates that the user has finished editing.
        case finishedEditing
        /// Indicates that the user has tapped on an option to visualize a feature on the map.
        case showOnMapRequested(ArcGISFeature)
    }
}

public extension FeatureFormGroupView /* View modifiers */ {
    /// Sets an closure to perform when the active feature form has changed.
    /// - Parameter action: The closure to perform.
    func onFeatureFormChanged(perform action: @escaping (FeatureForm) -> Void) -> FeatureFormGroupView {
        model.onFeatureFormChangedAction = action
        return self
    }
    
    /// Sets a closure to perform when a form group editing event occurs.
    /// - Parameter action: The closure to perform.
    func onFormEditingEvent(perform action: @escaping (EditingEvent) -> Void) -> FeatureFormGroupView {
        model.onFormEditingEventAction = action
        return self
    }
}

extension FeatureFormGroupView /* Internal view modifiers */ {
    /// Sets an action to run before finishing edits.
    ///
    /// When an action is set, the view acts as if the forms in the group have edits, even if they do
    /// not, and makes the finish editing button available.
    ///
    /// If the action throws an error, `FeatureFormGroup.finishEditing` will not be called.
    /// - Parameter action: The closure to perform.
    func willFinishEditing(perform action: @escaping () throws -> Void) -> FeatureFormGroupView {
        model.willFinishEditingAction = action
        return self
    }
}

struct FeatureFormGroupViewPreview: View {
    let model: FeatureFormGroupView.Model?
    var body: some View {
        if let model {
            FeatureFormGroupView(model: model)
        }
    }
}

// The task on the ProgressView is problematic in Xcode 26.4.1 (Swift 6.3)
#if swift(>=6.4)
#Preview {
    @Previewable @State var map: Map?
    @Previewable @State var model: FeatureFormGroupView.Model?
    @Previewable @State var loadResult: Result<Void, Error>?
    
    switch loadResult {
    case .success(let success):
        MapView(map: map!)
            .sheet(isPresented: .constant(true)) {
                FeatureFormGroupViewPreview(model: model)
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
