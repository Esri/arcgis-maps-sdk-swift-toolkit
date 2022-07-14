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

/// An object that represents a network authentication challenge in the queue of challenges.
final class QueuedNetworkChallenge: QueuedChallenge {
    /// The host that prompted the challenge.
    let host: String
    /// The kind of challenge.
    let kind: Kind
    
    /// Creates a `QueuedNetworkChallenge`.
    /// - Parameters:
    ///   - host: The host that prompted the challenge.
    ///   - kind: The kind of challenge.
    init(host: String, kind: Kind) {
        self.host = host
        self.kind = kind
    }
    
    /// Resumes the queued challenge.
    /// - Parameter disposition: The disposition to resume with.
    func resume(with disposition: NetworkAuthenticationChallengeDisposition) {
        guard _disposition == nil else { return }
        _disposition = disposition
    }
    
    /// Use a streamed property because we need to support multiple listeners
    /// to know when the challenge completed.
    @Streamed private var _disposition: (NetworkAuthenticationChallengeDisposition)?
    
    /// The resulting disposition of the challenge.
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
}

extension QueuedNetworkChallenge {
    /// Creates a `QueuedNetworkChallenge`.
    /// - Parameter networkChallenge: The associated network authentication challenge.
    convenience init?(networkChallenge: NetworkAuthenticationChallenge) {
        guard let kind = Kind(networkChallenge.kind) else {
            return nil
        }
        self.init(host: networkChallenge.host, kind: kind)
    }
}

extension QueuedNetworkChallenge {
    /// An enumeration that describes the kind of challenge.
    enum Kind {
        /// A challenge for an untrusted host.
        case serverTrust
        /// A challenge that requires a login via username and password.
        case login
        /// A challenge that requires a client certificate.
        case certificate
    }
}

extension QueuedNetworkChallenge.Kind {
    /// Creates an instance.
    /// - Parameter networkAuthenticationChallengeKind: The kind of network authentication
    /// challenge.
    init?(_ networkAuthenticationChallengeKind: NetworkAuthenticationChallenge.Kind) {
        switch networkAuthenticationChallengeKind {
        case .serverTrust:
            self = .serverTrust
        case .ntlm, .basic, .digest:
            self = .login
        case .clientCertificate:
            self = .certificate
        }
    }
}
