***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Foundation
***REMOVED***

***REMOVED***/ An `ArcGISChallengeHandler` that can handle challenges using ArcGIS credential.
final class ArcGISChallengeHandler: ArcGISAuthenticationChallengeHandler {
***REMOVED******REMOVED***/ The arcgis credential used when an ArcGIS challenge is received.
***REMOVED***let credentialProvider: @Sendable (ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?
***REMOVED***
***REMOVED******REMOVED***/ The ArcGIS authentication challenges.
***REMOVED***private(set) var challenges: [ArcGISAuthenticationChallenge] = []
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***credentialProvider: @escaping @Sendable (ArcGISAuthenticationChallenge) async throws -> ArcGISCredential?
***REMOVED***) {
***REMOVED******REMOVED***self.credentialProvider = credentialProvider
***REMOVED***
***REMOVED***
***REMOVED***func handleArcGISAuthenticationChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED***challenges.append(challenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if let arcgisCredential = try await credentialProvider(challenge) {
***REMOVED******REMOVED******REMOVED***return .continueWithCredential(arcgisCredential)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return .continueWithoutCredential
***REMOVED***
***REMOVED***
***REMOVED***
