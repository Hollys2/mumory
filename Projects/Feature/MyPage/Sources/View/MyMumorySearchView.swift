//
//  MyMumorySearchView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/30.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared

public struct MyMumorySearchView: View {
    
    @Binding private var isShown: Bool

    @State private var searchText: String = ""
    @State private var currentTabSelection: Int = 0
    @State private var isRecentSearch: Bool = false
    @State private var recentSearches: [String] = []
    @State private var isSearching: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    public init(isShown: Binding<Bool>) {
        self._isShown = isShown
        self._recentSearches = State(initialValue: UserDefaults.standard.stringArray(forKey: "myMumorySearch") ?? [])
    }
        
    public var body: some View {
        VStack(spacing: 0) {
            
            Spacer().frame(height: self.getSafeAreaInsets().top + 12)
            
            HStack(spacing: 8) {
                ZStack(alignment: .leading) {
                    TextField("", text: $searchText,
                              prompt: Text("나의 뮤모리 검색").font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .submitLabel(.search)
                    .onSubmit {
                        self.isSearching = true
                        
                        self.currentUserViewModel.mumoryViewModel.searchedMumoryAnnotations = []
                        currentUserViewModel.mumoryViewModel.searchMumoryByContent(self.searchText) {
                            self.isSearching = false
                        }
                        
                        recentSearches.insert(self.searchText, at: 0)
                        var uniqueRecentSearches: [String] = []
                        for search in recentSearches {
                            if !uniqueRecentSearches.contains(search) {
                                uniqueRecentSearches.append(search)
                            }
                        }
                        if uniqueRecentSearches.count > 10 {
                            uniqueRecentSearches = Array(recentSearches.prefix(10)) // 최대 10개까지만 유지
                        }
                        recentSearches = uniqueRecentSearches
                        UserDefaults.standard.set(recentSearches, forKey: "myMumorySearch")
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .padding(.horizontal, 15 + 23 + 7)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    )
                    .foregroundColor(.white)
                    
                    
                    SharedAsset.searchIconCreateMumory.swiftUIImage
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        .padding(.leading, 15)
                    
                    if !self.searchText.isEmpty {
                        HStack {
                            Spacer()
                            SharedAsset.removeButtonSearch.swiftUIImage
                                .resizable()
                                .frame(width: 23, height: 23)
                                .onTapGesture {
                                    self.searchText = ""
                                }
                        }
                        .padding(.trailing, 17)
                    }
                }
                
                Text("취소")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.white)
                    .onTapGesture {
                        self.currentUserViewModel.mumoryViewModel.searchedMumoryAnnotations.removeAll()
                        self.isShown = false
                    }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
            
            if self.searchText == "" {
                VStack(spacing: 0) {

                    HStack {
                        Text("최근 검색")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            .foregroundColor(.white)

                        Spacer()

                        if !self.recentSearches.isEmpty {
                            Button(action: {
                                self.recentSearches = []
                                UserDefaults.standard.set(recentSearches, forKey: "myMumorySearch")
                            }) {
                                Text("전체삭제")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            }
                        }
                    }
                    .padding([.horizontal, .top], 20)
                    .padding(.bottom, 11)

                    if !self.recentSearches.isEmpty {
                        ForEach(self.recentSearches, id: \.self) { value in
                            RecentSearchItem(title: value) {
                                self.recentSearches.removeAll { $0 == value }
                                UserDefaults.standard.set(self.recentSearches, forKey: "myMumorySearch")
                            }
                            .onTapGesture {
                                self.isSearching = true
                                
                                self.searchText = value
                                
                                self.currentUserViewModel.mumoryViewModel.searchedMumoryAnnotations = []
                                self.currentUserViewModel.mumoryViewModel.searchMumoryByContent(self.searchText) {
                                    self.isSearching = false
                                }
                                
                                recentSearches.insert(self.searchText, at: 0)
                                recentSearches = Array(Set(recentSearches).prefix(10))
                                UserDefaults.standard.set(recentSearches, forKey: "myMumorySearch")
                            }
                        }
                    } else {
                        Text("최근 검색내역이 없습니다.")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                            .frame(height: 50)
                    }

                    Spacer().frame(height: 15)
                }
                .frame(width: getUIScreenBounds().width - 40)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                .cornerRadius(15)
                .padding(.top, 6)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Text("검색 결과 \(self.currentUserViewModel.mumoryViewModel.searchedMumoryAnnotations.count)건")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65))
                            
                            Spacer()
                        }
                        .padding(.top, 13)
                        .padding(.bottom, 19)
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 0) {
                            ForEach(self.currentUserViewModel.mumoryViewModel.searchedMumoryAnnotations, id: \.self) { mumory in
                                SearchedMumoryItemView(mumory: mumory)
                            }
                        }
                        .frame(height: 148 * CGFloat(self.currentUserViewModel.mumoryViewModel.searchedMumoryAnnotations.count) + 30)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .cornerRadius(15)
                        .padding(.horizontal, 20)
                        .overlay(
                            Rectangle()
                                .frame(width: getUIScreenBounds().width - 40, height: 0.3)
                                .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                .offset(y: -15)
                                .opacity(self.currentUserViewModel.mumoryViewModel.searchedMumoryAnnotations.isEmpty ? 0 : 1)
                            , alignment: .bottom
                        )
                        .padding(.bottom, 100)
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}
