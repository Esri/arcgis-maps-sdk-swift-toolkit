***REMOVED*** Copyright 2022 Esri.

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

struct CertificateCredential: Hashable {
***REMOVED***let host: String
***REMOVED***let data: Data
***REMOVED***let password: String
***REMOVED***

extension CertificateCredential: Codable {***REMOVED***

final actor CertificateCredentialStore {
***REMOVED***private var storage: [String: CertificateCredential] = [:]
***REMOVED***
***REMOVED***let keychain: Keychain?
***REMOVED***let access: KeychainAccess?
***REMOVED***let groupIdentifier: String?
***REMOVED***let isSynchronizable: Bool
***REMOVED***
***REMOVED***static let label: String = "ArcGIS Certificate Credential"
***REMOVED***
***REMOVED***init() {
***REMOVED******REMOVED***keychain = nil
***REMOVED******REMOVED***groupIdentifier = nil
***REMOVED******REMOVED***access = nil
***REMOVED******REMOVED***isSynchronizable = false
***REMOVED***
***REMOVED***
***REMOVED***init(access: KeychainAccess, groupIdentifier: String? = nil, isSynchronizable: Bool = false) async throws {
***REMOVED******REMOVED***keychain = .shared
***REMOVED******REMOVED***self.access = access
***REMOVED******REMOVED***self.groupIdentifier = groupIdentifier
***REMOVED******REMOVED***self.isSynchronizable = isSynchronizable
***REMOVED******REMOVED***
***REMOVED******REMOVED***for item in try await Keychain.shared.items(labeled: Self.label, inGroup: groupIdentifier) {
***REMOVED******REMOVED******REMOVED***let credential = try JSONDecoder().decode(CertificateCredential.self, from: item.value)
***REMOVED******REMOVED******REMOVED***storage[credential.host] = credential
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func credential(for protectionSpace: URLProtectionSpace) -> CertificateCredential? {
***REMOVED******REMOVED***guard protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate else {
***REMOVED******REMOVED******REMOVED***return nil
***REMOVED***
***REMOVED******REMOVED***return storage[protectionSpace.host]
***REMOVED***
***REMOVED***
***REMOVED***func add(credential: CertificateCredential) async {
***REMOVED******REMOVED***storage[credential.host] = credential
***REMOVED******REMOVED***if let keychain = keychain, let access = access {
***REMOVED******REMOVED******REMOVED***try? await keychain.storeItem(
***REMOVED******REMOVED******REMOVED******REMOVED***identifier: credential.host,
***REMOVED******REMOVED******REMOVED******REMOVED***value: try JSONEncoder().encode(credential),
***REMOVED******REMOVED******REMOVED******REMOVED***access: access,
***REMOVED******REMOVED******REMOVED******REMOVED***label: Self.label,
***REMOVED******REMOVED******REMOVED******REMOVED***groupIdentifier: groupIdentifier,
***REMOVED******REMOVED******REMOVED******REMOVED***isSynchronizable: isSynchronizable
***REMOVED******REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func clear() async {
***REMOVED******REMOVED***storage.removeAll()
***REMOVED******REMOVED***if let keychain = keychain {
***REMOVED******REMOVED******REMOVED***try? await keychain.removeItems(labeled: Self.label, inGroup: groupIdentifier)
***REMOVED***
***REMOVED***
***REMOVED***

