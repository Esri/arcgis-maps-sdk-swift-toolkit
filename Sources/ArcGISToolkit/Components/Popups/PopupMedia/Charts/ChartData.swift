// Copyright 2022 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import ArcGIS

internal struct ChartData: Identifiable {
    var label: String
    var value: Double
    var id = UUID()
    
    init(label: String, value: Any) {
        self.label = label
        if let int32 = value as? Int32 {
            self.value = Double(int32)
        } else if let int = value as? Int {
            self.value = Double(int)
        } else if let float = value as? Float {
            self.value = Double(float)
        } else if let double = value as? Double {
            self.value = double
        } else {
            self.value = 0
        }
    }
    
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
