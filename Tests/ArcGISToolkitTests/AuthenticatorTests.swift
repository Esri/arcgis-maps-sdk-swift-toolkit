// Copyright 2022 Esri
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

import XCTest
@testable import ArcGISToolkit
import ArcGIS
import Combine

final class AuthenticatorTests: XCTestCase {
    @MainActor
    func testInit() {
        let oAuthUserConfiguration = OAuthUserConfiguration(
            portalURL: URL(string:"www.arcgis.com")!,
            clientID: "client id",
            redirectURL: URL(string:"myapp://auth")!
        )
        let iapConfiguration = try! IAPConfiguration.configuration(
            authorizeURL: URL(string: "https://login.microsoftonline.com/tenantID/oauth2/v2.0/authorize")!,
            tokenURL: URL(string: "https://login.microsoftonline.com/tenantID/oauth2/v2.0/token")!,
            logoutURL: URL(string: "https://login.microsoftonline.com/tenantID/oauth2/v2.0/logout")!,
            clientID: "clientID",
            redirectURL: URL(string: "myapp://auth")!,
            scopes: [
                "clientID/.default",
                "offline_access",
                "openid",
                "profile"
            ],
            hostsBehindProxy: ["*.domain.com"],
            authorizationPromptType: .login
        )
        let authenticator = Authenticator(
            promptForUntrustedHosts: true,
            oAuthUserConfigurations: [oAuthUserConfiguration],
            iapConfigurations: [iapConfiguration]
        )
        XCTAssertTrue(authenticator.promptForUntrustedHosts)
        XCTAssertEqual(authenticator.oAuthUserConfigurations, [oAuthUserConfiguration])
        XCTAssertEqual(authenticator.iapConfigurations, [iapConfiguration])
    }
}
