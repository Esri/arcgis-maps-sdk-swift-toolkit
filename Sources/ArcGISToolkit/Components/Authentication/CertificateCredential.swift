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

struct CertificateCredential: Hashable {
    let host: String
    let data: Data
    let password: String
}

extension CertificateCredential: Codable {}

final actor CertificateCredentialStore {
    private var storage: [String: CertificateCredential] = [:]
    
    let keychain: Keychain?
    let access: KeychainAccess?
    let groupIdentifier: String?
    let isSynchronizable: Bool
    
    static let label: String = "ArcGIS Certificate Credential"
    
    init() {
        keychain = nil
        groupIdentifier = nil
        access = nil
        isSynchronizable = false
    }
    
    init(access: KeychainAccess, groupIdentifier: String? = nil, isSynchronizable: Bool = false) async throws {
        keychain = .shared
        self.access = access
        self.groupIdentifier = groupIdentifier
        self.isSynchronizable = isSynchronizable
        
        for item in try await Keychain.shared.items(labeled: Self.label, inGroup: groupIdentifier) {
            let credential = try JSONDecoder().decode(CertificateCredential.self, from: item.value)
            storage[credential.host] = credential
        }
    }
    
    func credential(for protectionSpace: URLProtectionSpace) -> CertificateCredential? {
        guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate else {
            return nil
        }
        return storage[protectionSpace.host]
    }
    
    func add(credential: CertificateCredential) async {
        storage[credential.host] = credential
        if let keychain = keychain, let access = access {
            try? await keychain.storeItem(
                identifier: credential.host,
                value: try JSONEncoder().encode(credential),
                access: access,
                label: Self.label,
                groupIdentifier: groupIdentifier,
                isSynchronizable: isSynchronizable
            )
        }
    }
    
    func clear() async {
        storage.removeAll()
        if let keychain = keychain {
            try? await keychain.removeItems(labeled: Self.label, inGroup: groupIdentifier)
        }
    }
}

