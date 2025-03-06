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
    private let presentedForm: Binding<FeatureForm?>
    
    /// The root feature form.
    private let rootFeatureForm: FeatureForm?
    
    /// The visibility of the close button.
    var closeButtonVisibility: Visibility = .automatic
    
    /// The closure to perform when a ``EditingEvent`` occurs.
    var onFormEditingEventAction: ((EditingEvent) -> Void)?
    
    /// The validation error visibility configuration of the form.
    var validationErrorVisibility: Visibility = .hidden
    
    /// Continuation information for the alert.
    @State private var alertContinuation: (willNavigate: Bool, action: () -> Void)?
    
    /// A Boolean value indicating whether the presented feature form has edits.
    @State private var hasEdits: Bool = false
    
    /// Initializes a form view.
    /// - Parameters:
    ///   - featureForm: The feature form defining the editing experience.
    public init(featureForm: Binding<FeatureForm?>) {
        self.rootFeatureForm = featureForm.wrappedValue
        self.presentedForm = featureForm
    }
    
    public var body: some View {
        if let rootFeatureForm {
            VStack(spacing: 0) {
                NavigationLayer {
                    InternalFeatureFormView(
                        featureForm: rootFeatureForm
                    )
                } headerTrailing: {
                    if closeButtonVisibility != .hidden {
                        XButton(.dismiss) {
                            if hasEdits {
                                alertContinuation = (false, {
                                    presentedForm.wrappedValue = nil
                                })
                            } else {
                                presentedForm.wrappedValue = nil
                            }
                        }
                        .font(.title)
                    }
                } footer: {
                    if let presentedForm = presentedForm.wrappedValue, let onFormEditingEventAction, hasEdits {
                        FormFooter(featureForm: presentedForm, formHandlingEventAction: onFormEditingEventAction)
                    }
                }
            }
            .alert(
                "Discard Edits?",
                isPresented: alertIsPresented,
                actions: {
                    if let presentedForm = presentedForm.wrappedValue, let (willNavigate, continuation) = alertContinuation {
                        Button("Discard Edits", role: .destructive) {
                            presentedForm.discardEdits()
                            onFormEditingEventAction?(.discardedEdits(willNavigate: willNavigate))
                            continuation()
                        }
                        Button("Save Edits") {
                            Task {
                                do {
                                    try await presentedForm.finishEditing()
                                    onFormEditingEventAction?(.savedEdits(willNavigate: willNavigate))
                                    continuation()
                                } catch {
                                    #warning("Handle thrown errors.")
                                }
                            }
                        }
                        Button("Continue Editing", role: .cancel) {
                            alertIsPresented.wrappedValue = false
                        }
                    }
                },
                message: {
                    Text("Updates to the form will be lost.")
                }
            )
            .environment(\.formChangedAction, onFormChangedAction)
            .environment(\.setAlertContinuation, setAlertContinuation)
            .environment(\._validationErrorVisibility, validationErrorVisibility)
            .task(id: presentedForm.wrappedValue?.feature.globalID) {
                if let presentedForm = presentedForm.wrappedValue {
                    for await hasEdits in presentedForm.$hasEdits {
                        withAnimation { self.hasEdits = hasEdits }
                    }
                }
            }
        }
    }
}

public extension FeatureFormView {
    /// <#Description#>
    enum EditingEvent {
        /// <#Description#>
        case discardedEdits(willNavigate: Bool)
        /// <#Description#>
        case savedEdits(willNavigate: Bool)
    }
    
    /// Sets the visibility of the close button on the form.
    /// - Parameter visibility: The visibility of the close button.
    func closeButton(_ visibility: Visibility) -> Self {
        var copy = self
        copy.closeButtonVisibility = visibility
        return copy
    }
    
    /// Sets a closure to perform when a form editing event occurs.
    /// - Parameter action: The closure to perform when the form editing event occurs.
    func onFormEditingEvent(perform action: @escaping (EditingEvent) -> Void) -> Self {
        var copy = self
        copy.onFormEditingEventAction = action
        return copy
    }
}

extension FeatureFormView {
    /// A Boolean value indicating whether the alert is presented.
    var alertIsPresented: Binding<Bool> {
        Binding {
            alertContinuation != nil
        } set: { newIsPresented in
            if !newIsPresented {
                alertContinuation = nil
            }
        }
    }
    
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
            if let presentedForm = presentedForm.wrappedValue {
                if featureForm.feature.globalID != presentedForm.feature.globalID {
                    self.presentedForm.wrappedValue = featureForm
                }
            }
        }
    }
    
    /// A closure used to set the alert continuation.
    var setAlertContinuation: (Bool, @escaping () -> Void) -> Void {
        { willNavigate, continuation in
            alertContinuation = (willNavigate: willNavigate, action: continuation)
        }
    }
}

extension EnvironmentValues {
    /// The environment value to access the closure to call when the presented feature form changes.
    @Entry var formChangedAction: ((FeatureForm) -> Void)?
    
    /// The environment value to set the continuation to use when the user responds to the alert.
    @Entry var setAlertContinuation: ((Bool, @escaping () -> Void) -> Void)?
    
    /// The environment value to access the validation error visibility.
    @Entry var _validationErrorVisibility: Visibility = .hidden
}
