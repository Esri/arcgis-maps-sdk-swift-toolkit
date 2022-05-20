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

import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
    var contentTypes: [UTType]
    var onPickDocument: (URL) -> Void
    var onCancel: () -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onPickDocument: onPickDocument, onCancel: onCancel)
    }
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
        documentPicker.delegate = context.coordinator
        return documentPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

extension DocumentPickerView {
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        var onPickDocument: (URL) -> Void
        var onCancel: () -> Void
        
        init(onPickDocument: @escaping (URL) -> Void, onCancel: @escaping () -> Void) {
            self.onPickDocument = onPickDocument
            self.onCancel = onCancel
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onCancel()
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
            onPickDocument(url)
        }
    }
}
