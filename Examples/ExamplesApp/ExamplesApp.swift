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
import ArcGISToolkit
import SwiftUI

@main
struct ExamplesApp: App {    
    @StateObject private var authenticator = Authenticator(
        promptForUntrustedHosts: true
        // If you want to use OAuth, uncomment this code:
        //      oAuthUserConfigurations: [.arcgisDotCom]
    )

    var body: some SwiftUI.Scene {
        WindowGroup {
            Examples()
                .authenticator(authenticator)
                .task {
                    ArcGISEnvironment.authenticationManager.handleChallenges(using: authenticator)
                }
        }
    }

    init() {
        #warning("You must set your API Key or request that the user signs in with an ArcGIS account")
        /*
         Use of ArcGIS location services, such as basemap styles, geocoding, and routing services, requires either user authentication or API key authentication. For more information see https://developers.arcgis.com/documentation/security-and-authentication/types-of-authentication/ or https://developers.arcgis.com/swift/security-and-authentication/.
         1) User authentication: Allows users with an ArcGIS account to sign into an application and access secure services.
         2) API key authentication: A long-lived access token that gives your application access to secure services. Go to the [Create an API key](https://developers.arcgis.com/documentation/security-and-authentication/api-key-authentication/tutorials/create-an-api-key/) tutorial to copy the API key access token. To access all services used by this application set the location services privileges to:
         
           Location services > Basemaps
           Location services > Geocoding
         
        Production deployment of applications built with the ArcGIS Maps SDK for Swift requires that you license your app. For more information see https://developers.arcgis.com/swift/license-and-deployment/.
         */
        // Uncomment the following line to access ArcGIS location services using an API key.
//         ArcGISEnvironment.apiKey = APIKey("<#API Key#>")
//        ArcGISEnvironment.apiKey = APIKey("AAPK83fdb937974a43fda5dcc544a4d2c831Kt05knTmR1dZSbizfPRt-8xC9ieZqaew87pYsuESt1kK2GrhUpOSeDlkVqoCQgho")
        // Uncomment the following line to access Esri location services using an API key.
        Task {
            do {
                //                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(try await .rtPublisher1)
                //                print("rt_publisher1 Done.")
//                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(try await .nitroTest)
//                print("popupDev Done.")
//                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(try await .mapsqaTest)
//                print("mapsqaTest Done.")
                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(try await .cAPI)
                print("c_api Done.")
//                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(try await .apolloUser)
//                print("apolloUser Done.")
                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(try await .devext)
                print("devext Done.")
//                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(try await .d)
//                print("d Done.")
                ArcGISEnvironment.authenticationManager.arcGISCredentialStore.add(try await .rtPublisher1)
                print("rtPublisher1 Done.")
            } catch {
                print("cred error: \(error)")
            }
        }
    }
}

private extension ArcGISCredential {
    static var nitroTest: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://nitrotest.mapsqa.arcgis.com")!,
                username: "fmuser200",
                password: "fmuser1234"
                //                username: "PopDev",
                //                password: "I68VGU^PopupElements930"
            )
        }
    }
    static var mapsqaTest: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://qaext.arcgis.com")!,
                username: "sharing",
                password: "ago.test"
                //                username: "PopDev",
                //                password: "I68VGU^PopupElements930"
            )
        }
    }
}

private extension ArcGISCredential {
    static var popupDev: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://nitrotest.mapsqa.arcgis.com")!,
                username: "PopDev",
                password: "I68VGU^PopupElements930"
            )
        }
    }
    static var d: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://geo-dev.sbb.ch/portal")!,
                username: "fxesrid@sbb.ch",
                password: ";BBDQIoenXbTy^1`NOdn"
            )
        }
    }
}

private extension ArcGISCredential {
    static var rtPublisher1: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://rt-server11.esri.com/portal/home/")!,
                username: "publisher1",
                password: "test.publisher01"
            )
        }
    }
}

private extension ArcGISCredential {
    static var rtPublisher2: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://runtimecoretest.maps.arcgis.com")!,
                username: "rt_publisher2",
                password: "rt_password01"
            )
        }
    }
}

private extension ArcGISCredential {
    static var cAPI: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://runtimecoretest.maps.arcgis.com")!,
                username: "c_api_publisher",
                password: "c_api_pub1"
            )
        }
    }
}

public extension ArcGISCredential {
    static var apolloUser: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://runtimecoretest.maps.arcgis.com")!,
                username: "apollo_user",
                password: "apollo_user.1234"
            )
        }
    }
}

private extension ArcGISCredential {
    static var nitro: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://nitrotest.mapsqa.arcgis.com")!,
                username: "nitroadmin",
                password: "neonmusiclittle4"
            )
        }
    }
}

private extension ArcGISCredential {
    static var devext: ArcGISCredential {
        get async throws {
            try await TokenCredential.credential(
                for: URL(string: "https://pulsars.mapsdevext.arcgis.com")!,
                username: "rt_publisher1",
                password: "rt_password01"
            )
        }
    }
}
