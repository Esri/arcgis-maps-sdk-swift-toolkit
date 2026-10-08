// Copyright 2023 Esri
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

/// The `FeatureFormView` component enables users to edit field values of a feature using
/// pre-configured forms, either from the Web Map Viewer or the Fields Maps Designer.
///
/// ![An image of the FeatureFormView component](FeatureFormView)
///
/// Forms are currently only supported in maps. The form definition is stored
/// in the web map itself and contains a title, description, and a list of "form elements".
///
/// `FeatureFormView` supports the display of form elements created by
/// the Map Viewer or Field Maps Designer, including:
///
/// - Attachments Element - used to display and edit attachments.
/// - Field Element - used to edit a single field of a feature with a specific "input type".
/// - Group Element - used to group elements together. Group Elements
/// can be expanded, to show all enclosed elements, or collapsed, hiding
/// the elements it contains.
/// - Text Element - used to display read-only plain or Markdown-formatted text.
/// - Utility Associations Element - used to edit associations in utility networks.
///
/// A Field Element has a single input type object. The following are the supported input types:
///
/// - Barcode - machine readable data
/// - Combo Box - long list of values in a coded value domain
/// - Date/Time - date/time picker
/// - Radio Buttons - short list of values in a coded value domain
/// - Switch - two mutually exclusive values
/// - Text Area - multi-line text area
/// - Text Box - single-line text box
///
/// **Features**
///
/// - Display a form editing view for a feature based on the feature form definition defined in a web map and obtained from either an `ArcGISFeature`, `ArcGISFeatureTable`, `FeatureLayer` or `SubtypeSublayer`.
/// - Uses native SwiftUI controls for editing, such as `TextEditor`, `TextField`, and `DatePicker` for consistent platform styling.
/// - Supports elements containing Arcade expression and automatically evaluates expressions for element visibility, editability, values, and "required" state.
/// - Add, delete, or rename feature attachments.
/// - Fully supports dark mode, as do all Toolkit components.
///
/// **Behavior**
///
/// As of 200.8, FeatureFormView uses a NavigationStack internally to support browsing utility network
/// associations. As a result, a FeatureFormView requires a navigation context isolated from any app-level
/// navigation. Basic apps without navigation can continue to place a FeatureFormView where desired.
/// More complex apps using NavigationStack or NavigationSplitView will need to relocate the FeatureFormView
/// outside of that navigation context. If the FeatureFormView can be presented modally (no background
/// interaction with the map is needed), consider using a Sheet. If a non-modal presentation is needed,
/// consider placing the FeatureFormView in a Floating Panel or Inspector, on the app-level navigation container.
/// On supported platforms, WindowGroups are another alternative to consider as a FeatureFormView container.
///
/// To see it in action, try out the [Examples](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/tree/main/Examples/Examples)
/// and refer to [FeatureFormExampleView.swift](https://github.com/Esri/arcgis-maps-sdk-swift-toolkit/blob/main/Examples/Examples/FeatureFormExampleView.swift)
/// in the project. To learn more about using the `FeatureFormView` see the <doc:FeatureFormViewTutorial>.
///
/// - Note: In order to capture video and photos as form attachments, your application will need
/// `NSCameraUsageDescription` and, `NSMicrophoneUsageDescription` entries in the
/// `Info.plist` file.
///
/// - Since: 200.4
public struct FeatureFormView: View {
    @State private var model: Model
    private var legacyIsPresented: Binding<Bool>?
    
    /// Initializes a form view.
    /// - Parameters:
    ///   - root: The feature form defining the editing experience.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    /// - Since: 200.8
    public init(root: FeatureForm, isPresented: Binding<Bool>? = nil) {
        self.legacyIsPresented = isPresented
        self.model = .init(isPresented: isPresented?.wrappedValue, rootFeatureForm: root)
    }
    
    /// Initializes a Feature Form View.
    /// - Parameters:
    ///   - model: A model for the view.
    /// - Since: 300.2
    public init(model: Model) {
        self.model = model
    }
    
    public var body: some View {
        if model.legacyModeIsActive {
            legacyView
        } else {
            // GroupFormView
            EmptyView()
        }
    }
}

public extension FeatureFormView {
    /// Sets the visibility of the save and discard buttons on the form.
    /// - Parameter visibility: The visibility of the save and discard buttons.
    /// - Since: 200.8
    func editingButtons(_ visibility: Visibility) -> Self {
        model.editingButtonsVisibility = visibility
        return self
    }
    
    /// Sets whether navigation to forms for features associated via utility association form
    /// elements is disabled.
    ///
    /// Use this modifier to conditionally disable navigation into other forms.
    /// - Parameter disabled: A Boolean value that determines whether navigation is disabled. Pass `true` to disable navigation; otherwise, pass `false`.
    /// - Since: 200.8
    func navigationDisabled(_ disabled: Bool) -> Self {
        model.navigationIsDisabled = disabled
        return self
    }
    
    /// Sets a closure to perform when a new feature form is shown in the view.
    ///
    /// This can happen when navigating through the associations in a `UtilityAssociationsFormElement`.
    /// - Parameter action: The closure to perform when the new feature form is shown.
    /// - Since: 200.8
    func onFeatureFormChanged(perform action: @escaping (FeatureForm) -> Void) -> Self {
        model.onFeatureFormChanged = action
        return self
    }
    
    /// Sets a closure to perform when a form editing event occurs.
    /// - Parameter action: The closure to perform when the form editing event occurs.
    /// - Since: 200.8
    func onFormEditingEvent(perform action: @escaping (EditingEvent) -> Void) -> Self {
        model.onFormEditingEventAction = .init(action: action)
        return self
    }
    
    /// Sets the visibility of validation errors on the form.
    /// - Parameter visibility: The preferred visibility of validation errors in the form.
    ///
    /// `FeatureFormView` will automatically show validation errors on fields once they've received
    /// user interaction or the user has attempted to save the form with the built-in "Save" buttons.
    ///
    /// If it's preferred that validation errors are always shown, override the default behavior with this
    /// modifier, passing `.visible`.
    ///
    /// If the built-in "Save" button in the form footer has been hidden with
    /// ``FeatureFormView/editingButtons(_:)``, use this modifier to make any validation
    /// errors visible when the user attempts to save the form with a custom save button.
    func validationErrors(_ visibility: ValidationErrorVisibility) -> Self {
        model.validationErrorVisibilityExternal = visibility
        return self
    }
    
    /// Sets an action to run before finishing edits.
    ///
    /// When an action is set, the view acts as if the forms in the view have edits, even if they do
    /// not, and makes the finish editing button available.
    ///
    /// If the action throws an error, `finishEditing` will not be called.
    /// - Parameter action: The closure to perform.
    func willFinishEditing(perform action: (() throws -> Void)?) -> Self {
        model.willFinishEditingAction = action
        return self
    }
}

extension FeatureFormView {
    var legacyView: some View {
        StackView()
            .environment(model)
            .onChange(of: legacyIsPresented?.wrappedValue) { _, newValue in
                model.isPresented = newValue
            }
            .onChange(of: model.isPresented) { _, newValue in
                if let newValue, let legacyIsPresented, newValue != legacyIsPresented.wrappedValue {
                    legacyIsPresented.wrappedValue = newValue
                }
            }
    }
}
