//
//  PlayQueueView.swift
//  Feature
//
//  Created by 제이콥 on 2/20/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import MusicKit

struct testSong: Hashable{
    var title: String
    var artistName: String
}
struct PlaylistTestStruct: Hashable {
    var title: String
    var songs: [testSong]
    var isClosed: Bool
}

struct PlayQueueTestView: View {
    @State var offset: CGPoint = .zero
    @State var playlist: [PlaylistTestStruct] = []
    @State var id = 0
    @State var isTapDownArrow: Bool = false
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack{
                SharedAsset.xWhite.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(20)
                
                ScrollView(.vertical) {
                    ForEach(0 ..< playlist.count, id: \.self) { index in
                        LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                            Section {
                                songListView(list: playlist[index].songs)
                                    .frame(height: playlist[index].isClosed ? 0 : nil)
                                    .opacity(playlist[index].isClosed ? 0 : 1)
                            } header: {
                                HStack{
                                    Text(playlist[index].title)
                                         .frame(maxWidth: .infinity, alignment: .leading)
                                         .foregroundStyle(.white)
 
                                     Spacer()
 
                                     SharedAsset.downArrow.swiftUIImage
                                         .onTapGesture {
                                             withAnimation {
                                                 playlist[index].isClosed.toggle()
                                             }
                                         }
                                 }
                                .frame(height: 50)
                                 .padding(10)
                                 .background(Color.yellow)
                                 .overlay {
                                     Rectangle()
                                         .stroke(Color.white, lineWidth: 1)
                                 }
                            }

                        }
                    }
                    .frame(width: 390)
                }

            }
        }
        .onAppear(perform: {
//            playlist["재생목록"] = Array(repeating: PlaylistTest(title: "타이틀", artistName: "아티스트이름"), count: 10)
//            playlist["플리재생재생"] = Array(repeating: PlaylistTest(title: "타이틀", artistName: "아티스트이름"), count: 10)
            
            playlist.append(PlaylistTestStruct(title: "재생기록", songs: Array(repeating: testSong(title: "타이틀", artistName: "아티스트이름"), count: 10), isClosed: false))
            playlist.append(PlaylistTestStruct(title: "플리재생기록", songs: Array(repeating: testSong(title: "타이틀", artistName: "아티스트이름"), count: 10), isClosed: false))
        })
    }
}

struct songListView: View {
    var list: [testSong]
    @State var isTapClosed = false

    var body: some View {
        ZStack{
            VStack(spacing: 0, content: {
                ForEach(list, id: \.self) { song in
                    MusicTestItem()
                        .background()
                }
                .frame(height: isTapClosed ? 0 : nil)
                .opacity(isTapClosed ? 0 : 1)
            })
        }
           
        

    }
}

#Preview {
    PlayQueueTestView()
}
