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

***REMOVED***/ The possible errors when importing an attachment.
enum AttachmentImportError: Error, Equatable {
***REMOVED******REMOVED***/ The SDK failed to create a ``ArcGIS/FormAttachment``.
***REMOVED***case creationFailed
***REMOVED******REMOVED***/ The raw attachment is inaccessible.
***REMOVED***case dataInaccessible
***REMOVED******REMOVED***/ The provided file is empty (0 bytes).
***REMOVED***case emptyFilesNotSupported
***REMOVED******REMOVED***/ The provided file exceeds the toolkit imposed size limit.
***REMOVED***case sizeLimitExceeded
***REMOVED******REMOVED***/ The file import failed with a system error.
***REMOVED***case system(String)
***REMOVED***
