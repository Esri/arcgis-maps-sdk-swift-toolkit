import ArcGIS
import ArcGISToolkit
import SwiftUI

struct ClassificationViewExample: View {
    @State private var map = {
        let portal = Portal(
            url: URL(string: "<#Portal URL#>")!,
            connection: .authenticated
        )
        let portalItem = PortalItem(
            portal: portal,
            id: Item.ID(rawValue: "<#Portal item ID#>")!
        )
        return Map(item: portalItem)
    }()

    var body: some View {
        MapView(map: map)
            .classification(portalItem: map.item as? PortalItem)
    }
}
