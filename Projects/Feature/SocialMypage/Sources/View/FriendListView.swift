//
//  FriendListView.swift
//  Feature
//
//  Created by 제이콥 on 3/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct FriendListView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    private let lineGray = Color(white: 0.48)
    @State var term: String = ""
    @State var friends: [MumoriUser]
    @State var results: [MumoriUser]
    init(friends: [MumoriUser]) {
        self.friends = friends
        self.results = friends
    }
    
    var body: some View {
        ZStack(alignment: .top, content: {
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                HStack{
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    Text("친구")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    SharedAsset.addFriendOnSocial.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .frame(height: 63)
                
                Divider()
                    .background(lineGray)
                    .frame(height: 0.5)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 0, content: {
                        SearchTextField(term: $term, placeHolder: "친구 검색")
                            .onChange(of: term) { value in
                                if term.isEmpty {
                                    DispatchQueue.main.async {
                                        self.results = friends
                                    }
                                }else {
                                    let result = friends.filter({ user in
                                        return user.nickname.contains(value.lowercased()) || user.id.contains(value.lowercased())
                                    })
                                    if result != self.results {
                                        DispatchQueue.main.async {
                                            self.results = result
                                        }
                                    }
                                }
                            }
                        
                        Text("\(friends.count)명")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.leading, 20)
                            .padding(.bottom, 15)
                        
                        ForEach(results, id: \.uid) { friend in
                            FriendListItem(friend: friend)
                                .onTapGesture {
                                    appCoordinator.rootPath.append(MyPage.friendPage(friend: friend))
                                }
                        }
                            
                    })
                }
            })
        
        })
    }
}

//#Preview {
//    FriendListView()
//}

struct SearchTextField: View {
    @Binding var term: String
    let placeHolder: String
    init(term: Binding<String>, placeHolder: String) {
        self._term = term
        self.placeHolder = placeHolder
    }
    
    let textfieldBackground = Color(white: 0.24)
    var body: some View {
        HStack(spacing: 0, content: {
            SharedAsset.graySearch.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(width: 23, height: 23)
                .padding(.trailing, 7)
            
            TextField("", text: $term, prompt: getPrompt(placeHolder: self.placeHolder))
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundStyle(Color.white)
                .frame(maxWidth: .infinity)
            
            Button {
                term = ""
            } label: {
                SharedAsset.xWhiteCircle.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
            }
            .padding(.leading, 2)
          
        })
        .padding(.horizontal, 15)
        .frame(height: 45)
        .background(textfieldBackground)
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 28)
    }
    
    
    private func getPrompt(placeHolder: String) -> Text {
        return Text(placeHolder)
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
            .foregroundColor(ColorSet.subGray)
    }
}

