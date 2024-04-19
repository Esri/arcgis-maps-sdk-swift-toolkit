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

extension AttachmentFormElement : AttachmentsFeatureElement {
***REMOVED***public var title: String {
***REMOVED******REMOVED***get {
***REMOVED******REMOVED******REMOVED***label
***REMOVED***
***REMOVED******REMOVED***set { ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***public var attachmentDisplayType: AttachmentsFeatureElementDisplayType {
***REMOVED******REMOVED***AttachmentsFeatureElementDisplayType.preview
***REMOVED***
***REMOVED***
***REMOVED***public var featureAttachments: [FeatureAttachment] {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***try await fetchAttachments()
***REMOVED******REMOVED******REMOVED***return attachments.map { FeatureAttachment(featureFormAttachment: $0) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
