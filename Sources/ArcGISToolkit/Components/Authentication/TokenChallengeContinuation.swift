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

/// An object that represents an ArcGIS token authentication challenge continuation.
@MainActor
final class TokenChallengeContinuation: ValueContinuation<Result<ArcGISAuthenticationChallenge.Disposition, Error>>, ChallengeContinuation {
    /// The host that prompted the challenge.
    let host: String
    
    /// A closure that provides a token credential from a username and password.
    let tokenCredentialProvider: (LoginCredential) async throws -> ArcGISCredential
    
    /// Creates a `ArcGISChallengeContinuation`.
    /// - Parameters:
    ///   - host: The host that prompted the challenge.
    ///   - tokenCredentialProvider: A closure that provides a token credential from a username and password.
    init(
        host: String,
        tokenCredentialProvider: @escaping (LoginCredential) async throws -> ArcGISCredential
    ) {
        self.host = host
        self.tokenCredentialProvider = tokenCredentialProvider
    }
    
    /// Creates a `ArcGISChallengeContinuation`.
    /// - Parameter arcGISChallenge: The associated ArcGIS authentication challenge.
    convenience init(arcGISChallenge: ArcGISAuthenticationChallenge) {
        self.init(host: arcGISChallenge.requestURL.host ?? "") { loginCredential in
            try await TokenCredential.credential(
                for: arcGISChallenge,
                username: loginCredential.username,
                password: loginCredential.password
            )
        }
    }
    
    /// Resumes the challenge with a username and password.
    /// - Parameters:
    ///   - loginCredential: The username and password.
    func resume(with loginCredential: LoginCredential) {
        Task { @MainActor in
            setValue(await Result { @MainActor in
                .continueWithCredential(try await tokenCredentialProvider(loginCredential))
            })
        }
    }
    
    /// Cancels the challenge.
    func cancel() {
        setValue(.success(.cancel))
    }
}
