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
***REMOVED***

***REMOVED***/ A view displaying a thumbnail image for an attachment.
struct ThumbnailView: View  {
***REMOVED******REMOVED***/ The model represented by the thumbnail.
***REMOVED***@ObservedObject var attachmentModel: AttachmentModel
***REMOVED***
***REMOVED******REMOVED***/ The display size of the thumbnail.
***REMOVED***var size: CGSize = CGSize(width: 36, height: 36)
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***Group {
***REMOVED******REMOVED******REMOVED***if attachmentModel.usingDefaultImage,
***REMOVED******REMOVED******REMOVED***   let systemName = attachmentModel.defaultSystemName {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(systemName: systemName)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.renderingMode(.template)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fit)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.fontWeight(.light)
***REMOVED******REMOVED*** else if let image = attachmentModel.thumbnail {
***REMOVED******REMOVED******REMOVED******REMOVED***Image(uiImage: image)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.resizable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.renderingMode(.original)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.aspectRatio(contentMode: .fill)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***.frame(width: size.width, height: size.height, alignment: .center)
***REMOVED******REMOVED***.clipShape(RoundedRectangle(cornerRadius: 4))
***REMOVED******REMOVED***.contentShape(RoundedRectangle(cornerRadius: 4))
***REMOVED******REMOVED***.foregroundColor(foregroundColor(for: attachmentModel))
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The foreground color of the thumbnail image.
***REMOVED******REMOVED***/ - Parameter attachmentModel: The model for the associated attachment.
***REMOVED******REMOVED***/ - Returns: A color to be used as the foreground color.
***REMOVED***func foregroundColor(for attachmentModel: AttachmentModel) -> Color {
***REMOVED******REMOVED***attachmentModel.loadStatus == .failed ? .red :
***REMOVED******REMOVED***(attachmentModel.usingDefaultImage ? .gray : .primary)
***REMOVED***
***REMOVED***
