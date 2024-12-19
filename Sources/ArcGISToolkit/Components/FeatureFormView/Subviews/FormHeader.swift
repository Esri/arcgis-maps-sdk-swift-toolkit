***REMOVED*** Copyright 2023 Esri
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

***REMOVED***/ A view shown at the top of a form. If the provided title is `nil`, no text is rendered.
struct FormHeader: View {
***REMOVED***@State private var formAssistantPhotoCaptureIsPresented = false
***REMOVED***
***REMOVED***@State private var formAssistantPhotoImportState: AttachmentImportState = .none
***REMOVED***
***REMOVED***@Binding var formAssistantPhoto: UIImage?
***REMOVED***
***REMOVED******REMOVED***/ The title defined for the form.
***REMOVED***let title: String
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***WandButton {
***REMOVED******REMOVED******REMOVED******REMOVED***formAssistantPhotoCaptureIsPresented = true
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED***.sheet(isPresented: $formAssistantPhotoCaptureIsPresented) {
***REMOVED******REMOVED******REMOVED******REMOVED***AttachmentCameraController(importState: $formAssistantPhotoImportState)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.edgesIgnoringSafeArea(.all)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Text(title)
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.bold)
***REMOVED***
***REMOVED******REMOVED***.onChange(formAssistantPhotoImportState) { newValue in
***REMOVED******REMOVED******REMOVED***guard case let .finalizing(newAttachmentImportData) = newValue else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***formAssistantPhoto = UIImage(data: newAttachmentImportData.data)
***REMOVED***
***REMOVED***
***REMOVED***
