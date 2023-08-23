//
//  FrameView.swift
//  CameraTest
//
//  Created by Heawon Seo on 2023/08/16.
//

import SwiftUI

struct LiveCameraView: View {
    
    @StateObject var viewModel = LiveCameraVM()
    
    var body: some View {
        
        Rectangle()
            .fill(.clear)
            .background {
                VStack {
                    if let hasImage = viewModel.frame {
                        Image(decorative: hasImage, scale: 1.0, orientation: .up)
                    } else {
                        Color.black
                    }
                }
                .ignoresSafeArea()
            }
            .overlay {
                if viewModel.frame != nil {
                VStack(spacing: 0) {
                        
                        HStack() {
                            Spacer()
                            
                            Button {
                                viewModel.didTapFocusBtn()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.blue)
                                        .frame(width: 110, height: 35)
                                    
                                    Text("Focus")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.trailing, 8)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        HStack() {
                            Spacer()
                            
                            Button {
                                viewModel.didTapExposureBtn()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.red)
                                        .frame(width: 110, height: 35)
                                    
                                    Text("Exposure")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.trailing, 8)
                        }
                        .padding(.bottom, 20)
                    
                        HStack() {
                            Spacer()
                            
                            Button {
                                viewModel.didTapWBBtn()
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(.green)
                                        .frame(width: 110, height: 35)
                                    
                                    Text("White balance")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16))
                                }
                            }
                            .padding(.trailing, 8)
                        }
                    
                    Text("f - \(String(format: "%.2f", viewModel.f_value))")
                        .font(.system(size: 20))
                        .foregroundColor(Color.yellow)
                        .bold()
                        .padding(.top, 20)
                    
                        Spacer()
                        
                    if viewModel.indicatorState != nil {
                        
                        if viewModel.indicatorState == .FOCUS {
                            HStack {
                                Spacer()
                                Text(viewModel.lensePosition.description)
                                    .foregroundColor(.blue)
                                
                            }
                            .padding(.trailing, viewModel.sliderPadding)
                            .bold()
                            
                            ZStack {
                                Capsule()
                                    .fill(.black.opacity(0.25))
                                    .frame(height: 20)
                                
                                HStack {
                                    Capsule()
                                        .fill(.blue.opacity(0.4))
                                        .frame(width: UIScreenSize.width/2 - viewModel.sliderPadding + viewModel.focusOffset, height: 20)
                                    
                                    Spacer()
                                }
                                
                                Circle()
                                    .fill(.white)
                                    .frame(width: viewModel.indicatorRadius)
                                    .background {
                                        Circle().stroke(Color.black, lineWidth: 5)
                                    }
                                    .offset(x: viewModel.focusOffset)
                                    .gesture(DragGesture().onChanged({ value in
                                        
                                        if value.location.x < -(UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2) {
                                            viewModel.focusOffset = -(UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2)
                                        } else if value.location.x > UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2 {
                                            viewModel.focusOffset = UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2
                                        } else {
                                            viewModel.focusOffset = value.location.x
                                        }
                                        
                                    }))
                            }
                            .padding(.bottom, 50)
                            .padding(.horizontal, viewModel.sliderPadding)
                            
                        } else if viewModel.indicatorState == .EXPOSURE {
                            // Shutter Speed
                            HStack {
                                Spacer()
                                Text("S/S: 1/\(viewModel.expoSSConstant)")
                                    .foregroundColor(.red)
                            }
                            .padding(.trailing, viewModel.sliderPadding)
                            .bold()
                            
                            ZStack {
                                Capsule()
                                    .fill(.black.opacity(0.25))
                                    .frame(height: 20)
                                
                                HStack {
                                    Capsule()
                                        .fill(.red.opacity(0.4))
                                        .frame(width: viewModel.expoSSOffset + viewModel.indicatorRadius/2, height: 20)
                                    
                                    Spacer()
                                }
                                
                                Circle()
                                    .fill(.white)
                                    .frame(width: viewModel.indicatorRadius)
                                    .background {
                                        Circle().stroke(Color.black, lineWidth: 5)
                                    }
                                    .offset(x: viewModel.expoSSOffset - UIScreenSize.width/2 + viewModel.sliderPadding + viewModel.indicatorRadius/2)
                                    .gesture(DragGesture().onChanged({ value in
                                        
                                        if value.location.x < -(UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2) {
                                            viewModel.expoSSOffset = 0
                                        } else if value.location.x > UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2 {
                                            viewModel.expoSSOffset = UIScreenSize.width - 2*viewModel.sliderPadding - viewModel.indicatorRadius
                                        } else {
                                            viewModel.expoSSOffset = value.location.x + UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2
                                        }
                                        
                                    }))
                            }
                            .padding(.bottom, 50)
                            .padding(.horizontal, viewModel.sliderPadding)
                            
                            // ISO
                            HStack {
                                Spacer()
                                Text("ISO: \(viewModel.expoIsoConstant.description)")
                                    .foregroundColor(.red)
                            }
                            .padding(.trailing, viewModel.sliderPadding)
                            .bold()
                            
                            ZStack {
                                Capsule()
                                    .fill(.black.opacity(0.25))
                                    .frame(height: 20)
                                
                                HStack {
                                    Capsule()
                                        .fill(.red.opacity(0.4))
                                        .frame(width: viewModel.expoIsoOffset + viewModel.indicatorRadius/2, height: 20)
                                    
                                    Spacer()
                                }
                                
                                Circle()
                                    .fill(.white)
                                    .frame(width: viewModel.indicatorRadius)
                                    .background {
                                        Circle().stroke(Color.black, lineWidth: 5)
                                    }
                                    .offset(x: viewModel.expoIsoOffset - UIScreenSize.width/2 + viewModel.sliderPadding + viewModel.indicatorRadius/2)
                                    .gesture(DragGesture().onChanged({ value in
                                        
                                        if value.location.x < -(UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2) {
                                            viewModel.expoIsoOffset = 0
                                        } else if value.location.x > UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2 {
                                            viewModel.expoIsoOffset = UIScreenSize.width - 2*viewModel.sliderPadding - viewModel.indicatorRadius
                                        } else {
                                            viewModel.expoIsoOffset = value.location.x + UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2
                                        }
                                        
                                    }))
                            }
                            .padding(.bottom, 50)
                            .padding(.horizontal, viewModel.sliderPadding)
                            
                        } else if viewModel.indicatorState == .WB {
                            
                            if viewModel.wbOption == nil {
                                HStack(spacing: 30) {
                                    Button {
                                        viewModel.didTapTempBtn()
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(.black)
                                                .frame(width: 110, height: 35)
                                            
                                            Text("Temperature")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                    Button {
                                        viewModel.didTapRGBBtn()
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(.black)
                                                .frame(width: 110, height: 35)
                                            
                                            Text("RGB")
                                                .foregroundColor(.white)
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                }
                                .padding(.bottom, 40)
                                
                            } else if viewModel.wbOption == .RGB {
                            
                                HStack {
                                    Spacer()
                                    Text("Red: \(viewModel.redConstant.description)")
                                        .foregroundColor(.red)
                                }
                                .padding(.trailing, viewModel.sliderPadding)
                                .bold()

                                ZStack {
                                    Capsule()
                                        .fill(.black.opacity(0.25))
                                        .frame(height: 20)

                                    HStack {
                                        Capsule()
                                            .fill(.red.opacity(0.4))
                                            .frame(width: viewModel.redOffset + viewModel.indicatorRadius/2, height: 20)

                                        Spacer()
                                    }

                                    Circle()
                                        .fill(.white)
                                        .frame(width: viewModel.indicatorRadius)
                                        .background {
                                            Circle().stroke(Color.black, lineWidth: 5)
                                        }
                                        .offset(x: viewModel.redOffset - UIScreenSize.width/2 + viewModel.sliderPadding + viewModel.indicatorRadius/2)
                                        .gesture(DragGesture().onChanged({ value in

                                            if value.location.x < -(UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2) {
                                                viewModel.redOffset = 0
                                            } else if value.location.x > UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2 {
                                                viewModel.redOffset = UIScreenSize.width - 2*viewModel.sliderPadding - viewModel.indicatorRadius
                                            } else {
                                                viewModel.redOffset = value.location.x + UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2
                                            }

                                        }))
                                }
                                .padding(.bottom, 50)
                                .padding(.horizontal, viewModel.sliderPadding)

                                HStack {
                                    Spacer()
                                    Text("Green: \(viewModel.greenConstant.description)")
                                        .foregroundColor(.green)
                                }
                                .padding(.trailing, viewModel.sliderPadding)
                                .bold()

                                ZStack {
                                    Capsule()
                                        .fill(.black.opacity(0.25))
                                        .frame(height: 20)

                                    HStack {
                                        Capsule()
                                            .fill(.green.opacity(0.4))
                                            .frame(width: viewModel.greenOffset + viewModel.indicatorRadius/2, height: 20)

                                        Spacer()
                                    }

                                    Circle()
                                        .fill(.white)
                                        .frame(width: viewModel.indicatorRadius)
                                        .background {
                                            Circle().stroke(Color.black, lineWidth: 5)
                                        }
                                        .offset(x: viewModel.greenOffset - UIScreenSize.width/2 + viewModel.sliderPadding + viewModel.indicatorRadius/2)
                                        .gesture(DragGesture().onChanged({ value in

                                            if value.location.x < -(UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2) {
                                                viewModel.greenOffset = 0
                                            } else if value.location.x > UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2 {
                                                viewModel.greenOffset = UIScreenSize.width - 2*viewModel.sliderPadding - viewModel.indicatorRadius
                                            } else {
                                                viewModel.greenOffset = value.location.x + UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2
                                            }

                                        }))
                                }
                                .padding(.bottom, 50)
                                .padding(.horizontal, viewModel.sliderPadding)

                                HStack {
                                    Spacer()
                                    Text("Blue: \(viewModel.blueConstant.description)")
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing, viewModel.sliderPadding)
                                .bold()

                                ZStack {
                                    Capsule()
                                        .fill(.black.opacity(0.25))
                                        .frame(height: 20)

                                    HStack {
                                        Capsule()
                                            .fill(.blue.opacity(0.4))
                                            .frame(width: viewModel.blueOffset + viewModel.indicatorRadius/2, height: 20)

                                        Spacer()
                                    }

                                    Circle()
                                        .fill(.white)
                                        .frame(width: viewModel.indicatorRadius)
                                        .background {
                                            Circle().stroke(Color.black, lineWidth: 5)
                                        }
                                        .offset(x: viewModel.blueOffset - UIScreenSize.width/2 + viewModel.sliderPadding + viewModel.indicatorRadius/2)
                                        .gesture(DragGesture().onChanged({ value in

                                            if value.location.x < -(UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2) {
                                                viewModel.blueOffset = 0
                                            } else if value.location.x > UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2 {
                                                viewModel.blueOffset = UIScreenSize.width - 2*viewModel.sliderPadding - viewModel.indicatorRadius
                                            } else {
                                                viewModel.blueOffset = value.location.x + UIScreenSize.width/2 - viewModel.sliderPadding - viewModel.indicatorRadius/2
                                            }

                                        }))
                                }
                                .padding(.bottom, 50)
                                .padding(.horizontal, viewModel.sliderPadding)
                                
                            } else if viewModel.wbOption == .TEMPERATURE {
                                HStack(spacing: 10) {
                                    Button {
                                        viewModel.didTapTmpConstantBtn(temp: 3200)
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill( viewModel.selectedTemp == 3200 ? .black : .white )
                                                .frame(width: 60, height: 35)
                                            
                                            Text("3200")
                                                .foregroundColor( viewModel.selectedTemp == 3200 ? .white : .black )
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                    Button {
                                        viewModel.didTapTmpConstantBtn(temp: 4000)
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill( viewModel.selectedTemp == 4000 ? .black : .white )
                                                .frame(width: 60, height: 35)
                                            
                                            Text("4000")
                                                .foregroundColor( viewModel.selectedTemp == 4000 ? .white : .black )
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                    Button {
                                        viewModel.didTapTmpConstantBtn(temp: 5200)
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill( viewModel.selectedTemp == 5200 ? .black : .white )
                                                .frame(width: 60, height: 35)
                                            
                                            Text("5200")
                                                .foregroundColor( viewModel.selectedTemp == 5200 ? .white : .black )
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                    Button {
                                        viewModel.didTapTmpConstantBtn(temp: 6000)
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill( viewModel.selectedTemp == 6000 ? .black : .white )
                                                .frame(width: 60, height: 35)
                                            
                                            Text("6000")
                                                .foregroundColor( viewModel.selectedTemp == 6000 ? .white : .black )
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                    Button {
                                        viewModel.didTapTmpConstantBtn(temp: 7000)
                                    } label: {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill( viewModel.selectedTemp == 7000 ? .black : .white )
                                                .frame(width: 60, height: 35)
                                            
                                            Text("7000")
                                                .foregroundColor( viewModel.selectedTemp == 7000 ? .white : .black )
                                                .font(.system(size: 16))
                                        }
                                    }
                                    
                                }
                                .padding(.bottom, 40)
                                
                            }
                            

                        }
                            
                    }
                        
                        Image(systemName: "circle.circle")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .onTapGesture {
                                viewModel.didTapShutterBtn()
                            }
                    }
                } else {
                    VStack {
                        Text("Sorry!")
                            .font(.system(size: 20))
                        Text("Your camera does not support!")
                            .font(.system(size: 18))
                    }
                    .foregroundColor(.white)
                    .bold()
                }
            }
    }
}

struct LiveCamera_Previews: PreviewProvider {
    static var previews: some View {
        LiveCameraView()
    }
}
