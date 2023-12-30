//
//  MumoryDetailMenuSheetView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

struct MumoryDetailMenuSheetView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @GestureState var dragAmount: CGSize = CGSize(width: 0, height: 0)
    @State private var translation: CGSize = CGSize(width: 0, height: 0)
    
    public init() {}
    
    var dragGesture: some Gesture {
        DragGesture()
            .updating($dragAmount) { value, state, _ in
                print("updating: \(value.translation.height)")
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        self.translation.height = value.translation.height
                    }
                }
                
            }
            .onEnded { value in
                print("onEnded: \(value.translation.height)")
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    if value.translation.height > 50 {
                        appCoordinator.isMumoryDetailMenuSheetShown = false
                    }
                    self.translation.height = 0
                }
            }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.12, green: 0.12, blue: 0.12)
            
            VStack(spacing: 0) {
//                Image(uiImage: SharedAsset.dragIndicator.image)
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 22)
//                    .background(.pink) // 색이 존재해야 제스처 동작함
//                    .gesture(dragGesture)
                
                Group {
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.editMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("뮤모리 수정")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.lockMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("나만 보기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.mapMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("지도에서 보기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                }
                
                //                Rectangle()
                //                    .foregroundColor(.clear)
                //                    .frame(height: 0.3)
                //                    .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                
                Group {
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.deleteMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("뮤모리 삭제")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(Color(red: 1, green: 0.25, blue: 0.25))
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.shareMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("공유하기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.complainMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("신고")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                }
            }
            .frame(width: UIScreen.main.bounds.width - 14 - 18, height: 330)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .cornerRadius(15)
        } // VStack
        .frame(width: UIScreen.main.bounds.width - 14, height: 361)
        .cornerRadius(15)
        .offset(y: (UIScreen.main.bounds.height - 361) / 2 - appCoordinator.safeAreaInsetsBottom) // withAnimation과 연관 있음
    }
}

struct MumoryDetailMenuSheetView_Previews: PreviewProvider {
    
    static var previews: some View {
        let appCoordinator = AppCoordinator() // 또는 실제 AppCoordinator 인스턴스 생성
        
        MumoryDetailMenuSheetView()
            .environmentObject(appCoordinator)
    }
}
