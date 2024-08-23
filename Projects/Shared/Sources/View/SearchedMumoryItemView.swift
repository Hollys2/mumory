//
//  SearchedMumoryItemView.swift
//  Shared
//
//  Created by 다솔 on 2024/08/23.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


public struct SearchedMumoryItemView: View {
        
    @State private var user: UserProfile = UserProfile()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    private var mumory: Mumory
    
    public init(mumory: Mumory) {
        self.mumory = mumory
    }
    
    public  var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 15)
            
            HStack(alignment: .center, spacing: 0) {
                AsyncImage(url: self.user.profileImageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                    default:
                        self.user.defaultProfileImage
                            .resizable()
                    }
                }
                .scaledToFill()
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
                
                Text("\(mumory.location.locationTitle)")
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
                        
                        Text(mumory.song.title)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                            .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Spacer().frame(width: 6)
                        
                        Text(mumory.song.artist)
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
        .onAppear {
            Task {
                self.user = await FetchManager.shared.fetchUser(uId: self.mumory.uId)
            }
        }
        .onTapGesture {
            self.appCoordinator.rootPath.append(MumoryPage.mumoryDetailView(mumory: self.mumory))
        }
    }
}
