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
/// The feature form view can be embedded in any type of container view including, as demonstrated in the
/// example, the Toolkit's `FloatingPanel`.
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
    /// The feature form currently visible in the navigation layer.
    @State private var presentedForm: FeatureForm?
    
    /// A Boolean value indicating whether the presented feature form has edits.
    @State private var hasEdits: Bool = false
    
    /// The root feature form.
    let rootFeatureForm: FeatureForm
    
    /// The visibility of the form header.
    var headerVisibility: Visibility = .automatic
    
    /// The action to perform when the close button is pressed.
    var onCloseAction: (() -> Void)?
    
    /// The closure to perform when a ``HandlingEvent`` occurs.
    var onFormHandlingEventAction: ((HandlingEvent) -> Void)?
    
    /// The validation error visibility configuration of the form.
    var validationErrorVisibility: ValidationErrorVisibility = FormViewValidationErrorVisibility.defaultValue
    
    /// Initializes a form view.
    /// - Parameters:
    ///   - featureForm: The feature form defining the editing experience.
    public init(featureForm: FeatureForm) {
        self.rootFeatureForm = featureForm
        _presentedForm = .init(initialValue: featureForm)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if let onCloseAction {
                XButton(.dismiss) {
#warning("TODO: Check if the presented form has edits.")
                    onCloseAction()
                }
            }
            NavigationLayer {
                InternalFeatureFormView(
                    featureForm: rootFeatureForm
                )
                .navigationLayerFooter {
                    if let presentedForm, let onFormHandlingEventAction, hasEdits {
                        FormFooter(featureForm: presentedForm, formHandlingEventAction: onFormHandlingEventAction)
                    }
                }
            }
        }
        .environment(\.formChangedAction, onFormChangedAction)
        .environment(\.validationErrorVisibility, validationErrorVisibility)
        .task(id: presentedForm?.feature.globalID) {
            if let presentedForm {
                onFormHandlingEventAction?(.StartedEditing(presentedForm))
                for await hasEdits in presentedForm.$hasEdits {
                    withAnimation { self.hasEdits = hasEdits }
                }
            }
        }
    }
}

public extension FeatureFormView {
    /// Sets a closure to perform when the form's close button is pressed.
    /// - Parameter action: The closure to perform when the form's close button is pressed.
    ///
    /// Use this modifier to show a close button on the form. If the feature form has edits the user will be
    /// prompted to first save or discard the edits.
    func onClose(perform action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onCloseAction = action
        return copy
    }
    
    /// Sets a closure to perform when a form handling event occurs.
    /// - Parameter action: The closure to perform when the form handling event occurs.
    func onFormHandlingEvent(perform action: @escaping (HandlingEvent) -> Void) -> Self {
        var copy = self
        copy.onFormHandlingEventAction = action
        return copy
    }
}

extension FeatureFormView {
    /// The closure to perform when the presented feature form changes.
    ///
    /// - Note: This action has the potential to be called under four scenarios. Whenever an
    /// ``InternalFeatureFormView`` appears (which can happen during forward
    /// or reverse navigation) and whenever a ``UtilityAssociationGroupResultView`` appears
    /// (which can also happen during forward or reverse navigation). Because those two views (and the
    /// intermediate ``UtilityAssociationsFilterResultView`` are all considered to be apart of
    /// the same ``FeatureForm`` make sure not to over-emit form handling events.
    var onFormChangedAction: (FeatureForm) -> Void {
        { featureForm in
            if featureForm.feature.globalID != presentedForm?.feature.globalID {
                self.presentedForm = featureForm
            }
        }
    }
}


extension EnvironmentValues {
    /// The environment value to access the closure to call when the presented feature form changes.
    @Entry var formChangedAction: ((FeatureForm) -> Void)?
}
