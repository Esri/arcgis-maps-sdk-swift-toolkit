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
public struct FeatureFormBrowserView: View {
    /// <#Description#>
    @Binding var model: Model
    
    /// <#Description#>
    /// - Parameter model: <#model description#>
    public init(model: Binding<Model>) {
        _model = model
    }
    
    public var body: some View {
        tabView
    }
}

extension FeatureFormBrowserView /* Model */ {
    /// <#Description#>
    @Observable public final class Model {
        /// <#Description#>
        /// - Parameter forms: <#forms description#>
        public init(forms: [FeatureForm] = []) {
            self.forms = forms
            self.selectedID = forms.first?.feature.globalID
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
        public func add(form: FeatureForm, select: Bool = true) {
            forms.append(form)
            if select {
                self.select(form: form)
            }
        }
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        public func remove(form: FeatureForm) {
            forms.removeAll {
                $0.feature.globalID == form.feature.globalID
            }
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
        public func select(form: FeatureForm) {
            if let selectedID {
                backStack.append(selectedID)
            }
            selectedID = form.feature.globalID
        }
    }
}

extension FeatureFormBrowserView /* TabView */ {
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
