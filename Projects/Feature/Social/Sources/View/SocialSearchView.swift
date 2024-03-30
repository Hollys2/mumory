//
//  SocialSearchView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/08.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct PageTabView<Content: View, Label: View>: View {
    
    @Binding var selection: Int
    
    private var content: Content
    private var label: Label
    
    init(selection: Binding<Int>, @ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping () -> Content) {
        self._selection = selection
        self.label = label()
        self.content = content()
    }
    
    @State private var underlineOffset: CGFloat = 0
    @State private var tabWidths: [CGFloat] = Array(repeating: 0, count: 3)
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(spacing: 0) {
                label
            }
            .onPreferenceChange(TabWidthPreferenceKey.self) { preferences in
                for (index, width) in preferences {
                    tabWidths[index] = width
                }
            }
            
            Rectangle()
                .fill(Color(red: 0.64, green: 0.51, blue: 0.99))
                .frame(width: tabWidths[selection], height: 3)
                .frame(width: getUIScreenBounds().width / 2, height: 3)
                .offset(x: underlineOffset, y: 0)
                .animation(.easeInOut(duration: 0.2), value: selection)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: getUIScreenBounds().width, height: 0.3)
                .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.3))
            
            TabView(selection: $selection) {
                content
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .onChange(of: selection) { _ in
                withAnimation(.easeInOut(duration: 0.2)) {
                    underlineOffset = getUIScreenBounds().width / CGFloat(2) * CGFloat(selection)
                }
            }
        }
    }
}

public struct SocialSearchView: View {
    
    @Binding private var isShown: Bool
    
    @State private var searchText: String = ""
    @State private var currentTabSelection: Int = 0
    @State private var isRecentSearch: Bool = false
    @State private var recentSearches: [String] = []

    @State private var isSearching: Bool = false
    
    @StateObject var friendManager: FriendManager = .init()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    
    public init(isShown: Binding<Bool>) {
        self._isShown = isShown
        self._recentSearches = State(initialValue: UserDefaults.standard.stringArray(forKey: "socialSearch") ?? [])
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            Spacer().frame(height: self.appCoordinator.safeAreaInsetsTop + 12)
            
            HStack(spacing: 8) {
                
                ZStack(alignment: .leading) {
                    
                    TextField("", text: $searchText, prompt:
                                Text("친구 및 게시물 검색")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .submitLabel(.search)
                    .onSubmit {
                        self.isSearching = true

                        friendManager.searchedFriends = []
                        mumoryDataViewModel.searchedMumoryAnnotations = []
                        
                        friendManager.searchFriend(nickname: self.searchText)
                        mumoryDataViewModel.searchMumoryByContent(self.searchText) {
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
                        UserDefaults.standard.set(recentSearches, forKey: "socialSearch")
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
                        self.mumoryDataViewModel.searchedMumoryAnnotations.removeAll()
                        self.isShown = false
                    }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            
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
                                UserDefaults.standard.set(recentSearches, forKey: "socialSearch")
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
                                UserDefaults.standard.set(self.recentSearches, forKey: "socialSearch")
                            }
                            .onTapGesture {
                                self.isSearching = true
                                self.searchText = value
                                
                                mumoryDataViewModel.searchedMumoryAnnotations = []
                                friendManager.searchedFriends = []
                                
                                friendManager.searchFriend(nickname: self.searchText)
                                mumoryDataViewModel.searchMumoryByContent(self.searchText) {
                                    self.isSearching = false
                                }
                                
                                recentSearches.insert(self.searchText, at: 0)
                                recentSearches = Array(Set(recentSearches).prefix(10))
                                UserDefaults.standard.set(recentSearches, forKey: "socialSearch")
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
                PageTabView(selection: $currentTabSelection) {

                    ForEach(Array(["친구", "게시물"].enumerated()), id: \.element) { index, title in
                        Text(title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                            .multilineTextAlignment(.center)
                            .foregroundColor(currentTabSelection == index ? .white : Color(red: 0.82, green: 0.82, blue: 0.82))
                            .background(
                                GeometryReader{ g in
                                    Color.clear
                                        .preference(key: TabWidthPreferenceKey.self, value: [index: g.size.width])
                                }
                            )
                            .pageLabel()
                            .background(Color(red: 0.09, green: 0.09, blue: 0.09)) // 터치영역 확장
                            .onTapGesture {
                                withAnimation {
                                    currentTabSelection = index
                                }
                            }
                    }

                } content: {

                    ScrollView(showsIndicators: false) {

                        VStack(spacing: 0) {

                            ForEach(friendManager.searchedFriends, id: \.self) { friend in

                                HStack(spacing: 0) {

                                    Spacer().frame(width: 15)
                                    
                                    AsyncImage(url: friend.profileImageURL) { image in
                                        image
                                            .resizable()
                                         
                                    } placeholder: {
                                        friend.defaultProfileImage
                                            .resizable()
                                    }
                                    .frame(width: 50, height: 50)
                                    .onTapGesture {
                                        Task {
                                            if friend.uId == currentUserData.user.uId {
                                                appCoordinator.rootPath.append(MyPage.myPage)
                                            } else {
                                                let friend = await MumoriUser(uId: friend.uId)
                                                appCoordinator.rootPath.append(MumoryPage.friend(friend: friend))
                                            }
                                        }
                                    }

                                    Spacer().frame(width: 15)

                                    VStack(alignment: .leading, spacing: 5.5) {
                                        Text(friend.nickname)
                                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                                            .foregroundColor(.white)

                                        Text("@\(friend.id)")
                                            .font(SharedFontFamily.Pretendard.extraLight.swiftUIFont(size: 13))
                                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                    }

                                    Spacer()

                                    SharedAsset.nextButtonSocialSearch.swiftUIImage
                                        .resizable()
                                        .frame(width: 24, height: 24)

                                    Spacer().frame(width: 15)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                            }
                        }
                        .frame(height: 70 * CGFloat(friendManager.searchedFriends.count) + 30)
                        .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                        .cornerRadius(15)
                        .padding(.top, 18)
                        .padding(.horizontal, 20)
                    }
                    .pageView()
                    .tag(0)

                    ScrollView(showsIndicators: false) {

                        VStack(spacing: 0) {
                            
                            HStack(spacing: 0) {
                                
                                Text("검색 결과 \(mumoryDataViewModel.searchedMumoryAnnotations.count)건")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                    .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65))
                                
                                Spacer()
                                
                                Text("정확도")
                                    .font(self.isRecentSearch ? SharedFontFamily.Pretendard.light.swiftUIFont(size: 14) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(self.isRecentSearch ? Color(red: 0.65, green: 0.65, blue: 0.65) : Color(red: 0.64, green: 0.51, blue: 0.99))
                                    .overlay(
                                        self.isRecentSearch ? AnyView(EmptyView()) :
                                            AnyView(
                                                Rectangle()
                                                    .foregroundColor(.clear)
                                                    .frame(width: 5, height: 5)
                                                    .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                                                    .cornerRadius(2.5)
                                                    .offset(x: -10)
                                            )
                                        , alignment: .leading
                                    )
                                    .onTapGesture {
                                        self.mumoryDataViewModel.searchedMumoryAnnotations.sort { (doc1, doc2) -> Bool in
                                            guard let content1 = doc1.content, let content2 = doc2.content  else { return false }
                                            //                                  return content.localizedCaseInsensitiveCompare(searchText) == .orderedSame
                                            return content1.count < content2.count
                                        }
                                        
                                        self.isRecentSearch = false
                                    }
                                
                                Spacer().frame(width: 19)
                                
                                Text("최신")
                                    .font(self.isRecentSearch ? SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14) : SharedFontFamily.Pretendard.light.swiftUIFont(size: 14))
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(self.isRecentSearch ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.65, green: 0.65, blue: 0.65))
                                    .overlay(
                                        self.isRecentSearch ?
                                        AnyView(Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 5, height: 5)
                                            .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                                            .cornerRadius(2.5)
                                            .offset(x: -10))
                                        : AnyView(EmptyView())
                                        , alignment: .leading
                                    )
                                    .onTapGesture {
                                        self.mumoryDataViewModel.searchedMumoryAnnotations.sort { (doc1, doc2) -> Bool in
                                            return doc1.date > doc2.date
                                        }
                                        
                                        self.isRecentSearch = true
                                    }
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            
                            VStack(spacing: 0) {
                                
                                ForEach(mumoryDataViewModel.searchedMumoryAnnotations, id: \.self) { mumory in
                                    SearchedMumoryItemView(mumory: mumory)
                                }
                            }
                            .frame(height: 148 * CGFloat(mumoryDataViewModel.searchedMumoryAnnotations.count) + 30)
                            .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                            .cornerRadius(15)
                            .padding(.horizontal, 20)
                            .overlay(
                                Rectangle()
                                    .frame(width: getUIScreenBounds().width - 40, height: 0.3)
                                    .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                                    .offset(y: -15)
                                    .opacity(mumoryDataViewModel.searchedMumoryAnnotations.isEmpty ? 0 : 1)
                                , alignment: .bottom
                            )
                            .padding(.bottom, 100)
                        }
                    }
                    .tag(1)
                }
                .onDisappear {
                    self.currentTabSelection = 0
                }
            }
            
            Spacer(minLength: 0)
        }
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
        .simultaneousGesture(TapGesture(count: 1).onEnded({
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }))
        .loadingLottie(self.isSearching)
    }
}

struct SearchedMumoryItemView: View {
    
    var mumory: Mumory
    
    @State private var user: MumoriUser = MumoriUser()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            Spacer().frame(height: 15)
            
            HStack(alignment: .center, spacing: 0) {
                
                AsyncImage(url: user.profileImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        Color(red: 0.184, green: 0.184, blue: 0.184)
                    }
                }
                .frame(width: 24, height: 24)
                .mask {
                    Circle()
                }
                
                Spacer().frame(width: 7)
                
                Text("\(user.nickname)")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                    .foregroundColor(.white)
                    .frame(maxWidth: 75)
                    .frame(height: 10, alignment: .leading)
                    .fixedSize(horizontal: true, vertical: false)
                
                
                Text(" ・ \(DateManager.formattedDate(date: mumory.date, dateFormat: "M월 d일"))")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                
                Spacer()
                
                Image(uiImage: SharedAsset.locationMumoryDatail.image)
                    .resizable()
                    .frame(width: 15, height: 15)
                
                Spacer().frame(width: 4)
                
                Text("\(mumory.locationModel.locationTitle)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                    .lineLimit(1)
                    .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                    .frame(maxWidth: 99)
                    .frame(height: 12, alignment: .leading)
                    .fixedSize(horizontal: true, vertical: false)
            } // HStack
            
            Spacer().frame(height: 15)
            
            HStack(spacing: 0) {
                
                VStack(alignment: .leading, spacing: 0) {
                    mumory.content.map { content in
                        Text(content)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    }
                    
                    mumory.tags?.isEmpty == false ? (
                        HStack(spacing: 10) {
                            ForEach(mumory.tags!, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                                    .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                        }
                            .frame(maxWidth: .infinity, alignment: .leading) // HStack 정렬
                            .padding(.vertical, 5)
                    ) : nil
                    
                    HStack(spacing: 0) {
                        Image(uiImage: SharedAsset.musicIconMumoryDetail.image)
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Spacer().frame(width: 5)
                        
                        Text(mumory.musicModel.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                            .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Spacer().frame(width: 6)
                        
                        Text(mumory.musicModel.artist)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            .lineLimit(1)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } // VStack
                
                mumory.imageURLs?.isEmpty == false ? (
                    AsyncImage(url: URL(string: mumory.imageURLs![0])) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                        case .empty:
                            ProgressView()
                        default:
                            Color(red: 0.247, green: 0.247, blue: 0.247)
                        }
                    }
                        .foregroundColor(.clear)
                        .frame(width: 75, height: 75)
                        .background(Color(red: 0.247, green: 0.247, blue: 0.247))
                        .cornerRadius(5)
                        .padding(.leading, 20)
                        .overlay(
                            (mumory.imageURLs ?? []).count > 1 ? ZStack {
                                    Circle()
                                        .foregroundColor(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.6))
                                        .frame(width: 19, height: 19)
                                    
                                    Text("\((mumory.imageURLs ?? []).count)")
                                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 10))
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(.white)
                                }
                                .offset(x: -5, y: -5)
                            : nil

                            , alignment: .bottomTrailing
                        )
                ) : nil
                
            } // HStack
            
            Spacer().frame(height: 17)
            
            Spacer(minLength: 0)
        } // VStack
        .frame(height: 148)
        .padding(.horizontal, 17)
        .overlay(
            Rectangle()
                .frame(height: 0.3)
                .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
            , alignment: .top
        )
        .background(Color(red: 0.165, green: 0.165, blue: 0.165))
        .simultaneousGesture(TapGesture(count: 1).onEnded({
            self.mumoryDataViewModel.selectedMumoryAnnotation = self.mumory
            self.appCoordinator.rootPath.append(MumoryView(type: .mumoryDetailView, mumoryAnnotation: self.mumory))
        }))
        .onAppear {
            Task {
                self.user = await MumoriUser(uId: self.mumory.uId)
            }
        }
    }
}
