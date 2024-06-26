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
        #warning("You must set your API Key or request that the user signs in with an ArcGIS account")
        /*
         Use of ArcGIS location services, such as basemaps, geocoding, and routing, requires either user authentication or API key authentication. For more information see https://links.esri.com/arcgis-maps-sdk-security-auth or https://links.esri.com/arcgis-maps-sdk-license-and-deploy.
         1) User authentication: Allows users with an ArcGIS account to sign into an application and access secure services.
         2) API key authentication: A long-lived access token that gives your application access to secure services. Go to the [Create an API key](https://developers.arcgis.com/documentation/security-and-authentication/api-key-authentication/tutorials/create-an-api-key/) tutorial to copy the API key access token. To access all services used by this application set the location services privileges to:
         
           Location services > Basemaps
           Location services > Geocoding
           Location services > Routing
         
        Production deployment of applications built with the ArcGIS Runtime SDK requires you to license ArcGIS Runtime functionality. For more information see https://links.esri.com/arcgis-runtime-license-and-deploy.
         */
        // Uncomment the following line to access ArcGIS location services using an API key.
//         ArcGISEnvironment.apiKey = APIKey("<#API Key#>")
    }
}
