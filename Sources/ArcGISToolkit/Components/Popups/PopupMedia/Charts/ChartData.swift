// Copyright 2022 Esri
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

import SwiftUI
import ArcGIS

/// Data for a chart, representing a label and value pair.
struct ChartData: Identifiable {
    /// A label for the data.
    let label: String
    /// The value of the data.
    let value: Double
    let id = UUID()
    
    /// Creates a `ChartData`.
    /// - Parameters:
    ///   - label: The label for the data.
    ///   - value: The value of the data.
    init(label: String, value: Any) {
        self.label = label
        if let int = value as? Int {
            self.value = Double(int)
        } else if let float = value as? Float {
            self.value = Double(float)
        } else if let double = value as? Double {
            self.value = double
        } else {
            self.value = 0
        }
    }
    
    /// Gets the chart data for a `PopupMedia`.
    /// - Parameter popupMedia: The popup media to get the data for.
    /// - Returns: The array of chart data for the popup media.
    static func getChartData(from popupMedia: PopupMedia) -> [ChartData] {
        guard let labels = popupMedia.value?.labels,
              let data = popupMedia.value?.data else { return [] }
        
        let chartRawData = zip(labels, data).map { ($0, $1) }
        let chartData = chartRawData.map {
            ChartData(label: $0.0, value: $0.1)
        }
        
        return chartData
    }
}
