// Copyright 2023 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import ArcGIS
import XCTest
@testable import ArcGISToolkit

final class ViewpointTests: XCTestCase {
    func testWithRotation() async {
        let viewpoint = Viewpoint(center: .esriRedlands, scale: 15_000)
        let expectedViewpoint = viewpoint.withRotation(45)
        
        XCTAssertEqual(expectedViewpoint.rotation, 45)
        XCTAssertEqual(expectedViewpoint.targetScale, viewpoint.targetScale)
        XCTAssertEqual(expectedViewpoint.targetGeometry, viewpoint.targetGeometry)
    }
    
    func testWithRotationWithBoundingGeometry() {
        let rotatedViewpoint = Viewpoint(boundingGeometry: Polyline.simple.extent, rotation: -45)
        XCTAssertEqual(rotatedViewpoint.rotation, -45)
        
        let nonRotatedViewpoint = rotatedViewpoint.withRotation(.zero)
        XCTAssertEqual(nonRotatedViewpoint.rotation, 0)
        XCTAssertEqual(nonRotatedViewpoint.targetGeometry, rotatedViewpoint.targetGeometry)
    }
    
    func testWithRotationWithCenterAndScale() {
        let rotatedViewpoint = Viewpoint(center: .esriRedlands, scale: 1_000, rotation: 45)
        XCTAssertEqual(rotatedViewpoint.rotation, 45)
        
        let nonRotatedViewpoint = rotatedViewpoint.withRotation(.zero)
        XCTAssertEqual(nonRotatedViewpoint.rotation, 0)
        XCTAssertEqual(nonRotatedViewpoint.targetScale, rotatedViewpoint.targetScale)
        XCTAssertEqual(nonRotatedViewpoint.targetGeometry, rotatedViewpoint.targetGeometry)
    }
}

extension Point {
    static var esriRedlands: Point {
        .init(
            x: -117.19494,
            y: 34.05723,
            spatialReference: .wgs84
        )
    }
}

private extension Polyline {
    static var simple: Polyline {
        .init(points: [
            Point(x: -117, y: 34, spatialReference: .wgs84),
            Point(x: -116, y: 34, spatialReference: .wgs84),
            Point(x: -116, y: 33, spatialReference: .wgs84)
        ])
    }
}
