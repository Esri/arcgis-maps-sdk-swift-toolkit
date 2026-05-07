// Copyright 2026 Esri
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
import Foundation

@MainActor
public enum _DebugSettings {}

public extension _DebugSettings {
    static let disabled = true
    
    // MARK: Feature Editor
    
    static var openFeatureEditor = disabled ? false : true
    static let featureEditorIdentifyPoint = Point(
        x: -9813064,
        y: 5130209,
        spatialReference: .webMercator
    )
    
    // MARK: Demo
    
    static var openDemo = disabled ? false : true
    static let demo = 2
    
    // MARK: Programmatic Reticle Demo
    
    static var startReticleDemo = disabled ? false : true
    static let reticleDemoGeometry = CGPoint(x: 267.5, y: 382.5)
    
    // MARK: Group and Preset Templates Demo
    
    static var startTemplatesDemo = disabled ? false : true
    
    static let openTemplatePicker = disabled ? false : true
    static let templatePickerSearch = disabled ? "" : "service"
    
    static var openTemplate = disabled ? false : true
    static let selectedGroupItem = "Pipeline Line"
    static let selectedTemplateItem = "Service Pipe Group (Tee-Valve-Meter)"
    
    static var addTemplateGeometry = disabled ? false : true
    static let templateGeometry = "{\"paths\":[[[-9810790.1490485538,5123470.000108473],[-9810795.5708231665,5123492.1209488912]]],\"spatialReference\":{\"wkid\":102100,\"latestWkid\":3857}}"
    
    // MARK: Editing Associations Demo
    
    static var openAssociationsDemo = disabled ? false : true
    static let associationsDemoGeometry = CGPoint(x: 461.0, y: 361.0)
}
