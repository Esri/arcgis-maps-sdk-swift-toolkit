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
struct CodeScanner: View {
***REMOVED***@Binding var code: String
***REMOVED***
***REMOVED***@Binding var isPresented: Bool
***REMOVED***
***REMOVED***@State private var cameraAccessIsAuthorized = false
***REMOVED***
***REMOVED***@StateObject private var cameraRequester = CameraRequester()
***REMOVED***
***REMOVED***var body: some View {
***REMOVED******REMOVED***if cameraAccessIsAuthorized {
***REMOVED******REMOVED******REMOVED***CodeScannerRepresentable(scannerIsPresented: $isPresented, scanOutput: $code)
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea()
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment:.topTrailing) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***Button(String.cancel, role: .cancel) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.buttonStyle(.borderedProminent)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.overlay(alignment: .bottom) {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***FlashlightButton()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.hiddenIfUnavailable()
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.font(.title)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***.padding()
***REMOVED******REMOVED******REMOVED***
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***Color.clear
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraRequester.request {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraAccessIsAuthorized = true
***REMOVED******REMOVED******REMOVED******REMOVED*** onAccessDenied: {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***isPresented = false
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.cameraRequester(cameraRequester)
***REMOVED***
***REMOVED***
***REMOVED***

struct CodeScannerRepresentable: UIViewControllerRepresentable {
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
***REMOVED******REMOVED***let scannerViewController: ScannerViewController
***REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED***scannerViewController = ScannerViewController()
***REMOVED*** else {
***REMOVED******REMOVED******REMOVED***scannerViewController = LegacyScannerViewController()
***REMOVED***
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
***REMOVED***private let captureSession = AVCaptureSession()
***REMOVED***
***REMOVED***private let feedbackGenerator = UISelectionFeedbackGenerator()
***REMOVED***
***REMOVED***private let metadataObjectsOverlayLayersDrawingSemaphore = DispatchSemaphore(value: 1)
***REMOVED***
***REMOVED******REMOVED***/ The color of a code overlay before it's been targeted for auto-scan.
***REMOVED***private let normalOverlayColor = UIColor.white.withAlphaComponent(0.25)
***REMOVED***
***REMOVED******REMOVED***/ The number of consecutive hits required to trigger an automatic scan.
***REMOVED***private let requiredTargetHits = 25
***REMOVED***
***REMOVED***private let sessionQueue = DispatchQueue(label: "ScannerViewController")
***REMOVED***
***REMOVED******REMOVED*** MARK: Variables
***REMOVED***
***REMOVED***var previewLayer: AVCaptureVideoPreviewLayer!
***REMOVED***
***REMOVED***private var metadataObjectOverlayLayers = [MetadataObjectLayer]()
***REMOVED***
***REMOVED***private var removeMetadataObjectOverlayLayersTimer: Timer?
***REMOVED***
***REMOVED***private var reticleLayer: CAShapeLayer?
***REMOVED***
***REMOVED******REMOVED***/ The number of consecutive target hits. See also `requiredTargetHits`.
***REMOVED***private var targetHits = 0
***REMOVED***
***REMOVED******REMOVED***/ The string value of the targeted code.
***REMOVED***private var targetStringValue: String?
***REMOVED***
***REMOVED***private var videoRotationProvider: AnyObject?
***REMOVED***
***REMOVED***weak var delegate: ScannerViewControllerDelegate?
***REMOVED***
***REMOVED***private class MetadataObjectLayer: CAShapeLayer {
***REMOVED******REMOVED***var metadataObject: AVMetadataObject?
***REMOVED******REMOVED***var stringValue: String? {
***REMOVED******REMOVED******REMOVED***(metadataObject as? AVMetadataMachineReadableCodeObject)?.stringValue
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: UIViewController methods
***REMOVED***
***REMOVED***override func viewDidLayoutSubviews() {
***REMOVED******REMOVED***previewLayer.frame = view.bounds
***REMOVED******REMOVED***updateReticleAndAutoFocus()
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
***REMOVED******REMOVED***view.layer.addSublayer(previewLayer)
***REMOVED******REMOVED***updateReticleAndAutoFocus()
***REMOVED******REMOVED***if #available(iOS 17.0, *) {
***REMOVED******REMOVED******REMOVED***videoRotationProvider = RotationCoordinator(videoCaptureDevice: videoCaptureDevice, previewLayer: previewLayer)
***REMOVED***
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
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***let overlayLayer = self.createMetadataObjectOverlayWithMetadataObject(metadataObject)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***metadataObjectOverlayLayers.append(overlayLayer)
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***self.addMetadataObjectOverlayLayersToVideoPreviewView(metadataObjectOverlayLayers)
***REMOVED******REMOVED******REMOVED******REMOVED***self.checkTargetHits()
***REMOVED******REMOVED******REMOVED******REMOVED***self.metadataObjectsOverlayLayersDrawingSemaphore.signal()
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
***REMOVED******REMOVED***/ Checks if the reticle intersects with any of the current overlays. When a code with a consistent string
***REMOVED******REMOVED***/ value intersects with the reticle for the `requiredTargetHits` count, it is auto-scanned.
***REMOVED***private func checkTargetHits() {
***REMOVED******REMOVED***var reticleWasContainedInAOverlay = false
***REMOVED******REMOVED***for overlayLayer in metadataObjectOverlayLayers {
***REMOVED******REMOVED******REMOVED***if overlayLayer.path!.contains(self.reticleLayer!.position) {
***REMOVED******REMOVED******REMOVED******REMOVED***reticleWasContainedInAOverlay = true
***REMOVED******REMOVED******REMOVED******REMOVED***if let stringValue = self.targetStringValue, stringValue == overlayLayer.stringValue {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.targetHits += 1
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***overlayLayer.fillColor = normalOverlayColor.interpolatedWith(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***UIColor.tintColor,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***at: CGFloat(self.targetHits) / CGFloat(self.requiredTargetHits)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***)?.cgColor
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if self.targetHits >= self.requiredTargetHits {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***delegate?.didScanCode(stringValue)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***if #available(iOS 17.5, *), let metadataObject = overlayLayer.metadataObject {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.feedbackGenerator.selectionChanged(at: metadataObject.bounds.origin)
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.targetHits = 0
***REMOVED******REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED*** else {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.targetStringValue = overlayLayer.stringValue
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.targetHits = 0
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED******REMOVED***if !reticleWasContainedInAOverlay {
***REMOVED******REMOVED******REMOVED***self.targetStringValue = nil
***REMOVED******REMOVED******REMOVED***self.targetHits = 0
***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func createMetadataObjectOverlayWithMetadataObject(_ metadataObject: AVMetadataObject) -> MetadataObjectLayer {
***REMOVED******REMOVED***let transformedMetadataObject = previewLayer.transformedMetadataObject(for: metadataObject)
***REMOVED******REMOVED***let metadataObjectOverlayLayer = MetadataObjectLayer()
***REMOVED******REMOVED***metadataObjectOverlayLayer.metadataObject = transformedMetadataObject
***REMOVED******REMOVED***metadataObjectOverlayLayer.lineJoin = .round
***REMOVED******REMOVED***metadataObjectOverlayLayer.lineWidth = 2.5
***REMOVED******REMOVED***metadataObjectOverlayLayer.fillColor = normalOverlayColor.cgColor
***REMOVED******REMOVED***metadataObjectOverlayLayer.strokeColor = UIColor.tintColor.cgColor
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
***REMOVED******REMOVED***return metadataObjectOverlayLayer
***REMOVED***
***REMOVED***
***REMOVED***@objc private func removeMetadataObjectOverlayLayers() {
***REMOVED******REMOVED***for sublayer in metadataObjectOverlayLayers {
***REMOVED******REMOVED******REMOVED***sublayer.removeFromSuperlayer()
***REMOVED***
***REMOVED******REMOVED***metadataObjectOverlayLayers = []
***REMOVED******REMOVED***removeMetadataObjectOverlayLayersTimer?.invalidate()
***REMOVED******REMOVED***removeMetadataObjectOverlayLayersTimer = nil
***REMOVED***
***REMOVED***
***REMOVED******REMOVED*** MARK: Other methods
***REMOVED***
***REMOVED******REMOVED***/ Focus on and adjust exposure at the point of interest.
***REMOVED***private func updateAutoFocus(for point: CGPoint) {
***REMOVED******REMOVED***let convertedPoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
***REMOVED******REMOVED***guard let device = AVCaptureDevice.default(for: .video) else { return ***REMOVED***
***REMOVED******REMOVED***do {
***REMOVED******REMOVED******REMOVED***try device.lockForConfiguration()
***REMOVED******REMOVED******REMOVED***if device.isFocusModeSupported(.autoFocus) && device.isFocusPointOfInterestSupported {
***REMOVED******REMOVED******REMOVED******REMOVED***device.focusPointOfInterest = convertedPoint
***REMOVED******REMOVED******REMOVED******REMOVED***device.focusMode = .continuousAutoFocus
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***if device.isExposureModeSupported(.autoExpose) && device.isExposurePointOfInterestSupported {
***REMOVED******REMOVED******REMOVED******REMOVED***device.exposurePointOfInterest = convertedPoint
***REMOVED******REMOVED******REMOVED******REMOVED***device.exposureMode = .continuousAutoExposure
***REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED***device.unlockForConfiguration()
***REMOVED*** catch { ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***private func updateReticle(for point: CGPoint) {
***REMOVED******REMOVED***self.reticleLayer?.removeFromSuperlayer()
***REMOVED******REMOVED***
***REMOVED******REMOVED***let reticleLayer = CAShapeLayer()
***REMOVED******REMOVED***let radius: CGFloat = 5.0
***REMOVED******REMOVED***reticleLayer.path = UIBezierPath(
***REMOVED******REMOVED******REMOVED***roundedRect: CGRect(x: 0, y: 0, width: 2.0 * radius, height: 2.0 * radius),
***REMOVED******REMOVED******REMOVED***cornerRadius: radius
***REMOVED******REMOVED***).cgPath
***REMOVED******REMOVED***reticleLayer.frame = CGRect(
***REMOVED******REMOVED******REMOVED***origin: CGPoint(
***REMOVED******REMOVED******REMOVED******REMOVED***x: point.x - radius,
***REMOVED******REMOVED******REMOVED******REMOVED***y: point.y - radius
***REMOVED******REMOVED******REMOVED***),
***REMOVED******REMOVED******REMOVED***size: CGSize(
***REMOVED******REMOVED******REMOVED******REMOVED***width: radius * 2,
***REMOVED******REMOVED******REMOVED******REMOVED***height: radius * 2
***REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED***)
***REMOVED******REMOVED***reticleLayer.fillColor = UIColor.tintColor.cgColor
***REMOVED******REMOVED***reticleLayer.zPosition = .greatestFiniteMagnitude
***REMOVED******REMOVED***previewLayer.addSublayer(reticleLayer)
***REMOVED******REMOVED***self.reticleLayer = reticleLayer
***REMOVED***
***REMOVED***
***REMOVED***private func updateReticleAndAutoFocus() {
***REMOVED******REMOVED***let pointOfInterest = CGPoint(
***REMOVED******REMOVED******REMOVED***x: view.frame.midX,
***REMOVED******REMOVED******REMOVED***y: view.frame.midY
***REMOVED******REMOVED***)
***REMOVED******REMOVED***updateAutoFocus(for: pointOfInterest)
***REMOVED******REMOVED***updateReticle(for: pointOfInterest)
***REMOVED***
***REMOVED***

@available(iOS 17.0, *)
class RotationCoordinator {
***REMOVED***private let rotationObservation: NSKeyValueObservation
***REMOVED***
***REMOVED***private let rotationCoordinator: AVCaptureDevice.RotationCoordinator
***REMOVED***
***REMOVED***init(videoCaptureDevice: AVCaptureDevice, previewLayer: AVCaptureVideoPreviewLayer) {
***REMOVED******REMOVED***rotationCoordinator = AVCaptureDevice.RotationCoordinator(device: videoCaptureDevice, previewLayer: previewLayer)
***REMOVED******REMOVED***rotationObservation = rotationCoordinator.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) { _, change in
***REMOVED******REMOVED******REMOVED***if let angle = change.newValue {
***REMOVED******REMOVED******REMOVED******REMOVED***Task { @MainActor in
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***previewLayer.connection?.videoRotationAngle = angle
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

***REMOVED*** MARK: Deprecated

***REMOVED***/ - Bug: The camera preview is inverted when started with the device in a landscape face-up orientation.
***REMOVED***/ This is fixed when using the `AVCaptureConnection.videoRotationAngle`
***REMOVED***/ property available in iOS 17.0.
@available(iOS, introduced: 16.0, deprecated: 17.0, message: "Use ScannerViewController with RotationCoordinator instead")
class LegacyScannerViewController: ScannerViewController {
***REMOVED***override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
***REMOVED******REMOVED***super.viewWillTransition(to: size, with: coordinator)
***REMOVED******REMOVED***updateRotation()
***REMOVED***
***REMOVED***
***REMOVED***override func viewDidLoad() {
***REMOVED******REMOVED***super.viewDidLoad()
***REMOVED******REMOVED***updateRotation()
***REMOVED***
***REMOVED***
***REMOVED***func updateRotation() {
***REMOVED******REMOVED***let deviceOrientation = UIDevice.current.orientation
***REMOVED******REMOVED***let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation)
***REMOVED******REMOVED***if let videoPreviewLayerConnection = previewLayer.connection {
***REMOVED******REMOVED******REMOVED***videoPreviewLayerConnection.videoOrientation = newVideoOrientation
***REMOVED***
***REMOVED***
***REMOVED***

@available(iOS, introduced: 16.0, deprecated: 17.0)
extension AVCaptureVideoOrientation {
***REMOVED***init(deviceOrientation: UIDeviceOrientation) {
***REMOVED******REMOVED***switch deviceOrientation {
***REMOVED******REMOVED***case .portraitUpsideDown: self = .portraitUpsideDown
***REMOVED******REMOVED***case .landscapeLeft: self = .landscapeRight
***REMOVED******REMOVED***case .landscapeRight: self = .landscapeLeft
***REMOVED******REMOVED***default: self = .portrait
***REMOVED***
***REMOVED***
***REMOVED***
