// Copyright 2021 Esri
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
struct ExamplesApp: App {
    var body: some SwiftUI.Scene {
        WindowGroup {
            Examples()
        }
    }
    
    init() {
        #warning("Require user to sign in with an ArcGIS identity or set your developer API key")
        /*
         Use of Esri location services, including basemaps and geocoding, requires either an ArcGIS identity or an API Key. For more information see https://links.esri.com/arcgis-maps-sdk-security-auth.
         1) ArcGIS identity: An ArcGIS named user account that is a member of an organization in ArcGIS Online or ArcGIS Enterprise.
         2) API key: A permanent key that gives your application access to Esri location services. Create a new API key or access existing API keys from your ArcGIS for Developers dashboard (https://links.esri.com/arcgis-api-keys).
         Production deployment of applications built with ArcGIS Maps SDK requires you to license ArcGIS Maps SDK functionality. For more information see https://links.esri.com/arcgis-maps-sdk-license-and-deploy.
         */
        // Uncomment the following line to access Esri location services using an API key.
//         ArcGISEnvironment.apiKey = APIKey("<#API Key#>")
    }
}
