//
//  SearchEntryView.swift
//  Feature
//
//  Created by 제이콥 on 12/4/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import ShazamKit
import AVFAudio

struct SearchMusicEntryView: View {
    @Binding var term: String
    @StateObject var recentSearchObject: RecentSearchObject = RecentSearchObject()
    @EnvironmentObject var appCoordinator: AppCoordinator
    var body: some View {
        ZStack(alignment: .top) {
            ColorSet.background.ignoresSafeArea()
            ScrollView{
                VStack(spacing: 15){
                    //음악 인식
                    HStack(spacing: 10){
                        SharedAsset.songRecognize.swiftUIImage
                            .frame(width: 25, height: 25)
                        
                        Text("음악 인식")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .foregroundColor(.white)
                            .onTapGesture {
                                appCoordinator.rootPath.append(LibraryPage.shazam)
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 17)
                    .padding(.bottom, 17)
                    .background(ColorSet.moreDeepGray)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15), style: .circular))
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    
                    //뮤모리 인기 검색어
                    VStack(spacing: 0){
                        Text("뮤모리 인기 검색어")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.white)
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                        
                        LazyVStack(content: {
                            ForEach(1...3, id: \.self) { count in
                                Text("\(count) 검색검색")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                    .foregroundColor(.black)
                                    .padding(.horizontal, 16)
                                    .frame(height: 33)
                                    .background(ColorSet.mainPurpleColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .circular))
                            }
                        })
                        .padding(.top, 25)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(ColorSet.moreDeepGray)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15), style: .circular))
                    .padding(.horizontal, 20)
                    
                    
                    //최근 검색
                    VStack(spacing: 0){
                        HStack{
                            Text("최근 검색")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.white)
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                            
                            Text("전체삭제")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .onTapGesture {
                                    let userDefault = UserDefaults.standard
                                    userDefault.removeObject(forKey: "recentSearchList")
                                    recentSearchObject.recentSearchList = []
                                }
                        }
                        
                        LazyVStack(content: {
                            ForEach(recentSearchObject.recentSearchList, id: \.self) { string in
                                RecentSearchItem(title: string)
                                    .environmentObject(recentSearchObject)
                                    .onTapGesture {
                                        term = string
                                    }
                            }
                        })
                        .padding(.top, 25)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .background(ColorSet.moreDeepGray)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15), style: .circular))
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                }
            }

        }
        .onAppear(perform: {
            let userDefault = UserDefaults.standard
            guard let result = userDefault.value(forKey: "recentSearchList") as? [String] else {print("no recent list");return}
            recentSearchObject.recentSearchList = result
        })
    }
}

//#Preview {
//    SearchEntryView()
//}
