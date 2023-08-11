***REMOVED*** Copyright 2023 Esri.

***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED*** http:***REMOVED***www.apache.org/licenses/LICENSE-2.0

***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

import Foundation
import CryptoTokenKit
***REMOVED***

@MainActor
public final class SmartCardManager: ObservableObject {
***REMOVED******REMOVED***/ The smart card connection watcher.
***REMOVED***private let watcher = TKTokenWatcher()
***REMOVED***
***REMOVED******REMOVED***/ The last used smart card personal identity verification (PIV) token.
***REMOVED***public private(set) var lastUsedPIVToken: String? = nil
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the smart card is disconnected.
***REMOVED***@Published public internal(set) var isCardDisconnected: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a different smart card is connected.
***REMOVED***@Published public internal(set) var isDifferentCardConnected: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ Creates smart card manager.
***REMOVED***init() {
***REMOVED******REMOVED******REMOVED*** Monitor the smart card connection for PIV tokens.
***REMOVED******REMOVED***watcher.setInsertionHandler { [weak self] tokenID in
***REMOVED******REMOVED******REMOVED***guard let self = self, tokenID.localizedCaseInsensitiveContains("pivtoken") else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let lastUsedPIVToken, tokenID != lastUsedPIVToken {
***REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isDifferentCardConnected = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***watcher.addRemovalHandler( { [weak self] tokenID in
***REMOVED******REMOVED******REMOVED******REMOVED***guard let self = self else { return ***REMOVED***

***REMOVED******REMOVED******REMOVED******REMOVED***if tokenID == lastUsedPIVToken {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isCardDisconnected = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***, forTokenID: tokenID)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The first PIV token found the the token watcher.
***REMOVED******REMOVED***/ - Note: The PIV token will be available only if smart card is connected to the device.
***REMOVED***var pivToken: String? {
***REMOVED******REMOVED***watcher.tokenIDs.filter({ $0.localizedCaseInsensitiveContains("pivtoken") ***REMOVED***).first
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the last used PIV token with given value.
***REMOVED***func setLastUsedPIVToken(_ token: String?) {
***REMOVED******REMOVED***lastUsedPIVToken = token
***REMOVED***
***REMOVED***
