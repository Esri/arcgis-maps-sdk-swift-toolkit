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

import XCTest
***REMOVED***

extension XCTestCase {
***REMOVED******REMOVED***/ Sets up an ArcGIS challenge handler on the `ArcGISURLSession` and registers a tear-down block to
***REMOVED******REMOVED***/ reset it to previous handler.
***REMOVED***func setArcGISChallengeHandler(_ challengeHandler: ArcGISAuthenticationChallengeHandler) {
***REMOVED******REMOVED***let previous = ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = challengeHandler
***REMOVED******REMOVED***addTeardownBlock { ArcGISEnvironment.authenticationManager.arcGISAuthenticationChallengeHandler = previous ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets up a network challenge handler on the `ArcGISURLSession` and registers a tear-down block to
***REMOVED******REMOVED***/ reset it to  previous handler.
***REMOVED***func setNetworkChallengeHandler(_ challengeHandler: NetworkAuthenticationChallengeHandler) {
***REMOVED******REMOVED***let previous = ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler
***REMOVED******REMOVED***ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = challengeHandler
***REMOVED******REMOVED***addTeardownBlock { ArcGISEnvironment.authenticationManager.networkAuthenticationChallengeHandler = previous ***REMOVED***
***REMOVED***
***REMOVED***
