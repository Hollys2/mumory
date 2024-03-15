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
    @EnvironmentObject var manager: LibraryCoordinator
    @EnvironmentObject var playerManager: PlayerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State var term: String
    @State var musicList: MusicItemCollection<Song> = []
    @State var artistList: MusicItemCollection<Artist> = []
   
        
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
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
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
                    .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .circular))
                    
                  
                        Text("취소")
                            .padding(.leading, 8)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                            .onTapGesture {
                                manager.pop()
                            }
                  
                })
                .padding(.top, 12)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.bottom, 15)
                .background(.clear)
                
                if term.count > 0{
                    SearchResultView(term: $term)
                    
                }else{
                    SearchEntryView(term: $term)
                }
                
                
    
                Spacer()
            }
        }
        .navigationBarBackButtonHidden()
        .background(.black)

    }

    
    private func searchPlaceHolder() -> Text {
        return Text("노래 및 아티스트 검색")
            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
    }
}

//#Preview {
//    SearchView()
//}
