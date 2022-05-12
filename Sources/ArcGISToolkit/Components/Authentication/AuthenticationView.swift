//
// COPYRIGHT 1995-2022 ESRI
//
// TRADE SECRETS: ESRI PROPRIETARY AND CONFIDENTIAL
// Unpublished material - all rights reserved under the
// Copyright Laws of the United States and applicable international
// laws, treaties, and conventions.
//
// For additional information, contact:
// Environmental Systems Research Institute, Inc.
// Attn: Contracts and Legal Services Department
// 380 New York Street
// Redlands, California, 92373
// USA
//
// email: contracts@esri.com
//

import SwiftUI

struct AuthenticationView: View {
    init(continuation: ChallengeContinuation) {
        self.continuation = continuation
    }
    
    var continuation: ChallengeContinuation
    
    var body: some View {
        EmptyView()
//        UsernamePasswordView(viewModel: UsernamePasswordViewModel(continuation))
    }
}
