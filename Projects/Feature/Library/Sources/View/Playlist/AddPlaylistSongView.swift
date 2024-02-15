//
//  AddPlaylistSongView.swift
//  Feature
//
//  Created by 제이콥 on 2/14/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct AddPlaylistSongView: View {
    //보라색: 즐찾-55, 검색-28
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: LibraryManageModel
    @State var isTapFavorite: Bool = true
    @State var selectLineWidth: CGFloat = 55
    @State var tagIndex = 1
    private let lineGray = Color(white: 0.31)
    private let noneSelectedColor = Color(white: 0.65)
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0, content: {
                //상단바
                HStack(spacing: 0){
                        SharedAsset.back.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                            .onTapGesture {
                                manager.pop()
                            }

                    Spacer()
                    
                    Text("음악 추가")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundStyle(.clear)
                        .frame(width: 30, height: 30)
                    
                }
                .padding(.horizontal, 20)
                .frame(height: 40)
                
                HStack(spacing: 0, content: {
                    Text("즐겨찾기")
                        .font(isTapFavorite ?  SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundStyle(isTapFavorite ? .white : noneSelectedColor)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            withAnimation (.linear(duration: 0.2)){
                                isTapFavorite = true
                                selectLineWidth = 55
                            }
                        }
                    
                    Text("검색")
                        .font(isTapFavorite ?  SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundStyle(isTapFavorite ? noneSelectedColor : .white)
                        .frame(maxWidth: .infinity)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .onTapGesture {
                            withAnimation (.linear(duration: 0.2)) {
                                isTapFavorite = false
                                selectLineWidth = 28
                            }
                        }
                })
                .padding(.vertical, 14)
                
                //선택시 움직이는 보라색 선
                VStack(content: {
                    Rectangle()
                        .frame(width: 390/2, height: 3)
                        .foregroundStyle(.clear)
                        .overlay(content: {
                            Rectangle()
                                .frame(width: selectLineWidth, height: 3)
                                .foregroundStyle(ColorSet.mainPurpleColor)
                        })
                })
                .frame(maxWidth: .infinity, alignment: isTapFavorite ? .leading : .trailing)
                
                Divider()
                    .frame(maxWidth: .infinity)
                    .frame(height: 0.5)
                    .background(lineGray)
                
                if isTapFavorite{
                    AddSongFromFavoriteView()
                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                }else {
                    AddSongFromSearchView()
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                }
                
//                TabView(selection: $isTapFavorite){
//                    AddSongFromFavoriteView().tag(true)
//                        .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
//                    AddSongFromSearchView().tag(false)
//                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
//                }
//                .tabViewStyle(.page(indexDisplayMode: .never))
        
                
            })
        }
    }
}

#Preview {
    AddPlaylistSongView()
}


