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
import UniformTypeIdentifiers

@MainActor protocol CertificatePickerViewModelProtocol: ObservableObject {
***REMOVED***var challengingHost: String { get ***REMOVED***
***REMOVED***
***REMOVED***var certificateURL: URL? { get set ***REMOVED***
***REMOVED***
***REMOVED***func signIn()
***REMOVED***func cancel()
***REMOVED***

final class CertificatePickerViewModel: CertificatePickerViewModelProtocol {
***REMOVED***let challengingHost: String
***REMOVED***let challenge: QueuedURLChallenge
***REMOVED***
***REMOVED***@Published var certificateURL: URL?
***REMOVED***@Published var password: String = ""
***REMOVED***
***REMOVED***init(challenge: QueuedURLChallenge) {
***REMOVED******REMOVED***self.challenge = challenge
***REMOVED******REMOVED***challengingHost = challenge.urlChallenge.protectionSpace.host
***REMOVED***
***REMOVED***
***REMOVED***func signIn() {
***REMOVED******REMOVED***guard let certificateURL = certificateURL else {
***REMOVED******REMOVED******REMOVED***preconditionFailure()
***REMOVED***

***REMOVED******REMOVED***challenge.resume(with: .certificate(url: certificateURL, passsword: password))
***REMOVED***
***REMOVED***
***REMOVED***func cancel() {
***REMOVED******REMOVED***challenge.cancel()
***REMOVED***
***REMOVED***

struct CertificatePickerView: View {
***REMOVED***var body: some View {
***REMOVED******REMOVED***VStack {
***REMOVED******REMOVED******REMOVED***Text("Choose a certificate for host")
***REMOVED******REMOVED******REMOVED***DocumentPickerView(contentTypes: [.image])
***REMOVED***
***REMOVED******REMOVED***.edgesIgnoringSafeArea(.bottom)
***REMOVED***
***REMOVED***
