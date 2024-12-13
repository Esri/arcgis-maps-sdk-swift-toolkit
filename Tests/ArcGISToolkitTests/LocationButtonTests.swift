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

import Testing
import ArcGIS
@testable import ArcGISToolkit

@Suite("LocationButton Tests")
struct LocationButtonTests {
    @Test
    @MainActor
    func testInit() async throws {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        
        do {
            let model = LocationButton.Model(
                locationDisplay: locationDisplay
            )
            
            #expect(model.locationDisplay === locationDisplay)
            #expect(model.autoPanOptions == [.compassNavigation, .off, .navigation, .recenter])
            #expect(model.lastSelectedAutoPanMode == .recenter)
        }
        
        do {
            let model = LocationButton.Model(
                locationDisplay: locationDisplay,
                autoPanOptions: [.recenter]
            )
            #expect(model.autoPanOptions == [.recenter])
            #expect(model.lastSelectedAutoPanMode == .recenter)
        }
        
        do {
            let model = LocationButton.Model(
                locationDisplay: locationDisplay,
                autoPanOptions: []
            )
            #expect(model.autoPanOptions == [])
            #expect(model.lastSelectedAutoPanMode == .off)
        }
        
        do {
            let model = LocationButton.Model(
                locationDisplay: locationDisplay,
                autoPanOptions: [.off, .recenter]
            )
            #expect(model.autoPanOptions == [.off, .recenter])
            #expect(model.lastSelectedAutoPanMode == .recenter)
        }
        
        do {
            let model = LocationButton.Model(
                locationDisplay: locationDisplay,
                autoPanOptions: [.off]
            )
            #expect(model.autoPanOptions == [.off])
            #expect(model.lastSelectedAutoPanMode == .off)
        }
    }
    
    @Test
    @MainActor
    func testSelectAutoPanMode() async throws {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        
        let model = LocationButton.Model(
            locationDisplay: locationDisplay
        )
        
        model.select(autoPanMode: .compassNavigation)
        #expect(model.locationDisplay.autoPanMode == .compassNavigation)
        #expect(model.lastSelectedAutoPanMode == .compassNavigation)
        
        model.select(autoPanMode: .off)
        #expect(model.locationDisplay.autoPanMode == .off)
        #expect(model.lastSelectedAutoPanMode == .compassNavigation)
    }
    
    @Test
    @MainActor
    func testButtonAction() async throws {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        
        let model = LocationButton.Model(locationDisplay: locationDisplay)
        
//        let observationTask = Task.detached { await model.observeStatus() }
//        try await Task.sleep(for: .seconds(1))
        
        //while model.status != .stopped { await Task.yield() }
        
//        #expect(model.status == .stopped)
//        #expect(model.buttonIsDisabled == false)
        
        let ds = model.locationDisplay.dataSource
        #expect(ds is MockLocationDataSource)
//        let ds = MockLocationDataSource()
        try await ds.start()
        try await Task.sleep(nanoseconds: 1_000_000)
        #expect(ds.status == .started)
        
//        model.buttonAction()
//        try await Task.sleep(for: .seconds(5))
//        #expect(model.status == .started)
        
//        observationTask.cancel()
    }
    
    @Test
    @MainActor
    func testLDS() async throws {
        let ds = MockLocationDataSource()
        try await ds.start()
        #expect(ds.status == .started)
    }
}

private typealias MockLocationDataSource = CustomLocationDataSource<MockLocationProvider>

extension MockLocationDataSource {
    convenience init() {
        self.init { MockLocationProvider() }
    }
}

private struct MockLocationProvider: LocationProvider {
    var locations: AsyncThrowingStream<Location, Error> {
        .init {
            print("-- here...")
//            return nil
            try await Task.sleep(for: .milliseconds(100))
            return .init(
                position: .init(latitude: 10, longitude: 10),
                horizontalAccuracy: 10,
                verticalAccuracy: 10,
                speed: 10,
                course: 0
            )
        }
    }
    
    var headings: AsyncThrowingStream<Double, Error> {
        .init {
            try await Task.sleep(for: .milliseconds(100))
            return 0
        }
    }
}
