//
//  MumoryDetailCommentSheetView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

//struct MyComment: View {
//
//    var body: some View {
//    }
//}
//
//struct OtherComment: View {
//
//    var body: some View {
//    }
//}

struct MumoryDetailCommentSheetView: View {
    
    @State private var commentText: String = ""
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 390, height: 72)
                    .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                    .cornerRadius(23)
                
                HStack {
                    Text("댓글")
                        .font(
                            Font.custom("Pretendard", size: 18)
                                .weight(.semibold)
                        )
                        .foregroundColor(.white)
                    
                    Spacer().frame(width: 5)
                    
                    Text("3")
                      .font(
                        Font.custom("Pretendard", size: 18)
                          .weight(.medium)
                      )
                      .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                    
                    Spacer()
                    
                    Button(action: {
                        
                    }, label: {
                        SharedAsset.commentCloseButtonMumoryDetail.swiftUIImage
                            .frame(width: 25, height: 25)
                    })
                } // HStack
                .frame(height: 72)
                .padding(.horizontal, 20)
                .background(.gray)
            }

            ScrollView {
                VStack(spacing: 0) {
                    

                }
            }
            
            Spacer()
            
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 72)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                    .overlay(
                        
                        Rectangle()
                            .frame(height: 0.5)
                            .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                            .offset(y: -36 - 0.25)
                    )
                
                HStack(spacing: 0) {
                    Spacer().frame(width: 16)
                    
                    Button(action: {
                        
                    }, label: {
                        SharedAsset.commentLockButtonMumoryDetail.swiftUIImage
                            .frame(width: 35, height: 39)
                    })

                    Spacer().frame(width: 12)
                    
//                    Rectangle()
//                      .foregroundColor(.clear)
//                      .frame(width: UIScreen.main.bounds.width * 0.78, height: 44.99997)
//                      .background(Color(red: 0.24, green: 0.24, blue: 0.24))
//                      .background(Color(red: 0.09, green: 0.09, blue: 0.09))
//                      .cornerRadius(22.99999)
                    
                    TextField("", text: $commentText, prompt: Text("댓글을 입력하세요.")
                        .font(Font.custom("Apple SD Gothic Neo", size: 15))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                    )
                    .padding(.leading, 25)
                    .padding(.trailing, 50)
                    .background(
                        ZStack(alignment: .trailing) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: UIScreen.main.bounds.width * 0.78, height: 44.99997)
                                .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                                .cornerRadius(22.99999)
                            
                            Button(action: {
                                
                            }, label: {
                                SharedAsset.commentWriteButtonMumoryDetail.swiftUIImage
                                    .frame(width: 20, height: 20)
                            })
                            .padding(.trailing, 10)
                        }
                    )
                    .foregroundColor(.white)
                    .frame(width: UIScreen.main.bounds.width * 0.78)
//                    .onChange(of: searchText){ newValue in
//                        if !searchText.isEmpty {
//                        } else {
//                        }
//                    }
                    
                    
                    Spacer().frame(width: 20)
                }
                .frame(maxWidth: .infinity)
                
            } // ZStack

        } // VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
        .cornerRadius(23, corners: [.topLeft, .topRight])
    }
}

struct MumoryDetailCommentSheetView_Previews: PreviewProvider {
    static var previews: some View {
        MumoryDetailCommentSheetView()
    }
}
