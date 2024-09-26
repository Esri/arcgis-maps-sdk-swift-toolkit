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
@preconcurrency import AVFoundation
***REMOVED***

struct BarcodeScannerInput: View {
***REMOVED******REMOVED***/ The view model for the form.
***REMOVED***@EnvironmentObject var model: FormViewModel
***REMOVED***
***REMOVED******REMOVED***/ The element the input belongs to.
***REMOVED***private let element: FieldFormElement
***REMOVED***
***REMOVED******REMOVED***/ The input configuration of the field.
***REMOVED***private let input: BarcodeScannerFormInput
***REMOVED***
***REMOVED******REMOVED***/ A Boolean value indicating whether the code scanner is presented.
***REMOVED***@State private var scannerIsPresented = false
***REMOVED***
***REMOVED******REMOVED***/ The current barcode value.
***REMOVED***@State private var value = ""
***REMOVED***
***REMOVED******REMOVED***/ Creates a view for a barcode scanner input.
***REMOVED******REMOVED***/ - Parameters:
***REMOVED******REMOVED***/   - element: The input's parent element.
***REMOVED***init(element: FieldFormElement) {
***REMOVED******REMOVED***precondition(
***REMOVED******REMOVED******REMOVED***element.input is BarcodeScannerFormInput,
***REMOVED******REMOVED******REMOVED***"\(Self.self).\(#function) element's input must be \(BarcodeScannerFormInput.self)."
***REMOVED******REMOVED***)
***REMOVED******REMOVED***self.element = element
***REMOVED******REMOVED***self.input = element.input as! BarcodeScannerFormInput
***REMOVED***
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***HStack {
***REMOVED******REMOVED******REMOVED***Text(value.isEmpty ? String.noValue : value)
***REMOVED******REMOVED******REMOVED******REMOVED***.lineLimit(1)
***REMOVED******REMOVED******REMOVED******REMOVED***.truncationMode(.tail)
***REMOVED******REMOVED******REMOVED***Spacer()
***REMOVED******REMOVED******REMOVED***if !value.isEmpty {
***REMOVED******REMOVED******REMOVED******REMOVED***ClearButton {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***value.removeAll()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***Image(systemName: "barcode.viewfinder")
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundStyle(.tint)
***REMOVED***
***REMOVED******REMOVED***.frame(maxWidth: .infinity, alignment: .leading)
***REMOVED******REMOVED***.formInputStyle()
***REMOVED******REMOVED***.onChange(of: value) { value in
***REMOVED******REMOVED******REMOVED***element.convertAndUpdateValue(value)
***REMOVED******REMOVED******REMOVED***model.evaluateExpressions()
***REMOVED***
***REMOVED******REMOVED***.onTapGesture {
***REMOVED******REMOVED******REMOVED***scannerIsPresented = true
***REMOVED***
***REMOVED******REMOVED***.onValueChange(of: element) { newValue, newFormattedValue in
***REMOVED******REMOVED******REMOVED***value = newFormattedValue
***REMOVED***
***REMOVED******REMOVED***.sheet(isPresented: $scannerIsPresented) {
***REMOVED******REMOVED******REMOVED***ScannerView(scanOutput: $value, scannerIsPresented: $scannerIsPresented)
***REMOVED***
***REMOVED***
***REMOVED***

struct ScannerView: UIViewControllerRepresentable {
***REMOVED***@Binding var scanOutput: String
***REMOVED***@Binding var scannerIsPresented: Bool
***REMOVED***
***REMOVED***class Coordinator: NSObject, ScannerViewControllerDelegate {
***REMOVED******REMOVED***@Binding var scanOutput: String
***REMOVED******REMOVED***@Binding var scannerIsPresented: Bool
***REMOVED******REMOVED***
***REMOVED******REMOVED***init(scannedCode: Binding<String>, isShowingScanner: Binding<Bool>) {
***REMOVED******REMOVED******REMOVED***_scanOutput = scannedCode
***REMOVED******REMOVED******REMOVED***_scannerIsPresented = isShowingScanner
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***func didScanCode(_ code: String) {
***REMOVED******REMOVED******REMOVED***scanOutput = code
***REMOVED******REMOVED******REMOVED***scannerIsPresented = false
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func makeCoordinator() -> Coordinator {
***REMOVED******REMOVED***Coordinator(scannedCode: $scanOutput, isShowingScanner: $scannerIsPresented)
***REMOVED***
***REMOVED***
***REMOVED***func makeUIViewController(context: Context) -> ScannerViewController {
***REMOVED******REMOVED***let scannerViewController = ScannerViewController()
***REMOVED******REMOVED***scannerViewController.delegate = context.coordinator
***REMOVED******REMOVED***return scannerViewController
***REMOVED***
***REMOVED***
***REMOVED***func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {***REMOVED***
***REMOVED***

protocol ScannerViewControllerDelegate: AnyObject {
***REMOVED***func didScanCode(_ code: String)
***REMOVED***

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
***REMOVED***weak var delegate: ScannerViewControllerDelegate?
***REMOVED***
***REMOVED***private let captureSession = AVCaptureSession()
***REMOVED***
***REMOVED***private var previewLayer: AVCaptureVideoPreviewLayer!
***REMOVED***
***REMOVED***private let sessionQueue = DispatchQueue(label: "ScannerViewController")
***REMOVED***
***REMOVED***override func viewDidLayoutSubviews() {
***REMOVED******REMOVED***previewLayer.frame = view.bounds
***REMOVED******REMOVED***let deviceOrientation = UIDevice.current.orientation
***REMOVED******REMOVED***switch deviceOrientation {
***REMOVED******REMOVED***case .landscapeLeft:
***REMOVED******REMOVED******REMOVED***previewLayer.connection!.videoOrientation = .landscapeRight
***REMOVED******REMOVED***case .landscapeRight:
***REMOVED******REMOVED******REMOVED***previewLayer.connection!.videoOrientation = .landscapeLeft
***REMOVED******REMOVED***case .portraitUpsideDown:
***REMOVED******REMOVED******REMOVED***previewLayer.connection!.videoOrientation = .portraitUpsideDown
***REMOVED******REMOVED***default:
***REMOVED******REMOVED******REMOVED***previewLayer.connection!.videoOrientation = .portrait
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***override func viewDidLoad() {
***REMOVED******REMOVED***super.viewDidLoad()
***REMOVED******REMOVED***
***REMOVED******REMOVED***guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return ***REMOVED***
***REMOVED******REMOVED***let videoInput: AVCaptureDeviceInput
***REMOVED******REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
***REMOVED*** catch {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***if captureSession.canAddInput(videoInput) {
***REMOVED******REMOVED******REMOVED***captureSession.addInput(videoInput)
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let metadataOutput = AVCaptureMetadataOutput()
***REMOVED******REMOVED***
***REMOVED******REMOVED***if captureSession.canAddOutput(metadataOutput) {
***REMOVED******REMOVED******REMOVED***captureSession.addOutput(metadataOutput)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
***REMOVED******REMOVED******REMOVED***metadataOutput.metadataObjectTypes = [
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** Barcodes
***REMOVED******REMOVED******REMOVED******REMOVED***.codabar,
***REMOVED******REMOVED******REMOVED******REMOVED***.code39,
***REMOVED******REMOVED******REMOVED******REMOVED***.code39Mod43,
***REMOVED******REMOVED******REMOVED******REMOVED***.code93,
***REMOVED******REMOVED******REMOVED******REMOVED***.code128,
***REMOVED******REMOVED******REMOVED******REMOVED***.ean8,
***REMOVED******REMOVED******REMOVED******REMOVED***.ean13,
***REMOVED******REMOVED******REMOVED******REMOVED***.gs1DataBar,
***REMOVED******REMOVED******REMOVED******REMOVED***.gs1DataBarExpanded,
***REMOVED******REMOVED******REMOVED******REMOVED***.gs1DataBarLimited,
***REMOVED******REMOVED******REMOVED******REMOVED***.interleaved2of5,
***REMOVED******REMOVED******REMOVED******REMOVED***.itf14,
***REMOVED******REMOVED******REMOVED******REMOVED***.upce,
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED*** 2D Codes
***REMOVED******REMOVED******REMOVED******REMOVED***.aztec,
***REMOVED******REMOVED******REMOVED******REMOVED***.dataMatrix,
***REMOVED******REMOVED******REMOVED******REMOVED***.microPDF417,
***REMOVED******REMOVED******REMOVED******REMOVED***.microQR,
***REMOVED******REMOVED******REMOVED******REMOVED***.pdf417,
***REMOVED******REMOVED******REMOVED******REMOVED***.qr,
***REMOVED******REMOVED******REMOVED***]
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***return
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
***REMOVED******REMOVED***previewLayer.frame = view.layer.bounds
***REMOVED******REMOVED***previewLayer.videoGravity = .resizeAspectFill
***REMOVED******REMOVED***view.layer.addSublayer(previewLayer)
***REMOVED***
***REMOVED***
***REMOVED***override func viewWillAppear(_ animated: Bool) {
***REMOVED******REMOVED***super.viewWillAppear(animated)
***REMOVED******REMOVED***
***REMOVED******REMOVED***if captureSession.isRunning == false {
***REMOVED******REMOVED******REMOVED***sessionQueue.async { [captureSession] in
***REMOVED******REMOVED******REMOVED******REMOVED***captureSession.startRunning()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func finish(stringValue: String) {
***REMOVED******REMOVED***captureSession.stopRunning()
***REMOVED******REMOVED***delegate?.didScanCode(stringValue)
***REMOVED***
***REMOVED***
***REMOVED***nonisolated func metadataOutput(
***REMOVED******REMOVED***_ output: AVCaptureMetadataOutput,
***REMOVED******REMOVED***didOutput metadataObjects: [AVMetadataObject],
***REMOVED******REMOVED***from connection: AVCaptureConnection
***REMOVED***) {
***REMOVED******REMOVED***if let metadataObject = metadataObjects.first {
***REMOVED******REMOVED******REMOVED***guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***guard let stringValue = readableObject.stringValue else { return ***REMOVED***
***REMOVED******REMOVED******REMOVED***Task {
***REMOVED******REMOVED******REMOVED******REMOVED***await finish(stringValue: stringValue)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
