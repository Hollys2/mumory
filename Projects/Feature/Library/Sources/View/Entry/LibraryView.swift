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
    @EnvironmentObject var userManager: UserViewModel
    @State var isTapMyMusic: Bool = true
    @State var changeDetectValue: Bool = false
    @State var contentOffset: CGPoint = .zero
    @State var screenWidth: CGFloat = .zero
    @State var scrollDirection: ScrollDirection = .up
    @State var scrollYOffset: CGFloat = 0
    
    let topBarHeight = 68.0
    var body: some View {
        ZStack(alignment: .top){
            StickyHeaderScrollView(changeDetectValue: $changeDetectValue, contentOffset: $contentOffset,viewWidth: $screenWidth,scrollDirection: $scrollDirection, topbarYoffset: $scrollYOffset, content: {
                
                ZStack(alignment: .top) {
                    VStack(spacing: 0) {
                        
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
                        .padding(.top, 17)
                        .padding(.top, topBarHeight )//상단뷰높이
                        
                        //마이뮤직, 추천에 따라 바뀔 뷰
                        if isTapMyMusic{
                            MyMusicView()
                                .environmentObject(playerManager)
                                .environmentObject(manager)
                                .padding(.top, 26)
                        }else {
                            RecommendationView()
                                .environmentObject(playerManager)
                                .environmentObject(manager)
                                .padding(.top, 26)

                        }
                        
                        Rectangle()
                            .foregroundStyle(.clear)
                            .frame(height: 87)
                        
                        
                        
                    }
                    
                    
                    
                }
                .frame(width: screenWidth)
                
            })
            
            //상단바
            HStack(){
                Text("라이브러리")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 24))
                    .foregroundStyle(Color.white)
                    .padding(.leading, 20)
                    .padding(.bottom, 5)
                
                Spacer()
                
                SharedAsset.search.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
                    .padding(.trailing, 20)
                    .padding(.top, 5)
                    .onTapGesture {
                        manager.push(destination: .search(term: ""))
                    }
            }
            .frame(height: topBarHeight, alignment: .center)
            .background(ColorSet.background)
            .offset(x: 0, y: scrollYOffset)
            .onChange(of: scrollDirection) { newValue in
                if newValue == .up {
                    //스크롤뷰는 safearea공간 내부부터 offset이 0임. 따라서 세이프공간을 무시하고 스크롤 시작하면 safearea 높이 만큼의 음수부터 시작임
                    //하지만 현재 상단뷰는 safearea를 무시해도 최상단이 0임. 따라서 스크롤뷰와 시작하는 offset이 다름
                    if contentOffset.y >= topBarHeight/*상단뷰의 높이만큼의 여유 공간이 있는 경우*/{
                        scrollYOffset = -topBarHeight/*-topbar height -safearea */
                    }
                }
                
            }
        }
    }
}


//#Preview {
//    LibraryView()
//}
