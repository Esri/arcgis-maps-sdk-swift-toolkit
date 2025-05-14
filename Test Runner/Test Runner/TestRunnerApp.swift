// Copyright 2023 Esri
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

@main
struct TestRunnerApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            Tests()
        }
    }
    
    init() {
//        ArcGISEnvironment.apiKey = APIKey("AAPK83fdb937974a43fda5dcc544a4d2c831Kt05knTmR1dZSbizfPRt-8xC9ieZqaew87pYsuESt1kK2GrhUpOSeDlkVqoCQgho")
        ArcGISEnvironment.apiKey = APIKey("AAPK64f41d7ae01a4c64b8acbb63a830b592D0LE_PN47pvnwe9B9BObfw99iNYjbeKCJLOcEJKnToAS-C_hG-FMdjneelPvWXQ7")
    }
}
