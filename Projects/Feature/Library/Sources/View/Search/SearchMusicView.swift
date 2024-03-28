//
//  SearchView.swift
//  Feature
//
//  Created by 제이콥 on 12/4/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit
import MapKit

struct SearchMusicView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var playerViewModel: PlayerViewModel
    
    @State var term: String
    @State var musicList: MusicItemCollection<Song> = []
    @State var artistList: MusicItemCollection<Artist> = []

    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack(spacing: 0, content: {
                    //검색 텍스트 필드 뷰
                    HStack(spacing: 0, content: {
                        SharedAsset.graySearch.swiftUIImage
                            .frame(width: 23, height: 23)
                            .padding(.leading, 15)
                        
                        TextField("", text: $term, prompt: searchPlaceHolder())
                            .textFieldStyle(.plain)
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                            .padding(.leading, 7)
                            .foregroundColor(.white)
                    
                        
                        SharedAsset.xWhiteCircle.swiftUIImage
                            .frame(width: 23, height: 23)
                            .padding(.trailing, 17)
                            .opacity(term.isEmpty ? 0 : 1)
                            .onTapGesture {
                                term = ""
                            }
                    })
                    .frame(height: 45)
                    .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .circular))
                    
                  
                        Text("취소")
                            .padding(.leading, 8)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .onTapGesture {
                                appCoordinator.rootPath.removeLast()
                            }
                  
                })
                .padding(.top, 12)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 15)
                .background(.clear)
                
                if term.count > 0{
                    SearchMusicResultView(term: $term)
                    
                }else{
                    SearchMusicEntryView(term: $term)
                }
                
                
    
                Spacer()
            }
            .padding(.top, appCoordinator.safeAreaInsetsTop)
            
            CreateMumoryBottomSheetView(isSheetShown: $appCoordinator.isCreateMumorySheetShown, offsetY: $appCoordinator.offsetY)
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden()
        .background(.black)
        .onAppear {
            playerViewModel.miniPlayerMoveToBottom = true
        }


    }

    
    private func searchPlaceHolder() -> Text {
        return Text("노래 및 아티스트 검색")
            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
    }
}
