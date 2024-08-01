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

import PhotosUI
***REMOVED***

***REMOVED***/ A wrapper for the PhotosPicker API.
@MainActor
struct AttachmentPhotoPicker: ViewModifier {
***REMOVED******REMOVED***/ The item selected in the photos picker.
***REMOVED***@State private var item: PhotosPickerItem?
***REMOVED***
***REMOVED******REMOVED***/ The current import state.
***REMOVED***@Binding var importState: AttachmentImportState
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the photos picker is presented.
***REMOVED***@Binding var photoPickerIsPresented: Bool
***REMOVED***
***REMOVED***func body(content: Content) -> some View {
***REMOVED******REMOVED***content
***REMOVED******REMOVED******REMOVED***.photosPicker(
***REMOVED******REMOVED******REMOVED******REMOVED***isPresented: $photoPickerIsPresented,
***REMOVED******REMOVED******REMOVED******REMOVED***selection: $item,
***REMOVED******REMOVED******REMOVED******REMOVED***matching: .any(of: [
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.images,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.videos
***REMOVED******REMOVED******REMOVED******REMOVED***])
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***.task(id: item) {
***REMOVED******REMOVED******REMOVED******REMOVED***guard let item else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***self.item = nil
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .importing
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***guard let contentType = item.supportedContentTypes.first,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***  let data = try await item.loadTransferable(type: Data.self) else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.dataInaccessible)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***importState = .finalizing(AttachmentImportData(contentType: contentType, data: data))
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.system(error.localizedDescription))
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***

extension PhotosPickerItem: @unchecked Swift.Sendable {***REMOVED***
