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
import Foundation

@Observable public final class FeatureFormGroup: @unchecked Sendable {
    private let lock = NSLock()
    
    init(forms: Array<FeatureForm>) {
        self.forms = forms
    }
    
    public func add(_ form: FeatureForm) {
        lock.lock()
        defer { lock.unlock() }
        forms.append(form)
    }
    
    public func remove(_ form: FeatureForm) {
        lock.lock()
        defer { lock.unlock() }
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
