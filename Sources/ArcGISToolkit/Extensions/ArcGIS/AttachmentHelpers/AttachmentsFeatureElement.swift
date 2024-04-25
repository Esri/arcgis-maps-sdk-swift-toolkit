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
import Foundation

***REMOVED***/ Indicates how to display the attachments. If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the view. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
public enum AttachmentsFeatureElementDisplayType {
***REMOVED******REMOVED***/ Show attachments as links.
***REMOVED***case list
***REMOVED******REMOVED***/ Attachments expand to the width of the view.
***REMOVED***case preview
***REMOVED******REMOVED***/ Allows applications to choose the most suitable default experience.
***REMOVED***case auto
***REMOVED***

***REMOVED***/ Common properties for elements which display feature attachments.
public protocol AttachmentsFeatureElement {
***REMOVED******REMOVED***/ Indicates how to display the attachments.
***REMOVED******REMOVED***/ If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the view. Setting the value to `auto` allows applications to choose the most suitable default experience.
***REMOVED***var attachmentDisplayType: AttachmentsFeatureElementDisplayType { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A string value describing the element in detail. Can be an empty string.
***REMOVED***var description: String { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The list of attachments.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ The feature attachments associated with this element. This property will be empty if the element has not yet been evaluated.
***REMOVED***var featureAttachments: [FeatureAttachment] { get async throws ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A descriptive label that appears with the element. Can be an empty string.
***REMOVED***var title: String { get ***REMOVED***
***REMOVED***

extension AttachmentsFeatureElementDisplayType {
***REMOVED******REMOVED***/ Creates a display type from an attachment popup element's display type.
***REMOVED******REMOVED***/ - Parameter kind: The display type of the popup element.
***REMOVED***init(kind: AttachmentsPopupElement.DisplayType) {
***REMOVED******REMOVED***switch kind {
***REMOVED******REMOVED***case .list:
***REMOVED******REMOVED******REMOVED***self = .list
***REMOVED******REMOVED***case .preview:
***REMOVED******REMOVED******REMOVED***self = .preview
***REMOVED******REMOVED***case .auto:
***REMOVED******REMOVED******REMOVED***self = .auto
***REMOVED***
***REMOVED***
***REMOVED***
