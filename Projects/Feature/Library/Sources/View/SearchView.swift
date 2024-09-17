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

struct SearchView: View {
    @EnvironmentObject var nowPlaySong: NowPlaySong
    @Environment(\.dismiss) private var dismiss

    @State var term: String = ""
    @State var musicList: MusicItemCollection<Song> = []
    @State var albumList: MusicItemCollection<Album> = []
    @State var artistList: MusicItemCollection<Artist> = []
    @State var playRate: CGFloat = 1
    @State var songID: MusicItemID = MusicItemID(stringLiteral: "")
    @State var playlist = []
    private var player = ApplicationMusicPlayer.shared
    
    var body: some View {
        ZStack{
            Color(red: 0.09, green: 0.09, blue: 0.09, opacity: 1).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 0, content: {
                    HStack(spacing: 0, content: {
                        SharedAsset.graySearch.swiftUIImage
                            .frame(width: 23, height: 23)
                            .padding(.leading, 15)
                        
                        TextField("제목을 입력하세요", text: $term, prompt: searchPlaceHolder())
                            .textFieldStyle(.plain)
                            .font(.system(size: 16, weight: .medium))
                            .padding(.leading, 7)
                            .foregroundColor(.white)
                    
                        
                        SharedAsset.xWhiteCircle.swiftUIImage
                            .frame(width: 23, height: 23)
                            .padding(.trailing, 17)
                            .onTapGesture {
                                term = ""
                            }
                    })
                    .frame(height: 45)
                    .background(Color(red: 0.24, green: 0.24, blue: 0.24).clipShape(RoundedRectangle(cornerSize: CGSize(width: 22, height: 22))))
                    
                    Button(action: {
                        dismiss()
                    }, label: {
                        Text("취소")
                            .padding(.leading, 8)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                    })
                })
                .padding(.top, 12)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .background(.clear)
                
                if term.count > 0{
                    SearchResultView(term: $term)
                }else{
                    SearchEntryView()
                }
                
                
    
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
    }    

    
    private func searchPlaceHolder() -> Text {
        return Text("노래 및 아티스트 검색")
            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
    }
}

//#Preview {
//    SearchView()
//}
