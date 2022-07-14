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

// TODO: should be actor?
/// An object that represents an ArcGIS authentication challenge in the queue of challenges.
final class QueuedArcGISChallenge: QueuedChallenge {
    /// The host that prompted the challenge.
    let host: String
    
    /// A closure that provides a token credential from a username and password.
    let tokenCredentialProvider: (String, String) async throws -> ArcGISCredential
    
    /// Creates a `QueuedArcGISChallenge`.
    /// - Parameter arcGISChallenge: The associated ArcGIS authentication challenge.
    init(arcGISChallenge: ArcGISAuthenticationChallenge) {
        host = arcGISChallenge.request.url?.host ?? ""
        tokenCredentialProvider = { username, password in
            try await .token(challenge: arcGISChallenge, username: username, password: password)
        }
    }
    
    /// Resumes the challenge with a username and password.
    /// - Parameters:
    ///   - username: The username.
    ///   - password: The password.
    func resume(username: String, password: String) {
        Task {
            guard _result == nil else { return }
            _result = await Result {
                .useCredential(try await tokenCredentialProvider(username, password))
            }
        }
    }
    
    /// Cancels the challenge.
    func cancel() {
        guard _result == nil else { return }
        _result = .success(.cancelAuthenticationChallenge)
    }
    
    /// Use a streamed property because we need to support multiple listeners
    /// to know when the challenge completed.
    @Streamed private var _result: Result<ArcGISAuthenticationChallenge.Disposition, Error>?
    
    /// The result of the challenge.
    var result: Result<ArcGISAuthenticationChallenge.Disposition, Error> {
        get async {
            await $_result
                .compactMap({ $0 })
                .first(where: { _ in true })!
        }
    }
    
    public func complete() async {
        _ = await result
    }
}
