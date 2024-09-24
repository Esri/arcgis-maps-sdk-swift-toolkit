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
import AVFoundation
***REMOVED***
import UniformTypeIdentifiers

internal import os

***REMOVED***/ The context menu shown when the new attachment button is pressed.
struct AttachmentImportMenu: View {
***REMOVED******REMOVED***/ The attachment form element displaying the menu.
***REMOVED***private let element: AttachmentsFormElement
***REMOVED***
***REMOVED******REMOVED***/ Creates an `AttachmentImportMenu`
***REMOVED******REMOVED***/ - Parameter element: The attachment form element displaying the menu.
***REMOVED******REMOVED***/ - Parameter onAdd: The action to perform when an attachment is added.
***REMOVED***init(element: AttachmentsFormElement, onAdd: (@MainActor (FeatureAttachment) -> Void)? = nil) {
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.onAdd = onAdd
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment camera controller is presented.
***REMOVED***@State private var cameraIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment file importer is presented.
***REMOVED***@State private var fileImporterIsShowing = false
***REMOVED***
***REMOVED******REMOVED***/ The current import state.
***REMOVED***@State private var importState: AttachmentImportState = .none
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the microphone access alert is visible.
***REMOVED***@State private var microphoneAccessAlertIsVisible = false
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the attachment photo picker is presented.
***REMOVED***@State private var photoPickerIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ Performs camera authorization request handling.
***REMOVED***@StateObject private var cameraRequester = CameraRequester()
***REMOVED***
***REMOVED******REMOVED***/ The maximum attachment size limit.
***REMOVED***let attachmentUploadSizeLimit = Measurement(
***REMOVED******REMOVED***value: 50,
***REMOVED******REMOVED***unit: UnitInformationStorage.megabytes
***REMOVED***)
***REMOVED***
***REMOVED******REMOVED***/ The action to perform when an attachment is added.
***REMOVED***let onAdd: (@MainActor (FeatureAttachment) -> Void)?
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating if the error alert is presented.
***REMOVED***var errorIsPresented: Binding<Bool> {
***REMOVED******REMOVED***Binding {
***REMOVED******REMOVED******REMOVED***importState.isErrored
***REMOVED*** set: { newIsPresented in
***REMOVED******REMOVED******REMOVED***if !newIsPresented {
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .none
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@available(visionOS, unavailable)
***REMOVED***private func takePhotoOrVideoButton() -> Button<some View> {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***cameraRequester.request {
***REMOVED******REMOVED******REMOVED******REMOVED***cameraIsShowing = true
***REMOVED******REMOVED*** onAccessDenied: { ***REMOVED***
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(cameraButtonLabel)
***REMOVED******REMOVED******REMOVED***Image(systemName: "camera")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func chooseFromLibraryButton() -> Button<some View> {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***photoPickerIsPresented = true
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(libraryButtonLabel)
***REMOVED******REMOVED******REMOVED***Image(systemName: "photo")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func chooseFromFilesButton() -> Button<some View> {
***REMOVED******REMOVED***Button {
***REMOVED******REMOVED******REMOVED***fileImporterIsShowing = true
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Text(filesButtonLabel)
***REMOVED******REMOVED******REMOVED***Image(systemName: "folder")
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if importState.importInProgress {
***REMOVED******REMOVED******REMOVED***ProgressView()
***REMOVED******REMOVED******REMOVED******REMOVED***.progressViewStyle(.circular)
***REMOVED******REMOVED******REMOVED******REMOVED***.catalystPadding(5)
***REMOVED***
***REMOVED******REMOVED***Menu {
***REMOVED******REMOVED******REMOVED******REMOVED*** Show photo/video and library picker.
#if !os(visionOS)
***REMOVED******REMOVED******REMOVED***takePhotoOrVideoButton()
#endif
***REMOVED******REMOVED******REMOVED***chooseFromLibraryButton()
***REMOVED******REMOVED******REMOVED******REMOVED*** Always show file picker, no matter the input type.
***REMOVED******REMOVED******REMOVED***chooseFromFilesButton()
***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED***Image(systemName: "plus")
***REMOVED******REMOVED******REMOVED******REMOVED***.font(.title2)
***REMOVED******REMOVED******REMOVED******REMOVED***.padding(5)
***REMOVED***
***REMOVED******REMOVED***.disabled(importState.importInProgress)
***REMOVED******REMOVED***.cameraRequester(cameraRequester)
***REMOVED******REMOVED***.alert(importFailureAlertTitle, isPresented: errorIsPresented) { ***REMOVED*** message: {
***REMOVED******REMOVED******REMOVED***Text(importFailureAlertMessage)
***REMOVED***
#if targetEnvironment(macCatalyst)
***REMOVED******REMOVED***.menuStyle(.borderlessButton)
#endif
***REMOVED******REMOVED***.task(id: importState) {
***REMOVED******REMOVED******REMOVED***guard case let .finalizing(newAttachmentImportData) = importState else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let attachmentSize = Measurement(
***REMOVED******REMOVED******REMOVED******REMOVED***value: Double(newAttachmentImportData.data.count),
***REMOVED******REMOVED******REMOVED******REMOVED***unit: UnitInformationStorage.bytes
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***guard attachmentSize <= attachmentUploadSizeLimit else {
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.sizeLimitExceeded)
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard attachmentSize.value > .zero else {
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.emptyFilesNotSupported)
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let fileName: String
***REMOVED******REMOVED******REMOVED***if let presetFileName = newAttachmentImportData.fileName {
***REMOVED******REMOVED******REMOVED******REMOVED***fileName = presetFileName
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName = try await element.makeDefaultName(contentType: newAttachmentImportData.contentType)
***REMOVED******REMOVED******REMOVED*** catch {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***fileName = "Unnamed Attachment"
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***guard let newAttachment = element.addAttachment(
***REMOVED******REMOVED******REMOVED******REMOVED***name: fileName,
***REMOVED******REMOVED******REMOVED******REMOVED***contentType: newAttachmentImportData.contentType,
***REMOVED******REMOVED******REMOVED******REMOVED***data: newAttachmentImportData.data
***REMOVED******REMOVED******REMOVED***) else {
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.creationFailed)
***REMOVED******REMOVED******REMOVED******REMOVED***return
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***onAdd?(newAttachment)
***REMOVED******REMOVED******REMOVED***importState = .none
***REMOVED***
***REMOVED******REMOVED***.fileImporter(isPresented: $fileImporterIsShowing, allowedContentTypes: [.item]) { result in
***REMOVED******REMOVED******REMOVED***importState = .importing
***REMOVED******REMOVED******REMOVED***switch result {
***REMOVED******REMOVED******REMOVED***case .success(let url):
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** gain access to the url resource and verify there's data.
***REMOVED******REMOVED******REMOVED******REMOVED***if url.startAccessingSecurityScopedResource(),
***REMOVED******REMOVED******REMOVED******REMOVED***   let contentType = url.contentType,
***REMOVED******REMOVED******REMOVED******REMOVED***   let data = FileManager.default.contents(atPath: url.path) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***importState = .finalizing(AttachmentImportData(contentType: contentType, data: data, fileName: url.lastPathComponent))
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.dataInaccessible)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** release access
***REMOVED******REMOVED******REMOVED******REMOVED***url.stopAccessingSecurityScopedResource()
***REMOVED******REMOVED******REMOVED***case .failure(let error):
***REMOVED******REMOVED******REMOVED******REMOVED***importState = .errored(.system(error.localizedDescription))
***REMOVED******REMOVED***
***REMOVED***
#if os(iOS)
***REMOVED******REMOVED***.fullScreenCover(isPresented: $cameraIsShowing) {
***REMOVED******REMOVED******REMOVED***AttachmentCameraController(
***REMOVED******REMOVED******REMOVED******REMOVED***importState: $importState
***REMOVED******REMOVED******REMOVED***)
#if !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
***REMOVED******REMOVED******REMOVED***.onCameraCaptureModeChanged { captureMode in
***REMOVED******REMOVED******REMOVED******REMOVED***if captureMode == .video && AVCaptureDevice.authorizationStatus(for: .audio) == .denied {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***microphoneAccessAlertIsVisible = true
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
#endif
***REMOVED******REMOVED******REMOVED***.alert(microphoneAccessWarningMessage, isPresented: $microphoneAccessAlertIsVisible) {
***REMOVED******REMOVED******REMOVED******REMOVED***appSettingsButton
***REMOVED******REMOVED******REMOVED******REMOVED***Button(role: .cancel) { ***REMOVED*** label: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Text(recordVideoOnlyButtonLabel)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
#endif
***REMOVED******REMOVED***.modifier(
***REMOVED******REMOVED******REMOVED***AttachmentPhotoPicker(
***REMOVED******REMOVED******REMOVED******REMOVED***importState: $importState,
***REMOVED******REMOVED******REMOVED******REMOVED***photoPickerIsPresented: $photoPickerIsPresented
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension AttachmentImportMenu {
***REMOVED******REMOVED***/ A button that redirects the user to the application's entry in the iOS system Settings application.
***REMOVED***var appSettingsButton: some View {
***REMOVED******REMOVED***Button(String.settings) {
***REMOVED******REMOVED******REMOVED***Task { await UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!) ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for a button to capture a new photo or video.
***REMOVED***var cameraButtonLabel: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Take Photo or Video",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to capture a new photo or video."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An error message indicating the selected attachment is an empty file and not supported.
***REMOVED***var emptyFilesNotSupportedAlertMessage: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Empty files are not supported.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "An error message indicating the selected attachment is an empty file and not supported."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for a button to choose an file from the user's files.
***REMOVED***var filesButtonLabel: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Choose From Files",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose an file from the user's files."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A generic message for an alert that the selected file was not able to be imported as an attachment.
***REMOVED***var genericImportFailureAlertMessage: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "The selected attachment could not be imported.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED***A generic message for an alert that the selected file was not able
***REMOVED******REMOVED******REMOVED***to be imported as an attachment.
***REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Returns a user facing error message for the present attachment import error.
***REMOVED***var importFailureAlertMessage: String {
***REMOVED******REMOVED***guard case .errored(let attachmentImportError) = importState else { return "" ***REMOVED***
***REMOVED******REMOVED***return switch attachmentImportError {
***REMOVED******REMOVED***case .emptyFilesNotSupported:
***REMOVED******REMOVED******REMOVED***emptyFilesNotSupportedAlertMessage
***REMOVED******REMOVED***case .sizeLimitExceeded:
***REMOVED******REMOVED******REMOVED***sizeLimitExceededImportFailureAlertMessage
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***genericImportFailureAlertMessage
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A title for an alert that the selected file was not able to be imported as an attachment.
***REMOVED***var importFailureAlertTitle: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Error importing attachment",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: """
***REMOVED******REMOVED******REMOVED***A title for an alert that the selected file was not able to be
***REMOVED******REMOVED******REMOVED***imported as an attachment.
***REMOVED******REMOVED******REMOVED***"""
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A label for a button to choose a photo or video from the user's photo library.
***REMOVED***var libraryButtonLabel: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Choose From Library",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to choose a photo or video from the user's photo library."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A warning message indicating microphone access has been disabled for the current application in the system settings.
***REMOVED***var microphoneAccessWarningMessage: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Microphone access has been disabled in Settings.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A warning message indicating microphone access has been disabled for the current application in the system settings."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ A button allowing users to proceed to record a video while acknowledging audio will not be captured.
***REMOVED***var recordVideoOnlyButtonLabel: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Record video only",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A button allowing users to proceed to record a video while acknowledging audio will not be captured."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ An error message indicating the selected attachment exceeds the megabyte limit.
***REMOVED***var sizeLimitExceededImportFailureAlertMessage: String {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "The selected attachment exceeds the \(attachmentUploadSizeLimit.formatted()) limit.",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "An error message indicating the selected attachment exceeds the megabyte limit."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

private extension AttachmentsFormElement {
***REMOVED******REMOVED***/ Creates a unique name for a new attachments with a file extension.
***REMOVED******REMOVED***/ - Parameter contentType: The kind of attachment to generate a name for.
***REMOVED******REMOVED***/ - Returns: A unique name for an attachment.
***REMOVED***func makeDefaultName(contentType: UTType) async throws -> String {
***REMOVED******REMOVED***let currentAttachments = try await attachments
***REMOVED******REMOVED***let root = (contentType.preferredMIMEType?.components(separatedBy: "/").first ?? "Attachment").capitalized
***REMOVED******REMOVED***var count = currentAttachments.filter { $0.contentType == contentType ***REMOVED***.count
***REMOVED******REMOVED***var baseName: String
***REMOVED******REMOVED***repeat {
***REMOVED******REMOVED******REMOVED***count += 1
***REMOVED******REMOVED******REMOVED***baseName = "\(root)\(count)"
***REMOVED*** while( currentAttachments.filter { $0.name.deletingPathExtension == baseName ***REMOVED***.count > 0 )
***REMOVED******REMOVED***if let fileExtension = contentType.preferredFilenameExtension {
***REMOVED******REMOVED******REMOVED***return "\(baseName).\(fileExtension)"
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return baseName
***REMOVED***
***REMOVED***
***REMOVED***

private extension String {
***REMOVED******REMOVED***/ A filename with the extension removed.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ For example, "Photo.png" is returned as "Photo"
***REMOVED***var deletingPathExtension: String {
***REMOVED******REMOVED***(self as NSString).deletingPathExtension
***REMOVED***
***REMOVED***

private extension URL {
***REMOVED******REMOVED***/ The type of data at the URL.
***REMOVED***var contentType: UTType? {
***REMOVED******REMOVED***UTType(filenameExtension: self.pathExtension)
***REMOVED***
***REMOVED***
