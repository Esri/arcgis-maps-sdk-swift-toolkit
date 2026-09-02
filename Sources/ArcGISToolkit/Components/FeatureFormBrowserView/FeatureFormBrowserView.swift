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
public struct FeatureFormBrowserView: View {
    /// <#Description#>
    @Binding var model: Model
    
    /// <#Description#>
    /// - Parameter model: <#model description#>
    public init(model: Binding<Model>) {
        _model = model
    }
    
    public var body: some View {
        switch model.style {
        case .list:
            list
        case .menu:
            menuView
        case .tabs:
            tabView
        }
    }
}

extension FeatureFormBrowserView /* Model */ {
    /// <#Description#>
    @Observable public final class Model {
        /// <#Description#>
        var style: Style
        
        /// <#Description#>
        /// - Parameter forms: <#forms description#>
        public init(forms: [FeatureForm] = []) {
            self.forms = forms
            self.style = .list
        }
        
        /// <#Description#>
        ///
        /// When using the list style, users can always navigate back into the central list view.
        var canGoBack: Bool {
            // The list style is applied and the user is in a form.
            (style == .list && selectedForm != nil)
            // There's a previous item to navigate back to.
            || backStack.count > 1
        }
        
        /// <#Description#>
        public var count: Int {
            forms.count == ids.count ? forms.count : -1
        }
        
        /// <#Description#>
        var forms = [FeatureForm]()
        
        /// <#Description#>
        var selectedID: UUID? {
            didSet {
                if let oldValue {
                    backStack.append(oldValue)
                }
            }
        }
        
        /// <#Description#>
        var ids: [UUID] {
            forms.compactMap { $0.feature.globalID }
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
                Logger.featureFormBrowserView.warning("The feature cannot be added because the its global ID is not available.")
                return
            }
            defer {
                // Select the form, if directed, or if not in list style and no
                // form is already selected, regardless of whether it's already
                // in the collection of managed forms.
                if select || (style != .list && selectedID == nil) {
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
                Logger.featureFormBrowserView.info("Feature \(id.description) is already added.")
                return
            }
            forms.append(form)
        }
        
        /// <#Description#>
        public func navigateBack() {
            guard canGoBack else {
                Logger.featureFormBrowserView.warning("Cannot navigate backwards without history.")
                return
            }
            if style == .list {
                withAnimation {
                    selectedID = nil
                }
            } else {
                backStack.removeLast()
                guard let lastID = backStack.last, let form = form(for: lastID) else {
                    Logger.featureFormBrowserView.warning("No ID for back navigation.")
                    return
                }
                select(form: form, recordNavigation: false)
            }
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        public func remove(form: FeatureForm) {
            forms.removeAll {
                $0.feature.globalID == form.feature.globalID
            }
            guard !backStack.isEmpty else { return }
            backStack.removeLast()
            selectedID = backStack.last
        }
        
        /// <#Description#>
        /// - Parameter id: <#id description#>
        /// - Returns: <#description#>
        public func form(for id: UUID) -> FeatureForm? {
            forms.first { $0.feature.globalID == id } ?? nil
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        public func select(form: FeatureForm, recordNavigation: Bool = true) {
            if recordNavigation, let selectedID {
                backStack.append(selectedID)
            }
            selectedID = form.feature.globalID
        }
    }
}

extension FeatureFormBrowserView /* Browser style variants */ {
    /// <#Description#>
    @ViewBuilder
    var list: some View {
        Group {
            if let selected = model.selectedForm {
                FeatureFormView(root: selected)
                    .transition(.asymmetric(insertion: .push(from: .trailing), removal: .move(edge: .trailing)))
            } else {
                NavigationStack {
                    List(model.forms, id: \.feature.globalID) { form in
                        Button(form.title) {
                            withAnimation {
                                model.select(form: form)
                            }
                        }
                    }
                    .navigationTitle(
                        model.forms.count == 1
                        ? "Editing 1 Feature"
                        : "Editing \(model.forms.count) Features"
                    )
                }
                .environment(model)
                .transition(.asymmetric(insertion: .push(from: .leading), removal: .move(edge: .leading)))
            }
        }
        .environment(model)
    }
    
    /// <#Description#>
    @ViewBuilder
    var menuView: some View {
        if let form = model.selectedForm {
            FeatureFormView(root: form)
                .editingButtons(.hidden)
                .environment(model)
        } else {
            ContentUnavailableView {
                Text("An unexpected error has occurred.")
            }
        }
    }
    
    /// <#Description#>
    var tabView: some View {
        TabView(selection: $model.selectedID) {
            ForEach(model.ids, id: \.self) { id in
                if let form = model.form(for: id) {
                    Tab(value: id) {
                        FeatureFormView(
                            root: form,
                            isPresented: Binding(
                                get: { true },
                                set: { _ in model.remove(form: form) }
                            )
                        )
                        .editingButtons(.hidden)
                        .environment(model)
                    } label: {
                        Image(systemName: "list.bullet.clipboard")
                        Text(form.title)
                    }
                }
            }
        }
    }
}

extension FeatureFormBrowserView /* Enums */ {
    /// <#Description#>
    public enum Style {
        case list
        case menu
        case tabs
    }
}

public extension FeatureFormBrowserView /* Modifiers */ {
    func style(_ style: FeatureFormBrowserView.Style) -> some View {
        model.style = style
        return self
    }
}

extension Logger {
    /// A logger for the feature form view.
    static var featureFormBrowserView: Logger {
        Logger(subsystem: "com.esri.ArcGISToolkit", category: "FeatureFormBrowserView")
    }
}

struct FeatureFormBrowserViewPreview: View {
    @State private var style: FeatureFormBrowserView.Style = .list
    @Binding var model: FeatureFormBrowserView.Model
    var body: some View {
        FeatureFormBrowserView(model: $model)
            .style(style)
        Menu {
            Picker("Browser Style", selection: $style) {
                Text("List")
                    .tag(FeatureFormBrowserView.Style.list)
                Text("Menu")
                    .tag(FeatureFormBrowserView.Style.menu)
                Text("Tabs")
                    .tag(FeatureFormBrowserView.Style.tabs)
            }
        } label: {
            Text("Style")
        }
    }
}

#Preview {
    @Previewable @State var model = FeatureFormBrowserView.Model()
    @Previewable @State var loadResult: Result<Void, Error>?
    
    switch loadResult {
    case .success(let success):
        FeatureFormBrowserViewPreview(model: $model)
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
                    let map = Map(url: URL(string: "https://maps.arcgis.com/home/item.html?id=471eb0bf37074b1fbb972b1da70fb310")!)
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
                    features?.forEach { feature in
                        model.add(form: FeatureForm.init(feature: feature))
                    }
                }
            }
    }
}
