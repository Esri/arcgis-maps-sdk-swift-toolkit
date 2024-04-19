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

import Foundation
***REMOVED***

***REMOVED***/ Indicates how to display the attachments. If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the pop-up. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
public enum AttachmentsFeatureElementDisplayType {
***REMOVED******REMOVED***/ Show attachments as links.
***REMOVED***case list
***REMOVED******REMOVED***/ Attachments expand to the width of the pop-up.
***REMOVED***case preview
***REMOVED******REMOVED***/ Allows applications to choose the most suitable default experience for their application.
***REMOVED***case auto
***REMOVED***

public protocol AttachmentsFeatureElement {
***REMOVED******REMOVED***/ A string value describing the element in detail. Can be an empty string.
***REMOVED***var description: String { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Indicates how to display the attachments.
***REMOVED******REMOVED***/ If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the pop-up. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
***REMOVED***var attachmentDisplayType: AttachmentsFeatureElementDisplayType { get ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A string value indicating what the element represents. Can be an empty string.
***REMOVED***var title: String { get set ***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The list of attachments.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This property will be empty if ``PopupElement/isEvaluated`` is `false`.
***REMOVED***var featureAttachments: [FeatureAttachment] { get async throws ***REMOVED***
***REMOVED***

***REMOVED***/ Represents an element of type attachments that is displayed in a pop-up or feature form.
public final class AttachmentsFeatureElementxx {
***REMOVED******REMOVED*** MARK: Nested Types
***REMOVED***
***REMOVED******REMOVED***/ Indicates how to display the attachments. If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the pop-up. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
***REMOVED***public enum DisplayType {
***REMOVED******REMOVED******REMOVED***/ Show attachments as links.
***REMOVED******REMOVED***case list
***REMOVED******REMOVED******REMOVED***/ Attachments expand to the width of the pop-up.
***REMOVED******REMOVED***case preview
***REMOVED******REMOVED******REMOVED***/ Allows applications to choose the most suitable default experience for their application.
***REMOVED******REMOVED***case auto
***REMOVED***
***REMOVED***
***REMOVED******REMOVED******REMOVED***public let displayType: DisplayType
***REMOVED***public let attachmentsPopupElement: AttachmentsPopupElement?
***REMOVED***public let attachmentFormElement: AttachmentFormElement?
***REMOVED***
***REMOVED******REMOVED*** MARK: Inits
***REMOVED***
***REMOVED******REMOVED***/ Creates a new attachments pop-up element with the given ``DisplayType-swift.enum``.
***REMOVED******REMOVED***/ - Parameter displayType: Indicates how to display the attachments.
***REMOVED***public init(attachmentsPopupElement: AttachmentsPopupElement) {
***REMOVED******REMOVED***self.attachmentsPopupElement = attachmentsPopupElement
***REMOVED******REMOVED***self.attachmentFormElement = nil
***REMOVED***
***REMOVED***
***REMOVED***public init(attachmentFormElement: AttachmentFormElement) {
***REMOVED******REMOVED***self.attachmentsPopupElement = nil
***REMOVED******REMOVED***self.attachmentFormElement = attachmentFormElement
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Properties
***REMOVED***
***REMOVED******REMOVED***/ A string value describing the element in detail. Can be an empty string.
***REMOVED***public var description: String {
***REMOVED******REMOVED***if let attachmentsPopupElement {
***REMOVED******REMOVED******REMOVED***return attachmentsPopupElement.description
***REMOVED*** else if let attachmentFormElement {
***REMOVED******REMOVED******REMOVED***return attachmentFormElement.description
***REMOVED***
***REMOVED******REMOVED***return ""
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Indicates how to display the attachments.
***REMOVED******REMOVED***/ If `list` is specified, attachments show as links. If `preview` is specified, attachments expand to the width of the pop-up. Setting the value to `auto` allows applications to choose the most suitable default experience for their application.
***REMOVED***public var displayType: DisplayType {
***REMOVED******REMOVED***if let attachmentsPopupElement {
***REMOVED******REMOVED******REMOVED***return .preview***REMOVED***DisplayType(kind: attachmentsPopupElement.displayType)
***REMOVED***
***REMOVED******REMOVED***return .preview
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A string value indicating what the element represents. Can be an empty string.
***REMOVED***public var title: String {
***REMOVED******REMOVED***if let attachmentsPopupElement {
***REMOVED******REMOVED******REMOVED***return attachmentsPopupElement.title
***REMOVED*** else if let attachmentFormElement {
***REMOVED******REMOVED******REMOVED***return attachmentFormElement.label
***REMOVED***
***REMOVED******REMOVED***return ""
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ The list of attachments.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ This property will be empty if ``PopupElement/isEvaluated`` is `false`.
***REMOVED***var attachments: [FeatureAttachment] {
***REMOVED******REMOVED***get async throws {
***REMOVED******REMOVED******REMOVED***if let attachmentsPopupElement {
***REMOVED******REMOVED******REMOVED******REMOVED***let attachments = try await attachmentsPopupElement.attachments
***REMOVED******REMOVED******REMOVED******REMOVED***return attachments.map { FeatureAttachment(popupAttachment: $0) ***REMOVED***
***REMOVED******REMOVED*** else if let attachmentFormElement {
***REMOVED******REMOVED******REMOVED******REMOVED***try await attachmentFormElement.fetchAttachments()
***REMOVED******REMOVED******REMOVED******REMOVED***let attachments = attachmentFormElement.attachments
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let attachments = try await attachmentFormElement.attachments
***REMOVED******REMOVED******REMOVED******REMOVED***return attachments.map { FeatureAttachment(featureFormAttachment: $0) ***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***return []
***REMOVED***
***REMOVED***
***REMOVED***

extension AttachmentsFeatureElementDisplayType {
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
