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

import Foundation
import ArcGIS

/// An `ArcGISChallengeHandler` that can handle challenges using ArcGIS credential.
final class ArcGISChallengeHandler: ArcGISAuthenticationChallengeHandler {
    /// The arcgis credential used when an ArcGIS challenge is received.
    let credentialProvider: @Sendable (ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?
    
    /// The ArcGIS authentication challenges.
    private(set) var challenges: [ArcGISAuthenticationChallenge] = []
    
    init(
        credentialProvider: @escaping @Sendable (ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?
    ) {
        self.credentialProvider = credentialProvider
    }
    
    func handleArcGISAuthenticationChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        challenges.append(challenge)
        
        if let arcgisCredential = try await credentialProvider(challenge) {
            return .continueWithCredential(arcgisCredential)
        } else {
            return .continueWithoutCredential
        }
    }
}
