//
//  LibraryEntryView.swift
//  Feature
//
//  Created by 제이콥 on 1/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct LibraryView: View {
    @EnvironmentObject var manager: LibraryManageModel
    @EnvironmentObject var playerManager: PlayerViewModel
    @EnvironmentObject var setView: SetView
    @State var isTapMyMusic: Bool = true
    @State var changeDetectValue: Bool = false
    @State var contentOffset: CGPoint = .zero
    @State var screenWidth: CGFloat = .zero
    var body: some View {
        StickyHeaderScrollView(changeDetectValue: $changeDetectValue, contentOffset: $contentOffset,viewWidth: $screenWidth, content: {
                
          
            VStack(spacing: 0) {

                //Top bar(라이브러리, 검색버튼)
                HStack{
                    Text("라이브러리")
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 24))
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    SharedAsset.search.swiftUIImage
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            manager.nowPage = .search
                        }
                }
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .offset(x: 0, y: contentOffset.y > 0 ? 0 : contentOffset.y)
                
                //마이뮤직, 추천 선택 스택
                HStack(spacing: 6, content: {
                    
                    //마이뮤직버튼
                    Button(action: {
                        isTapMyMusic = true
                    }, label: {
                        Text("마이뮤직")
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .foregroundStyle(isTapMyMusic ? Color.black : LibraryColorSet.lightGrayForeground)
                            .background(isTapMyMusic ? LibraryColorSet.purpleBackground : LibraryColorSet.darkGrayBackground)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22), style: .circular))
                    })
                    
                    //추천버튼
                    Button(action: {
                        isTapMyMusic = false
                    }, label: {
                        Text("추천")
                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .foregroundStyle(isTapMyMusic ? LibraryColorSet.lightGrayForeground : Color.black)
                            .background(isTapMyMusic ? LibraryColorSet.darkGrayBackground : LibraryColorSet.purpleBackground)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22), style: .circular))
                    })
                    
                })
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.top, 40)
                
                //마이뮤직, 추천에 따라 바뀔 뷰
                if isTapMyMusic{
                    MyMusicView()
                        .padding(.top, 40)
                        .environmentObject(playerManager)
                        .environmentObject(manager)
                }else {
                    RecommendationView()
                        .padding(.top, 40)
                        .environmentObject(playerManager)
                        .environmentObject(manager)
                }
                
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1000)
                    .foregroundColor(.clear)
//                    .onChange(of: contentOffset, perform: { value in
//                        print(contentOffset.y)
//                    })
                
                
            }
            .frame(width: screenWidth)
       
        })
    }
}

//struct SwitchView: View{
//    @EnvironmentObject var manager: LibraryManageModel
//    @EnvironmentObject var playerManager: PlayerViewModel
//    @EnvironmentObject var setView: SetView
//    var isMyMusic: Bool = true
//
//    var body: some View{
//        if isMyMusic{
//            MyPlaylistView()
//        }else{
//            RecommendationView()
//                .environmentObject(playerManager)
//                .environmentObject(manager)
//        }
//    }
//}

//#Preview {
//    LibraryView()
//}
