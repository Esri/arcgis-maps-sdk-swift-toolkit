// Copyright 2026 Esri
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
import SwiftUI

/// The `GeometryEditorToolbar` component allows users to perform common actions on a
/// `GeometryEditor`.
struct GeometryEditorToolbar: View {
    /// The geometry editor that this toolbar controls.
    private let geometryEditor: GeometryEditor
    /// The style to apply to the toolbar's controls.
    private let style: Style?
    /// The allowed snap source types for snap settings UI.
    private var snapSources: SnapSources
    
    /// The spacing to apply between the controls in the stacks.
    /// This is hardcoded to match the system styling for toolbar groups on iOS.
    private let stackSpacing = 30.0
    /// The padding to apply to the long edges of the stacks containing the controls.
    /// This is hardcoded to match the system styling for toolbar groups on iOS.
    private let stackEdgePadding = 5.0
    
    /// The view model for the view.
    @State private var model: GeometryEditorToolbarModel
    
    /// Creates a geometry editor toolbar.
    /// - Parameters:
    ///   - geometryEditor: The geometry editor that this toolbar controls.
    ///   - style: The style that determines the toolbar’s appearance and layout.  A `nil` value
    ///   displays the toolbar's controls without built-in layout or styling.
    init(geometryEditor: GeometryEditor, style: Style? = .vertical) {
        // Snapping is enabled by default to simplify the UI.
        geometryEditor.snapSettings.isEnabled = true
        self.geometryEditor = geometryEditor
        self.style = style
        self.snapSources = .all
        
        let model = GeometryEditorToolbarModel(geometryEditor: geometryEditor)
        self._model = .init(wrappedValue: model)
    }
    
    var body: some View {
        Group {
            if model.isStarted {
                switch style {
                case .vertical:
                    VStack(spacing: stackSpacing) {
                        controls
                    }
                    .padding(.vertical, stackEdgePadding)
                    .toolbarStackStyle()
                case .horizontal:
                    HStack(spacing: stackSpacing) {
                        controls
                    }
                    .padding(.horizontal, stackEdgePadding)
                    .toolbarStackStyle()
                case nil:
                    controls
                }
            }
        }
        .environment(model)
        .animation(.default, value: model.isStarted)
        .onChange(of: ObjectIdentifier(geometryEditor)) {
            model = GeometryEditorToolbarModel(geometryEditor: geometryEditor)
            // Snapping is enabled by default to simplify the UI.
            geometryEditor.snapSettings.isEnabled = true
        }
    }
    
    /// The control views for the toolbar.
    @ViewBuilder private var controls: some View {
        ToolPicker()
        DeleteButton()
        UndoButton()
        RedoButton()
        SnapSettingsButton(snapSources: snapSources)
    }
}

extension GeometryEditorToolbar {
    /// Limits the snap source types available in the snap settings UI.
    /// Disallowed snap sources are hidden in the UI and disabled in the underlying `SnapSettings`.
    /// - Parameter snapSources: The allowed snap source types.
    /// - Returns: A toolbar with snap settings restricted to `snapSources`.
    func snapSourceTypes(_ snapSources: SnapSources) -> Self {
        var copy = self
        copy.snapSources = snapSources
        return copy
    }
}

/// The view model for the geometry editor toolbar.
@MainActor
@Observable
final class GeometryEditorToolbarModel {
    /// The geometry editor that the toolbar controls.
    let geometryEditor: GeometryEditor
    
    /// A Boolean value indicating whether the geometry editor has started.
    private(set) var isStarted = false
    
    /// A task that observes the geometry editor's `isStarted` stream.
    @ObservationIgnored private var isStartedTask: Task<Void, Never>?
    
    init(geometryEditor: GeometryEditor) {
        self.geometryEditor = geometryEditor
        
        isStartedTask = Task { [weak self] in
            for await isStarted in geometryEditor.$isStarted {
                guard let self else { break }
                self.isStarted = isStarted
            }
        }
    }
    
    deinit {
        if let task = isStartedTask.take() {
            task.cancel()
        }
    }
}

extension GeometryEditorToolbar {
    /// A style that determines the appearance and layout of a geometry editor toolbar.
    ///
    /// This is commonly applied when displaying the toolbar overlaid on a `GeoView`.
    enum Style {
        /// Displays the toolbar in a styled horizontal layout.
        case horizontal
        /// Displays the toolbar in a styled vertical layout.
        case vertical
    }
    
    /// A set of `SnapSource` types allowed in the snap settings UI.
    struct SnapSources: OptionSet {
        let rawValue: Int
        
        init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        /// Allows `FeatureLayer` snap sources.
        static let featureLayer = SnapSources(rawValue: 1 << 0)
        /// Allows `GraphicsOverlay` snap sources.
        static let graphicsOverlay = SnapSources(rawValue: 1 << 1)
        /// Allows `SubtypeFeatureLayer` snap sources.
        static let subtypeFeatureLayer = SnapSources(rawValue: 1 << 2)
        /// Allows `SubtypeSublayer` snap sources.
        static let subtypeSublayer = SnapSources(rawValue: 1 << 3)
        
        /// Allows all supported `SnapSource` types.
        static let all: SnapSources = [
            .featureLayer,
            .graphicsOverlay,
            .subtypeFeatureLayer,
            .subtypeSublayer
        ]
        /// Allows `SnapSource` types that are layers.
        static let layers: SnapSources = [
            .featureLayer,
            .subtypeFeatureLayer,
            .subtypeSublayer
        ]
        
        /// Returns a Boolean value indicating whether a snap source type is
        /// allowed by the set.
        /// - Parameter source: A snap source to check for allowance by the set.
        /// - Returns: `true` if the snap source type is in the set, otherwise `false`.
        func contains(source: some SnapSource) -> Bool {
            switch source {
            case is FeatureLayer:
                contains(.featureLayer)
            case is GraphicsOverlay:
                contains(.graphicsOverlay)
            case is SubtypeFeatureLayer:
                contains(.subtypeFeatureLayer)
            case is SubtypeSublayer:
                contains(.subtypeSublayer)
            default:
                false
            }
        }
    }
}

// MARK: - Controls

/// A button for deleting the geometry editor's currently selected element.
private struct DeleteButton: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    
    /// A Boolean value indicating whether the selected element can be deleted.
    @State private var canDeleteSelectedElement = false
    
    var body: some View {
        Button(action: model.geometryEditor.deleteSelectedElement) {
            Label {
                Text(
                    "Delete Selected Element",
                    bundle: .toolkitModule,
                    comment: "A label for a button to delete the selected geometry editor element."
                )
            } icon: {
                Image(systemName: "circle.badge.minus")
            }
        }
        .disabled(!canDeleteSelectedElement)
        .task(id: ObjectIdentifier(model)) {
            for await selectedElement in model.geometryEditor.$selectedElement {
                canDeleteSelectedElement = selectedElement?.canBeDeleted ?? false
            }
        }
    }
}

/// A button for redoing the geometry editor's last undone action.
private struct RedoButton: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    
    /// A Boolean value indicating whether the geometry editor can redo an action.
    @State private var canRedo = false
    
    var body: some View {
        Button(action: model.geometryEditor.redo) {
            Label {
                Text(
                    "Redo",
                    bundle: .toolkitModule,
                    comment: "A label for a button to redo the last undone geometry editor action."
                )
            } icon: {
                Image(systemName: "arrow.uturn.forward")
            }
        }
        .disabled(!canRedo)
        .task(id: ObjectIdentifier(model)) {
            for await canRedo in model.geometryEditor.$canRedo {
                self.canRedo = canRedo
            }
        }
    }
}

/// A button for undoing the geometry editor's last action.
private struct UndoButton: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    
    /// A Boolean value indicating whether the geometry editor can undo an action.
    @State private var canUndo = false
    
    var body: some View {
        Button(action: model.geometryEditor.undo) {
            Label {
                Text(
                    "Undo",
                    bundle: .toolkitModule,
                    comment: "A label for a button to undo the last geometry editor action."
                )
            } icon: {
                Image(systemName: "arrow.uturn.backward")
            }
        }
        .disabled(!canUndo)
        .task(id: ObjectIdentifier(model)) {
            for await canUndo in model.geometryEditor.$canUndo {
                self.canUndo = canUndo
            }
        }
    }
}

/// A button for presenting a settings view for configuring snapping.
private struct SnapSettingsButton: View {
    /// The model for the parent geometry editor toolbar.
    @Environment(GeometryEditorToolbarModel.self) private var model
    /// The allowed snap source types shown in settings.
    let snapSources: GeometryEditorToolbar.SnapSources
    
    /// A Boolean value indicating whether the settings view is presented.
    @State private var isShowingSettings = false
    
    var body: some View {
        if !model.geometryEditor.snapSettings.sourceSettings.isEmpty {
            Button {
                isShowingSettings.toggle()
            } label: {
                Label {
                    Text(
                        "Settings",
                        bundle: .toolkitModule,
                        comment: "A label for a button to show settings for configuring snapping."
                    )
                } icon: {
                    Image(systemName: "gear")
                }
            }
            .sheet(isPresented: $isShowingSettings) {
                SnapSettingsView(
                    settings: model.geometryEditor.snapSettings,
                    snapSources: snapSources
                )
                // Needed to override the font set in toolbarStackStyle.
                .font(nil)
            }
        }
    }
}

// MARK: - Helper

private extension View {
    /// Applies the shared styling used by the vertical and horizontal stacks
    /// in a `GeometryEditorToolbar`.
    @ViewBuilder
    func toolbarStackStyle() -> some View {
        // glassEffect is not used because it bases its background color on the content behind it,
        // but the ToolPicker does not, causing the color to jump when the picker menu closes.
        self.fixedSize()
            .labelStyle(.iconOnly)
            .font(.title2)
            .buttonStyle(.borderless)
            .menuIndicator(.hidden)
            .padding(10)
            .background(.regularMaterial)
            .clipShape(.capsule)
            .shadow(radius: 1)
            .allowsHitTesting(true)
    }
}

#Preview {
    let geometryEditor = GeometryEditor()
    
    NavigationStack {
        MapView(map: Map(spatialReference: .wgs84))
            .attributionBarHidden(true)
            .geometryEditor(geometryEditor)
            .overlay(alignment: .topTrailing) {
                GeometryEditorToolbar(geometryEditor: geometryEditor)
                    .padding()
            }
            .overlay(alignment: .topLeading) {
                GeometryEditorToolbar(geometryEditor: geometryEditor, style: .horizontal)
                    .environment(\.colorScheme, .dark)
                    .padding()
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    GeometryEditorToolbar(geometryEditor: geometryEditor, style: nil)
                }
            }
            .onAppear {
                geometryEditor.start(withType: Polygon.self)
            }
    }
}
