//
//  ReportView.swift
//  Feature
//
//  Created by 제이콥 on 3/31/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct ReportView: View {
    @EnvironmentObject var settingViewModel: SettingViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var menuTitle: String = "신고 유형을 선택해주세요."
    @State var title: String = ""
    @State var content: String = ""
    @State var email: String = ""
    
    init() {
         UITextView.appearance().backgroundColor = .clear
     }
    var body: some View {
        ZStack(alignment: .top) {
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack{
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .fixedSize()
                        .frame(width: 30, height: 30)
                    Spacer()
                    Text("신고하기")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 30, height: 30)
                }
                .padding(.horizontal, 20)
                .frame(height: 63)
                
                
                HStack(spacing: 14, content: {
                    Text("닉네임")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)

                    Text("\(settingViewModel.nickname)")
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                        .foregroundStyle(ColorSet.charSubGray)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 50)
                .padding(.leading, 20)
                
                HStack(spacing: 14, content: {
                    Text("이메일")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)

                    Text("\(settingViewModel.email)")
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                        .foregroundStyle(ColorSet.charSubGray)
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 50)
                .padding(.leading, 20)
                
                Menu {
                    Button(action: {
                        menuTitle = "스팸"
                    }, label: {
                        Text("스팸")
                    })
                    
                    Button(action: {
                        menuTitle = "성적 콘텐츠"
                    }, label: {
                        Text("성적 콘텐츠")
                    })
                    
                    Button(action: {
                        menuTitle = "자해"
                    }, label: {
                        Text("자해")
                    })
                    
                    Button(action: {
                        menuTitle = "잘못된 정보"
                    }, label: {
                        Text("잘못된 정보")
                    })
                    
                    Button(action: {
                        menuTitle = "혐오 활동"
                    }, label: {
                        Text("혐오 활동")
                    })
                    
                    Button(action: {
                        menuTitle = "모욕적인 내용 / 사생활 침해"
                    }, label: {
                        Text("모욕적인 내용 / 사생활 침해")
                    })
                    
                    Button(action: {
                        menuTitle = "노골적인 폭력 묘사"
                    }, label: {
                        Text("노골적인 폭력 묘사")
                    })
                    
                } label: {
                    HStack(spacing: 0, content: {
                        Text(menuTitle)
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 15)
                        
                        Spacer()
                        
                        SharedAsset.downArrowGray.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    })
                    .padding(.horizontal, 20)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .circular)
                            .stroke(Color.white, lineWidth: 0.5)
                            .frame(height: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                TextField("title", text: $title, prompt: prompt())
                    .padding(.horizontal, 20)
                    .frame(height: 50)
                    .background(ColorSet.moreDeepGray)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .foregroundStyle(Color.white)

                
                TextEditor(text: $content)
                    .frame(height: 150)
                    .padding(20)
                    .background(ColorSet.moreDeepGray)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .circular))
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 20)
                    .padding(.top, 15)
                    .foregroundStyle(Color.white)

                Spacer()
                
                WhiteButton(title: "보내기", isEnabled: !title.isEmpty && !content.isEmpty && !settingViewModel.email.isEmpty && !settingViewModel.nickname.isEmpty)
                    .padding(20)
                    .onTapGesture {
                        <#code#>
                    }
                    .disabled(title.isEmpty || content.isEmpty || settingViewModel.email.isEmpty || settingViewModel.nickname.isEmpty)
            }
        }
        .onAppear(perform: {
            settingViewModel.uid = currentUserData.uId
        })
        
        private func saveReport() {
            let db = FBManager.shared.db
            let data = [
                "uId": settingViewModel.uid
                "email": settingViewModel.email
            ]
            db.collection("Report").addDocument(data: <#T##[String : Any]#>)
        }
    }
    
    private func prompt() -> Text {
        return Text("제목을 입력하세요.")
            .foregroundColor(ColorSet.charSubGray)
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
    }
}

#Preview {
    ReportView()
}
