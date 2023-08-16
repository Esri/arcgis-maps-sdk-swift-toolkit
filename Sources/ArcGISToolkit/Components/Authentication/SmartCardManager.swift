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
***REMOVED******REMOVED***/ An enumeration of the various status values for a smart card connection.
***REMOVED***public enum ConnectionStatus {
***REMOVED******REMOVED******REMOVED***/ A smart card is connected to the device.
***REMOVED******REMOVED***case connected
***REMOVED******REMOVED******REMOVED***/ A smart card is disconnected from the device.
***REMOVED******REMOVED***case disconnected
***REMOVED******REMOVED******REMOVED***/ The connection is unspecified.
***REMOVED******REMOVED***case unspecified
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/  The current smart card connection status.
***REMOVED***@Published public var connectionStatus: ConnectionStatus = .unspecified
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the smart card is disconnected.
***REMOVED***@Published var isCardDisconnected: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether a different smart card is connected.
***REMOVED***@Published var isDifferentCardConnected: Bool = false
***REMOVED***
***REMOVED******REMOVED***/ The smart card connection watcher.
***REMOVED***private let watcher = TKTokenWatcher()
***REMOVED***
***REMOVED******REMOVED***/ The last connected smart card.
***REMOVED***private var lastConnectedCard: String? = nil
***REMOVED***
***REMOVED******REMOVED***/ Creates smart card manager.
***REMOVED***init() {
***REMOVED******REMOVED******REMOVED*** Monitor the smart card connection.
***REMOVED******REMOVED***watcher.setInsertionHandler { [weak self] tokenID in
***REMOVED******REMOVED******REMOVED***guard let self = self, tokenID.localizedCaseInsensitiveContains("pivtoken") else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***print("tokenID added: \(tokenID)")
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let lastConnectedCard, tokenID != lastConnectedCard {
***REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isDifferentCardConnected = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***lastConnectedCard = tokenID
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED***if self.connectionStatus != .connected {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.connectionStatus = .connected
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***watcher.addRemovalHandler( { [weak self] tokenID in
***REMOVED******REMOVED******REMOVED******REMOVED***guard let self = self else { return ***REMOVED***

***REMOVED******REMOVED******REMOVED******REMOVED***print("tokenID removed: \(tokenID)")

***REMOVED******REMOVED******REMOVED******REMOVED***if tokenID == lastConnectedCard {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.connectionStatus = .disconnected
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.isCardDisconnected = true
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***, forTokenID: tokenID)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The first PIV token found in the token watcher.
***REMOVED******REMOVED***/ - Note: The PIV token will be available only if smart card is connected to the device.
***REMOVED***var pivToken: String? {
***REMOVED******REMOVED***watcher.tokenIDs.filter({ $0.localizedCaseInsensitiveContains("pivtoken") ***REMOVED***).first
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets the last connected card if PIV token is available. This is being called from the
***REMOVED******REMOVED***/ authentication challenge handler to monitor the smart card.
***REMOVED***func setLastConnectedCard() {
***REMOVED******REMOVED***guard let pivToken = pivToken else { return ***REMOVED***
***REMOVED******REMOVED***if lastConnectedCard == nil {
***REMOVED******REMOVED******REMOVED***lastConnectedCard = pivToken
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Resets the smart card manager.
***REMOVED***func reset() {
***REMOVED******REMOVED***lastConnectedCard = nil
***REMOVED******REMOVED***isCardDisconnected = false
***REMOVED******REMOVED***isDifferentCardConnected = false
***REMOVED******REMOVED***connectionStatus = .unspecified
***REMOVED***
***REMOVED***
