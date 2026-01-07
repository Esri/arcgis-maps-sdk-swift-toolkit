// Copyright 2022 Esri
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
@preconcurrency import QuickLook
import SwiftUI
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

internal import os

/// A view model representing the combination of a `FeatureAttachment` and
/// an associated `UIImage` used as a thumbnail.
@MainActor class AttachmentModel: ObservableObject {
    /// The `FeatureAttachment`.
    nonisolated let attachment: FeatureAttachment
    
    /// The thumbnail representing the attachment.
    @Published var thumbnail: UIImage? {
        didSet {
            systemImageName = nil
        }
    }
    
    /// The name of the system SF symbol used instead of `thumbnail`.
    @Published var systemImageName: String?
    
    /// The `LoadStatus` of the feature attachment.
    @Published var loadStatus: LoadStatus = .notLoaded
    
    /// The name of the attachment.
    @Published var name: String
    
    /// A Boolean value specifying whether the thumbnails is using a
    /// system image or an image generated from the feature attachment.
    var usingSystemImage: Bool {
        systemImageName != nil
    }
    
    /// The pixel density of the display on the intended device.
    private let displayScale: CGFloat
    
    /// The desired size of the thumbnail image.
    let thumbnailSize: CGSize
    
    /// The initial attachment load task.
    private var initialLoad: Task<Void, Never>?
    
    /// Creates a view model representing the combination of a `FeatureAttachment` and
    /// an associated `UIImage` used as a thumbnail.
    /// - Parameters:
    ///   - attachment: The `FeatureAttachment`.
    ///   - displayScale: The pixel density of the display on the intended device.
    ///   - thumbnailSize: The desired size of the thumbnail image.
    init(
        attachment: FeatureAttachment,
        displayScale: CGFloat,
        thumbnailSize: CGSize
    ) {
        self.attachment = attachment
        self.displayScale = displayScale
        self.name = attachment.name
        self.thumbnailSize = thumbnailSize
        
        if attachment.isLocal {
            initialLoad = Task { [weak self] in
                await self?.load()
            }
        } else {
            systemImageName = switch attachment.featureAttachmentKind {
            case .image: "photo"
            case .video: "film"
            case .audio: "waveform"
            case .document: "doc"
            case .other: "questionmark"
            }
        }
    }
    
    deinit {
        initialLoad?.cancel()
    }
    
    /// Removes Personally Identifying Information from the image by blurring the offending content
    func blur() -> URL? {
        print("absoluteString: \(attachment.fileURL?.path())")
        
        guard let url = attachment.fileURL,
              let image = UIImage(contentsOfFile: url.path())
        else { print("failed image creation"); return nil }
        var blurredImage = blurLicensePlates(in: image)
        
        blurredImage = blurFaces(in: blurredImage)
        var blurUrl: URL?
        if let data = blurredImage.pngData() {
            let filename = getDocumentsDirectory().appendingPathComponent("copy.png")
            try? data.write(to: filename)
            print("fileName = \(filename)")
            blurUrl = filename
        }
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        return blurUrl
    }
    
    /// Loads the attachment and generates a thumbnail image.
    func load() async {
        loadStatus = .loading
        do {
            try await withTaskCancellationHandler {
                try await attachment._load()
            } onCancel: {
                attachment.cancelLoad()
                Logger.attachmentsFeatureElementView.error("Attachment loading was cancelled.")
            }
        } catch {
            Logger.attachmentsFeatureElementView.error("Attachment loading failed \(error.localizedDescription).")
        }
        sync()
        guard loadStatus != .failed, let url = attachment.fileURL else {
            systemImageName = "exclamationmark.circle.fill"
            return
        }
        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: thumbnailSize,
            scale: displayScale,
            representationTypes: .all
        )
        do {
            let thumbnail = try await QLThumbnailGenerator.shared.generateBestRepresentation(for: request)
            withAnimation { self.thumbnail = thumbnail.uiImage }
        } catch {
            systemImageName = "exclamationmark.circle.fill"
        }
    }
    
    /// Synchronizes published properties with attachment metadata.
    func sync() {
        name = attachment.name
        loadStatus = attachment._loadStatus
    }
}

extension AttachmentModel: Identifiable {}

extension AttachmentModel {
    
    func blurLicensePlates(in image: UIImage, blurRadius: Float = 15.0) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        // Create text recognition request
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("Text recognition error: \(error)")
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Text detection failed: \(error)")
            return image
        }
        
        guard let results = request.results as? [VNRecognizedTextObservation], !results.isEmpty else {
            print("No text detected.")
            return image
        }
        
        // Convert UIImage to CIImage for processing
        guard let ciImage = CIImage(image: image) else { return image }
        let context = CIContext()
        var finalImage = ciImage
        let imageSize = image.size
        
        // Regex pattern for license plates (adjust for your region)
        let platePattern = "^[A-Z0-9*]{5,8}$"
        
        for observation in results {
            if let candidate = observation.topCandidates(1).first {
                let text = candidate.string
                
                // Check if text matches license plate format
                if text.range(of: platePattern, options: .regularExpression) != nil {
                    
                    // Convert Vision bounding box to image coordinates
                    let boundingBox = observation.boundingBox
                    let plateRect = CGRect(
                        x: boundingBox.origin.x * imageSize.width,
                        y: boundingBox.origin.y * imageSize.height,
//                        y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
                        width: boundingBox.width * imageSize.width,
                        height: boundingBox.height * imageSize.height
                    )
                    
                    // Crop the plate region
                    let plateCrop = ciImage.cropped(to: plateRect)
                    guard let blurredPlate = applyEnhancedBlur(
                        to: plateCrop,
                        radius: CGFloat(blurRadius),
                        times: 1
                    ) else { return image}
                    
//                    // Apply Gaussian blur
//                    let blurFilter = CIFilter.gaussianBlur()
//                    blurFilter.inputImage = plateCrop
//                    blurFilter.radius = blurRadius
//                    guard let blurredPlate = blurFilter.outputImage else { continue }

                    // Composite blurred plate back onto original image
                    let compositor = CIFilter.sourceOverCompositing()
                    compositor.inputImage = blurredPlate
                    compositor.backgroundImage = finalImage
                    guard let composited = compositor.outputImage else { continue }
                    finalImage = composited
                }
            }
        }
        
        // Render final blurred image
        if let cgFinal = context.createCGImage(finalImage, from: finalImage.extent) {
            return UIImage(cgImage: cgFinal, scale: image.scale, orientation: image.imageOrientation)
        }
        return image
    }

    func blurFaces(in image: UIImage, blurRadius: Float = 15.0) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        
        // Create a face detection request
        let request = VNDetectFaceRectanglesRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Face detection failed: \(error)")
            return image
        }
        
        guard let results = request.results as? [VNFaceObservation], !results.isEmpty else {
            print("No faces detected.")
            return image
        }
        
        // Convert UIImage to CIImage for processing
        guard let ciImage = CIImage(image: image) else { return image }
        let context = CIContext()
        var finalImage = ciImage
        
        let imageSize = image.size
        
        for face in results {
            // Convert Vision bounding box to image coordinates
            let boundingBox = face.boundingBox
            let faceRect = CGRect(
                x: boundingBox.origin.x * imageSize.width,
                y: boundingBox.origin.y * imageSize.height,
//                y: (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height,
                width: boundingBox.width * imageSize.width,
                height: boundingBox.height * imageSize.height
            )
            print(
                "face: \(face.boundingBox); faceRect: \(faceRect); imageHeight: \(imageSize.height), imageWidth: \(imageSize.width)"
            )

            // Crop the face region
            let faceCrop = ciImage.cropped(to: faceRect)
  
            guard let blurredFace = applyEnhancedBlur(
                to: faceCrop,
                radius: CGFloat(blurRadius),
                times: 1
            ) else { return image}
            
//            // Apply Gaussian blur to the cropped face
//            let blurFilter = CIFilter.gaussianBlur()
//            blurFilter.inputImage = faceCrop
//            blurFilter.radius = blurRadius
//            guard let blurredFace = blurFilter.outputImage else { continue }
            
            // Composite blurred face back onto original image
            let compositor = CIFilter.sourceOverCompositing()
            compositor.inputImage = blurredFace
            compositor.backgroundImage = finalImage
            guard let composited = compositor.outputImage else { continue }
            
            finalImage = composited
        }
        
        // Render final blurred image
        if let cgFinal = context.createCGImage(finalImage, from: finalImage.extent) {
            return UIImage(cgImage: cgFinal, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return image
    }
    
    func applyBlur(to ciImage: CIImage, radius: CGFloat) -> CIImage? {
        // Create a Gaussian Blur filter
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(radius, forKey: kCIInputRadiusKey)
        
        // Get the output image
        guard let outputImage = blurFilter?.outputImage else { return nil }
        return outputImage
//        // Create a context and render the output image
//        let context = CIContext()
//        if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
//            return UIImage(cgImage: cgImage)
//        }
//        
//        return nil
    }

    func applyEnhancedBlur(to ciImage: CIImage, radius: CGFloat, times: Int) -> CIImage? {
        var blurredImage = ciImage
        
        for _ in 0..<times {
            if let newBlurredImage = applyBlur(to: blurredImage, radius: radius) {
                blurredImage = newBlurredImage
            }
        }
        
        return blurredImage
    }
}
