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

import ArcGIS
import ArcGISToolkit
import SwiftUI

struct BookmarksExampleView: View {
    /// The map displayed in the map view.
    private let map = Map(basemapStyle: .arcGISImagery)

    /// Indicates if the bookmarks list is shown or not.
    /// - Remark: This allows a developer to control how the bookmarks menu is shown/hidden,
    /// whether that be in a group of options or a standalone button.
    @State
    var showingBookmarks = false

    @State
    var viewpoint: Viewpoint?  = nil

    var body: some View {
        MapView(map: map, viewpoint: viewpoint)
            .onTapGesture {
                showingBookmarks = false
            }
            // Show the bookmarks control as button
            .overlay(alignment: .topLeading) {
                Button {
                    showingBookmarks.toggle()
                } label: {
                    Image(
                        systemName:
                            showingBookmarks ? "bookmark.fill" : "bookmark"
                    )
                }
                .buttonStyle(.bordered)
                .padding(
                    EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 0)
                )
            }
            // Show the bookmarks control as an option within a group
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingBookmarks.toggle()
                        } label: {
                            Label(
                                showingBookmarks ?
                                "Hide Bookmarks" : "Show Bookmarks",
                                systemImage: showingBookmarks ?
                                "bookmark.fill" : "bookmark"
                            )
                        }
                        Text("More Options")
                    }
                    label: {
                        Label("Options", systemImage: "ellipsis")
                    }
                }
            }
            .overlay {
                Bookmarks(sampleBookmarks, isPresented: $showingBookmarks)
                    .onSelectionChanged {
                        print($0.name)
                        viewpoint = $0.viewpoint
                    }
            }
    }
}

extension BookmarksExampleView {
    var sampleBookmarks: [Bookmark] {[
        Bookmark(
            name: "Yosemite National Park",
            viewpoint: Viewpoint(
                center: Point(
                    x: -119.538330,
                    y: 37.865101,
                    spatialReference: .wgs84
                ),
                scale: 250_000
            )
        ),
        Bookmark(
            name: "Zion National Park",
            viewpoint: Viewpoint(
                center: Point(
                    x: -113.028770,
                    y: 37.297817,
                    spatialReference: .wgs84
                ),
                scale: 250_000
            )
        ),
        Bookmark(
            name: "Yellowstone National Park",
            viewpoint: Viewpoint(
                center: Point(
                    x: -110.584663,
                    y: 44.429764,
                    spatialReference: .wgs84
                ),
                scale: 375_000
            )
        ),
        Bookmark(
            name: "Grand Canyon National Park",
            viewpoint: Viewpoint(
                center: Point(
                    x: -112.1129,
                    y: 36.1069,
                    spatialReference: .wgs84
                ),
                scale: 375_000
            )
        ),
    ]}
}
