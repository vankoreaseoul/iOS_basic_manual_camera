//
//  ContentView.swift
//  CameraTest
//
//  Created by Heawon Seo on 2023/08/16.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel = HomeVM()
    
    var body: some View {
        VStack {
            Button {
                viewModel.didTapCameraBtn()
            } label: {
                Image(systemName: "camera.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
            }
        }
        .fullScreenCover(isPresented: viewModel.viewState == .CAMERA ? .constant(true) : .constant(false), content: {
            LiveCameraView()
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
