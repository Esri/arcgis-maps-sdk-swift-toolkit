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
    func testInit() {
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
    func testSelectAutoPanMode() {
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
    func testActionForButtonPress() async throws {
        do {
            let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
            let model = LocationButton.Model(locationDisplay: locationDisplay)
            #expect(model.actionForButtonPress == .start)
        }
        
        do {
            let ds = MockLocationDataSource()
            try await ds.start()
            let locationDisplay = LocationDisplay(dataSource: ds)
            let model = LocationButton.Model(locationDisplay: locationDisplay)
            let observation = Task { await model.observeStatus() }
            while model.status != .started { await Task.yield() }
            #expect(model.actionForButtonPress == .autoPanOn)
            observation.cancel()
        }
        
        do {
            let ds = MockLocationDataSource()
            try await ds.start()
            let locationDisplay = LocationDisplay(dataSource: ds)
            locationDisplay.autoPanMode = .navigation
            let model = LocationButton.Model(locationDisplay: locationDisplay)
            let observation = Task { await model.observeStatus() }
            while model.status != .started { await Task.yield() }
            #expect(model.actionForButtonPress == .autoPanOff)
            observation.cancel()
        }
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
        .init { return nil }
    }
    
    var headings: AsyncThrowingStream<Double, Error> {
        .init { return nil }
    }
}
