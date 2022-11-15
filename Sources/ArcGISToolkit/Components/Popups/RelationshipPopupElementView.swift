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
@available(iOS 16, *)
struct RelationshipPopupElementView: View {
    /// The `PopupElement` to display.
    var popupElement: RelationshipPopupElement
    
    /// The view model for the view.
    @StateObject private var viewModel: RelationshipPopupElementModel
    
    /// Creates a `RelationshipPopupElementView`.
    /// - Parameters:
    ///   - popupElement: The popup element to display.
    ///   - geoElement: The geo element to display relationships for.
    init(popupElement: RelationshipPopupElement, geoElement: GeoElement) {
        self.popupElement = popupElement
        
        _viewModel = StateObject(
            wrappedValue: RelationshipPopupElementModel(
                feature: geoElement as? ArcGISFeature,
                popupElement: popupElement
            )
        )
    }
    
    /// A Boolean value specifying whether the dislosure group is expanded or not.
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
        if viewModel.relatedPopups.count > 0 {
            ForEach(viewModel.displayedPopups, id:\Popup.self) { popup in
                // TODO: create custom NavigationLink (NavLink?) that handles
                // TODO: all the commonalities between here and the "ShowAll"
                // TODO: link below.
                NavigationLink(value: popup) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(popup.title)
                                .foregroundColor(.primary)
                            if let text = popupElement.relatedPopupDescription(popup: popup) {
                                Text(text)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding([.bottom], -2)
                if popup != viewModel.displayedPopups.last {
                    Divider()
                }
            }
            Divider()
            // TODO: put back `popupElement.displayCount`.
            if viewModel.relatedPopups.count > 0/*popupElement.displayCount*/ {
                NavigationLink(value: viewModel.relatedPopups) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Show All")
                                .foregroundColor(.primary)
                            Text("\(viewModel.relatedPopups.count) records")
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.forward")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding([.bottom], -2)
                Divider()
            }
        } else {
            HStack {
                Text("No related records found.")
                    .italic()
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
    }
}

private extension RelationshipPopupElement {
    /// Provides a default title to display if `title` is empty.
    var displayTitle: String {
        title.isEmpty ? "Related Records" : title
    }
}

// TODO: remove these once they are implemented in core.
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
