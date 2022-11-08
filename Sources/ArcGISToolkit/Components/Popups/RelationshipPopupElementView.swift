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

/// A view displaying a `RelationshipPopupElement`.
struct RelationshipPopupElementView: View {
    /// The `PopupElement` to display.
    var popupElement: RelationshipPopupElement
    
    @StateObject private var viewModel: RelationshipPopupElementModel
    
    init(popupElement: RelationshipPopupElement, geoElement: GeoElement) {
        self.popupElement = popupElement
        
        _viewModel = StateObject(
            wrappedValue: RelationshipPopupElementModel(
                feature: geoElement as? ArcGISFeature,
                popupElement: popupElement
            )
        )
    }
    
    @State var isExpanded: Bool = true
    
    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            relatedFeaturesView
        } label: {
            VStack(alignment: .leading) {
                PopupElementHeader(
                    title: popupElement.title,
                    description: popupElement.description
                )
                Divider()
            }
        }
    }
    
    @ViewBuilder private var relatedFeaturesView: some View {
        if #available(iOS 16.0, *) {
            ForEach(viewModel.displayedPopups, id:\Popup.self) { popup in
                NavigationLink(value: popup) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(popup.title)
                                .foregroundColor(.primary)
                            if let text = popupElement.relatedPopupDescription(popup: popup) {
                                Text(text)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Divider()
            if viewModel.relatedPopups.count > 0/*popupElement.displayCount*/ {
                NavigationLink(value: viewModel.relatedPopups) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Show All")
                                .foregroundColor(.primary)
                            Text("\(viewModel.relatedPopups.count) records")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Divider()
            }
        }
    }
}

extension Popup: Equatable {
    public static func == (lhs: Popup, rhs: Popup) -> Bool {
        lhs === rhs
    }
}

extension Popup: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
