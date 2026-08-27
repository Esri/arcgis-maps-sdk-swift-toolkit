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
        case .paged:
            paged
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
            self.style = .tabs
            self.selectedID = forms.first?.feature.globalID
        }
        
        /// <#Description#>
        var canGoBack: Bool {
            backStack.count > 1
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
                // Select the form, if directed or no form is already selected,
                // regardless of whether it's already in the collection of
                // managed forms.
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
            backStack.removeLast()
            guard let lastID = backStack.last, let form = form(for: lastID) else {
                Logger.featureFormBrowserView.warning("No ID for back navigation.")
                return
            }
            select(form: form, recordNavigation: false)
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
        Text("Under construction")
            .foregroundStyle(.red)
        List(model.forms, id: \.feature.globalID) { form in
            Text(form.title)
                .disabled(true)
        }
        menuView
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
    @ViewBuilder
    var paged: some View {
        Text("Under construction")
            .foregroundStyle(.red)
        menuView
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
        case paged
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
