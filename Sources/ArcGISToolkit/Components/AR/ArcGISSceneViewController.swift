***REMOVED***
***REMOVED***  File.swift
***REMOVED***  
***REMOVED***
***REMOVED***  Created by Ryan Olson on 9/13/23.
***REMOVED***

import Foundation
import UIKit
***REMOVED***
***REMOVED***

class ArcGISSceneViewController: UIHostingController<ArcGISSceneViewController.HostedView> {
***REMOVED***private let model: HostedViewModel
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***scene: ArcGIS.Scene = Scene(),
***REMOVED******REMOVED***cameraController: CameraController = TransformationMatrixCameraController(),
***REMOVED******REMOVED***timeExtent: Binding<TimeExtent?>? = nil,
***REMOVED******REMOVED***graphicsOverlays: [GraphicsOverlay] = [],
***REMOVED******REMOVED***analysisOverlays: [AnalysisOverlay] = [],
***REMOVED******REMOVED***spaceEffect: SceneView.SpaceEffect = .stars,
***REMOVED******REMOVED***atmosphereEffect: SceneView.AtmosphereEffect = .off,
***REMOVED******REMOVED***isAttributionBarHidden: Bool = false,
***REMOVED******REMOVED***viewDrawingMode: ViewDrawingMode = .automatic
***REMOVED***) {
***REMOVED******REMOVED***model = .init(
***REMOVED******REMOVED******REMOVED***scene: scene,
***REMOVED******REMOVED******REMOVED***cameraController: cameraController,
***REMOVED******REMOVED******REMOVED***graphicsOverlays: graphicsOverlays,
***REMOVED******REMOVED******REMOVED***analysisOverlays: analysisOverlays,
***REMOVED******REMOVED******REMOVED***spaceEffect: spaceEffect,
***REMOVED******REMOVED******REMOVED***atmosphereEffect: atmosphereEffect,
***REMOVED******REMOVED******REMOVED***isAttributionBarHidden: isAttributionBarHidden,
***REMOVED******REMOVED******REMOVED***viewDrawingMode: viewDrawingMode
***REMOVED******REMOVED***)
***REMOVED******REMOVED***
***REMOVED******REMOVED***super.init(rootView: HostedView(model: model))
***REMOVED***
***REMOVED***
***REMOVED***required dynamic init?(coder aDecoder: NSCoder) {
***REMOVED******REMOVED***fatalError("init(coder:) has not been implemented")
***REMOVED***
***REMOVED***
***REMOVED***var scene: ArcGIS.Scene {
***REMOVED******REMOVED***get { model.scene ***REMOVED***
***REMOVED******REMOVED***set { model.scene = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var cameraController: CameraController {
***REMOVED******REMOVED***get { model.cameraController ***REMOVED***
***REMOVED******REMOVED***set { model.cameraController = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var timeExtent: TimeExtent? {
***REMOVED******REMOVED***get { model.timeExtent ***REMOVED***
***REMOVED******REMOVED***set { model.timeExtent = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var graphicsOverlays: [GraphicsOverlay] {
***REMOVED******REMOVED***get { model.graphicsOverlays ***REMOVED***
***REMOVED******REMOVED***set { model.graphicsOverlays = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var analysisOverlays: [AnalysisOverlay] {
***REMOVED******REMOVED***get { model.analysisOverlays ***REMOVED***
***REMOVED******REMOVED***set { model.analysisOverlays = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var spaceEffect: SceneView.SpaceEffect {
***REMOVED******REMOVED***get { model.spaceEffect ***REMOVED***
***REMOVED******REMOVED***set { model.spaceEffect = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var atmosphereEffect: SceneView.AtmosphereEffect {
***REMOVED******REMOVED***get { model.atmosphereEffect ***REMOVED***
***REMOVED******REMOVED***set { model.atmosphereEffect = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var isAttributionBarHidden: Bool {
***REMOVED******REMOVED***get { model.isAttributionBarHidden ***REMOVED***
***REMOVED******REMOVED***set { model.isAttributionBarHidden = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***var viewDrawingMode: ViewDrawingMode {
***REMOVED******REMOVED***get { model.viewDrawingMode ***REMOVED***
***REMOVED******REMOVED***set { model.viewDrawingMode = newValue ***REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***func draw() {
***REMOVED******REMOVED***model.sceneViewProxy?.draw()
***REMOVED***
***REMOVED***
***REMOVED***func setFieldOfViewFromLensIntrinsics(
***REMOVED******REMOVED***xFocalLength: Float,
***REMOVED******REMOVED***yFocalLength: Float,
***REMOVED******REMOVED***xPrincipal: Float,
***REMOVED******REMOVED***yPrincipal: Float,
***REMOVED******REMOVED***xImageSize: Float,
***REMOVED******REMOVED***yImageSize: Float,
***REMOVED******REMOVED***deviceOrientation: UIDeviceOrientation
***REMOVED***) {
***REMOVED******REMOVED***model.sceneViewProxy?.setFieldOfViewFromLensIntrinsics(
***REMOVED******REMOVED******REMOVED***xFocalLength: xFocalLength,
***REMOVED******REMOVED******REMOVED***yFocalLength: yFocalLength,
***REMOVED******REMOVED******REMOVED***xPrincipal: xPrincipal,
***REMOVED******REMOVED******REMOVED***yPrincipal: yPrincipal,
***REMOVED******REMOVED******REMOVED***xImageSize: xImageSize,
***REMOVED******REMOVED******REMOVED***yImageSize: yImageSize,
***REMOVED******REMOVED******REMOVED***deviceOrientation: deviceOrientation
***REMOVED******REMOVED***)
***REMOVED***
***REMOVED***

extension ArcGISSceneViewController {
***REMOVED***struct HostedView: View {
***REMOVED******REMOVED***@ObservedObject private var model: HostedViewModel
***REMOVED******REMOVED***
***REMOVED******REMOVED***fileprivate init(model: HostedViewModel) {
***REMOVED******REMOVED******REMOVED***self.model = model
***REMOVED***
***REMOVED******REMOVED***
***REMOVED******REMOVED***var body: some View {
***REMOVED******REMOVED******REMOVED***SceneViewReader { proxy in
***REMOVED******REMOVED******REMOVED******REMOVED***ArcGIS.SceneView(
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***scene: model.scene,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***cameraController: model.cameraController,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***timeExtent: $model.timeExtent,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***graphicsOverlays: model.graphicsOverlays,
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***analysisOverlays: model.analysisOverlays
***REMOVED******REMOVED******REMOVED******REMOVED***)
***REMOVED******REMOVED******REMOVED******REMOVED***.spaceEffect(model.spaceEffect)
***REMOVED******REMOVED******REMOVED******REMOVED***.atmosphereEffect(model.atmosphereEffect)
***REMOVED******REMOVED******REMOVED******REMOVED***.attributionBarHidden(model.isAttributionBarHidden)
***REMOVED******REMOVED******REMOVED******REMOVED***.viewDrawingMode(model.viewDrawingMode)
***REMOVED******REMOVED******REMOVED******REMOVED***.onAppear {
***REMOVED******REMOVED******REMOVED******REMOVED******REMOVED***self.model.sceneViewProxy = proxy
***REMOVED******REMOVED******REMOVED***
***REMOVED******REMOVED******REMOVED******REMOVED***.ignoresSafeArea()
***REMOVED******REMOVED***
***REMOVED***
***REMOVED***
***REMOVED***

@MainActor
private class HostedViewModel: ObservableObject {
***REMOVED***var sceneViewProxy: SceneViewProxy?
***REMOVED***
***REMOVED***@Published var scene: ArcGIS.Scene
***REMOVED***@Published var cameraController: CameraController
***REMOVED***@Published var timeExtent: TimeExtent?
***REMOVED***@Published var graphicsOverlays: [GraphicsOverlay]
***REMOVED***@Published var analysisOverlays: [AnalysisOverlay]
***REMOVED***@Published var spaceEffect: SceneView.SpaceEffect
***REMOVED***@Published var atmosphereEffect: SceneView.AtmosphereEffect
***REMOVED***@Published var isAttributionBarHidden: Bool
***REMOVED***@Published var viewDrawingMode: ViewDrawingMode
***REMOVED***
***REMOVED***
***REMOVED***init(
***REMOVED******REMOVED***scene: ArcGIS.Scene,
***REMOVED******REMOVED***cameraController: CameraController,
***REMOVED******REMOVED***timeExtent: TimeExtent? = nil,
***REMOVED******REMOVED***graphicsOverlays: [GraphicsOverlay],
***REMOVED******REMOVED***analysisOverlays: [AnalysisOverlay],
***REMOVED******REMOVED***spaceEffect: SceneView.SpaceEffect,
***REMOVED******REMOVED***atmosphereEffect: SceneView.AtmosphereEffect,
***REMOVED******REMOVED***isAttributionBarHidden: Bool,
***REMOVED******REMOVED***viewDrawingMode: ViewDrawingMode
***REMOVED***) {
***REMOVED******REMOVED***self.scene = scene
***REMOVED******REMOVED***self.cameraController = cameraController
***REMOVED******REMOVED***self.timeExtent = timeExtent
***REMOVED******REMOVED***self.graphicsOverlays = graphicsOverlays
***REMOVED******REMOVED***self.analysisOverlays = analysisOverlays
***REMOVED******REMOVED***self.spaceEffect = spaceEffect
***REMOVED******REMOVED***self.atmosphereEffect = atmosphereEffect
***REMOVED******REMOVED***self.isAttributionBarHidden = isAttributionBarHidden
***REMOVED******REMOVED***self.viewDrawingMode = viewDrawingMode
***REMOVED***
***REMOVED***
