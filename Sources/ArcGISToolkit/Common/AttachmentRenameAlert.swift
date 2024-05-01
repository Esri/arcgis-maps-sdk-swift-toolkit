***REMOVED*** Copyright 2024 Esri
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

***REMOVED***/ The contents of an alert to rename an attachment.
struct AttachmentRenameAlert: View {
***REMOVED******REMOVED***/ The model for the attachment the user has requested be renamed.
***REMOVED***let attachmentModel: AttachmentModel
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when the attachment is renamed.
***REMOVED***let onRename: (AttachmentModel, String) async throws -> Void
***REMOVED***
***REMOVED******REMOVED***/ The attachment's file extension.
***REMOVED***@State private var fileExtension: String?
***REMOVED***
***REMOVED******REMOVED***/ The attachment's new name.
***REMOVED***@State private var newName = ""
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***TextField("New name", text: $newName)
***REMOVED******REMOVED******REMOVED***Button("Cancel", role: .cancel) { ***REMOVED***
***REMOVED******REMOVED******REMOVED***Button("Ok") {
***REMOVED******REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if let fileExtension {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await onRename(attachmentModel, [newName, fileExtension].joined(separator: "."))
***REMOVED******REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***try? await onRename(attachmentModel, newName)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileExtension = nil
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***newName.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.task(id: attachmentModel) {
***REMOVED******REMOVED******REMOVED***let currentName = attachmentModel.name
***REMOVED******REMOVED******REMOVED***if let separatorIndex = currentName.lastIndex(of: ".") {
***REMOVED******REMOVED******REMOVED******REMOVED***newName = String(currentName[..<separatorIndex])
***REMOVED******REMOVED******REMOVED******REMOVED***fileExtension = String(currentName[currentName.index(after: separatorIndex)...])
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***newName = attachmentModel.name
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
