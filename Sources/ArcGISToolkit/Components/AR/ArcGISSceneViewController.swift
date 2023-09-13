//
//  File.swift
//  
//
//  Created by Ryan Olson on 9/13/23.
//

import Foundation
import UIKit
import SwiftUI
import ArcGIS

@MainActor
class ArcGISSceneViewController: UIHostingController<ArcGISSceneViewController.HostedView> {
    private let model: ViewModel
    
    init(
        scene: ArcGIS.Scene = Scene(),
        cameraController: CameraController = TransformationMatrixCameraController(),
        timeExtent: Binding<TimeExtent?>? = nil,
        graphicsOverlays: [GraphicsOverlay] = [],
        analysisOverlays: [AnalysisOverlay] = [],
        spaceEffect: SceneView.SpaceEffect = .stars,
        atmosphereEffect: SceneView.AtmosphereEffect = .off,
        isAttributionBarHidden: Bool = false,
        viewDrawingMode: ViewDrawingMode = .automatic
    ) {
        model = .init(
            scene: scene,
            cameraController: cameraController,
            graphicsOverlays: graphicsOverlays,
            analysisOverlays: analysisOverlays,
            spaceEffect: spaceEffect,
            atmosphereEffect: atmosphereEffect,
            isAttributionBarHidden: isAttributionBarHidden,
            viewDrawingMode: viewDrawingMode
        )
        
        super.init(rootView: HostedView(model: model))
    }
    
    var scene: ArcGIS.Scene {
        get { model.scene }
        set { model.scene = newValue }
    }
    
    var cameraController: CameraController {
        get { model.cameraController }
        set { model.cameraController = newValue }
    }
    
    var timeExtent: TimeExtent? {
        get { model.timeExtent }
        set { model.timeExtent = newValue }
    }
    
    var graphicsOverlays: [GraphicsOverlay] {
        get { model.graphicsOverlays }
        set { model.graphicsOverlays = newValue }
    }
    
    var analysisOverlays: [AnalysisOverlay] {
        get { model.analysisOverlays }
        set { model.analysisOverlays = newValue }
    }
    
    var spaceEffect: SceneView.SpaceEffect {
        get { model.spaceEffect }
        set { model.spaceEffect = newValue }
    }
    
    var atmosphereEffect: SceneView.AtmosphereEffect {
        get { model.atmosphereEffect }
        set { model.atmosphereEffect = newValue }
    }
    
    var isAttributionBarHidden: Bool {
        get { model.isAttributionBarHidden }
        set { model.isAttributionBarHidden = newValue }
    }
    
    var viewDrawingMode: ViewDrawingMode {
        get { model.viewDrawingMode }
        set { model.viewDrawingMode = newValue }
    }
    
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ArcGISSceneViewController {
    struct HostedView: View {
        @ObservedObject private var model: ViewModel
        
        fileprivate init(model: ViewModel) {
            self.model = model
        }
        
        var body: some View {
            SceneViewReader { proxy in
                ArcGIS.SceneView(
                    scene: model.scene,
                    cameraController: model.cameraController,
                    timeExtent: $model.timeExtent,
                    graphicsOverlays: model.graphicsOverlays,
                    analysisOverlays: model.analysisOverlays
                )
                .spaceEffect(model.spaceEffect)
                .atmosphereEffect(model.atmosphereEffect)
                .attributionBarHidden(model.isAttributionBarHidden)
                .viewDrawingMode(model.viewDrawingMode)
                .onAppear {
                    self.model.sceneViewProxy = proxy
                }
                .ignoresSafeArea()
            }
        }
    }
}

@MainActor
private class ViewModel: ObservableObject {
    var sceneViewProxy: SceneViewProxy?
    
    @Published var scene: ArcGIS.Scene
    @Published var cameraController: CameraController
    @Published var timeExtent: TimeExtent?
    @Published var graphicsOverlays: [GraphicsOverlay]
    @Published var analysisOverlays: [AnalysisOverlay]
    @Published var spaceEffect: SceneView.SpaceEffect
    @Published var atmosphereEffect: SceneView.AtmosphereEffect
    @Published var isAttributionBarHidden: Bool
    @Published var viewDrawingMode: ViewDrawingMode
    
    
    init(
        scene: ArcGIS.Scene,
        cameraController: CameraController,
        timeExtent: TimeExtent? = nil,
        graphicsOverlays: [GraphicsOverlay],
        analysisOverlays: [AnalysisOverlay],
        spaceEffect: SceneView.SpaceEffect,
        atmosphereEffect: SceneView.AtmosphereEffect,
        isAttributionBarHidden: Bool,
        viewDrawingMode: ViewDrawingMode
    ) {
        self.scene = scene
        self.cameraController = cameraController
        self.timeExtent = timeExtent
        self.graphicsOverlays = graphicsOverlays
        self.analysisOverlays = analysisOverlays
        self.spaceEffect = spaceEffect
        self.atmosphereEffect = atmosphereEffect
        self.isAttributionBarHidden = isAttributionBarHidden
        self.viewDrawingMode = viewDrawingMode
    }
}

/*
 
 .spaceEffect(.transparent)
 .atmosphereEffect(.off)
 .attributionBarHidden(true)
 .viewDrawingMode(.manual)
 */
