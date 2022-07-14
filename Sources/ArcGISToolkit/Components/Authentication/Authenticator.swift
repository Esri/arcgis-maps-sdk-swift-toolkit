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

***REMOVED***
***REMOVED***
import Combine

***REMOVED***/ A configurable object that handles authentication challenges.
@MainActor
public final class Authenticator: ObservableObject {
***REMOVED******REMOVED***/ The OAuth configurations that this authenticator can work with.
***REMOVED***let oAuthConfigurations: [OAuthConfiguration]
***REMOVED***
***REMOVED******REMOVED***/ A value indicating whether we should prompt the user when encountering an untrusted host.
***REMOVED***var promptForUntrustedHosts: Bool
***REMOVED***
***REMOVED***deinit {
***REMOVED******REMOVED***observationTask?.cancel()
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** The task for the observation of the challenge queue.
***REMOVED***private var observationTask: Task<Void, Never>?
***REMOVED***
***REMOVED******REMOVED***/ Creates an authenticator.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - promptForUntrustedHosts: A value indicating whether we should prompt the user when
***REMOVED******REMOVED***/   encountering an untrusted host.
***REMOVED******REMOVED***/   - oAuthConfigurations: The OAuth configurations that this authenticator can work with.
***REMOVED***public init(
***REMOVED******REMOVED***promptForUntrustedHosts: Bool = false,
***REMOVED******REMOVED***oAuthConfigurations: [OAuthConfiguration] = []
***REMOVED***) {
***REMOVED******REMOVED***self.promptForUntrustedHosts = promptForUntrustedHosts
***REMOVED******REMOVED***self.oAuthConfigurations = oAuthConfigurations
***REMOVED******REMOVED***observationTask = Task { [weak self] in await self?.observeChallengeQueue() ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Sets up new credential stores that will be persisted to the keychain.
***REMOVED******REMOVED***/ - Remark: The credentials will be stored in the default access group of the keychain.
***REMOVED******REMOVED***/ You can find more information about what the default group would be here:
***REMOVED******REMOVED***/ https:***REMOVED***developer.apple.com/documentation/security/keychain_services/keychain_items/sharing_access_to_keychain_items_among_a_collection_of_apps.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - access: When the credentials stored in the keychain can be accessed.
***REMOVED******REMOVED***/   - isSynchronizable: A value indicating whether the credentials are synchronized with iCloud.
***REMOVED***public func makePersistent(
***REMOVED******REMOVED***access: ArcGIS.KeychainAccess,
***REMOVED******REMOVED***isSynchronizable: Bool = false
***REMOVED***) async throws {
***REMOVED******REMOVED***let previousArcGISCredentialStore = ArcGISRuntimeEnvironment.credentialStore
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Set a persistent ArcGIS credential store on the ArcGIS environment.
***REMOVED******REMOVED***ArcGISRuntimeEnvironment.credentialStore = try await .makePersistent(
***REMOVED******REMOVED******REMOVED***access: access,
***REMOVED******REMOVED******REMOVED***isSynchronizable: isSynchronizable
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED*** Set a persistent network credential store on the ArcGIS environment.
***REMOVED******REMOVED******REMOVED***ArcGISRuntimeEnvironment.networkCredentialStore =
***REMOVED******REMOVED******REMOVED******REMOVED***try await .makePersistent(access: access, isSynchronizable: isSynchronizable)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED*** If making the shared network credential store persistent fails,
***REMOVED******REMOVED******REMOVED******REMOVED*** then restore the ArcGIS credential store.
***REMOVED******REMOVED******REMOVED***ArcGISRuntimeEnvironment.credentialStore = previousArcGISCredentialStore
***REMOVED******REMOVED******REMOVED***throw error
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Clears all ArcGIS and network credentials from the respective stores.
***REMOVED******REMOVED***/ Note: This sets up new `URLSessions` so that removed network credentials are respected
***REMOVED******REMOVED***/ right away.
***REMOVED***public func clearCredentialStores() async {
***REMOVED******REMOVED******REMOVED*** Clear ArcGIS Credentials.
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.credentialStore.removeAll()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Clear network credentials.
***REMOVED******REMOVED***await ArcGISRuntimeEnvironment.networkCredentialStore.removeAll()
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** We have to set new sessions for URLCredential storage to respect the removed credentials
***REMOVED******REMOVED******REMOVED*** right away.
***REMOVED******REMOVED***ArcGISRuntimeEnvironment.urlSession = ArcGISURLSession(configuration: .default)
***REMOVED******REMOVED***ArcGISRuntimeEnvironment.backgroundURLSession = ArcGISURLSession(configuration: .background(withIdentifier: "com.esri.arcgis.toolkit." + UUID().uuidString))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Observes the challenge queue and sets the current challenge.
***REMOVED***private func observeChallengeQueue() async {
***REMOVED******REMOVED***for await queuedChallenge in challengeQueue {
***REMOVED******REMOVED******REMOVED******REMOVED*** A yield here helps alleviate the already presenting bug.
***REMOVED******REMOVED******REMOVED***await Task.yield()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if let queuedArcGISChallenge = queuedChallenge as? QueuedTokenChallenge,
***REMOVED******REMOVED******REMOVED***   let url = queuedArcGISChallenge.arcGISChallenge.request.url,
***REMOVED******REMOVED******REMOVED***   let config = oAuthConfigurations.first(where: { $0.canBeUsed(for: url) ***REMOVED***) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** For an OAuth challenge, we create the credential and resume.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Creating the OAuth credential will present the OAuth login view.
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** We don't set the current challenge because this one is handled internally.
***REMOVED******REMOVED******REMOVED******REMOVED***queuedArcGISChallenge.resume(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***with: await Result {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.useCredential(try await .oauth(configuration: config))
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Set the current challenge, this should present the appropriate view.
***REMOVED******REMOVED******REMOVED******REMOVED***currentChallenge = queuedChallenge
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Wait for the queued challenge to finish.
***REMOVED******REMOVED******REMOVED******REMOVED***await queuedChallenge.complete()
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Reset the crrent challenge to `nil`, that will dismiss the view.
***REMOVED******REMOVED******REMOVED******REMOVED***currentChallenge = nil
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var subject = PassthroughSubject<QueuedChallenge, Never>()
***REMOVED***
***REMOVED******REMOVED***/ A serial queue for authentication challenges.
***REMOVED***private var challengeQueue: AsyncPublisher<AnyPublisher<QueuedChallenge, Never>> {
***REMOVED******REMOVED***AsyncPublisher(
***REMOVED******REMOVED******REMOVED***subject
***REMOVED******REMOVED******REMOVED******REMOVED***.buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
***REMOVED******REMOVED******REMOVED******REMOVED***.eraseToAnyPublisher()
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The current queued challenge being handled.
***REMOVED***@Published
***REMOVED***var currentChallenge: QueuedChallenge?
***REMOVED***

extension Authenticator: AuthenticationChallengeHandler {
***REMOVED***public func handleArcGISChallenge(
***REMOVED******REMOVED***_ challenge: ArcGISAuthenticationChallenge
***REMOVED***) async throws -> ArcGISAuthenticationChallenge.Disposition {
***REMOVED******REMOVED******REMOVED*** Queue up the challenge.
***REMOVED******REMOVED***let queuedChallenge = QueuedTokenChallenge(arcGISChallenge: challenge)
***REMOVED******REMOVED***subject.send(queuedChallenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for it to complete and return the resulting disposition.
***REMOVED******REMOVED***return try await queuedChallenge.result.get()
***REMOVED***
***REMOVED***
***REMOVED***public func handleNetworkChallenge(
***REMOVED******REMOVED***_ challenge: NetworkAuthenticationChallenge
***REMOVED***) async -> NetworkAuthenticationChallengeDisposition {
***REMOVED******REMOVED******REMOVED*** If `promptForUntrustedHosts` is `false` then perform default handling
***REMOVED******REMOVED******REMOVED*** for server trust challenges.
***REMOVED******REMOVED***guard promptForUntrustedHosts || challenge.kind != .serverTrust else {
***REMOVED******REMOVED******REMOVED***return .performDefaultHandling
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let queuedChallenge = QueuedNetworkChallenge(networkChallenge: challenge) else {
***REMOVED******REMOVED******REMOVED***return .performDefaultHandling
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Queue up the challenge.
***REMOVED******REMOVED***subject.send(queuedChallenge)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** Wait for it to complete and return the resulting disposition.
***REMOVED******REMOVED***return await queuedChallenge.disposition
***REMOVED***
***REMOVED***
