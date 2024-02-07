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
    @State var scrollDirection: ScrollDirection = .stay
    @State var scrollYOffset: CGFloat = 0
    var body: some View {
        ZStack(alignment: .top){
            StickyHeaderScrollView(changeDetectValue: $changeDetectValue, contentOffset: $contentOffset,viewWidth: $screenWidth,scrollDirection: $scrollDirection, topbarYoffset: $scrollYOffset, content: {
                
                ZStack(alignment: .top) {
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
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        .opacity(0)
                        
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
        
                        
                        
                    }
                    
               
                    
                }
                .frame(width: screenWidth)
                
            })
            
            HStack{
                Text("라이브러리")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 24))
                    .foregroundStyle(Color.white)
                    .padding(.leading, 20)

                Spacer()

                SharedAsset.search.swiftUIImage
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        manager.nowPage = .search
                    }
            }
            .frame(height: 70)
            .background(ColorSet.background)
            .offset(x: 0, y: scrollYOffset)
            .onChange(of: scrollDirection) { newValue in
                if newValue == .up {
                    if contentOffset.y >= 70 {
                        scrollYOffset = -70
                    }
                }
            }
            
            GeometryReader { geometry in
                ColorSet.background
                    .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top, alignment: .top)
                    .ignoresSafeArea()
                
            }
            

        }
    }
}


//#Preview {
//    LibraryView()
//}
