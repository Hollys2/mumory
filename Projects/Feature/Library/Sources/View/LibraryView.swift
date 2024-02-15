//
//  LibraryView.swift
//  Feature
//
//  Created by 제이콥 on 11/19/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

public struct LibraryView: View {
    @EnvironmentObject var nowPlaySong: NowPlaySong
    @State var isTapMyMusic: Bool = true
    @State var isPlaying: Bool = true
    
    public init() {
        
    }
    public var body: some View {
        NavigationView{
                ZStack{
                    LibraryColorSet.background.ignoresSafeArea()
                    VStack(spacing: 0, content: {
                        //                ScrollView(.vertical) {
                        HStack(spacing: 6, content: {
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
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22)))
                            })
                            
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
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22)))
                            })
                            
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 40)
                        
                        //                FeatureAsset.Asset1.next.swiftUii
                        
                        SwitchView(isMyMusic: isTapMyMusic)
                            .environmentObject(nowPlaySong)
                            .padding(.top, 40)
                        
                        
                        
                        Spacer()
                        //                }
                        
                    })
                    
                    VStack{
                        Spacer()
                        if isPlaying{
                            MiniPlayerView()
                                .environmentObject(nowPlaySong)
                        }
                    }
                }
                .navigationBarBackButtonHidden()
//                .toolbar {
//                    ToolbarItem(placement: .topBarLeading) {
//                        Text("라이브러리")
//                            .font(.system(size: 24, weight: .bold))
//                            .foregroundStyle(.white)
//                    }
//                    
//                    ToolbarItem(placement: .topBarTrailing) {
//                        NavigationLink {
//                            SearchView()
//                        } label: {
//                            SharedAsset.search.swiftUIImage
//                                .frame(width: 30, height: 30)
//                        }
//                    }
//                }
                
            }
        }
    
    
}

struct SwitchView: View{
    @EnvironmentObject var nowPlaySong: NowPlaySong
    var isMyMusic: Bool = true

    var body: some View{
        if isMyMusic{
//            MyRecentMusicView()
//                .environmentObject(nowPlaySong)
            MyPlaylistView()
        }else{
            RecommendationView()
                .environmentObject(nowPlaySong)
        }
    }
}

//#Preview {
//    LibraryView()
//}

