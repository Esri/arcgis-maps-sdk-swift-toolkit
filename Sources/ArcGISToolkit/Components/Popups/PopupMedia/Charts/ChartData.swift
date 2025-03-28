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
    /// A chart color to be used for the data.
    let color: UIColor
    let id = UUID()
    
    /// Creates a `ChartData`.
    /// - Parameters:
    ///   - label: The label for the data.
    ///   - value: The value of the data.
    init(label: String, value: Any, color: UIColor) {
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
        self.color = color
    }
    
    /// Gets the chart data for a `PopupMedia`.
    /// - Parameter popupMedia: The popup media to get the data for.
    /// - Returns: The array of chart data for the popup media.
    static func getChartData(from popupMedia: PopupMedia) -> [ChartData] {
        guard let labels = popupMedia.value?.labels,
              let data = popupMedia.value?.data,
              let colors = popupMedia.value?.chartColors else { return [] }
        
        let chartData: [ChartData]
        let chartRawData = zip(labels, data).map { ($0, $1) }
        if popupMedia.kind == .lineChart, let color = colors.first {
            // When the popup media type is line chart, the first color
            // will be the line color and other colors are ignored.
            chartData = chartRawData.map {
                ChartData(label: $0.0, value: $0.1, color: color)
            }
        } else {
            var paddedColors = colors
            if paddedColors.count > labels.count {
                // Ignores the additional colors when the color array is
                // longer than field labels.
                paddedColors.removeLast(colors.count - labels.count)
            } else if colors.count < labels.count {
                // Uses a fallback color ramp when the color array is
                // shorter than field labels.
                for i in 0 ..< labels.count - colors.count {
                    paddedColors += [color(for: i)]
                }
            }
            chartData = zip(chartRawData, paddedColors).map {
                ChartData(label: $0.0, value: $0.1, color: $1)
            }
        }
        return chartData
    }
    
    /// The pre-defined colors for a color ramp.
    private static let rampColors: [UIColor] = [
        .systemMint,
        .systemTeal,
        .systemGreen,
        .systemCyan,
        .systemYellow,
        .systemBlue,
        .systemOrange,
        .systemIndigo,
        .systemRed,
        .systemPurple,
        .systemPink,
        .systemBrown
    ]
    
    /// Calculates a color for the given index.
    /// - Parameter index: The index of an element in color ramp array.
    /// - Returns: The color for the element at `index`.
    private static func color(for index: Int) -> UIColor {
        // We don't want to just wrap color indices because we don't want
        // two adjacent slices to have the same color. "extra" will skip the
        // the 1st color for the second time through the list, skip the 2nd
        // color the third time through the list, etc., ensuring that we
        // don't get adjacent colors.
        let extra = index / rampColors.count
        return rampColors[(index + extra) % rampColors.count]
    }
}
