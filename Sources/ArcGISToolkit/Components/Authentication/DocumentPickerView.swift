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

import SwiftUI
import UniformTypeIdentifiers

/// A view that allows the user to browse to and select a document.
/// This view wraps a `UIDocumentPickerViewController`.
public struct DocumentPickerView: UIViewControllerRepresentable {
    /// The content types that are allowed to be selected.
    var contentTypes: [UTType]
    /// The closure called when a document is selected.
    var onPickDocument: (URL) -> Void
    /// The closure called when the user cancels.
    var onCancel: () -> Void
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(onPickDocument: onPickDocument, onCancel: onCancel)
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    public init(contentTypes: [UTType], onPickDocument: @escaping (URL) -> Void, onCancel: @escaping () -> Void) {
        self.contentTypes = contentTypes
        self.onPickDocument = onPickDocument
        self.onCancel = onCancel
    }
}

extension DocumentPickerView {
    /// The coordinator for the document picker view that acts as a delegate to the underlying
    /// `UIDocumentPickerViewController`.
    public final class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPickDocument: (URL) -> Void
        var onCancel: () -> Void
        
        init(onPickDocument: @escaping (URL) -> Void, onCancel: @escaping () -> Void) {
            self.onPickDocument = onPickDocument
            self.onCancel = onCancel
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancel()
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let url = urls.first!
            if url.startAccessingSecurityScopedResource() {
                onPickDocument(url)
                url.stopAccessingSecurityScopedResource()
            }
        }
    }
}
