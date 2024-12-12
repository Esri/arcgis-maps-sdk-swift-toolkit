***REMOVED*** Copyright 2022 Esri
***REMOVED***
***REMOVED*** Licensed under the Apache License, Version 2.0 (the "License");
***REMOVED*** you may not use this file except in compliance with the License.
***REMOVED*** You may obtain a copy of the License at
***REMOVED***
***REMOVED***   https:***REMOVED***www.apache.org/licenses/LICENSE-2.0
***REMOVED***
***REMOVED*** Unless required by applicable law or agreed to in writing, software
***REMOVED*** distributed under the License is distributed on an "AS IS" BASIS,
***REMOVED*** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
***REMOVED*** See the License for the specific language governing permissions and
***REMOVED*** limitations under the License.

***REMOVED***
import UniformTypeIdentifiers

***REMOVED***/ A view that allows the user to browse to and select a document.
***REMOVED***/ This view wraps a `UIDocumentPickerViewController`.
struct DocumentPickerView: UIViewControllerRepresentable {
***REMOVED******REMOVED***/ The content types that are allowed to be selected.
***REMOVED***var contentTypes: [UTType]
***REMOVED******REMOVED***/ The closure called when a document is selected.
***REMOVED***var onPickDocument: (URL) -> Void
***REMOVED******REMOVED***/ The closure called when the user cancels.
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
***REMOVED******REMOVED***/ The coordinator for the document picker view that acts as a delegate to the underlying
***REMOVED******REMOVED***/ `UIDocumentPickerViewController`.
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
***REMOVED******REMOVED***func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
***REMOVED******REMOVED******REMOVED***guard let firstURL = urls.first else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***onPickDocument(firstURL)
***REMOVED***
***REMOVED***
***REMOVED***
