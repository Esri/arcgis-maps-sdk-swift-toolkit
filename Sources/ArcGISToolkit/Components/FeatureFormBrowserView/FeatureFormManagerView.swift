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
public struct FeatureFormManagerView: View {
    /// <#Description#>
    @Binding var model: Model
    
    /// <#Description#>
    /// - Parameter model: <#model description#>
    public init(model: Binding<Model>) {
        _model = model
    }
    
    public var body: some View {
        Group {
            switch model.style {
            case .list:
                list
            case .menu:
                menuView
            case .menuWithTabs:
                tabView
            case .paged:
                pagedView
            }
        }
        .task(id: model.manager.forms.count) {
            await model.monitorEdits()
        }
        .task(id: model.manager.forms.count) {
            await model.monitorErrors()
        }
    }
}

extension FeatureFormManagerView /* Model */ {
    /// <#Description#>
    @Observable public final class Model: @unchecked Sendable {
        /// <#Description#>
        var style: Style {
            didSet {
                switch style {
                // Under the .menu, .menuWithTabs, and .paged styles there is
                // always a selected form. If the style was switched from .list
                // to one of these make sure there is a selection.
                case .menu, .menuWithTabs, .paged:
                    if selectedID == nil, let firstForm = manager.forms.first {
                        select(feature: firstForm.feature, recordNavigation: false)
                    }
                case .list:
                    break
                }
            }
        }
        
        /// <#Description#>
        /// - Parameter features: <#features description#>
        public init(features: [ArcGISFeature] = []) {
            self.style = .paged
            self.manager = .init(features: features)
        }
        
        /// <#Description#>
        /// - Parameter forms: <#forms description#>
        public init(forms: [FeatureForm] = []) {
            self.style = .paged
            self.manager = .init(forms: forms)
        }
        
        /// <#Description#>
        var manager: FeatureFormManager
        
        /// <#Description#>
        ///
        /// When using the list style, users can always navigate back into the central list view.
        var canGoBack: Bool {
            // The list style is applied and the user is in a form.
            (style == .list && selectedForm != nil)
            // There's a previous item to navigate back to.
            || (style != .list && backStack.count > 0)
        }
        
        /// <#Description#>
        public var count: Int {
            manager.forms.count == ids.count ? manager.forms.count : -1
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
            manager.forms.compactMap { $0.feature.globalID }
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
        /// - Parameter feature: <#form description#>
        /// - Parameter select: <#select description#>
        public func add(feature: ArcGISFeature, select: Bool = false) {
            guard let id = feature.globalID else {
                Logger.featureFormBrowserView.warning("The feature cannot be added because the its global ID is not available.")
                return
            }
            defer {
                // Select the form, if directed, or if not in list style and no
                // form is already selected, regardless of whether it's already
                // in the collection of managed forms.
                if select || (style != .list && selectedID == nil) {
                    self.select(feature: feature)
                }
            }
            guard !ids.contains(id) else {
                let id: any CustomStringConvertible
                if let objectID = feature.objectID {
                    id = objectID
                } else if let globalID = feature.globalID {
                    id = globalID
                } else {
                    id = "?"
                }
                Logger.featureFormBrowserView.info("Feature \(id.description) is already added.")
                return
            }
            manager.add(feature)
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
        public func navigateBack() {
            guard canGoBack else {
                Logger.featureFormBrowserView.warning("Cannot navigate backwards without history.")
                return
            }
            if style == .list {
                withAnimation {
                    selectedID = nil
                }
                backStack.removeAll()
            } else {
                let top = backStack.removeFirst()
                guard let form = form(for: top) else {
                    Logger.featureFormBrowserView.warning("No ID for back navigation.")
                    return
                }
                select(feature: form.feature, recordNavigation: false)
            }
        }
        
        /// <#Description#>
        /// - Parameter feature: <#form description#>
        public func remove(feature: ArcGISFeature) {
            manager.forms.forEach { form in
                if feature.globalID == form.feature.globalID {
                    manager.remove(feature)
                }
            }
            backStack.removeAll { id in
                feature.globalID == id
            }
            if selectedID == feature.globalID, canGoBack {
                let top = backStack.removeFirst()
                if let _form = self.form(for: top) {
                    select(feature: _form.feature)
                }
            }
            selectedID = backStack.last
        }
        
        /// <#Description#>
        /// - Parameter id: <#id description#>
        /// - Returns: <#description#>
        public func form(for id: UUID) -> FeatureForm? {
            manager.forms.first { $0.feature.globalID == id } ?? nil
        }
        
        /// <#Description#>
        /// - Parameters:
        ///   - feature: <#feature description#>
        ///   - recordNavigation: <#recordNavigation description#>
        public func select(feature: ArcGISFeature, recordNavigation: Bool = true) {
            guard feature.globalID != selectedID else { return }
            if recordNavigation, let selectedID {
                backStack.insert(selectedID, at: 0)
            }
            selectedID = feature.globalID
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
            let nextForm = manager.forms[nextIndex]
            select(feature: nextForm.feature)
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
            let nextForm = manager.forms[nextIndex]
            select(feature: nextForm.feature)
        }
            
        private(set) var formsWithEdits = [UUID: Bool]()
        
        private(set) var formsWithErrors = [UUID: Int]()
        
        func monitorEdits() async {
            Logger.featureFormBrowserView.info("Starting edit monitoring.")
            await withTaskGroup { group in
                for form in manager.forms {
                    group.addTask { @Sendable in
                        for await hasEdits in form.$hasEdits {
                            if let globalID = form.feature.globalID {
#warning("Edit monitoring temporarily disabled.")
//                                self.formsWithEdits[globalID] = hasEdits
                            }
                        }
                    }
                }
            }
        }
        
        func monitorErrors() async {
            Logger.featureFormBrowserView.info("Starting error monitoring.")
            await withTaskGroup { group in
                for form in manager.forms {
                    group.addTask { @Sendable in
                        for await errors in form.$elementValidationErrors {
                            if let globalID = form.feature.globalID {
#warning("Error monitoring temporarily disabled.")
//                                self.formsWithErrors[globalID] = errors.count
                            }
                        }
                    }
                }
            }
        }
    }
}

@Observable public final class FeatureFormManager {
    convenience init(features: Array<ArcGISFeature>) {
        self.init(forms: features.map { .init(feature: $0) })
    }
    
    init(forms: Array<FeatureForm>) {
        self.forms = forms
    }
    
    public func add(_ feature: ArcGISFeature) {
        let newForm = FeatureForm(feature: feature)
        forms.append(newForm)
    }
    
    public func add(_ form: FeatureForm) {
        forms.append(form)
    }
    
    public func remove(_ feature: ArcGISFeature) {
        forms.removeAll { form in
            feature.globalID == form.feature.globalID
        }
    }
    
    public func remove(_ form: FeatureForm) {
        forms.removeAll { _form in
            form.feature.globalID == _form.feature.globalID
        }
    }
    
    public func discardEdits() async {
        forms.forEach { form in
            form.discardEdits()
        }
    }
    
    public func evaluateExpressions() async {
        await withThrowingTaskGroup { group in
            forms.forEach { form in
                group.addTask {
                    try await form.evaluateExpressions()
                }
            }
        }
    }
    
    public func finishEditing() async {
        await withThrowingTaskGroup { group in
            forms.forEach { form in
                group.addTask {
                    try await form.finishEditing()
                }
            }
        }
    }
    
    private(set) var forms = [FeatureForm]()
}

extension FeatureFormManagerView /* Manager style variants */ {
    /// <#Description#>
    @ViewBuilder
    var list: some View {
        Group {
            if let selected = model.selectedForm {
                FeatureFormView(root: selected)
                    .transition(.asymmetric(insertion: .push(from: .trailing), removal: .move(edge: .trailing)))
            } else {
                NavigationStack {
                    List(model.manager.forms, id: \.feature.globalID) { form in
                        Button(form.title) {
                            withAnimation {
                                model.select(feature: form.feature)
                            }
                        }
                    }
                    .navigationTitle(
                        model.manager.forms.count == 1
                        ? "Editing 1 Feature"
                        : "Editing \(model.manager.forms.count) Features"
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Menu {} label: {
                                Label {} icon: {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
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
                Text("No form is selected.")
            }
        }
    }
    
    /// <#Description#>
    @ViewBuilder
    var pagedView: some View {
        if let selection = model.selectedID {
            TabView(
                selection: Binding {
                    selection
                } set: { newID in
                    guard let form = model.form(for: newID) else { return }
                    model.select(feature: form.feature, recordNavigation: true)
                }
            ) {
                ForEach(model.ids, id: \.self) { id in
                    if let form = model.form(for: id) {
                        Tab(value: id) {
                            FeatureFormView(
                                root: form,
                                isPresented: Binding(
                                    get: { true },
                                    set: { _ in model.remove(feature: form.feature) }
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
            .tabViewStyle(.page(indexDisplayMode: .never))
        } else {
            Text("No form is selected.")
        }
    }
    
    /// <#Description#>
    @ViewBuilder
    var tabView: some View {
        if let selection = model.selectedID {
            if let form = model.form(for: selection) {
                FeatureFormView(
                    root: form,
                    isPresented: Binding(
                        get: { true },
                        set: { _ in
                            model.manager.remove(form.feature)
                        }
                    )
                )
                .editingButtons(.hidden)
                .environment(model)
                .id(model.selectedIndex)
            }
        } else {
            Text("No form is selected.")
        }
    }
}

extension FeatureFormManagerView /* Enums */ {
    /// <#Description#>
    public enum Style {
        case list
        case menu
        case menuWithTabs
        case paged
    }
}

public extension FeatureFormManagerView /* Modifiers */ {
    func style(_ style: FeatureFormManagerView.Style) -> some View {
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

struct FeatureFormManagerViewPreview: View {
    @State private var style: FeatureFormManagerView.Style = .paged
    @Binding var model: FeatureFormManagerView.Model
    var body: some View {
        FeatureFormManagerView(model: $model)
            .style(style)
        HStack(spacing: 50) {
            Menu {
                Picker("Browser Style", selection: $style) {
                    Text("List")
                        .tag(FeatureFormManagerView.Style.list)
                    Text("Menu")
                        .tag(FeatureFormManagerView.Style.menu)
                    Text("Menu With Tabs")
                        .tag(FeatureFormManagerView.Style.menuWithTabs)
                    Text("Paged")
                        .tag(FeatureFormManagerView.Style.paged)
                }
            } label: {
                Text("Style")
            }
            Button("Log model state") {
                model.debugLog()
            }
        }
    }
}

#Preview {
    @Previewable @State var map: Map?
    @Previewable @State var model = FeatureFormManagerView.Model(features: [])
    @Previewable @State var loadResult: Result<Void, Error>?
    
    switch loadResult {
    case .success(let success):
        MapView(map: map!)
            .sheet(isPresented: .constant(true)) {
                FeatureFormManagerViewPreview(model: $model)
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
                    features?.forEach { feature in
                        model.add(feature: feature)
                    }
                }
            }
    }
}
