// Copyright 2022 Esri.

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
import ArcGIS

protocol QueuedChallenge: AnyObject {
    func complete() async
}

final class QueuedArcGISChallenge: QueuedChallenge {
    let arcGISChallenge: ArcGISAuthenticationChallenge
    
    init(arcGISChallenge: ArcGISAuthenticationChallenge) {
        self.arcGISChallenge = arcGISChallenge
    }

    func resume(with response: Response) {
        guard _response == nil else { return }
        _response = response
    }
    
    func cancel() {
        guard _response == nil else { return }
        _response = .cancel
    }
    
    /// Use a streamed property because we need to support multiple listeners
    /// to know when the challenge completed.
    @Streamed private var _response: Response?
    
    var response: Response {
        get async {
            await $_response
                .compactMap({ $0 })
                .first(where: { _ in true })!
        }
    }
    
    public func complete() async {
        _ = await response
    }
    
    enum Response {
        case tokenCredential(username: String, password: String)
        case oAuth(configuration: OAuthConfiguration)
        case cancel
    }
}

final class QueuedNetworkChallenge: QueuedChallenge {
    let networkChallenge: NetworkAuthenticationChallenge
    
    init(networkChallenge: NetworkAuthenticationChallenge) {
        self.networkChallenge = networkChallenge
    }

    func resume(with response: NetworkAuthenticationChallengeDisposition) {
        guard _disposition == nil else { return }
        _disposition = response
    }
    
    /// Use a streamed property because we need to support multiple listeners
    /// to know when the challenge completed.
    @Streamed private var _disposition: (NetworkAuthenticationChallengeDisposition)?
    
    var disposition: NetworkAuthenticationChallengeDisposition {
        get async {
            await $_disposition
                .compactMap({ $0 })
                .first(where: { _ in true })!
        }
    }
    
    public func complete() async {
        _ = await disposition
    }
    
    enum Kind {
        case serverTrust
        case login
        case certificate
    }
    
    var kind: Kind {
        switch networkChallenge.kind {
        case .serverTrust:
            return .serverTrust
        case .ntlm, .basic, .digest:
            return .login
        case .pki:
            return .certificate
        case .htmlForm, .negotiate:
            fatalError("TODO: ")
        }
    }
}
