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
import os

@Suite("LocationButton Tests")
struct LocationButtonTests {
    @Test
    @MainActor
    func testInit() {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        let button = LocationButton(locationDisplay: locationDisplay)
        
        #expect(button.locationDisplay === locationDisplay)
        #expect(button.autoPanOptions == [.recenter, .compassNavigation, .navigation, .off])
        #expect(button.status == .stopped)
        #expect(button.autoPanMode == .off)
        #expect(button.buttonIsDisabled)
        #expect(button.initialAutoPanMode == .recenter)
        #expect(button.contextMenuAutoPanOptions == [.off, .recenter, .compassNavigation, .navigation])
    }
    
    @Test
    @MainActor
    func testAutoPanOptions() {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        var button = LocationButton(locationDisplay: locationDisplay)
        
        button = button.autoPanOptions([.off])
        #expect(button.autoPanMode == .off)
        #expect(button.initialAutoPanMode == .off)
        #expect(button.contextMenuAutoPanOptions == [.off])
        
        // Test that we make the options unique
        button = button.autoPanOptions([.off, .off, .recenter, .off])
        #expect(button.autoPanOptions == [.off, .recenter])
        #expect(button.autoPanMode == .off)
        #expect(button.initialAutoPanMode == .off)
        #expect(button.contextMenuAutoPanOptions == [.off, .recenter])
        
        // Test when `.off` is last
        button = button.autoPanOptions([.recenter, .compassNavigation, .off])
        #expect(button.autoPanOptions == [.recenter, .compassNavigation, .off])
        // Still `.off` because the location display hasn't been started.
        #expect(button.autoPanMode == .off)
        #expect(button.initialAutoPanMode == .recenter)
        #expect(button.contextMenuAutoPanOptions == [.off, .recenter, .compassNavigation])
        // Still `.recenter` because the location display hasn't been started.
    }
    
    @Test
    @MainActor
    func testHideLocationDisplay() async throws {
        let datasource = MockLocationDataSource()
        let locationDisplay = LocationDisplay(dataSource: datasource)
        try await datasource.start()
        #expect(datasource.status == .started || datasource.status == .starting)
        let button = LocationButton(locationDisplay: locationDisplay)
        await button.hideLocationDisplay()
        #expect(locationDisplay.dataSource.status == .stopped || locationDisplay.dataSource.status == .stopping)
    }
    
    @Test
    @MainActor
    func testNextAutoPanMode() {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        var button = LocationButton(locationDisplay: locationDisplay)
        
        button = button.autoPanOptions([.off])
        #expect(button.nextAutoPanMode(current: .off, initial: .off) == .off)
        
        // Test circular cycle.
        button = button.autoPanOptions([.off, .recenter])
        #expect(button.nextAutoPanMode(current: .off, initial: .off) == .recenter)
        
        // Test when `.off` is last
        button = button.autoPanOptions([.recenter, .compassNavigation, .navigation, .off])
        #expect(button.nextAutoPanMode(current: .compassNavigation, initial: .recenter) == .navigation)
    }
    
    @Test
    @MainActor
    func testButtonAction() {
        #expect(
            LocationButton.Action(status: .stopped, autoPanOptions: []) == .start
        )
        #expect(
            LocationButton.Action(status: .failedToStart, autoPanOptions: []) == .start
        )
        #expect(
            LocationButton.Action(status: .started, autoPanOptions: []) == .stop
        )
        #expect(
            LocationButton.Action(status: .started, autoPanOptions: [.off]) == .stop
        )
        #expect(
            LocationButton.Action(status: .started, autoPanOptions: [.recenter]) == .stop
        )
        #expect(
            LocationButton.Action(status: .started, autoPanOptions: [.off, .recenter]) == .autoPanCycle
        )
        #expect(
            LocationButton.Action(status: .started, autoPanOptions: [.off, .recenter, .compassNavigation]) == .autoPanCycle
        )
        #expect(
            LocationButton.Action(status: .starting, autoPanOptions: []) == nil
        )
        #expect(
            LocationButton.Action(status: .stopping, autoPanOptions: []) == nil
        )
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
        .init { nil }
    }
    
    var headings: AsyncThrowingStream<Double, Error> {
        .init { nil }
    }
}
