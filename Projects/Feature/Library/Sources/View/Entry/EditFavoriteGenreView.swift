//
//  EditFavoriteGenreView.swift
//  Feature
//
//  Created by 제이콥 on 2/11/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core

struct EditFavoriteGenreView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userManager: UserViewModel
    
    @State var selectedGenres: [Int] = []
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(alignment:.center, spacing: 0) {
                
                TopBar(leftButton: nil, title: "장르", rightButton: SharedAsset.xWhite.swiftUIImage, leftButtonAction: nil ) {
                    dismiss()
                }
                .frame(maxWidth: userManager.width)
                
                ScrollView(.vertical) {
                    Text("선택항목 \(userManager.favoriteGenres.count)개")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundStyle(ColorSet.subGray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 30)
                    
                    VStack(spacing: 13, content: {
                        ForEach(gerRows(list: MusicGenreHelper().genres, screenWidth: userManager.width), id: \.self){ genreList in
                            HStack(spacing: 9, content: {
                                ForEach(genreList, id: \.self){ genre in
                                    Text(genre.name)
                                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                                        .padding(.horizontal, 19)
                                        .padding(.vertical, 8)
                                        .background(contains(genre: genre) ? ColorSet.mainPurpleColor : ColorSet.moreDeepGray)
                                        .foregroundStyle(contains(genre: genre) ? Color.black : ColorSet.lightGray)
                                        .overlay(content: {
                                            RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular)
                                                .stroke(ColorSet.lightGray, lineWidth: contains(genre: genre) ? 0 : 1)
                                        })
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
                                        .onTapGesture {
                                            addOrDelete(genre: genre)
                                        }
                                    
                                }
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                        }
                    })
                    .padding(.top, 30)
                    
                    Rectangle()
                        .frame(height: 150)
                        .foregroundStyle(.clear)
                }
                
                
            }
            VStack{
                Spacer()
                Button {
                    saveGenre()
                } label: {
                    WhiteButton(title: "저장", isEnabled: selectedGenres.count > 0 && selectedGenres.count < 6)
                        .shadow(color: .black, radius: 10, y: 8)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)
                }
                .disabled(!(selectedGenres.count > 0 && selectedGenres.count < 6))
            }
        }
        .onAppear {
            selectedGenres = userManager.favoriteGenres
        }
    }
    
    private func saveGenre() {
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let data = [
            "favorite_genres" : selectedGenres
        ]
        
        db.collection("User").document(userManager.uid).setData(data, merge: true) { error in
            
            if error == nil {
                userManager.favoriteGenres = selectedGenres
                dismiss()
            }else {
                print(error!)
            }
        }
    }
    
    private func contains(genre: MusicGenre) -> Bool {
        return selectedGenres.contains(genre.id)
    }
    
    private func addOrDelete(genre: MusicGenre) {
        if contains(genre: genre) {
            selectedGenres.removeAll(where: {$0 == genre.id})
        }else {
            if selectedGenres.count < 5 {
                selectedGenres.append(genre.id)
            }
        }
    }
    
    private func getTextWidth(term: String) -> CGFloat {
        let fontAttribute = [NSAttributedString.Key.font: SharedFontFamily.Pretendard.bold.font(size: 16)]
        var width = (term as NSString).size(withAttributes: fontAttribute).width
        width += 39 //아이템 좌우 여백
        width += 7 //spacing
        return width
    }
    
    private func gerRows(list: [MusicGenre], screenWidth: CGFloat) ->[[MusicGenre]] {
        var sumWidth: CGFloat = 0
        var returnValue:[[MusicGenre]] = [[]]
        let screen = screenWidth - 40 //좌우 여백 35씩
        var index = 0
        for genre in list{
            let textWidth = getTextWidth(term: genre.name)
            if sumWidth + textWidth > screen{
                sumWidth = textWidth
                index += 1
                returnValue.append([])
                returnValue[index].append(genre)
            }else {
                sumWidth += textWidth
                returnValue[index].append(genre)
            }
        }
        return returnValue
    }
}

#Preview {
    EditFavoriteGenreView()
}
