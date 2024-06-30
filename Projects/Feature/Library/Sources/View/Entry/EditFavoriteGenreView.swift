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
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @State var isLoading: Bool = false
    @State var selectedGenres: [Int] = []
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            ScrollView(.vertical) {
                Text("선택항목 \(selectedGenres.count)개")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundStyle(ColorSet.subGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.top, 30 + 118)
                
                VStack(spacing: 15, content: {
                    ForEach(gerRows(list: MusicGenreHelper().genres, screenWidth: getUIScreenBounds().width), id: \.self){ genreList in
                        HStack(spacing: 11, content: {
                            ForEach(genreList, id: \.self){ genre in
                                Text(genre.name)
                                    .font(contains(genre: genre) ? SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16) : SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                    .padding(.horizontal, 19)
                                    .padding(.vertical, 8)
                                    .background(contains(genre: genre) ? ColorSet.mainPurpleColor : ColorSet.background)
                                    .foregroundStyle(contains(genre: genre) ? Color.black : ColorSet.subGray)
                                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
                                    .overlay(content: {
                                        RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular)
                                            .stroke(ColorSet.subGray, lineWidth: contains(genre: genre) ? 0 : 1)
                                    })
                                    .onTapGesture {
                                        addOrDelete(genre: genre)
                                    }
                                
                            }
                        })
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    }
                })
                .padding(.top, 20)
                
                Rectangle()
                    .foregroundStyle(Color.clear)
                    .frame(width: 10, height: 150)
            }
            .scrollIndicators(.hidden)
                
            
            HStack(alignment: .center, spacing: 0) {
                Rectangle()
                    .foregroundStyle(Color.clear)
                    .frame(width: 30, height: 30)
                Spacer()
                Text("장르")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                    .foregroundStyle(Color.white)
                    
                Spacer()
                SharedAsset.xWhite.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        dismiss()
                    }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70, alignment: .center)
            .padding(.horizontal, 20)
            .padding(.top, getSafeAreaInsets().top)
            .background(ColorSet.background.opacity(0.9))
            .padding(.bottom, 5)
            
            SharedAsset.underGradientLarge.swiftUIImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                  
            VStack{
                Spacer()
                Button {
                    saveGenre()
                } label: {
                    MumoryLoadingButton(title: "저장", isEnabled: selectedGenres.count > 0 && selectedGenres.count < 6, isLoading: $isLoading)
                        .padding(.bottom, 20 + appCoordinator.safeAreaInsetsBottom)
                        .padding(.horizontal, 20)
                        
                }
                .disabled(!(selectedGenres.count > 0 && selectedGenres.count < 6))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            selectedGenres = currentUserViewModel.playlistViewModel.favoriteGenres
        }
    }
    
    private func saveGenre() {
        isLoading = true
        let Firebase = FirebaseManager.shared
        let db = Firebase.db
        let data = [
            "favoriteGenres" : selectedGenres
        ]
        
        db.collection("User").document(currentUserViewModel.user.uId).setData(data, merge: true) { error in
            if error == nil {
                currentUserViewModel.playlistViewModel.favoriteGenres = selectedGenres
                isLoading
                dismiss()
            }else {
                isLoading
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
