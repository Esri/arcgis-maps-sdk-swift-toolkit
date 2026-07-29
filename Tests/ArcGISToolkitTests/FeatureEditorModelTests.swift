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
@testable import ArcGISToolkit
import Foundation
import Testing

@Suite("FeatureEditorModel Tests")
@MainActor
struct FeatureEditorModelTests {
    /// Verifies the model properties' default values.
    @Test
    func initializer() async {
        let model = FeatureEditorModel()
        await model.expectDefaultPropertyValues()
    }
    
    /// Verifies `isPresented` is `true` when editing and resets the model's properties when set
    /// to `false`.
    @Test
    func isPresented() async throws {
        let model = FeatureEditorModel()
        let monitorGeometryEditorStreamsTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorGeometryEditorStreamsTask.cancel() }
        
        let geodatabaseFile = try await TemporaryGeodatabaseFile()
        let table = try await geodatabaseFile.geodatabase.makeTable(description: .points)
        let geometry = Point(latitude: 0, longitude: 0)
        let feature = try #require(table.makeFeature(geometry: geometry) as? ArcGISFeature)
        
        // Verifies isPresented is true when feature editor starts.
        await model.startEditingFeature(feature, on: nil)
        model.expectIsEditing(rootFeature: feature)
        
        await model.expectIsGeometryEditing()
        await model.expectIsEditing(geometry: geometry)
        
        // Verifies setting isPresented to false resets the model's properties.
        model.isPresented = false
        await model.expectDefaultPropertyValues()
    }
    
    /// Verifies `monitorGeometryEditorStreams()` updates model properties
    /// when the geometry editor starts and stops.
    @Test
    func monitorGeometryEditorStreams() async {
        let model = FeatureEditorModel()
        let monitorTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorTask.cancel() }
        
        // Starts the geometry editor with a geometry.
        let geometry = Point(x: 0, y: 0)
        model.geometryEditor.start(withInitial: geometry)
        await Task.yieldExpect(model.geometryEditorIsStarted)
        await Task.yieldExpect(model.geometryEditorGeometry == geometry)
        await Task.yieldExpect(!model.geometryEditorCanUndo)
        
        // Stops the geometry editor.
        model.geometryEditor.stop()
        // Verifies the geometry editor properties have been reset and no other
        // properties have been modified.
        await model.expectDefaultPropertyValues()
    }
    
    /// Verifies `restartGeometryEditor()` restarts the geometry editor if it is started.
    @Test
    func restartGeometryEditor() async throws {
        let model = FeatureEditorModel()
        let monitorGeometryEditorStreamsTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorGeometryEditorStreamsTask.cancel() }
        
        // Verifies restartGeometryEditor does nothing if the geometry editor has not started.
        model.restartGeometryEditor()
        await model.expectDefaultPropertyValues()
        
        // Starts the feature editor.
        let geodatabaseFile = try await TemporaryGeodatabaseFile()
        let table = try await geodatabaseFile.geodatabase.makeTable(description: .points)
        let geometry = Point(latitude: 0, longitude: 0)
        let feature = try #require(table.makeFeature(geometry: geometry) as? ArcGISFeature)
        
        await model.startEditingFeature(feature, on: nil)
        await model.expectIsGeometryEditing()
        await model.expectIsEditing(geometry: geometry)
        
        // Verifies restartGeometryEditor restarts the geometry editor when it is started.
        let newGeometry = Point(latitude: 1, longitude: 1)
        feature.geometry = newGeometry
        
        model.restartGeometryEditor()
        await model.expectIsGeometryEditing()
        await model.expectIsEditing(geometry: newGeometry)
    }
    
    /// Verifies setup failure leads to loadResult failure, blocks editing,
    /// and `retryStartEditing()` clears the error on success.
    @Test
    func retryStartEditingAfterFailure() async throws {
        let model = FeatureEditorModel()
        let monitorGeometryEditorStreamsTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorGeometryEditorStreamsTask.cancel() }
        
        let geodatabaseFile = try await TemporaryGeodatabaseFile()
        let table = try await geodatabaseFile.geodatabase.makeTable(description: .points)
        let geometry = Point(latitude: 2, longitude: 2)
        let feature = try #require(table.makeFeature(geometry: geometry) as? ArcGISFeature)
        let map = Map(spatialReference: nil)
        
        // Simulates map fails to load by creating a map with nil spatial reference.
        await model.startEditingFeature(feature, on: map)
        let error = #expect(throws: MappingError.self) {
            try #require(model.loadResult).get()
        }
        #expect(error == .missingSpatialReference(details: ""))
        await Task.yieldExpect(!model.geometryEditorIsStarted)
        await Task.yieldExpect(model.geometryEditorGeometry == nil)
        
        // Sets the map's spatial reference to a valid value and retries starting the feature editor.
        map.setSpatialReference(.wgs84)
        await model.retryStartEditing()
        
        try #require(model.loadResult).get()
        await model.expectIsGeometryEditing()
        await model.expectIsEditing(geometry: geometry)
    }
    
    /// Verifies `startEditingFeature(_:on:)` and `startEditingFeatureForm(_:)` using
    /// features with geometries.
    @Test
    func startEditing() async throws {
        let model = FeatureEditorModel()
        let monitorGeometryEditorStreamsTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorGeometryEditorStreamsTask.cancel() }
        
        let geodatabaseFile = try await TemporaryGeodatabaseFile()
        let table = try await geodatabaseFile.geodatabase.makeTable(description: .points)
        
        // Verifies startEditingFeature(_:on:) starts the feature editor and geometry editor.
        do {
            let geometry = Point(latitude: 0, longitude: 0)
            let feature = try #require(table.makeFeature(geometry: geometry) as? ArcGISFeature)
            let map = Map(spatialReference: .wgs84)
            
            // Verifies feature editor is started using the feature instance.
            await model.startEditingFeature(feature, on: map)
            model.expectIsEditing(rootFeature: feature)
            
            // Verifies geometry editor is started using the feature's geometry.
            await model.expectIsGeometryEditing()
            await model.expectIsEditing(geometry: geometry)
            
            // Verifies map is loaded when starting.
            #expect(map.loadStatus == .loaded)
        }
        
        // Verifies startEditingFeatureForm(_:) updates the correct model properties.
        do {
            let geometry = Point(latitude: 1, longitude: 1)
            let feature = try #require(table.makeFeature(geometry: geometry) as? ArcGISFeature)
            let featureForm = FeatureForm(feature: feature)
            
            // Verifies feature editor uses the new feature instance.
            await model.startEditingFeatureForm(featureForm)
            #expect(model.feature === feature)
            
            // Verifies rootFeatureForm does not update.
            #expect(model.rootFeatureForm !== featureForm)
            #expect(model.rootFeatureForm?.feature !== feature)
            #expect(model.isPresented)
            
            // Verifies geometry editor uses the new geometry.
            await model.expectIsGeometryEditing()
            await model.expectIsEditing(geometry: geometry)
        }
    }
    
    /// Verifies `startEditingFeature(_:on:)` using a feature without a geometry.
    @Test
    func startEditingFeatureWithoutGeometry() async throws {
        let model = FeatureEditorModel()
        let monitorGeometryEditorStreamsTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorGeometryEditorStreamsTask.cancel() }
        
        let geodatabaseFile = try await TemporaryGeodatabaseFile()
        let table = try await geodatabaseFile.geodatabase.makeTable(description: .points)
        let feature = try #require(table.makeFeature() as? ArcGISFeature)
        #expect(feature.geometry == nil)
        
        // Verifies feature editor and geometry editor are started.
        await model.startEditingFeature(feature, on: nil)
        model.expectIsEditing(rootFeature: feature)
        await model.expectIsGeometryEditing()
        
        // Verifies geometry editor is using the table's geometry type.
        let modelGeometry = try #require(model.geometryEditorGeometry)
        #expect(modelGeometry is Point)
        #expect(modelGeometry.isEmpty)
        #expect(model.viewpointGeometry == nil)
    }
    
    /// Verifies `startEditingFeature(_:on:)` using a non-spatial feature.
    @Test
    func startEditingNonSpatialFeature() async throws {
        let model = FeatureEditorModel()
        let monitorGeometryEditorStreamsTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorGeometryEditorStreamsTask.cancel() }
        
        let geodatabaseFile = try await TemporaryGeodatabaseFile()
        let tableDescription = TableDescription(name: "NonSpatial")
        let table = try await geodatabaseFile.geodatabase.makeTable(description: tableDescription)
        
        let feature = try #require(table.makeFeature() as? ArcGISFeature)
        try await feature.load()
        #expect(!feature.canUpdateGeometry)
        
        // Verifies feature editor is started using the feature instance.
        await model.startEditingFeature(feature, on: nil)
        model.expectIsEditing(rootFeature: feature)
        
        // Geometry editor is not started.
        await Task.yieldExpect(!model.geometryEditorIsStarted)
        await Task.yieldExpect(model.geometryEditorGeometry == nil)
        await Task.yieldExpect(!model.geometryEditorCanUndo)
        #expect(model.viewpointGeometry == nil)
        #expect(!model.geometryEditor.snapSettings.isEnabled)
    }
    
    /// Verifies `stopEditing()` resets the model's properties to their default values.
    @Test
    func stopEditing() async throws {
        let model = FeatureEditorModel()
        let monitorGeometryEditorStreamsTask = Task(operation: model.monitorGeometryEditorStreams)
        defer { monitorGeometryEditorStreamsTask.cancel() }
        
        let geodatabaseFile = try await TemporaryGeodatabaseFile()
        let table = try await geodatabaseFile.geodatabase.makeTable(description: .points)
        let geometry = Point(latitude: 0, longitude: 0)
        let feature = try #require(table.makeFeature(geometry: geometry) as? ArcGISFeature)
        
        // Verifies feature editor and geometry editor are started.
        await model.startEditingFeature(feature, on: nil)
        model.expectIsEditing(rootFeature: feature)
        await model.expectIsGeometryEditing()
        await model.expectIsEditing(geometry: geometry)
        
        // Verifies stopEditing resets the model's properties.
        model.stopEditing()
        await model.expectDefaultPropertyValues()
    }
}

// MARK: Helper

private extension FeatureEditorModel {
    /// Verifies the model's properties have their default values.
    func expectDefaultPropertyValues(sourceLocation: SourceLocation = #_sourceLocation) async {
        #expect(feature == nil, sourceLocation: sourceLocation)
        #expect(!isPresented, sourceLocation: sourceLocation)
        #expect(rootFeatureForm == nil, sourceLocation: sourceLocation)
        #expect(loadResult == nil, sourceLocation: sourceLocation)
        #expect(!snapSettingsSheetIsPresented, sourceLocation: sourceLocation)
        #expect(viewpointGeometry == nil, sourceLocation: sourceLocation)
        
        // Yields to ensure geometry editor properties are updated by monitorGeometryEditorStreams().
        await Task.yieldExpect(!self.geometryEditorCanUndo, sourceLocation: sourceLocation)
        await Task.yieldExpect(self.geometryEditorGeometry == nil, sourceLocation: sourceLocation)
        await Task.yieldExpect(!self.geometryEditorIsStarted, sourceLocation: sourceLocation)
    }
    
    /// Verifies the model has started editing a given feature instance as the root feature.
    func expectIsEditing(
        rootFeature: ArcGISFeature,
        sourceLocation: SourceLocation = #_sourceLocation
    ) {
        #expect(feature === rootFeature, sourceLocation: sourceLocation)
        #expect(isPresented, sourceLocation: sourceLocation)
        #expect(rootFeatureForm?.feature === rootFeature, sourceLocation: sourceLocation)
        
        // Verifies starting loaded the feature.
        #expect(rootFeature.loadStatus == .loaded, sourceLocation: sourceLocation)
    }
    
    /// Verifies the model is editing a given geometry.
    func expectIsEditing(
        geometry: Geometry,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        await Task.yieldExpect(
            self.geometryEditorGeometry == geometry,
            sourceLocation: sourceLocation
        )
        
        // The geometry is used to set the viewpoint.
        #expect(viewpointGeometry == geometry, sourceLocation: sourceLocation)
    }
    
    /// Verifies the model's geometry editor has started.
    func expectIsGeometryEditing(sourceLocation: SourceLocation = #_sourceLocation) async {
        await Task.yieldExpect(self.geometryEditorIsStarted, sourceLocation: sourceLocation)
        
        // Verifies it started without any edits.
        await Task.yieldExpect(!self.geometryEditorCanUndo, sourceLocation: sourceLocation)
        
        // Verifies snap settings are enabled by default.
        #expect(geometryEditor.snapSettings.isEnabled, sourceLocation: sourceLocation)
    }
}

private extension TableDescription {
    /// A description for a table containing WGS84 points.
    static var points: TableDescription {
        TableDescription(name: "Points", spatialReference: .wgs84, geometryType: Point.self)
    }
}

private extension Task where Failure == Never, Success == Never {
    /// Yields until a condition is met or a timeout occurs and then verifies the condition is true.
    @MainActor
    static func yieldExpect(
        _ condition: @autoclosure @escaping @MainActor () -> Bool,
        sourceLocation: SourceLocation = #_sourceLocation
    ) async {
        // Timeout error is ignored since the condition is already verified in the expect below.
        try? await yield(timeout: 0.1, until: condition)
        #expect(condition(), sourceLocation: sourceLocation)
    }
}

/// A file containing a temporary mobile geodatabase.
private final class TemporaryGeodatabaseFile {
    /// The geodatabase contained in the file.
    let geodatabase: Geodatabase
    
    init() async throws {
        let temporaryDirectoryURL = try FileManager.default.url(
            for: .itemReplacementDirectory,
            in: .userDomainMask,
            appropriateFor: .temporaryDirectory,
            create: true
        )
        let temporaryGeodatabaseURL = temporaryDirectoryURL.appending(path: "temp.geodatabase")
        geodatabase = try await Geodatabase.createEmpty(fileURL: temporaryGeodatabaseURL)
    }
    
    deinit {
        geodatabase.close()
        let temporaryDirectoryURL = geodatabase.fileURL.deletingLastPathComponent()
        try? FileManager.default.removeItem(at: temporaryDirectoryURL)
    }
}
