//
//  FloatingPanelExampleView.swift
//  Examples
//
//  Created by Mark Dostal on 12/16/21.
//

import SwiftUI
import ArcGISToolkit
import ArcGIS

struct FloatingPanelExampleView: View {
    let map = Map(basemapStyle: .arcGISImagery)

    var body: some View {
        FloatingPanel(content: MapView(map: map))
//        FloatingPanel(content: Rectangle().foregroundColor(.blue))
            .padding()
    }
}

struct FloatingPanelExampleView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingPanelExampleView()
    }
}
