//
//  RegionMyMumoryView.swift
//  Feature
//
//  Created by 다솔 on 2024/03/27.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI

import Shared


public struct RegionMyMumoryView: View {
    
    @State private var isMyMumorySearchViewShown: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    let user: UserProfile
    let region: String
    let mumorys: [Mumory]
    
    public var body: some View {
        ZStack {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer().frame(height: self.getSafeAreaInsets().top + 19)
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            self.appCoordinator.rootPath.removeLast()
                        }, label: {
                            SharedAsset.backButtonTopBar.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                        })
                        
                        Spacer()
                        
                        TopBarTitleView(title: self.region)
                        
                        Spacer()
                        
                        Button(action: {
                            self.isMyMumorySearchViewShown = true
                        }, label: {
                            SharedAsset.searchButtonMypage.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                        })
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 16)
                        .overlay(
                            Rectangle()
                                .fill(Color(red: 0.651, green: 0.651, blue: 0.651, opacity: 0.4))
                                .frame(width: getUIScreenBounds().width, height: 0.3)
                            , alignment: .bottom)
                    
                    VStack(spacing: 0) {
                        ZStack(alignment: .top) {
                            ScrollView(showsIndicators: false) {
                                VStack(spacing: 0) {
                                    ForEach(Array(self.mumorys.enumerated()), id: \.element) { index, mumory in
                                        if index == 0 || (index > 0 && !isSameMonth(mumory, with: self.self.mumorys[index - 1])) {
                                            ZStack(alignment: .topLeading) {
                                                Rectangle()
                                                    .foregroundColor(.clear)
                                                    .frame(height: 31)
                                                    .overlay(
                                                        Rectangle()
                                                            .foregroundColor(.clear)
                                                            .frame(width: getUIScreenBounds().width, height: 0.3)
                                                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.4)),
                                                        alignment: .top
                                                    )
                                                
                                                Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "YYYY년 M월"))")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                                    .foregroundColor(.white)
                                                    .padding(.leading, 12)
                                                    .offset(y: 21)
                                            }
                                            .padding(.top, index == 0 ? 0 : 30)
                                        }
                                        
                                        MumoryItemView(mumory: mumory, mumorys: self.mumorys, isRecent: index == 0 ? true : false)
                                    }
                                    Spacer(minLength: 0)
                                } // VStack
                            } // ScrollView
                        }
                    } // VStack
                }
            }
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            
            
            if self.isMyMumorySearchViewShown {
                MyMumorySearchView(isShown: self.$isMyMumorySearchViewShown)
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
    }
    
    func isSameMonth(_ mumory1: Mumory, with mumory2: Mumory) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month], from: mumory1.date)
        let components2 = calendar.dateComponents([.year, .month], from: mumory2.date)
        return components1.year == components2.year && components1.month == components2.month
    }
}

struct MumoryItemView: View {
    
    @State private var vStackOffsetY: CGFloat = 0
    @State private var isTruncated: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    private var mumory: Mumory
    private var mumorys: [Mumory]
    private var isRecent: Bool
    
    init(mumory: Mumory, mumorys: [Mumory], isRecent: Bool) {
        self.mumory = mumory
        self.mumorys = mumorys
        self.isRecent = isRecent
    }
    
    private var previousDate: Date? {
        guard let index = mumorys.firstIndex(where: { $0.id == mumory.id }) else {
            return nil
        }
        guard index > 0 else {
            return nil
        }
        return mumorys[index - 1].date
    }
    
    private var isSameDateAsPrevious: Bool {
        guard let previousDate = previousDate else {
            return false
        }
        return Calendar.current.isDate(mumory.date, equalTo: previousDate, toGranularity: .day)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 12)
            
            VStack(spacing: 0) {
                if !isSameDateAsPrevious {
                    VStack(alignment: .center, spacing: 3) {
                        Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "dd"))")
                            .font(self.isRecent ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                            .foregroundColor(self.isRecent ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
                        
                        Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "E"))")
                            .font(self.isRecent ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(self.isRecent ? Color(red: 0.09, green: 0.09, blue: 0.09) : .white)
                    }
                    .frame(width: 35, height: 56, alignment: .center)
                    .background(self.isRecent ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.25, green: 0.25, blue: 0.25))
                    .cornerRadius(18)
                }
                
                Rectangle()
                    .fill(Color(red: 0.247, green: 0.247, blue: 0.247))
                    .frame(width: 0.5)
                    .frame(maxHeight: .infinity)
            }
            .frame(width: 35)
            
            Spacer().frame(width: 15)
            
            VStack(spacing: 0) {
                
                HStack(spacing: 0) {
                    
                    if !self.mumory.isPublic {
                        Image(uiImage: SharedAsset.lockIconMypage.image)
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Spacer().frame(width: 4)
                        
                        Text("・")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                            .frame(width: 4, alignment: .bottom)
                        
                        Spacer().frame(width: 4)
                    }
                    
                    Image(uiImage: SharedAsset.locationIconMypage.image)
                        .resizable()
                        .frame(width: 18, height: 18)
                    
                    Spacer().frame(width: 4)
                    
                    Text(self.mumory.location.locationTitle)
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        .foregroundColor(Color(red: 0.76, green: 0.76, blue: 0.76))
                        .frame(width: 210, height: 10, alignment: .leading)
                    
                    Spacer()
                    
                    SharedAsset.menuButtonMypage.swiftUIImage
                        .resizable()
                        .frame(width: 22, height: 22)
                        .onTapGesture {
                            self.appCoordinator.sheet = .myMumory(mumory: self.mumory, isOwn: self.mumory.uId == self.currentUserViewModel.user.uId, action: deleteMumoryAction)
                        }
                } // HStack
                .padding(.vertical, 6)
                .padding(.bottom, 2)
                
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: self.mumory.song.artworkUrl, transaction: Transaction(animation: .easeInOut(duration: 0.1))) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Text("Failed to load image")
                        case .empty:
                            ProgressView()
                        default:
                            Color(red: 0.18, green: 0.18, blue: 0.18)
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 82, height: UIScreen.main.bounds.width - 82)
                    .cornerRadius(15)
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: UIScreen.main.bounds.width - 82, height: UIScreen.main.bounds.width - 82)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: .black.opacity(0.5), location: 0.00),
                                    Gradient.Stop(color: .black.opacity(0), location: 0.26),
                                    Gradient.Stop(color: .black.opacity(0), location: 0.63),
                                    Gradient.Stop(color: .black.opacity(0.5), location: 0.96),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .cornerRadius(15)
                        .onTapGesture {
                            self.appCoordinator.rootPath.append(MumoryPage.mumoryDetailView(mumory: self.mumory))
                        }
                    
                    // MARK: Title & Menu & Heart & Comment
                    HStack(spacing: 0) {
                        SharedAsset.musicIconSocial.swiftUIImage
                            .resizable()
                            .frame(width: 14, height: 14)
                        
                        Spacer().frame(width: 5)
                        
                        Group {
                            Text(self.mumory.song.title)
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 14))
                            
                            + Text("  \(self.mumory.song.artist)")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        }
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(width: 158, alignment: .leading)
                        
                        Spacer()
                        
                        Group {
                            SharedAsset.heartMypage.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                            
                            Spacer().frame(width: 2)
                            
                            Text("\((mumory.likes ?? []).count)")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(.white)
                            
                            Spacer().frame(width: 8)
                            
                            SharedAsset.commentMypage.swiftUIImage
                                .resizable()
                                .frame(width: 18, height: 18)
                            
                            Spacer().frame(width: 2)
                            
                            Text("\(self.mumory.commentCount)")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(.white)
                        }
                    } // HStack
                    .padding(.top, 19)
                    .padding(.leading, 20)
                    .padding(.trailing, 19)
                    
                    VStack(spacing: 0) {
                        
                        Spacer(minLength: 0)
                        
                        // MARK: Image Counter & Tag
                        ScrollView(.horizontal, showsIndicators: false) {
                            
                            HStack(spacing: 8) {
                                
                                if let imageURLs = self.mumory.imageURLs, !imageURLs.isEmpty {
                                    HStack(spacing: 4) {
                                        
                                        SharedAsset.imageCountSocial.swiftUIImage
                                            .resizable()
                                            .frame(width: 18, height: 18)
                                        
                                        Text("\(imageURLs.count)")
                                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: 48, height: 28)
                                    .background(
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: 48, height: 28)
                                            .background(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.6))
                                            .cornerRadius(15)
                                    )
                                }
                                
                                if let tags = self.mumory.tags, !tags.isEmpty {
                                    ForEach(tags, id: \.self) { tag in
                                        HStack(alignment: .center, spacing: 5) {
                                            SharedAsset.tagMumoryDatail.swiftUIImage
                                                .resizable()
                                                .frame(width: 14, height: 14)
                                            
                                            Text("\(tag)")
                                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                        }
                                        .padding(.leading, 8)
                                        .padding(.trailing, 10)
                                        .padding(.vertical, 7)
                                        .background(.white.opacity(0.25))
                                        .cornerRadius(14)
                                    }
                                }
                                
                                Spacer()
                            } // HStack
                        } // ScrollView
                        .mask(
                            Rectangle()
                                .frame(height: 44)
                                .blur(radius: 3)
                        )
                        
                        // MARK: Content
                        if let content = self.mumory.content, !content.isEmpty {
                            
                            HStack(spacing: 0) {
                                
                                Text(content.replacingOccurrences(of: "\n", with: " "))
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.58, alignment: .leading)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .background(
                                        GeometryReader { proxy in
                                            Color.clear.onAppear {
                                                let size = content.replacingOccurrences(of: "\n", with: " ").size(withAttributes: [.font: SharedFontFamily.Pretendard.medium.font(size: 13)])
                                                
                                                if size.width > proxy.size.width {
                                                    self.isTruncated = true
                                                } else {
                                                    self.isTruncated = false
                                                }
                                            }
                                        }
                                    )
                                
                                if self.isTruncated {
                                    Text("더보기")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(.white.opacity(0.7))
                                        .lineLimit(1)
                                        .frame(alignment: .leading)
                                        .padding(.leading, 7)
                                }
                                
                                Spacer(minLength: 0)
                            }
                            .padding(.top, 14)
                        }
                    } // VStack
                    .frame(width: UIScreen.main.bounds.width - 82 - 47)
                    .background(
                        GeometryReader{ g in
                            Color.clear
                                .onAppear {
                                    DispatchQueue.main.async {
                                        self.vStackOffsetY = g.size.height
                                    }
                                }
                        }
                    )
                    .padding(.leading, 20)
                    .offset(y: UIScreen.main.bounds.width - 82 - self.vStackOffsetY - 17)
                } // ZStack
                
                Spacer()
            } // VStack
            
            Spacer().frame(width: 20)
        }
        .frame(height: 371)
        .padding(.top, !isSameDateAsPrevious ? 30 : 0)
    }
    
    private func deleteMumoryAction() {
        self.appCoordinator.popUp = .none
        self.appCoordinator.isLoading = true
        
        self.currentUserViewModel.mumoryViewModel.deleteMumory(mumory) { result in
            switch result {
            case .success():
                print("SUCCESS deleteMumory!")
            case .failure(let error):
                print("ERROR deleteMumory: \(error)")
            }
            
            self.appCoordinator.isLoading = false
        }
    }
}
