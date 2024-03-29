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
import MusicKit

struct SearchMusicEntryView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var recentSearchObject: RecentSearchObject = RecentSearchObject()
    @State var popularSearchTerm: [String] = []
    @Binding var term: String
    var shazamViewType: ShazamViewType = .normal
    init(term: Binding<String>){
        self._term = term
    }
    init(term: Binding<String>, shazamViewType: ShazamViewType) {
        self._term = term
        self.shazamViewType = shazamViewType
    }

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
                                appCoordinator.rootPath.append(LibraryPage.shazam(type: self.shazamViewType))
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
                        
                        
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(getRows(list: self.popularSearchTerm), id: \.self) { list in
                                HStack(spacing: 8) {
                                    ForEach(list, id: \.self) { term in
                                        Text(term)
                                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 16)
                                            .frame(height: 33)
                                            .background(ColorSet.mainPurpleColor)
                                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .circular))
                                            .onTapGesture {
                                                self.term = term
                                                
                                                let userDefault = UserDefaults.standard
                                                var recentSearchList = userDefault.value(forKey: "recentSearchList") as? [String] ?? []
                                                recentSearchList.removeAll(where: {$0 == term})
                                                recentSearchList.insert(term, at: 0)
                                                userDefault.set(recentSearchList, forKey: "recentSearchList")
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)

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
                            
                            if !recentSearchObject.recentSearchList.isEmpty {
                                Text("전체삭제")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    .onTapGesture {
                                        let userDefault = UserDefaults.standard
                                        userDefault.removeObject(forKey: "recentSearchList")
                                        recentSearchObject.recentSearchList = []
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        LazyVStack(content: {
                            ForEach(recentSearchObject.recentSearchList, id: \.self) { title in
                                RecentSearchItem(title: title, deleteAction: {
                                    recentSearchObject.recentSearchList.removeAll(where: {$0 == title})
                                    let userDefault = UserDefaults.standard
                                    guard var result = userDefault.value(forKey: "recentSearchList") as? [String] else {return}
                                    result.removeAll(where: {$0 == title})
                                    userDefault.set(result, forKey: "recentSearchList")
                                })
                                .onTapGesture {
                                    term = title
                                }
                            }
                            if recentSearchObject.recentSearchList.isEmpty {
                                Text("최근 검색내역이 없습니다")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                    .foregroundStyle(ColorSet.subGray)
                                    .frame(height: 50)
                            }
                        })
                        .padding(.top, 11)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                    .background(ColorSet.moreDeepGray)
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 15, height: 15), style: .circular))
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                }
            }

        }
        .onAppear(perform: {
            requestPupularMusic()

            let userDefault = UserDefaults.standard
            guard let result = userDefault.value(forKey: "recentSearchList") as? [String] else {print("no recent list");return}
            recentSearchObject.recentSearchList = result
        })
    }
    
    private func requestPupularMusic() {
        if !popularSearchTerm.isEmpty {
            return
        }
        
        Task {
            var request = MusicCatalogChartsRequest(kinds: [.dailyGlobalTop], types: [Song.self])
            request.limit = 6
            let response = try await request.response().songCharts
            guard let chart = response.first?.items else {
                return
            }
            chart.forEach { song in
                switch Int.random(in: 0...1) {
                case 0:
                    if !popularSearchTerm.contains(song.title){
                        self.popularSearchTerm.append(song.title)
                    }
                case 1:
                    if !popularSearchTerm.contains(song.artistName){
                        self.popularSearchTerm.append(song.artistName)
                    }
                default:
                    if !popularSearchTerm.contains(song.title){
                        self.popularSearchTerm.append(song.title)
                    }
                }
            }
      
        }
    }
    
    private func getTextWidth(term: String) -> CGFloat {
        let fontAttribute = [NSAttributedString.Key.font: SharedFontFamily.Pretendard.bold.font(size: 16)]
        var width = (term as NSString).size(withAttributes: fontAttribute).width
        width += 32 //아이템 좌우 여백
        width += 5 //spacing
        return width
    }
    
    private func getRows(list: [String]) ->[[String]] {
        var sumWidth: CGFloat = 0
        var returnValue:[[String]] = [[]]
        let screen = getUIScreenBounds().width - 80 //좌우 여백 35씩
        var index = 0
        for term in list{
            let textWidth = getTextWidth(term: term)
            if sumWidth + textWidth > screen{
                sumWidth = textWidth
                index += 1
                returnValue.append([])
                returnValue[index].append(term)
            }else {
                sumWidth += textWidth
                returnValue[index].append(term)
            }
        }
        return returnValue
    }
}

