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

#if os(iOS)
import ArcGIS
import ARKit
import Combine
import SwiftUI

/// A scene view that provides an augmented reality world scale experience.
@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public struct WorldScaleSceneView<Provider: WorldTrackingProvider>: View {
    /// Contextual information about the state of the world-scale AR scene.
    ///
    /// This context is provided to camera feed builders so they can access
    /// calibration, scene, tracking provider, and localization state.
    public struct Context {
        /// The current calibration applied to the AR experience.
        public let calibration: Calibration
        /// A proxy for interacting with the underlying scene view.
        public let sceneView: SceneViewProxy
        /// The active world tracking provider.
        public let provider: Provider
        /// The camera controller used to position the scene camera.
        public let cameraController: TransformationMatrixCameraController
        /// A Boolean value indicating whether calibration UI is currently
        /// shown.
        public let isCalibrating: Bool
        /// A Boolean value indicating whether coaching UI is currently
        /// active.
        public let isCoaching: Bool
        /// A Boolean value indicating whether world tracking is localized.
        @Binding public var isLocalized: Bool
    }
    
    /// The type of tracking configuration used by the view.
    @available(*, deprecated, renamed: "AppleWorldTracking.Mode", message: "Use 'AppleWorldTracking.Mode' instead.")
    public typealias TrackingMode = AppleWorldTracking.Mode
    
    /// The various ways that a world-tracking provider and camera feed can be
    /// supplied.
    private enum ProviderSource {
        /// A built-in Apple world-tracking provider with the given
        /// tracking mode.
        case `default`(mode: AppleWorldTracking.Mode)
        /// A caller-supplied world-tracking provider and camera feed view
        /// builder.
        case custom(Provider, cameraFeedView: (Context) -> Provider.CameraFeedView)
        
        /// The tracking mode of this source or `nil` if this is a custom
        /// source.
        var trackingMode: AppleWorldTracking.Mode? {
            guard case let .default(mode) = self else { return nil }
            return mode
        }
    }
    
    /// The source that determines which world-tracking provider is used.
    private let providerSource: ProviderSource
    /// The closure that builds the scene view.
    private let sceneViewBuilder: (SceneViewProxy) -> SceneView
    
    /// A store for the default Apple world-tracking provider.
    ///
    /// This is necessary to store the provider as a state object, ensuring that
    /// it is only created once.
    @MainActor private class DefaultProviderStore: ObservableObject {
        /// The default provider instance.
        private(set) var provider = AppleWorldTracking(mode: .geoTracking)
    }
    
    /// The state object that owns the default Apple world-tracking provider.
    @StateObject private var defaultProviderStore = DefaultProviderStore()
    
    /// The world tracking provider for this view.
    ///
    /// This is either the custom provider supplied by the caller or a default
    /// Apple world-tracking provider.
    var provider: Provider {
        if case let .custom(provider, cameraFeedView: _) = providerSource {
            provider
        } else {
            defaultProviderStore.provider as! Provider
        }
    }
    
    /// Builds the camera feed view for the provider of this view.
    /// - Parameter sceneView: The proxy for the overlaid scene view.
    /// - Returns: The camera feed view associated with the provider.
    func cameraFeedView(sceneView: SceneViewProxy) -> Provider.CameraFeedView {
        if case let .custom(_, cameraFeedView: cameraFeedView) = providerSource {
            let context = Context(
                calibration: calibration,
                sceneView: sceneView,
                provider: provider,
                cameraController: cameraController,
                isCalibrating: isCalibrating,
                isCoaching: isCoaching,
                isLocalized: $isLocalized
            )
            return cameraFeedView(context)
        } else {
            let context = WorldScaleSceneView<AppleWorldTracking>.Context(
                calibration: calibration,
                sceneView: sceneView,
                provider: defaultProviderStore.provider,
                cameraController: cameraController,
                isCalibrating: isCalibrating,
                isCoaching: isCoaching,
                isLocalized: $isLocalized
            )
            return AppleWorldTrackingCameraFeedView(context: context)
                .onCameraTrackingStateChanged { newTrackingState in
                    onCameraTrackingStateChangedAction?(newTrackingState)
                }
                .onGeoTrackingStatusChanged { newTrackingStatus in
                    onGeoTrackingStatusChangedAction?(newTrackingStatus)
                } as! Provider.CameraFeedView
        }
    }
    
    /// The alignment of the calibration button.
    var calibrationButtonAlignment: Alignment = .bottom
    /// A Boolean value that indicates whether the calibration view is hidden.
    var calibrationViewIsHidden = false
    
    /// The clipping distance of the scene view.
    private var clippingDistance: Double?
    /// The closure to call upon a single tap.
    private var onSingleTapGestureAction: ((CGPoint, Point?) -> Void)? = nil
    /// The closure to perform when the `isCalibrating` property has changed.
    private var onCalibratingChangedAction: ((Bool) -> Void)?
    /// The closure to perform when the camera tracking state changes.
    private var onCameraTrackingStateChangedAction: ((ARCamera.TrackingState) -> Void)?
    /// The closure to perform when the geo tracking status changes.
    private var onGeoTrackingStatusChangedAction: ((ARGeoTrackingStatus) -> Void)?
    
    /// The calibration currently applied to the AR experience.
    @State private var calibration = Calibration()
    /// A Boolean value that indicates if the user is calibrating.
    @State private var isCalibrating = false
    /// A Boolean value that indicates whether the coaching overlay view is
    /// active.
    @State private var isCoaching = false
    /// A Boolean value that indicates whether world tracking is localized.
    @State private var isLocalized = false
    /// The current camera of the scene view.
    @State private var currentCamera: Camera?
    /// The camera controller for this scene view.
    @State private var cameraController = TransformationMatrixCameraController()
    
    /// Creates a world scale scene view.
    /// - Parameters:
    ///   - clippingDistance: Determines the clipping distance in meters around
    ///   the camera. A value of `nil` means that no data will be clipped.
    ///   - trackingMode: The type of tracking configuration used by the AR
    ///   view.
    ///   - sceneViewBuilder: A closure that builds the scene view to be
    ///   overlayed on top of the augmented reality video feed.
    /// - Note: The provided scene view will have certain properties
    /// overridden in order to be effectively viewed in augmented reality.
    /// Properties such as the camera controller, and view drawing mode.
    @available(*, deprecated, message: "Use 'init(provider:cameraFeedView:sceneView:)' instead.")
    public init(
        clippingDistance: Double? = nil,
        trackingMode: TrackingMode = .worldTracking,
        sceneViewBuilder: @escaping (SceneViewProxy) -> SceneView
    ) where Provider == AppleWorldTracking {
        self.providerSource = .default(mode: trackingMode)
        self.clippingDistance = clippingDistance
        self.sceneViewBuilder = sceneViewBuilder
    }
    
    /// Creates an instance with the given world tracking provider and scene
    /// view builder.
    /// - Parameters:
    ///   - provider: The world tracking provider to use.
    ///   - cameraFeedView: A closure that returns the camera feed view for the
    ///   provider.
    ///   - sceneView: A closure that builds the scene view. The provided scene
    ///   view will be modified as necessary for viewing in augmented reality.
    public init(
        provider: Provider,
        cameraFeedView: @escaping (_ context: Context) -> Provider.CameraFeedView,
        sceneView: @escaping (_ sceneView: SceneViewProxy) -> SceneView
    ) {
        self.providerSource = .custom(provider, cameraFeedView: cameraFeedView)
        self.sceneViewBuilder = sceneView
    }
    
    public var body: some View {
        SceneViewReader { sceneView in
            ZStack {
                cameraFeedView(sceneView: sceneView)
                    .environment(CameraWrapper(currentCamera))
                sceneViewBuilder(sceneView)
                    .cameraController(cameraController)
                    .attributionBarHidden(true)
                    .spaceEffect(.transparent)
                    .atmosphereEffect(.off)
                    .interactiveNavigationDisabled(true)
                    .onCameraChanged { newCamera in
                        currentCamera = newCamera
                    }
                    .opacity(isLocalized ? 1 : 0)
            }
            .overlay {
                ARCoachingOverlay(goal: .geoTracking)
                    .sessionProvider(provider.arSessionProvider)
                    .onCoachingOverlayActivate { _ in
                        isCoaching = true
                    }
                    .onCoachingOverlayDeactivate { _ in
                        isCoaching = false
                    }
                    .onCoachingOverlayRequestSessionReset { _ in
                        provider.reset()
                    }
                    .ignoresSafeArea()
            }
        }
        .task {
            await provider.start()
        }
        .onDisappear {
            provider.stop()
        }
        .onChange(of: providerSource.trackingMode, initial: true) { _, newMode in
            guard let newMode else { return }
            defaultProviderStore.provider.mode = newMode
        }
        .onChange(of: calibration.headingCorrection) { _, newHeadingCorrection in
            // Update camera controller.
            let originCamera = cameraController.originCamera
            cameraController.originCamera = originCamera.rotatedTo(
                heading: originCamera.heading + newHeadingCorrection,
                pitch: originCamera.pitch,
                roll: originCamera.roll
            )
        }
        .onChange(of: calibration.elevationCorrection) { _, newElevationCorrection in
            // Update camera controller.
            cameraController.originCamera = cameraController.originCamera
                .elevated(by: newElevationCorrection)
        }
        .onChange(of: clippingDistance, initial: true) {
            cameraController.clippingDistance = clippingDistance
        }
        .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
        .overlay(alignment: calibrationButtonAlignment) {
            if !calibrationViewIsHidden && !isCalibrating {
                Button {
                    withAnimation {
                        isCalibrating = true
                    }
                } label: {
                    Text(
                        "Calibrate",
                        bundle: .toolkitModule,
                        comment: "A label for a button to show the calibration view."
                    )
                    .padding()
                }
                .background(.regularMaterial)
                .clipShape(.rect(cornerRadius: 10))
                .disabled(!isLocalized)
                .padding()
                .padding(.vertical)
            }
        }
        .overlay(alignment: .bottom) {
            if isCalibrating {
                CalibrationView(calibration: calibration, isPresented: $isCalibrating)
                    .padding(.bottom)
            }
        }
        .animation(.default.speed(0.25), value: isLocalized)
        .onChange(of: isCalibrating) {
            onCalibratingChangedAction?(isCalibrating)
        }
        .onTapGesture { tapPoint in
            let scenePoint = arScreenToLocation(screenPoint: tapPoint)
            onSingleTapGestureAction?(tapPoint, scenePoint)
        }
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public extension WorldScaleSceneView {
    /// Sets the visibility of the calibration view for the AR experience.
    /// - Parameter hidden: A Boolean value that indicates whether to hide the
    ///  calibration view.
    func calibrationViewHidden(_ hidden: Bool) -> Self {
        var copy = self
        copy.calibrationViewIsHidden = hidden
        return copy
    }
    
    /// Sets the alignment of the calibration button.
    /// - Parameter alignment: The alignment for the calibration button.
    func calibrationButtonAlignment(_ alignment: Alignment) -> Self {
        var copy = self
        copy.calibrationButtonAlignment = alignment
        return copy
    }
    
    /// Sets the clipping distance around the camera. A value
    ///   of `nil` means that no data will be clipped.
    /// - Parameter clippingDistance: The distance in meters. A value of `nil`
    /// means that no data will be clipped.
    func clippingDistance(_ clippingDistance: Double?) -> Self {
        var copy = self
        copy.clippingDistance = clippingDistance
        return copy
    }
    
    /// Sets a closure to perform when calibration begins or ends.
    /// - Parameter action: The closure to perform when calibration begins or ends.
    func onCalibratingChanged(
        perform action: @escaping (_ newCalibrating: Bool) -> Void
    ) -> Self {
        var copy = self
        copy.onCalibratingChangedAction = action
        return copy
    }
    
    /// Sets a closure to perform when a single tap occurs on the view.
    /// - Parameter action: A closure that takes the screen point of the tap
    /// and the corresponding scene point if available.
    func onSingleTapGesture(
        perform action: @escaping (_ screenPoint: CGPoint, _ scenePoint: Point?) -> Void
    ) -> some View {
        var copy = self
        copy.onSingleTapGestureAction = action
        return copy
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
public extension WorldScaleSceneView<AppleWorldTracking> /* Deprecated */ {
    /// Sets a closure to perform when the camera tracking state changes.
    /// - Parameter action: The closure to call when the camera tracking state
    /// has changed.
    @available(*, deprecated, message: "Use 'AppleWorldTrackingCameraFeedView.onCameraTrackingStateChanged(perform:)' instead.")
    func onCameraTrackingStateChanged(
        perform action: @escaping (_ cameraTrackingState: ARCamera.TrackingState) -> Void
    ) -> Self {
        var copy = self
        copy.onCameraTrackingStateChangedAction = action
        return copy
    }
    
    /// Sets a closure to perform when the geo tracking status changes.
    /// - Parameter action: The closure to call when the geo tracking status has
    /// changed.
    @available(*, deprecated, message: "Use 'AppleWorldTrackingCameraFeedView.onGeoTrackingStatusChanged(perform:)' instead.")
    func onGeoTrackingStatusChanged(
        perform action: @escaping (_ geoTrackingStatus: ARGeoTrackingStatus) -> Void
    ) -> Self {
        var copy = self
        copy.onGeoTrackingStatusChangedAction = action
        return copy
    }
}

@available(macCatalyst, unavailable)
@available(visionOS, unavailable)
private extension WorldScaleSceneView {
    /// Determines the scene point for the given screen point.
    ///
    /// If the raycast fails due to certain reasons, this method returns `nil`.
    /// - Parameter screenPoint: The point in screen's coordinate space.
    /// - Returns: The scene point corresponding to screen point.
    func arScreenToLocation(screenPoint: CGPoint) -> Point? {
        // Use the 'raycast' method to get the matrix of 'screenPoint'.
        guard let localOffsetMatrix = provider.arSessionProvider.arView.raycast(
            from: screenPoint,
            allowing: .estimatedPlane
        ) else {
            return nil
        }
        let originTransformationMatrix = cameraController.originCamera.transformationMatrix
        let scenePointMatrix = originTransformationMatrix.adding(localOffsetMatrix)
        // Create a camera from transformationMatrix and return its location.
        return Camera(transformationMatrix: scenePointMatrix).location
    }
}
#endif
