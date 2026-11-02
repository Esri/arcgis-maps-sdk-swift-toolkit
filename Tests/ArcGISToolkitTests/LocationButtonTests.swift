// Copyright 2025 Esri
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
import Testing

@Suite("LocationButton Tests")
@MainActor
struct LocationButtonTests {
    @Test
    func initializer() {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        let button = LocationButton(locationDisplay: locationDisplay)
        
        #expect(button.locationDisplay === locationDisplay)
        #expect(button.status == .stopped)
        #expect(button.autoPanMode == .off)
        #expect(button.buttonIsDisabled == false)
        #expect(button.allowsHidingLocationDisplay)
        #expect(button.initialAutoPanMode == .recenter)
#if os(visionOS)
        #expect(button.autoPanModes == [.recenter, .off])
        #expect(button.contextMenuAutoPanOptions == [.off, .recenter])
#else
        #expect(button.autoPanModes == [.recenter, .compassNavigation, .off])
        #expect(button.contextMenuAutoPanOptions == [.off, .recenter, .compassNavigation])
#endif
    }
    
    @Test
    func autoPanModes() {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        var button = LocationButton(locationDisplay: locationDisplay)
        
        button = button.autoPanModes([.off])
        #expect(button.autoPanMode == .off)
        #expect(button.initialAutoPanMode == .off)
        #expect(button.contextMenuAutoPanOptions == [.off])
        
        // Test that we make the options unique
        button = button.autoPanModes([.off, .off, .recenter, .off])
        #expect(button.autoPanModes == [.off, .recenter])
        #expect(button.autoPanMode == .off)
        #expect(button.initialAutoPanMode == .off)
        #expect(button.contextMenuAutoPanOptions == [.off, .recenter])
        
        // Test when `off` is last
        button = button.autoPanModes([.recenter, .off])
        #expect(button.autoPanModes == [.recenter, .off])
        // Still `off` because the location display hasn't been started.
        #expect(button.autoPanMode == .off)
        #expect(button.initialAutoPanMode == .recenter)
        #expect(button.contextMenuAutoPanOptions == [.off, .recenter])
        // Still `.recenter` because the location display hasn't been started.
    }
    
    @Test
    func allowsHidingLocationDisplay() {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())

        let buttonWithHide = LocationButton(locationDisplay: locationDisplay)
            .autoPanModes([.navigation])
        let buttonWithoutHide = LocationButton(locationDisplay: locationDisplay)
            .autoPanModes([.navigation])
            .allowsHidingLocationDisplay(false)
        let buttonWithTwoModes = LocationButton(locationDisplay: locationDisplay)
            .autoPanModes([.recenter, .navigation])
            .allowsHidingLocationDisplay(false)
        let buttonWithNoModes = LocationButton(locationDisplay: locationDisplay)
            .autoPanModes([])
        let buttonWithOffOnly = LocationButton(locationDisplay: locationDisplay)
            .autoPanModes([.off])

        #expect(buttonWithHide.allowsHidingLocationDisplay)
        #expect(buttonWithHide.shouldShowContextMenu)
        #expect(buttonWithHide.contextMenuAutoPanOptions == [.navigation])
        #expect(!buttonWithoutHide.allowsHidingLocationDisplay)
        #expect(!buttonWithoutHide.shouldShowContextMenu)
        #expect(buttonWithTwoModes.shouldShowContextMenu)
        #expect(buttonWithNoModes.shouldShowContextMenu)
        #expect(buttonWithNoModes.contextMenuAutoPanOptions.isEmpty)
        #expect(buttonWithOffOnly.shouldShowContextMenu)
        #expect(buttonWithOffOnly.contextMenuAutoPanOptions == [.off])
    }

    @Test
    func hideLocationDisplay() async throws {
        let datasource = MockLocationDataSource()
        let locationDisplay = LocationDisplay(dataSource: datasource)
        try await datasource.start()
        #expect(datasource.status == .started || datasource.status == .starting)
        let button = LocationButton(locationDisplay: locationDisplay)
        await button.hideLocationDisplay()
        #expect(locationDisplay.dataSource.status == .stopped || locationDisplay.dataSource.status == .stopping)
    }
    
    @Test
    func nextAutoPanMode() {
        let locationDisplay = LocationDisplay(dataSource: MockLocationDataSource())
        var button = LocationButton(locationDisplay: locationDisplay)
        
        button = button.autoPanModes([.off])
        #expect(button.nextAutoPanMode(current: .off, initial: .off) == .off)
        
        // Test circular cycle.
        button = button.autoPanModes([.off, .recenter])
        #expect(button.nextAutoPanMode(current: .off, initial: .off) == .recenter)
        
        // Test when `off` is last
        button = button.autoPanModes([.recenter, .navigation, .off])
        #expect(button.nextAutoPanMode(current: .navigation, initial: .recenter) == .off)
    }
    
    @Suite
    @MainActor
    struct ActionTests {
        typealias Action = LocationButton.Action
        
        @Test
        func initializer() {
            #expect(
                Action(
                    status: .stopped,
                    autoPanMode: .off,
                    autoPanOptions: []
                ) == .start
            )
            #expect(
                Action(
                    status: .failedToStart,
                    autoPanMode: .off,
                    autoPanOptions: []
                ) == .start
            )
            #expect(
                Action(
                    status: .started,
                    autoPanMode: .off,
                    autoPanOptions: []
                ) == nil
            )
            #expect(
                Action(
                    status: .started,
                    autoPanMode: .off,
                    autoPanOptions: [.off]
                ) == nil
            )
            #expect(
                Action(
                    status: .started,
                    autoPanMode: .off,
                    autoPanOptions: [.navigation]
                ) == .autoPanCycle
            )
            #expect(
                Action(
                    status: .started,
                    autoPanMode: .navigation,
                    autoPanOptions: [.navigation]
                ) == nil
            )
            #expect(
                Action(
                    status: .started,
                    autoPanMode: .navigation,
                    autoPanOptions: [.off]
                ) == .autoPanCycle
            )
            #expect(
                Action(
                    status: .started,
                    autoPanMode: .recenter,
                    autoPanOptions: [.recenter, .navigation]
                ) == .autoPanCycle
            )
            #expect(
                Action(
                    status: .starting,
                    autoPanMode: .off,
                    autoPanOptions: []
                ) == nil
            )
            #expect(
                Action(
                    status: .stopping,
                    autoPanMode: .off,
                    autoPanOptions: []
                ) == nil
            )
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
        .init { nil }
    }
    
    var headings: AsyncThrowingStream<Double, Error> {
        .init { nil }
    }
}
