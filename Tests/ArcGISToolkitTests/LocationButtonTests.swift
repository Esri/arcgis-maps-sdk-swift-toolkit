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
        let model = LocationButton.Model(locationDisplay: locationDisplay)
        
        #expect(model.locationDisplay === locationDisplay)
        #expect(model.autoPanOptions.isEmpty)
        #expect(model.status == .stopped)
        #expect(model.autoPanMode == .off)
        #expect(model.buttonIsDisabled)
        #expect(model.nonOffAutoPanOptions.isEmpty)
        #expect(model.initialAutoPanMode == .off)
        #expect(model.contextMenuAutoPanOptions.isEmpty)
        #expect(model.nextAutoPanMode == .off)
    }
    
    @Test
    @MainActor
    func testAutoPanOptions() {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        let model = LocationButton.Model(locationDisplay: locationDisplay)
        
        model.autoPanOptions = [.off]
        #expect(model.autoPanOptions == [.off])
        #expect(model.autoPanMode == .off)
        #expect(model.nonOffAutoPanOptions.isEmpty)
        #expect(model.initialAutoPanMode == .off)
        #expect(model.contextMenuAutoPanOptions == [.off])
        #expect(model.nextAutoPanMode == .off)
        
        // Test that we make the options unique
        model.autoPanOptions = [.off, .off, .recenter, .off]
        #expect(model.autoPanOptions == [.off, .recenter])
        #expect(model.autoPanMode == .off)
        #expect(model.nonOffAutoPanOptions == [.recenter])
        #expect(model.initialAutoPanMode == .off)
        #expect(model.contextMenuAutoPanOptions == [.off, .recenter])
        #expect(model.nextAutoPanMode == .recenter)
        
        // Test when `.off` is last
        model.autoPanOptions = [.recenter, .compassNavigation, .off]
        #expect(model.autoPanOptions == [.recenter, .compassNavigation, .off])
        // Still `.off` because the location display hasn't been started.
        #expect(model.autoPanMode == .off)
        #expect(model.nonOffAutoPanOptions == [.recenter, .compassNavigation])
        #expect(model.initialAutoPanMode == .recenter)
        #expect(model.contextMenuAutoPanOptions == [.off, .recenter, .compassNavigation])
        // Still `.recenter` because the location display hasn't been started.
        #expect(model.nextAutoPanMode == .recenter)
    }
    
    @Test
    @MainActor
    func testNextAutoPanMode() async throws {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        let model = LocationButton.Model(locationDisplay: locationDisplay)
        
        model.autoPanOptions = [.off]
        model.select(autoPanMode: .off)
        #expect(model.nextAutoPanMode == .off)
        
        // Test circular cycle.
        model.autoPanOptions = [.off, .off, .recenter, .off]
        model.select(autoPanMode: .recenter)
        #expect(model.nextAutoPanMode == .off)
        
        // Test when `.off` is last
        model.autoPanOptions = [.recenter, .compassNavigation, .navigation, .off]
        model.select(autoPanMode: .compassNavigation)
        #expect(model.nextAutoPanMode == .navigation)
    }
    
//    @Test
//    @MainActor
//    func testSelectAutoPanMode() {
//        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
//        
//        let model = LocationButton.Model(
//            locationDisplay: locationDisplay
//        )
//        
//        model.select(autoPanMode: .compassNavigation)
//        #expect(model.locationDisplay.autoPanMode == .compassNavigation)
//        #expect(model.lastSelectedAutoPanMode == .compassNavigation)
//        
//        model.select(autoPanMode: .off)
//        #expect(model.locationDisplay.autoPanMode == .off)
//        #expect(model.lastSelectedAutoPanMode == .compassNavigation)
//    }
//    
//    @Test
//    @MainActor
//    func testActionForButtonPress() async throws {
//        do {
//            let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
//            let model = LocationButton.Model(locationDisplay: locationDisplay)
//            #expect(model.actionForButtonPress == .start)
//        }
//        
//        do {
//            let ds = MockLocationDataSource()
//            try await ds.start()
//            let locationDisplay = LocationDisplay(dataSource: ds)
//            let model = LocationButton.Model(locationDisplay: locationDisplay)
//            let observation = Task { await model.observeStatus() }
//            while model.status != .started { await Task.yield() }
//            #expect(model.actionForButtonPress == .autoPanOn)
//            observation.cancel()
//        }
//        
//        do {
//            let ds = MockLocationDataSource()
//            try await ds.start()
//            let locationDisplay = LocationDisplay(dataSource: ds)
//            locationDisplay.autoPanMode = .navigation
//            let model = LocationButton.Model(locationDisplay: locationDisplay)
//            let observation = Task { await model.observeStatus() }
//            while model.status != .started { await Task.yield() }
//            #expect(model.actionForButtonPress == .autoPanOff)
//            observation.cancel()
//        }
//    }
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
        .init { return 0 }
    }
}
