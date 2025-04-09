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

extension FormAttachment: FeatureAttachment {
***REMOVED******REMOVED***/ The type of the attachment.
***REMOVED***var featureAttachmentKind: FeatureAttachmentKind {
***REMOVED******REMOVED***FeatureAttachmentKind(kind: kind)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The size of the attachment.
***REMOVED***var measuredSize: Measurement<UnitInformationStorage> {
***REMOVED******REMOVED***size
***REMOVED***
***REMOVED***
***REMOVED***func _load() async throws {
***REMOVED******REMOVED***try await load()
***REMOVED***
***REMOVED***
***REMOVED***var _loadStatus: LoadStatus {
***REMOVED******REMOVED***loadStatus
***REMOVED***
***REMOVED***
