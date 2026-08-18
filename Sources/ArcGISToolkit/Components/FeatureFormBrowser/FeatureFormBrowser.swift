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
public struct FeatureFormBrowser: View {
    /// <#Description#>
    @Binding var model: Model
    
    /// <#Description#>
    /// - Parameter model: <#model description#>
    public init(model: Binding<Model>) {
        _model = model
    }
    
    public var body: some View {
        TabView {
            ForEach(model.forms, id: \.feature.globalID) { form in
                Tab {
                    FeatureFormView(root: form)
                } label: {
                    Image(systemName: "list.bullet.clipboard")
                    Text(form.title)
                }
            }
        }
    }
}

extension FeatureFormBrowser {
    /// <#Description#>
    @Observable public final class Model {
        /// <#Description#>
        /// - Parameter forms: <#forms description#>
        public init(forms: [FeatureForm] = []) {
            self.forms = forms
        }
        
        /// <#Description#>
        var forms = [FeatureForm]()
        
        /// <#Description#>
        /// - Parameter form: <#form description#>
        public func add(form: FeatureForm) {
            forms.append(form)
        }
    }
}
