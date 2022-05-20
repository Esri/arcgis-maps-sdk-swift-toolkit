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

struct DocumentPickerView: UIViewControllerRepresentable {
***REMOVED***var contentTypes: [UTType]
***REMOVED***var onPickDocument: (URL) -> Void
***REMOVED***var onCancel: () -> Void
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(onPickDocument: onPickDocument, onCancel: onCancel)
***REMOVED***
***REMOVED***
***REMOVED***func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
***REMOVED******REMOVED***let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
***REMOVED******REMOVED***documentPicker.delegate = context.coordinator
***REMOVED******REMOVED***return documentPicker
***REMOVED***
***REMOVED***
***REMOVED***func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {***REMOVED***
***REMOVED***

extension DocumentPickerView {
***REMOVED***final class Coordinator: NSObject, UIDocumentPickerDelegate {
***REMOVED******REMOVED***var onPickDocument: (URL) -> Void
***REMOVED******REMOVED***var onCancel: () -> Void
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(onPickDocument: @escaping (URL) -> Void, onCancel: @escaping () -> Void) {
***REMOVED******REMOVED******REMOVED***self.onPickDocument = onPickDocument
***REMOVED******REMOVED******REMOVED***self.onCancel = onCancel
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
***REMOVED******REMOVED******REMOVED***onCancel()
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
***REMOVED******REMOVED******REMOVED***onPickDocument(url)
***REMOVED***
***REMOVED***
***REMOVED***
