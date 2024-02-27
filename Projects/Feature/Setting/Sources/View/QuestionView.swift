//
//  QuestionView.swift
//  Feature
//
//  Created by 제이콥 on 2/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import Lottie

struct QuestionView: View {
    @EnvironmentObject var userManager: UserViewModel
    @Environment(\.dismiss) private var dismiss
    let placeHolder = "내용을 입력하세요."
    @State var title: String = ""
    @State var content: String = "내용을 입력하세요."
    @State var isLoading: Bool = false
    @State var isPresent: Bool = false
    @FocusState var isFocusOnContent: Bool
    private let darkGray = Color(red: 0.12, green: 0.12, blue: 0.12)
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
            
            ZStack{
                ColorSet.background.ignoresSafeArea()
                
                ScrollView{
                    VStack(spacing: 0, content: {
                        
                        //닉네임 라인
                        HStack(spacing: 0, content: {
                            Text("닉네임")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                                .foregroundStyle(.white)
                            
                            Text(userManager.nickname)
                                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                                .foregroundStyle(ColorSet.charSubGray)
                                .padding(.leading, 14)
                            
                            Spacer()
                        })
                        .padding(20)
                        .padding(.top, 3)
                        
                        //이메일 라인
                        HStack(spacing: 0, content: {
                            Text("이메일")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                                .foregroundStyle(.white)
                            
                            Text(verbatim: userManager.email)
                                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                                .foregroundStyle(ColorSet.charSubGray)
                                .padding(.leading, 14)
                            
                            Spacer()
                        })
                        .padding(20)
                        .padding(.top, 3)
                        
                        
                        TextField("", text: $title, prompt: getPrompt())
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(.white)
                            .padding(.top, 17)
                            .padding(.bottom, 17)
                            .padding(.leading, 14)
                            .padding(.trailing, 14)
                            .background(darkGray)
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .circular))
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 20)
                        
                        
                        
                        TextEditor(text: $content)
                            .font(content == placeHolder ?  SharedFontFamily.Pretendard.light.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundStyle(content == placeHolder ? ColorSet.charSubGray : .white)
                            .frame(height: 150)
                            .padding(15)
                            .background(darkGray)
                            .clipShape(RoundedRectangle(cornerRadius: 13, style: .circular))
                            .scrollContentBackground(.hidden)
                            .padding(.top, 15)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .focused($isFocusOnContent)
                            .onChange(of: isFocusOnContent) { value in
                                if value {
                                    content = content.replacingOccurrences(of: placeHolder, with: "")
                                }
                            }
                        
                        
                        
                        Button(action: {
                            uploadQuestion()
                        }, label: {
                            WhiteButton(title: "보내기", isEnabled: title.count > 0 && content.count > 0)
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                        })
                        .padding(.top, 87)
                        .disabled(!(title.count > 0 && content.count > 0))
                        
                        
                        
                        
                        Spacer()
                    })
                }
                
                LottieView(animation: .named("loading", bundle: .module))
                    .looping()
                    .opacity(isLoading ? 1 : 0)
                    .frame(width: userManager.width * 0.2, height: userManager.width * 0.2)
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(ColorSet.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        SharedAsset.back.swiftUIImage
                            .frame(width: 30, height: 30)
                    }
                    
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    NavigationLink {
                        HomeView()
                    } label: {
                        SharedAsset.home.swiftUIImage
                            .frame(width: 30, height: 30)
                    }
                    
                }
                
                ToolbarItem(placement: .principal) {
                    Text("1:1 문의")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
    }
    
    private func getPrompt() -> Text {
        return Text("제목을 입력하세요.")
            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
            .foregroundColor(ColorSet.charSubGray)
    }
    
    private func uploadQuestion(){
        isLoading = true
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        guard let currentUser = auth.currentUser else {
            print("no current user. please sign in again")
            return
        }
        
        let questionData: [String: Any] = [
            "uid": currentUser.uid,
            "title": title,
            "content": content
        ]
        
        db.collection("Question").addDocument(data: questionData) { error in
            if let error = error {
                print("error: \(error)")
            }else {
                isLoading = false
                dismiss()
            }
        }
        
        
    }
}

#Preview {
    QuestionView()
}
