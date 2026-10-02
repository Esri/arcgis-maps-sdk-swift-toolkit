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

internal import os

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

extension FeatureFormGroupView /* Model */ {
    /// <#Description#>
    @MainActor @Observable public final class Model {
        /// <#Description#>
        /// - Parameter forms: <#forms description#>
        public init(forms: [FeatureForm] = []) {
            self.group = .init(forms: forms)
            if let first = forms.first {
                select(form: first)
            }
        }
        
        /// <#Description#>
        var group: FeatureFormGroup
        
        /// <#Description#>
        var canGoBack: Bool {
            backStack.count > 0
        }
        
        /// <#Description#>
        public var count: Int {
            group.forms.count == ids.count ? group.forms.count : -1
        }
        
        /// <#Description#>
        private(set) var selectedID: UUID?
        
        /// <#Description#>
        var selectedIndex: Int {
            if let selectedID {
                ids.firstIndex(of: selectedID) ?? -1
            } else {
                -1
            }
        }
        
        /// <#Description#>
        var ids: [UUID] {
            group.forms.compactMap { $0.feature.globalID }
        }
        
        /// <#Description#>
        var selectedForm: FeatureForm? {
            if let selectedID {
                form(for: selectedID) ?? nil
            } else {
                nil
            }
        }
        
        /// <#Description#>
        private var backStack = [UUID]()
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        /// - Parameter select: <#select description#>
        public func add(form: FeatureForm, select: Bool = false) {
            guard let id = form.feature.globalID else {
                Logger.featureFormGroupView.warning("The feature cannot be added because the its global ID is not available.")
                return
            }
            defer {
                // Select the form, if directed, or if not in list style and no
                // form is already selected, regardless of whether it's already
                // in the collection of managed forms.
                if select || selectedID == nil {
                    self.select(form: form)
                }
            }
            guard !ids.contains(id) else {
                let id: any CustomStringConvertible
                if let objectID = form.feature.objectID {
                    id = objectID
                } else if let globalID = form.feature.globalID {
                    id = globalID
                } else {
                    id = "?"
                }
                Logger.featureFormGroupView.info("Feature \(id.description) is already added.")
                return
            }
            group.add(form)
        }
        
        public func debugLog() {
            print("Selected:", selectedID ?? "None")
            print("Can Go Back:", canGoBack)
            print("Back Stack \(backStack.count)")
            backStack.forEach { item in
                print("\t", item)
            }
            print("Forms With Errors \(formsWithErrors.count)")
            formsWithErrors.forEach { id in
                print("\t", id)
            }
            print("Browser Forms With Edits \(formsWithEdits.filter({$0.value}).count)")
            formsWithEdits.forEach { id in
                print("\t", id.key, id.value)
            }
            print("Browser Forms With Errors \(formsWithErrors.filter({$0.value > 0}).count)")
            formsWithErrors.forEach { id in
                print("\t", id, id.value)
            }
            print("--- End Debug Print ---")
        }
        
        /// <#Description#>
        func discardEdits() {
            Task {
                await group.discardEdits()
            }
        }
        
        /// <#Description#>
        func finishEditing() {
            Task {
                await group.finishEditing()
            }
        }
        
        /// <#Description#>
        func navigateBack() {
            guard canGoBack else {
                Logger.featureFormGroupView.warning("Cannot navigate backwards without history.")
                return
            }
            let top = backStack.removeFirst()
            guard let form = form(for: top) else {
                Logger.featureFormGroupView.warning("No ID for back navigation.")
                return
            }
            select(form: form, recordNavigation: false)
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        public func remove(form: FeatureForm) {
            group.forms.forEach { _form in
                if form.feature.globalID == _form.feature.globalID {
                    group.remove(_form)
                }
            }
            backStack.removeAll { id in
                form.feature.globalID == id
            }
            if selectedID == form.feature.globalID, canGoBack {
                let top = backStack.removeFirst()
                if let form = self.form(for: top) {
                    select(form: form)
                }
            }
            selectedID = backStack.last
        }
        
        /// <#Description#>
        /// - Parameter id: <#id description#>
        /// - Returns: <#description#>
        public func form(for id: UUID) -> FeatureForm? {
            group.forms.first { $0.feature.globalID == id } ?? nil
        }
        
        /// <#Description#>
        /// - Parameters:
        ///   - form: <#feature description#>
        ///   - recordNavigation: <#recordNavigation description#>
        public func select(form: FeatureForm, recordNavigation: Bool = true, clearHistory: Bool = false) {
            guard form.feature.globalID != selectedID else { return }
            if recordNavigation, let selectedID {
                backStack.insert(selectedID, at: 0)
            }
            if clearHistory {
                backStack.removeAll()
            }
            selectedID = form.feature.globalID
        }
        
        /// <#Description#>
        public func selectNext() {
            guard ids.count > 1 else { return }
            guard selectedIndex >= 0 else { return }
            let nextIndex: Int
            if selectedIndex == ids.count - 1 {
                // Jump to start
                nextIndex = 0
            } else {
                nextIndex = selectedIndex + 1
            }
            let nextForm = group.forms[nextIndex]
            select(form: nextForm, clearHistory: true)
        }
        
        /// <#Description#>
        public func selectPrevious() {
            guard ids.count > 1 else { return }
            guard selectedIndex >= 0 else { return }
            let nextIndex: Int
            if selectedIndex == 0 {
                // Jump to end
                nextIndex = ids.count - 1
            } else {
                nextIndex = selectedIndex - 1
            }
            let nextForm = group.forms[nextIndex]
            select(form: nextForm, clearHistory: true)
        }
            
        private(set) var formsWithEdits = [UUID: Bool]()
        
        private(set) var formsWithErrors = [UUID: Int]()
        
        func monitorEdits() async {
            Logger.featureFormGroupView.info("Starting edit monitoring.")
            await withTaskGroup { taskGroup in
                for form in group.forms {
                    taskGroup.addTask { @Sendable in
                        for await hasEdits in form.$hasEdits {
                            if let globalID = form.feature.globalID {
                                await MainActor.run {
                                    self.formsWithEdits[globalID] = hasEdits
                                }
                            }
                        }
                    }
                }
            }
        }
        
        func monitorErrors() async {
            Logger.featureFormGroupView.info("Starting error monitoring.")
            await withTaskGroup { taskGroup in
                for form in group.forms {
                    taskGroup.addTask { @Sendable in
                        for await errors in form.$elementValidationErrors {
                            if let globalID = form.feature.globalID {
                                await MainActor.run {
                                    self.formsWithErrors[globalID] = errors.count
                                }
                            }
                        }
                    }
                }
            }
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

extension Logger {
    /// A logger for the `FeatureFormGroupView`.
    static var featureFormGroupView: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "FeatureFormGroupView")
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
