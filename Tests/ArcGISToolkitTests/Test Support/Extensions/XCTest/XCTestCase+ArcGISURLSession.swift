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
import ArcGIS

extension XCTestCase {
    /// Sets up an ArcGIS challenge handler on the `ArcGISURLSession` and registers a tear-down block to
    /// reset it to previous handler.
    func setArcGISChallengeHandler(_ challengeHandler: ArcGISAuthenticationChallengeHandler) {
        let previous = ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler
        ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = challengeHandler
        addTeardownBlock { ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = previous }
    }
    
    /// Sets up a network challenge handler on the `ArcGISURLSession` and registers a tear-down block to
    /// reset it to  previous handler.
    func setNetworkChallengeHandler(_ challengeHandler: NetworkAuthenticationChallengeHandler) {
        let previous = ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler
        ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = challengeHandler
        addTeardownBlock { ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = previous }
    }
}
