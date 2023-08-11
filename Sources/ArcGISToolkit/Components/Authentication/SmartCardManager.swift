// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation
import CryptoTokenKit
import SwiftUI

@MainActor
public final class SmartCardManager: ObservableObject {
    /// The smart card connection watcher.
    private let watcher = TKTokenWatcher()
    
    /// The last used smart card personal identity verification (PIV) token.
    public private(set) var lastUsedPIVToken: String? = nil
    
    /// A Boolean value indicating whether the smart card is disconnected.
    @Published public internal(set) var isCardDisconnected: Bool = false
    
    /// A Boolean value indicating whether a different smart card is connected.
    @Published public internal(set) var isDifferentCardConnected: Bool = false
    
    /// Creates smart card manager.
    init() {
        // Monitor the smart card connection for PIV tokens.
        watcher.setInsertionHandler { [weak self] tokenID in
            guard let self = self, tokenID.localizedCaseInsensitiveContains("pivtoken") else { return }
            
            if let lastUsedPIVToken, tokenID != lastUsedPIVToken {
                DispatchQueue.main.async {
                    self.isDifferentCardConnected = true
                }
            }
                    
            watcher.addRemovalHandler( { [weak self] tokenID in
                guard let self = self else { return }

                if tokenID == lastUsedPIVToken {
                    DispatchQueue.main.async {
                        self.isCardDisconnected = true
                    }
                }
            }, forTokenID: tokenID)
        }
    }
    
    /// The first PIV token found the the token watcher.
    /// - Note: The PIV token will be available only if smart card is connected to the device.
    var pivToken: String? {
        watcher.tokenIDs.filter({ $0.localizedCaseInsensitiveContains("pivtoken") }).first
    }
    
    /// Sets the last used PIV token with given value.
    func setLastUsedPIVToken(_ token: String?) {
        lastUsedPIVToken = token
    }
}
