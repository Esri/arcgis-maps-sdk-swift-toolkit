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

/// An object that represents an ArcGIS authentication challenge in the queue of challenges.
final class QueuedArcGISChallenge: QueuedChallenge {
    /// The ArcGIS authentication challenge.
    let arcGISChallenge: ArcGISAuthenticationChallenge
    
    /// Creates a `QueuedArcGISChallenge`.
    /// - Parameter arcGISChallenge: The associated ArcGIS authentication challenge.
    init(arcGISChallenge: ArcGISAuthenticationChallenge) {
        self.arcGISChallenge = arcGISChallenge
    }
    
    /// Resumes the challenge with a result.
    /// - Parameter result: The result of the challenge.
    func resume(with result: Result<ArcGISAuthenticationChallenge.Disposition, Error>) {
        guard _result == nil else { return }
        _result = result
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
    
    /// The host that prompted the challenge.
    var host: String {
        arcGISChallenge.request.url?.host ?? ""
    }
    
    public func complete() async {
        _ = await result
    }
}
