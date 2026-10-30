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
    private let isPresented: Binding<Bool>?
    private let providedModel: FeatureFormView.Model?
    
    /// A model created for the user when ``FeatureFormView.init(root:isPresented:)``
    /// is used.
    @State private var legacyModel: FeatureFormView.Model?
    
    /// Initializes a Feature Form View.
    /// - Parameters:
    ///   - model: A model for the view.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    /// - Since: 300.3
    public init(model: Model, isPresented: Binding<Bool>? = nil) {
        self.isPresented = isPresented
        self.providedModel = model
        _legacyModel = nil
    }
    
    public var body: some View {
        groupMenuOrFormStack
            .environment(model)
            .onAppear {
                model.isPresented = isPresented?.wrappedValue
            }
            .onChange(of: model.isPresented) { _, newValue in
                if let newValue, let isPresented, newValue != isPresented.wrappedValue {
                    isPresented.wrappedValue = newValue
                }
            }
    }
    
    /// Either the navigation stack for the ``FeatureFormView/Model/selectedForm`` or the
    /// group menu if no form is selected.
    var groupMenuOrFormStack: some View {
        Group {
            if let formModel = model.selectedModel {
                FormStack(formModel: formModel)
            } else {
                GroupMenu()
                    .transition(.move(edge: .bottom))
            }
        }
        .saveErrorAlert(model)
        .unsavedEditsAlert(model)
        .validationErrorsAlert(model)
    }
    
    /// Coalesces the provided or legacy model into one property.
    var model: FeatureFormView.Model! {
        providedModel ?? legacyModel
    }
}

public extension FeatureFormView /* Deprecated */ {
    /// Initializes a form view.
    /// - Parameters:
    ///   - root: The feature form defining the editing experience.
    ///   - isPresented: A Boolean value indicating if the view is presented.
    /// - Since: 200.8
    /// - Note: Deprecated at 300.3. Use ``FeatureFormView/init(model:isPresented:)`` instead.
    @available(*, deprecated, renamed: "FeatureFormView.init(model:isPresented:)")
    init(root: FeatureForm, isPresented: Binding<Bool>? = nil) {
        self.isPresented = isPresented
        self.providedModel = nil
        _legacyModel = .init(wrappedValue: .init(forms: [root]))
    }
    
    /// Sets the visibility of the save and discard buttons on the form.
    /// - Parameter visibility: The visibility of the save and discard buttons.
    /// - Since: 200.8
    /// - Note: Deprecated at 300.3. The component no longer has a Discard button.
    @available(*, deprecated, message: "Hiding the save button is no longer supported.")
    func editingButtons(_ visibility: Visibility) -> Self {
        return self
    }
    
    /// Sets whether navigation to forms for features associated via utility association form
    /// elements is disabled.
    ///
    /// Use this modifier to conditionally disable navigation into other forms.
    /// - Parameter disabled: A Boolean value that determines whether navigation is disabled.
    /// Pass `true` to disable navigation; otherwise, pass `false`.
    /// - Since: 200.8
    /// - Note: Deprecated at 300.3.
    @available(*, deprecated, message: "Disabling navigation is no longer supported.")
    func navigationDisabled(_ disabled: Bool) -> Self {
        return self
    }
    
    /// Sets a closure to perform when a new feature form is shown in the view.
    ///
    /// This can happen when navigating through the associations in a `UtilityAssociationsFormElement`.
    /// - Parameter action: The closure to perform when the new feature form is shown.
    /// - Since: 200.8
    /// - Note: Deprecated at 300.3. Use ``FeatureFormView/Model/selectedForm`` to
    /// know when no form is selected (the group menu is visible).
    @available(*, deprecated, message: "Use 'FeatureFormView.Model.selectedForm' instead.")
    func onFeatureFormChanged(perform action: @escaping (FeatureForm) -> Void) -> Self {
        model.onFeatureFormChanged = action
        return self
    }
    
    /// Sets a closure to perform when a form editing event occurs.
    /// - Parameter action: The closure to perform when the form editing event occurs.
    /// - Since: 200.8
    /// - Note: Deprecated at 300.3. Use ``FeatureFormView/Model/editingEvents`` to
    /// monitor editing events.
    @available(*, deprecated, message: "Use 'FeatureFormView.Model.editingEvents' instead.")
    func onFormEditingEvent(perform action: @escaping (EditingEvent) -> Void) -> Self {
        model.onFormEditingEventAction = action
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
    /// - Note: Deprecated at 300.3. Use ``FeatureFormView/Model/validationErrorVisibility`` to
    /// override validation error visibility.
    @available(*, deprecated, message: "Use 'FeatureFormView.Model.validationErrorVisibility' instead.")
    func validationErrors(_ visibility: ValidationErrorVisibility) -> Self {
        model.validationErrorVisibility = visibility
        return self
    }
}

private extension View /* Alerts */ {
    /// An alert for save errors.
    func saveErrorAlert(_ model: FeatureFormView.Model) -> some View {
        @Bindable var model = model
        return alert(
            LocalizedStringResource(
                "The form wasn't submitted",
                bundle: .toolkit,
                comment: "The title shown when the feature form failed to save."
            ),
            item: $model.finishOrDiscardError,
            actions: { _ in },
            message: { error in
                Text(
                    """
                    Finish editing failed.
                    \(String(describing: error))
                    """,
                    bundle: .toolkitModule,
                    comment: """
                        The message shown when a form could not be \
                        submitted with additional details.
                        """
                )
            }
        )
    }
    
    /// An alert for abandoning unsaved edits.
    func unsavedEditsAlert(_ model: FeatureFormView.Model) -> some View {
        @Bindable var model = model
        return alert(
            Text(
                "Discard Edits?",
                bundle: .toolkitModule,
                comment: """
                    A question asking if the user would like to discard their \
                    unsaved edits.
                    """
            ),
            isPresented: $model.alertForUnsavedEditsIsPresented,
            actions: {
                Button(role: .destructive) {
                    model.discard(ignoreEdits: true)
                } label: {
                    Text.discardEdits
                }
                Button(role: .cancel) {
                    model.alertForUnsavedEditsIsPresented = false
                } label: {
                    Text.continueEditing
                }
            },
            message: {
                Text(
                    "Edits will be lost.",
                    bundle: .toolkitModule,
                    comment: """
                        A message explaining that unsaved edits will be lost \
                        if the user continues to dismiss the component without \
                        saving.
                        """
                )
            }
        )
    }
    
    /// An alert for validation errors.
    func validationErrorsAlert(_ model: FeatureFormView.Model) -> some View {
        @Bindable var model = model
        return alert(
            Text(
                "Validation Errors",
                bundle: .toolkitModule,
                comment: """
                    A label indicating the feature form has validation errors.
                    """
            ),
            isPresented: $model.alertForValidationErrorsIsPresented,
            actions: {
                Button(role: .cancel) {
                    model.alertForUnsavedEditsIsPresented = false
                } label: {
                    Text.continueEditing
                }
            },
            message: {
                Text(
                    """
                    You have ^[\(model.totalErrorCount) errors](inflect: true) \
                    that must be fixed before saving.
                    """,
                    bundle: .toolkitModule,
                    comment: """
                        A message explaining that the indicated number \
                        of validation errors must be resolved before \
                        saving the feature form.
                        """
                )
            }
        )
    }
}

private extension Text {
    static var continueEditing: Self {
        .init(
            "Continue Editing",
            bundle: .toolkitModule,
            comment: "A label for a button to continue editing the feature form."
        )
    }
}
