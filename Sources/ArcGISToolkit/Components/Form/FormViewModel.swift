// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import FormsPlugin
import SwiftUI

public class FormViewModel: ObservableObject {
    /// The structure of the form.
    @Published var formDefinition: FeatureFormDefinition?
    
    /// The featured being edited in the form.
    @Published private(set) var feature: ArcGISFeature?
    
    /// Initializes a form view model.
    public init() {}
    
    /// Prepares the feature for editing in the form.
    /// - Parameter feature: The feature to be edited in the form.
    public func startEditing(_ feature: ArcGISFeature) {
        self.feature = feature
    }
    
    /// Submit the changes made to the form.
    public func submitChanges() {
        print(#function)
    }
}
