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

import PhotosUI
import SwiftUI

extension View {
    /// Presents a Photos picker that selects a PhotosPickerItem from a given photo library after obtaining
    /// read/write photo library authorization.
    /// - Parameters:
    ///   - isPresented: The binding to whether the Photos picker should be shown.
    ///   - selection: The item being shown and selected in the Photos picker.
    ///   - filter: Types of items that can be shown. Default is `nil`. Setting it to `nil` means all supported types can be shown.
    ///   - photoLibrary: The photo library to choose from. Default is `.shared()`.
    func authorizedPhotosPicker(
        isPresented: Binding<Bool>,
        selection: Binding<PhotosPickerItem?>,
        matching filter: PHPickerFilter? = nil,
        photoLibrary: PHPhotoLibrary = .shared(),
    ) -> some View {
        modifier(
            AuthorizedPhotosPicker(
                isPresented: isPresented,
                item: selection,
                filter: filter,
                photoLibrary: photoLibrary
            )
        )
    }
}

/// A view that displays a Photos picker for choosing assets from the photo library after obtaining read/write
/// photo library authorization.
///
/// `View.photosPicker` automatically grants access to items but that authorization doesn't grant all
/// abilities, such as reading original filenames, so this type can be use to get explicit read/write permission up
/// front.
struct AuthorizedPhotosPicker: ViewModifier {
    @Environment(\.openURL) var openURL
    
    /// A Boolean value which indicates whether the modifier is presented.
    @Binding var isPresented: Bool
    /// The item being shown and selected in the Photos picker.
    @Binding var item: PhotosPickerItem?
    /// Types of items that can be shown.
    let filter: PHPickerFilter?
    /// The photo library to choose from.
    let photoLibrary: PHPhotoLibrary
    
    /// A Boolean value that indicates whether a permission alert is presented.
    @State private var alertIsPresented = false
    /// An authorization error.
    @State private var error: AuthorizationError?
    /// The application's settings URL. When this is set, the settings are opened.
    @State private var openSettingsURL: URL?
    /// An Boolean value which controls whether the picker is presented after authorization has been determined.
    @State private var pickerIsPresented = false
    
    func body(content: Content) -> some View {
        content
            .photosPicker(
                isPresented: $pickerIsPresented,
                selection: $item,
                matching: filter,
                photoLibrary: photoLibrary
            )
            .alert(isPresented: $alertIsPresented, error: error) {
                switch error {
                case .denied:
                    Button.cancel {}
                    Button(String.settings) {
                        openSettingsURL = URL(string: UIApplication.openSettingsURLString)
                    }
                case .restricted, nil:
                    Button.cancel {}
                }
            }
            .task(id: alertIsPresented) {
                guard !alertIsPresented else { return }
                // Reset external presentation when the alert is dismissed.
                // Without this, re-presentation will be broken.
                isPresented = false
            }
            .task(id: pickerIsPresented) {
                guard !pickerIsPresented else { return }
                // Reset external presentation state when the picker is dismissed.
                // Without this, re-presentation will be broken.
                isPresented = false
            }
            .task(id: isPresented) {
                guard isPresented else { return }
                switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
                case .authorized, .limited:
                    pickerIsPresented = true
                case .denied:
                    error = .denied
                    alertIsPresented = true
                case .notDetermined:
                    let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                    guard status == .authorized || status == .limited else { return }
                    pickerIsPresented = true
                case .restricted:
                    error = .restricted
                    alertIsPresented = true
                @unknown default:
                    return
                }
            }
            .task(id: openSettingsURL) {
                guard let openSettingsURL else { return }
                await openURL(openSettingsURL)
            }
    }
    
    enum AuthorizationError: LocalizedError {
        /// The user explicitly denied this app access to the photo library.
        case denied
        /// The app isn’t authorized to access the photo library, and the user can’t grant such permission.
        ///
        /// Parental controls or institutional configuration profiles can restrict the user’s ability to grant photo library access to an app.
        case restricted
        
        var errorDescription: String? {
            switch self {
            case .denied:
                String(
                    localized: "Photo Library access is disabled in the system settings.",
                    bundle: .toolkitModule,
                    comment: "An error message indicating that Photo Library access is disabled in the system settings."
                )
            case .restricted:
                String(
                    localized: "Photo Library access is restricted.",
                    bundle: .toolkitModule,
                    comment: "An error message indicating that Photo Library access is restricted."
                )
            }
        }
        
        var recoverySuggestion: String? {
            switch self {
            case .denied:
                String(
                    localized: "Please provide authorization in settings.",
                    bundle: .toolkitModule,
                    comment: "A recovery suggestion for when Photo Library access is denied."
                )
            case .restricted:
                nil
            }
        }
    }
}
