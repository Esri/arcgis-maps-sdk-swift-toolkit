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

@preconcurrency import AVFoundation
***REMOVED***

***REMOVED***/ Scans machine readable information like QR codes and barcodes.
struct CodeScannerView: UIViewControllerRepresentable {
***REMOVED***@Binding var scannerIsPresented: Bool
***REMOVED***
***REMOVED***@Binding var scanOutput: String
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

class ScannerViewController: UIViewController, @preconcurrency AVCaptureMetadataOutputObjectsDelegate {
***REMOVED***
***REMOVED******REMOVED*** MARK: Constants
***REMOVED***
***REMOVED***private let autoScanDelay = 1.0
***REMOVED***
***REMOVED***private let captureSession = AVCaptureSession()
***REMOVED***
***REMOVED***private let feedbackGenerator = UISelectionFeedbackGenerator()
***REMOVED***
***REMOVED***private let metadataObjectsOverlayLayersDrawingSemaphore = DispatchSemaphore(value: 1)
***REMOVED***
***REMOVED***private let sessionQueue = DispatchQueue(label: "ScannerViewController")
***REMOVED***
***REMOVED******REMOVED*** MARK: Variables
***REMOVED***
***REMOVED***private var autoScanTimer: Timer?
***REMOVED***
***REMOVED***private var metadataObjectOverlayLayers = [MetadataObjectLayer]()
***REMOVED***
***REMOVED***private var previewLayer: AVCaptureVideoPreviewLayer!
***REMOVED***
***REMOVED***private var removeMetadataObjectOverlayLayersTimer: Timer?
***REMOVED***
***REMOVED***weak var delegate: ScannerViewControllerDelegate?
***REMOVED***
***REMOVED***private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
***REMOVED******REMOVED***UITapGestureRecognizer(target: self, action: #selector(userDidTap(with:)))
***REMOVED***()
***REMOVED***
***REMOVED***private class MetadataObjectLayer: CAShapeLayer {
***REMOVED******REMOVED***var metadataObject: AVMetadataObject?
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: UIViewController methods
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
***REMOVED******REMOVED***previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
***REMOVED******REMOVED***previewLayer.frame = view.layer.bounds
***REMOVED******REMOVED***previewLayer.videoGravity = .resizeAspectFill
***REMOVED******REMOVED***view.addGestureRecognizer(tapGestureRecognizer)
***REMOVED******REMOVED***view.layer.addSublayer(previewLayer)
***REMOVED***
***REMOVED***
***REMOVED***override func viewWillAppear(_ animated: Bool) {
***REMOVED******REMOVED***super.viewWillAppear(animated)
***REMOVED******REMOVED***sessionQueue.async { [captureSession] in
***REMOVED******REMOVED******REMOVED***captureSession.startRunning()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: AVCaptureMetadataOutputObjectsDelegate methods
***REMOVED***
***REMOVED***func metadataOutput(
***REMOVED******REMOVED***_ output: AVCaptureMetadataOutput,
***REMOVED******REMOVED***didOutput metadataObjects: [AVMetadataObject],
***REMOVED******REMOVED***from connection: AVCaptureConnection
***REMOVED***) {
***REMOVED******REMOVED***if metadataObjectsOverlayLayersDrawingSemaphore.wait(timeout: .now()) == .success {
***REMOVED******REMOVED******REMOVED***DispatchQueue.main.async {
***REMOVED******REMOVED******REMOVED******REMOVED***self.removeMetadataObjectOverlayLayers()
***REMOVED******REMOVED******REMOVED******REMOVED***var metadataObjectOverlayLayers = [MetadataObjectLayer]()
***REMOVED******REMOVED******REMOVED******REMOVED***for metadataObject in metadataObjects {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let metadataObjectOverlayLayer = self.createMetadataObjectOverlayWithMetadataObject(metadataObject)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***metadataObjectOverlayLayers.append(metadataObjectOverlayLayer)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***self.addMetadataObjectOverlayLayersToVideoPreviewView(metadataObjectOverlayLayers)
***REMOVED******REMOVED******REMOVED******REMOVED***self.metadataObjectsOverlayLayersDrawingSemaphore.signal()
***REMOVED******REMOVED******REMOVED******REMOVED***self.evaluateOutputForAutoScan(metadataObjects)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Scan handling methods
***REMOVED***
***REMOVED***private func addMetadataObjectOverlayLayersToVideoPreviewView(_ metadataObjectOverlayLayers: [MetadataObjectLayer]) {
***REMOVED******REMOVED***CATransaction.begin()
***REMOVED******REMOVED***CATransaction.setDisableActions(true)
***REMOVED******REMOVED***for metadataObjectOverlayLayer in metadataObjectOverlayLayers {
***REMOVED******REMOVED******REMOVED***previewLayer.addSublayer(metadataObjectOverlayLayer)
***REMOVED***
***REMOVED******REMOVED***CATransaction.commit()
***REMOVED******REMOVED***self.metadataObjectOverlayLayers = metadataObjectOverlayLayers
***REMOVED******REMOVED***removeMetadataObjectOverlayLayersTimer = Timer.scheduledTimer(
***REMOVED******REMOVED******REMOVED***timeInterval: 1,
***REMOVED******REMOVED******REMOVED***target: self,
***REMOVED******REMOVED******REMOVED***selector: #selector(removeMetadataObjectOverlayLayers),
***REMOVED******REMOVED******REMOVED***userInfo: nil,
***REMOVED******REMOVED******REMOVED***repeats: false
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
***REMOVED***private func barcodeOverlayPathWithCorners(_ corners: [CGPoint]) -> CGMutablePath {
***REMOVED******REMOVED***let path = CGMutablePath()
***REMOVED******REMOVED***if let corner = corners.first {
***REMOVED******REMOVED******REMOVED***path.move(to: corner, transform: .identity)
***REMOVED******REMOVED******REMOVED***for corner in corners[1..<corners.count] {
***REMOVED******REMOVED******REMOVED******REMOVED***path.addLine(to: corner)
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***path.closeSubpath()
***REMOVED***
***REMOVED******REMOVED***return path
***REMOVED***
***REMOVED***
***REMOVED***private func createMetadataObjectOverlayWithMetadataObject(_ metadataObject: AVMetadataObject) -> MetadataObjectLayer {
***REMOVED******REMOVED***let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)
***REMOVED******REMOVED***let metadataObjectOverlayLayer = MetadataObjectLayer()
***REMOVED******REMOVED***metadataObjectOverlayLayer.metadataObject = transformedMetadataObject
***REMOVED******REMOVED***metadataObjectOverlayLayer.lineJoin = .round
***REMOVED******REMOVED***metadataObjectOverlayLayer.lineWidth = 2.5
***REMOVED******REMOVED***metadataObjectOverlayLayer.fillColor = view.tintColor.withAlphaComponent(0.25).cgColor
***REMOVED******REMOVED***metadataObjectOverlayLayer.strokeColor = view.tintColor.withAlphaComponent(1).cgColor
***REMOVED******REMOVED***guard let barcodeMetadataObject = transformedMetadataObject as? AVMetadataMachineReadableCodeObject else {
***REMOVED******REMOVED******REMOVED***return metadataObjectOverlayLayer
***REMOVED***
***REMOVED******REMOVED***let barcodeOverlayPath = barcodeOverlayPathWithCorners(barcodeMetadataObject.corners)
***REMOVED******REMOVED***metadataObjectOverlayLayer.path = barcodeOverlayPath
***REMOVED******REMOVED***let fontSize = 12.0
***REMOVED******REMOVED***if let stringValue = barcodeMetadataObject.stringValue, !stringValue.isEmpty {
***REMOVED******REMOVED******REMOVED***let barcodeOverlayBoundingBox = barcodeOverlayPath.boundingBox
***REMOVED******REMOVED******REMOVED***let minimumTextLayerHeight: CGFloat = fontSize + 4
***REMOVED******REMOVED******REMOVED***let textLayerHeight: CGFloat
***REMOVED******REMOVED******REMOVED***if barcodeOverlayBoundingBox.size.height < minimumTextLayerHeight {
***REMOVED******REMOVED******REMOVED******REMOVED***textLayerHeight = minimumTextLayerHeight
***REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED***textLayerHeight = barcodeOverlayBoundingBox.size.height
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***let textLayer = CATextLayer()
***REMOVED******REMOVED******REMOVED***textLayer.alignmentMode = .center
***REMOVED******REMOVED******REMOVED***textLayer.bounds = CGRect(x: .zero, y: .zero, width: barcodeOverlayBoundingBox.size.width, height: textLayerHeight)
***REMOVED******REMOVED******REMOVED***textLayer.contentsScale = UIScreen.main.scale
***REMOVED******REMOVED******REMOVED***textLayer.font = UIFont.systemFont(ofSize: fontSize)
***REMOVED******REMOVED******REMOVED***textLayer.position = CGPoint(x: barcodeOverlayBoundingBox.midX, y: barcodeOverlayBoundingBox.midY)
***REMOVED******REMOVED******REMOVED***textLayer.string = NSAttributedString(
***REMOVED******REMOVED******REMOVED******REMOVED***string: stringValue,
***REMOVED******REMOVED******REMOVED******REMOVED***attributes: [
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font: UIFont.systemFont(ofSize: fontSize),
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor: UIColor.white
***REMOVED******REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED***textLayer.isWrapped = true
***REMOVED******REMOVED******REMOVED***textLayer.transform = previewLayer.transform
***REMOVED******REMOVED******REMOVED***metadataObjectOverlayLayer.addSublayer(textLayer)
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***let guideTextLayer = CATextLayer()
***REMOVED******REMOVED***let guideTextString = NSAttributedString(
***REMOVED******REMOVED******REMOVED***string: String.tapToScan,
***REMOVED******REMOVED******REMOVED***attributes: [
***REMOVED******REMOVED******REMOVED******REMOVED***.font: UIFont.systemFont(ofSize: fontSize),
***REMOVED******REMOVED******REMOVED******REMOVED***.foregroundColor: UIColor.white,
***REMOVED******REMOVED******REMOVED***]
***REMOVED******REMOVED***)
***REMOVED******REMOVED***guideTextLayer.alignmentMode = .center
***REMOVED******REMOVED***guideTextLayer.bounds = guideTextString.boundingRect(with: CGSize(width: CGFloat.infinity, height: CGFloat.infinity), options: .usesLineFragmentOrigin, context: nil)
***REMOVED******REMOVED***guideTextLayer.contentsScale = UIScreen.main.scale
***REMOVED******REMOVED***guideTextLayer.position = CGPoint(x: barcodeOverlayPath.boundingBox.midX, y: barcodeOverlayPath.boundingBox.minY - 8)
***REMOVED******REMOVED***guideTextLayer.string = guideTextString
***REMOVED******REMOVED***guideTextLayer.shadowColor = UIColor.black.cgColor
***REMOVED******REMOVED***guideTextLayer.shadowOffset = CGSizeZero
***REMOVED******REMOVED***guideTextLayer.shadowOpacity = 1.0
***REMOVED******REMOVED***metadataObjectOverlayLayer.addSublayer(guideTextLayer)
***REMOVED******REMOVED***
***REMOVED******REMOVED***return metadataObjectOverlayLayer
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Checks the scanned contents for the number of codes recognized. If only a single code is
***REMOVED******REMOVED***/ recognized, `autoScanTimer` is started, otherwise the `autoScanTimer` is invalidated.
***REMOVED******REMOVED***/
***REMOVED******REMOVED***/ - Parameter output: The sect of scanned codes.
***REMOVED***private func evaluateOutputForAutoScan(_ output: [AVMetadataObject]) {
***REMOVED******REMOVED***if output.count == 1 {
***REMOVED******REMOVED******REMOVED***if !(self.autoScanTimer?.isValid ?? false), let metadataObject = output.first {
***REMOVED******REMOVED******REMOVED******REMOVED***self.autoScanTimer = Timer.scheduledTimer(withTimeInterval: autoScanDelay, repeats: false) { _ in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.scan(metadataObject)
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***self.autoScanTimer?.invalidate()
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@objc
***REMOVED***private func removeMetadataObjectOverlayLayers() {
***REMOVED******REMOVED***for sublayer in metadataObjectOverlayLayers {
***REMOVED******REMOVED******REMOVED***sublayer.removeFromSuperlayer()
***REMOVED***
***REMOVED******REMOVED***metadataObjectOverlayLayers = []
***REMOVED******REMOVED***removeMetadataObjectOverlayLayersTimer?.invalidate()
***REMOVED******REMOVED***removeMetadataObjectOverlayLayersTimer = nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED***/ Triggers the delegated scan method.
***REMOVED******REMOVED***/ - Parameter metadataObject: The machine readable code.
***REMOVED***private func scan(_ metadataObject: AVMetadataObject) {
***REMOVED******REMOVED***if let machineReadableCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
***REMOVED******REMOVED***   let stringValue = machineReadableCodeObject.stringValue {
***REMOVED******REMOVED******REMOVED***delegate?.didScanCode(stringValue)
***REMOVED******REMOVED******REMOVED***if #available(iOS 17.5, *) {
***REMOVED******REMOVED******REMOVED******REMOVED***self.feedbackGenerator.selectionChanged(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: CGPoint(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***x: metadataObject.bounds.midX,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***y: metadataObject.bounds.midY
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***@objc
***REMOVED***private func userDidTap(with tapGestureRecognizer: UITapGestureRecognizer) {
***REMOVED******REMOVED***let point = tapGestureRecognizer.location(in: view)
***REMOVED******REMOVED***for metadataObjectOverlayLayer in metadataObjectOverlayLayers {
***REMOVED******REMOVED******REMOVED***if metadataObjectOverlayLayer.path?.contains(point) ?? false,
***REMOVED******REMOVED******REMOVED***   let metadataObject = metadataObjectOverlayLayer.metadataObject {
***REMOVED******REMOVED******REMOVED******REMOVED***scan(metadataObject)
***REMOVED******REMOVED******REMOVED******REMOVED***break
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

private extension String {
***REMOVED***static var tapToScan: Self {
***REMOVED******REMOVED***.init(
***REMOVED******REMOVED******REMOVED***localized: "Tap to scan",
***REMOVED******REMOVED******REMOVED***bundle: .toolkitModule,
***REMOVED******REMOVED******REMOVED***comment: "A label for a button to select a code identified with the barcode scanner."
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***
