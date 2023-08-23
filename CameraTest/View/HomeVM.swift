//
//  HomeVM.swift
//  CameraTest
//
//  Created by Heawon Seo on 2023/08/16.
//

import SwiftUI

enum ViewState {
    case HOME, CAMERA
}

class HomeVM: ObservableObject {
    
    @Published var viewState: ViewState = .HOME
    
    func didTapCameraBtn() {
        viewState = .CAMERA
    }
    
}
