// Copyright 2024 Esri
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
@preconcurrency import AVFoundation
import SwiftUI

struct BarcodeScannerInput: View {
    /// The element the input belongs to.
    private let element: FieldFormElement
    
    /// The input configuration of the field.
    private let input: BarcodeScannerFormInput
    
    /// A Boolean value indicating whether the code scanner is presented.
    @State private var scannerIsPresented = false
    
    /// The current barcode value.
    @State private var value = ""
    
    /// Creates a view for a barcode scanner input.
    /// - Parameters:
    ///   - element: The input's parent element.
    init(element: FieldFormElement) {
        precondition(
            element.input is BarcodeScannerFormInput,
            "\(Self.self).\(#function) element's input must be \(BarcodeScannerFormInput.self)."
        )
        self.element = element
        self.input = element.input as! BarcodeScannerFormInput
    }
    
    var body: some View {
        HStack {
            Text(value.isEmpty ? String.noValue : value)
            Spacer()
            if !value.isEmpty {
                ClearButton {
                    value.removeAll()
                }
            }
            Image(systemName: "barcode.viewfinder")
                .foregroundStyle(.tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .formInputStyle()
        .onTapGesture {
            scannerIsPresented = true
        }
        .sheet(isPresented: $scannerIsPresented) {
            ScannerView(scanOutput: $value, scannerIsPresented: $scannerIsPresented)
        }
    }
}

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scanOutput: String
    @Binding var scannerIsPresented: Bool
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let scannerViewController = ScannerViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scanOutput, isShowingScanner: $scannerIsPresented)
    }
    
    class Coordinator: NSObject, ScannerViewControllerDelegate {
        @Binding var scanOutput: String
        @Binding var scannerIsPresented: Bool
        
        init(scannedCode: Binding<String>, isShowingScanner: Binding<Bool>) {
            _scanOutput = scannedCode
            _scannerIsPresented = isShowingScanner
        }
        
        func didScanCode(_ code: String) {
            scanOutput = code
            scannerIsPresented = false
        }
    }
}

protocol ScannerViewControllerDelegate: AnyObject {
    func didScanCode(_ code: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerViewControllerDelegate?
    
    private let captureSession = AVCaptureSession()
    
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private let sessionQueue = DispatchQueue(label: "ScannerViewController")
    
    override func viewDidLayoutSubviews() {
        previewLayer.frame = view.bounds
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .landscapeLeft:
            previewLayer.connection!.videoOrientation = .landscapeRight
        case .landscapeRight:
            previewLayer.connection!.videoOrientation = .landscapeLeft
        case .portraitUpsideDown:
            previewLayer.connection!.videoOrientation = .portraitUpsideDown
        case .portrait:
            previewLayer.connection!.videoOrientation = .portrait
        default:
            previewLayer.connection!.videoOrientation = .portrait
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [
                // Barcodes
                .codabar,
                .code39,
                .code39Mod43,
                .code93,
                .code128,
                .ean8,
                .ean13,
                .gs1DataBar,
                .gs1DataBarExpanded,
                .gs1DataBarLimited,
                .interleaved2of5,
                .itf14,
                .upce,
                
                // 2D Codes
                .aztec,
                .dataMatrix,
                .microPDF417,
                .microQR,
                .pdf417,
                .qr,
            ]
        } else {
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession.isRunning == false {
            sessionQueue.async { [captureSession] in
                captureSession.startRunning()
            }
        }
    }
    
    func finish(stringValue: String) {
        captureSession.stopRunning()
        delegate?.didScanCode(stringValue)
    }
    
    nonisolated func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            Task {
                await finish(stringValue: stringValue)
            }
        }
    }
}
