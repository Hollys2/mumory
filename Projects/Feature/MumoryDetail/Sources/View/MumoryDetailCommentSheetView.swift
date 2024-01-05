//
//  MumoryDetailCommentSheetView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct Comment: View {
    
    @State private var isSecretComment: Bool = false
    @State private var isMenuShown: Bool = false
    @State private var isSelectedComment: Bool = false
    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다."
    //    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다. 게다가 문맥에 어울리지 않는 한자어를 남발하는 바람에 내용 파악조차 어렵습니다. 서술형 답안을 작성하고, 논술 시험을 대비하는 학생들의 글에서 흔히 발견하는 문제입니다. 앞으로 연재할 글쓰기의 10가지 원칙을 충분히 익힌 뒤 연습문제로 확인하세요. 1회성 연습에 그치지 말고 평소에 글을 읽고 쓸 때도 원칙을 적용해야 합니다. 시간이 없다고요? 매일 보는 교과서를 활용하세요. 공부할 때 글쓰기 원칙에 어긋나는 문장을 발견한다면 원칙에 맞춰 바꿔 써 보세요. 매회 실리는 ‘교과서 ‘옥의 티’’ 꼭지를 참고하면 도움이 될 겁니다. 예문은 초·중등 학생에게 실질적인 도움을 주기 위해 초·중등 대상 신문활용교육(NIE) 매체인 <아하! 한겨레> 누리집(ahahan.co.kr)에 올라온 글 위주로 골랐습니다."
    
    var body: some View {
        HStack(alignment: .top,  spacing: 13) {
            SharedAsset.profileMumoryDetail.swiftUIImage
                .resizable()
                .frame(width: 32, height: 32)
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 13)
                    
                    HStack(spacing: 0) {
                        Text("1일 전")
                            .font(
                                Font.custom("Pretendard", size: 13)
                                    .weight(.medium)
                            )
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        
                        Spacer().frame(width: 5)
                        
                        SharedAsset.commentLockMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: 15, height: 15)
                        
                        Spacer()
                        
                        Button(action: {
                            self.isMenuShown = true
                        }, label: {
                            SharedAsset.commentMenuMumoryDetail.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                        })
                        
                    } // HStack
                    
                    
                    Text(isSecretComment ? "비밀 댓글입니다." : textContent)
                        .lineSpacing(20)
                        .font(isSecretComment ? Font.custom("Pretendard", size: 14)
                            .weight(.medium) : Font.custom("Pretendard", size: 14))
                        .foregroundColor(isSecretComment ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding(.vertical, 15)
                    //                        .background(Color.gray.opacity(0.2))
                    
                } // VStack
                .padding(.horizontal, 15)
                .background(
                    Rectangle()
                        .foregroundColor(.clear)
                        .background(isSelectedComment ? Color(red: 0.09, green: 0.09, blue: 0.09) : Color(red: 0.12, green: 0.12, blue: 0.12))
                        .cornerRadius(15)
                )
                
                Spacer().frame(height: 15)
                
                Button(action: {
                    textContent += "\nMore lines added."
                }, label: {
                    Text("답글 달기")
                        .font(
                            Font.custom("Pretendard", size: 12)
                                .weight(.medium)
                        )
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        .background(.black)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
                
                Spacer().frame(height: 13)
            } // VStack
            .background(.blue)
            
        } // HStack
        .frame(width: UIScreen.main.bounds.width - 40)
        .frame(minHeight: 117 - 20)
        .padding(.top, 12)
        .background(.pink)
        
        
        // MARK: Reply
        Reply()
        
        Spacer().frame(height: 15)
        
        Rectangle()
            .foregroundColor(.clear)
            .frame(width: UIScreen.main.bounds.width - 10, height: 0.5)
            .background(Color(red: 0.25, green: 0.25, blue: 0.25))
        
        Spacer().frame(height: 5)
    }
}

struct Reply: View {
    
    @State private var isSecretComment: Bool = true
    @State private var isMenuShown: Bool = false
    @State private var textContent = "주어와 서술어는 호응하지 않고, 문장은 엿가락처럼 길기만 합니다."
    
    var body: some View {
        HStack(alignment: .top, spacing: 13) {
            SharedAsset.profileMumoryDetail.swiftUIImage
                .resizable()
                .frame(width: 28, height: 28)
            
            VStack(spacing: 0) {
                Spacer().frame(height: 13)
                
                HStack(spacing: 5) {
                    Text("닉네임임임임임")
                        .font(
                            Font.custom("Pretendard", size: 13)
                                .weight(.semibold)
                        )
                        .foregroundColor(.white)
                    
                    Text("・")
                        .font(
                            Font.custom("Pretendard", size: 13)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        .frame(width: 4, alignment: .bottom)
                    
                    Text("1일 전")
                        .font(
                            Font.custom("Pretendard", size: 13)
                                .weight(.medium)
                        )
                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                    
                    SharedAsset.commentLockMumoryDetail.swiftUIImage
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Spacer()
                    
                    Button(action: {
                        self.isMenuShown = true
                    }, label: {
                        SharedAsset.commentMenuMumoryDetail.swiftUIImage
                            .resizable()
                            .frame(width: 18, height: 18)
                    })
                    
                } // HStack
                
                Text(isSecretComment ? "비밀 댓글입니다." : textContent)
                    .lineSpacing(20)
                    .font(isSecretComment ? Font.custom("Pretendard", size: 14)
                        .weight(.medium) : Font.custom("Pretendard", size: 14))
                    .foregroundColor(isSecretComment ? Color(red: 0.64, green: 0.51, blue: 0.99) : .white)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(.vertical, 15)
                //                        .background(Color.gray.opacity(0.2))
                
            } // VStack
            .padding(.horizontal, 15)
            .background(
                Rectangle()
                    .foregroundColor(.clear)
                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .cornerRadius(15)
            )
        } // HStack
        .frame(width: UIScreen.main.bounds.width - 40 - 32 - 13)
        .frame(minHeight: 77)
        .padding(.top, 10)
        .padding(.leading, 45)
        .background(.black)
        
    }
}

public struct MumoryDetailCommentSheetView: View {
    
    @State private var commentText: String = ""
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    public var body: some View {
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
                        withAnimation(Animation.easeInOut(duration: 0.2)) {
                            appCoordinator.isMumoryDetailCommentSheetViewShown = false
                        }
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
                    // MARK: Comment
                    Comment()
                }
            }
            .gesture(TapGesture(count: 1))
            
            ZStack {
                Rectangle()
                  .foregroundColor(.clear)
                  .frame(height: 36)
                  .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                
                
                HStack(spacing: 5) {
                    Text("닉네임임임임임님에게 답글 남기는 중")
                        .font(
                            Font.custom("Pretendard", size: 12)
                                .weight(.medium)
                        )
                        .foregroundColor(.white)
                    
                    Text("・")
                      .font(
                        Font.custom("Pretendard", size: 13)
                          .weight(.medium)
                      )
                      .multilineTextAlignment(.center)
                      .foregroundColor(.white)
                      .frame(width: 4, alignment: .bottom)
                    
                    Button(action: {
                        
                    }, label: {
                        Text("취소")
                          .font(
                            Font.custom("Pretendard", size: 12)
                              .weight(.medium)
                          )
                          .foregroundColor(.white)
                    })
                    
                }
            }
            
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
                                SharedAsset.commentWriteOffButtonMumoryDetail.swiftUIImage
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
        .frame(height: UIScreen.main.bounds.height * 0.84)
        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
        .cornerRadius(23, corners: [.topLeft, .topRight])
    }
}

//struct MumoryDetailCommentSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        MumoryDetailCommentSheetView()
//    }
//}
