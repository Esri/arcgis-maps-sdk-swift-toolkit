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

import ArcGIS
import SwiftUI
import Combine

@MainActor
public final class Authenticator: ObservableObject {
    let oAuthConfigurations: [OAuthConfiguration]
    var trustedHosts: [String] = []
    var urlCredentialPersistence: URLCredential.Persistence = .forSession
    var promptForUntrustedHosts: Bool
    var certificateStore: CertificateCredentialStore?
    
    public init(
        promptForUntrustedHosts: Bool = false,
        oAuthConfigurations: [OAuthConfiguration] = []
    ) {
        self.promptForUntrustedHosts = promptForUntrustedHosts
        self.oAuthConfigurations = oAuthConfigurations
        self.certificateStore = nil
        Task { await observeChallengeQueue() }
    }
    
    /// Sets up a credential store that is synchronized with the keychain.
    /// - Remark: If no group is specified then the item will be stored in the default group.
    /// To know more about what the default group would be you can find information about that here:
    /// https://developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps.
    /// - Parameters:
    ///   - access: When the credentials stored in the keychain can be accessed.
    ///   - groupIdentifier: The identifier of the group that credentials should be persisted to
    ///   within the keychain.
    ///   - isSynchronizable: A value indicating whether the item is synchronized with iCloud.
    public func synchronizeWithKeychain(
        access: ArcGIS.KeychainAccess,
        groupIdentifier: String? = nil,
        isCloudSynchronizable: Bool = false
    ) async throws {
        ArcGISURLSession.credentialStore = try await .makePersistent(
            access: access,
            groupIdentifier: groupIdentifier,
            isSynchronizable: isCloudSynchronizable
        )
        certificateStore = try await CertificateCredentialStore(
            access: .whenUnlockedThisDeviceOnly,
            groupIdentifier: nil,
            isSynchronizable: isCloudSynchronizable
        )
        urlCredentialPersistence = isCloudSynchronizable ? .synchronizable : .permanent
    }
    
    public func clearCredentialStores() async {
        // Clear trusted hosts
        trustedHosts.removeAll()
        
        // Clear ArcGIS Credentials.
        await ArcGISURLSession.credentialStore.removeAll()
        
        // Clear certificate store.
        await certificateStore?.clear()
        
        // Clear URLCredentials.
        URLCredentialStorage.shared.removeAllCredentials()
        
        // We have to reset the sessions for URLCredential storage to respect the removed credentials
        ArcGISURLSession.shared = ArcGISURLSession.makeDefaultSharedSession()
        ArcGISURLSession.sharedBackground = ArcGISURLSession.makeDefaultSharedBackgroundSession()
    }
    
    private func observeChallengeQueue() async {
        for await queuedChallenge in challengeQueue {
            // A yield here helps alleviate the already presenting bug.
            await Task.yield()
            
            if let queuedArcGISChallenge = queuedChallenge as? QueuedArcGISChallenge,
               let url = queuedArcGISChallenge.arcGISChallenge.request.url,
               let config = oAuthConfigurations.first(where: { $0.canBeUsed(for: url) }) {
                // For an OAuth challenge, we create the credential and resume.
                // Creating the OAuth credential will present the OAuth login view.
                queuedArcGISChallenge.resume(with: .oAuth(configuration: config))
            } else {
                
                if let challenge = queuedChallenge as? QueuedArcGISChallenge,
                   let previous = await ArcGISURLSession.credentialStore.credential(for: challenge.arcGISChallenge.request.url!) {
                    print("-- previous: \(previous)")
                }
                    
                // Set the current challenge, this should present the appropriate view.
                currentChallenge = queuedChallenge

                // Wait for the queued challenge to finish.
                await queuedChallenge.complete()
                
                // Reset the crrent challenge to `nil`, that will dismiss the view.
                currentChallenge = nil
            }
        }
    }
    
    private var subject = PassthroughSubject<QueuedChallenge, Never>()
    private var challengeQueue: AsyncPublisher<AnyPublisher<QueuedChallenge, Never>> {
        AsyncPublisher(
            subject
                .buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
                .eraseToAnyPublisher()
        )
    }
    
    @Published
    var currentChallenge: QueuedChallenge?
}

extension Authenticator: AuthenticationChallengeHandler {
    public func handleArcGISChallenge(
        _ challenge: ArcGISAuthenticationChallenge
    ) async throws -> ArcGISAuthenticationChallenge.Disposition {
        guard challenge.proposedCredential == nil else {
            return .performDefaultHandling
        }
        
        // Queue up the challenge.
        let queuedChallenge = QueuedArcGISChallenge(arcGISChallenge: challenge)
        subject.send(queuedChallenge)
        
        // Wait for it to complete and return the resulting disposition.
        switch await queuedChallenge.response {
        case .tokenCredential(let username, let password):
            return try await .useCredential(.token(challenge: challenge, username: username, password: password))
        case .oAuth(let configuration):
            return try await .useCredential(.oauth(configuration: configuration))
        case .cancel:
            return .cancelAuthenticationChallenge
        }
    }
    
    public func handleURLSessionChallenge(
        _ challenge: URLAuthenticationChallenge,
        scope: URLAuthenticationChallengeScope
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod != NSURLAuthenticationMethodDefault else {
            return (.performDefaultHandling, nil)
        }
        
        guard challenge.proposedCredential == nil else {
            return (.performDefaultHandling, nil)
        }
        
        // Check for server trust challenge.
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            if trustedHosts.contains(challenge.protectionSpace.host) {
                // If the host is already trusted, then continue trusting it.
                return (.useCredential, URLCredential(trust: trust))
            } else if !trust.isRecoverableTrustFailure {
                // If not a recoverable trust failure then we perform default handling.
                return (.performDefaultHandling, nil)
            } else if !promptForUntrustedHosts {
                // If we aren't allowed to prompt for untrusted hosts then perform default handling.
                return (.performDefaultHandling, nil)
            }
        }
        
        // Look in certificate store, use that credential if available.
        if let certificateCredential = await certificateStore?.credential(for: challenge.protectionSpace),
           let urlCredential = try? URLCredential.withCertificateCredential(certificateCredential) {
            return (.useCredential, urlCredential)
        }
        
        // Queue up the url challenge.
        let queuedChallenge = QueuedURLChallenge(urlChallenge: challenge)
        subject.send(queuedChallenge)
        
        // Respond accordingly.
        switch await queuedChallenge.response {
        case .cancel:
            return (.cancelAuthenticationChallenge, nil)
        case .trustHost:
            if let trust = challenge.protectionSpace.serverTrust {
                trustedHosts.append(challenge.protectionSpace.host)
                return (.useCredential, URLCredential(trust: trust))
            } else {
                return (.performDefaultHandling, nil)
            }
        case .userCredential(let user, let password):
            return (.useCredential, URLCredential(user: user, password: password, persistence: urlCredentialPersistence))
        case .certificate(let url, let password):
            do {
                let data = try await Data(asyncWithContentsOf: url)
                await certificateStore?.add(credential: .init(host: challenge.protectionSpace.host, data: data, password: password))
                return (
                    .useCredential,
                    try URLCredential.urlCredential(forCertificateWithData: data, password: password)
                )
            } catch {
                return (.performDefaultHandling, nil)
            }
        }
    }
}

extension SecTrust {
    var isRecoverableTrustFailure: Bool {
        var result = SecTrustResultType.invalid
        SecTrustGetTrustResult(self, &result)
        return result == .recoverableTrustFailure
    }
}

extension URLCredentialStorage {
    func removeAllCredentials() {
        allCredentials.forEach { (protectionSpace: URLProtectionSpace, usernamesToCredentials: [String : URLCredential]) in
            for credential in usernamesToCredentials.values {
                remove(credential, for: protectionSpace)
            }
        }
    }
}

private extension URLCredential {
    /// An error that can occur when importing a certificate.
    struct CertificateImportError: Error, Hashable {
        /// The backing status code for this error.
        let status: OSStatus
        
        /// Initializes a certificate import error. This init will fail if the specified status is a success
        /// status value.
        /// - Parameter status: An `OSStatus`, usually the return value of a keychain operation.
        init?(status: OSStatus) {
            guard status != errSecSuccess else { return nil }
            self.status = status
        }
    }
    
    static func urlCredential(
        forCertificateAt fileURL: URL,
        password: String
    ) async throws -> URLCredential {
        return try urlCredential(
            forCertificateWithData: try await Data(asyncWithContentsOf: fileURL),
            password: password
        )
    }
    static func urlCredential(
        forCertificateWithData data: Data,
        password: String
    ) throws -> URLCredential {
        let options = [kSecImportExportPassphrase: password]
        var rawItems: CFArray?
        
        let status = SecPKCS12Import(
            data as CFData,
            options as CFDictionary,
            &rawItems
        )
        
        guard status == errSecSuccess else {
            throw CertificateImportError(status: status)!
        }
        
        let items = rawItems! as! [[CFString: Any]]
        let identity = items[0][kSecImportItemIdentity] as! SecIdentity
        let certificates = items[0][kSecImportItemCertChain] as! [SecTrust]
        
        return URLCredential(
            identity: identity,
            certificates: certificates,
            // Persistence is not supported at all at this point by apple for certificate credentials.
            // So we can just pass `.none`.
            persistence: .none
        )
    }
}

extension Data {
    init(asyncWithContentsOf fileURL: URL) async throws {
        let task = Task {
            try Data(contentsOf: fileURL)
        }
        self = try await task.value
    }
}

extension URLCredential.CertificateImportError {
    // The message for this error.
    var message: String {
        (SecCopyErrorMessageString(status, nil) as String?) ?? ""
    }
}

extension URLCredential {
    static func withCertificateCredential(_ certificateCredential: CertificateCredential) throws -> URLCredential {
        try URLCredential.urlCredential(forCertificateWithData: certificateCredential.data, password: certificateCredential.password)
    }
}
