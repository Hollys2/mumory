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
    
    private var mumoryAnnotation: MumoryAnnotation
    
    @Binding private var translation: CGSize
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @GestureState var dragAmount: CGSize = CGSize(width: 0, height: 0)
    
    @State private var isEditMumory: Bool = false
    
    public init(mumoryAnnotation: MumoryAnnotation, translation: Binding<CGSize>) {
        self.mumoryAnnotation = mumoryAnnotation
        self._translation =  translation
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
        
            Spacer().frame(height: 9)
            
            Image(uiImage: SharedAsset.dragIndicator.image)
                .resizable()
                .frame(width: 47, height: 4)
            
            Spacer().frame(height: 9)
            
            VStack(spacing: 0) {
                Group {
                    HStack(spacing: 0) {
                        Spacer().frame(width: 24)
                        SharedAsset.editMumoryDetailMenu.swiftUIImage
                            .frame(width: 22, height: 22)
                        
                        Spacer().frame(width: 14)
                        
                        Text("뮤모리 수정")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .foregroundColor(.white)
                            .frame(height: 55)
                        
                        Spacer()
                    }
                    .background(Color(red: 0.09, green: 0.09, blue: 0.09)) // 배경색 지정해야 탭제스처 동작함
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.appCoordinator.isMumoryDetailMenuSheetShown = false
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.appCoordinator.rootPath.append(MumoryView(type: .editMumoryView, musicItemID: self.mumoryAnnotation.musicModel.songID))
                        }
                    }
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.5)
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
                        .frame(height: 0.5)
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
                        .frame(height: 0.5)
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
                        .frame(height: 0.5)
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
                        .frame(height: 0.5)
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
            
            Spacer().frame(height: 9)
        }
        .frame(width: UIScreen.main.bounds.width - 14, height: 361)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(15)
    }
}

//struct MumoryDetailMenuSheetView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let appCoordinator = AppCoordinator() // 또는 실제 AppCoordinator 인스턴스 생성
//
//        MumoryDetailMenuSheetView()
//            .environmentObject(appCoordinator)
//    }
//}
