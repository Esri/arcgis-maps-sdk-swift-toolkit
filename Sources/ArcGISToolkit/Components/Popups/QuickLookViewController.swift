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
import QuickLook

struct QuickLookViewController: UIViewControllerRepresentable {
***REMOVED***let url: URL
***REMOVED***
***REMOVED***func makeUIViewController(context: Context) -> QLPreviewController {
***REMOVED******REMOVED***let controller = QLPreviewController()
***REMOVED******REMOVED***return controller
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***return Coordinator(parent: self)
***REMOVED***
***REMOVED***
***REMOVED***func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {***REMOVED***
***REMOVED***

***REMOVED***class Coordinator: QLPreviewControllerDataSource {
***REMOVED******REMOVED***let parent: QuickLookViewController
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(parent: QuickLookViewController) {
***REMOVED******REMOVED******REMOVED***self.parent = parent
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
***REMOVED******REMOVED******REMOVED***return 1
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func previewController(
***REMOVED******REMOVED******REMOVED***_ controller: QLPreviewController,
***REMOVED******REMOVED******REMOVED***previewItemAt index: Int
***REMOVED******REMOVED***) -> QLPreviewItem {
***REMOVED******REMOVED******REMOVED***return parent.url as NSURL
***REMOVED***
***REMOVED***
***REMOVED***
