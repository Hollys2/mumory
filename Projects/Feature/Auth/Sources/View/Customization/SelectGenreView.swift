//
//  SelectGenreView.swift
//  Feature
//
//  Created by 제이콥 on 12/11/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import UIKit
import Shared
import Core



public struct SelectGenreView: View {
    @EnvironmentObject var manager: CustomizationManageViewModel
    //장르가 결정되면, 서버에서 받아오기
    @State private var genreList: [String] = []
    
    public var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            GeometryReader(content: { geometry in
                
                ScrollView(){
                    VStack(spacing: 0, content: {
                        
                        Text("관심있는 음악 장르를\n선택해주세요")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .foregroundColor(.white)
                            .lineSpacing(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.top, 44)
                        
                        HStack(spacing: 0){
                            Text("관심있는 음악 장르를 ")
                                .foregroundColor(.white)
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            
                            Text("5가지 이내")
                                .foregroundStyle(ColorSet.mainPurpleColor)
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            
                            Text("로 선택해주세요.")
                                .foregroundColor(.white)
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 50)
                        
                        Text("나에게 맞는 음악을 추천받을 수 있습니다!")
                            .foregroundColor(.white)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        
                        Text("라이브러리 > 추천에서 수정할 수 있어요")
                            .foregroundColor(ColorSet.subGray)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                            .padding(.top, 13)
                        
                        
                        //Tag Layout
                        //2차원배열이기 때문에 ForEach 2개 사용
                        VStack(spacing: 13, content: {
                            ForEach(gerRows(list: genreList, screenWidth: geometry.size.width), id: \.self){ list in
                                HStack(spacing: 10, content: {
                                    ForEach(list, id: \.self){ genreText in
                                        Text(genreText)
                                            .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                                            .padding(.leading, 19)
                                            .padding(.trailing, 19)
                                            .padding(.top, 10)
                                            .padding(.bottom, 10)
                                            .background(manager.contains(genre: genreText) ? ColorSet.moreDeepGray : ColorSet.mainPurpleColor)
                                            .foregroundStyle(manager.contains(genre: genreText) ? ColorSet.lightGray : Color.black)
                                            .overlay(content: {
                                                RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular)
                                                    .stroke(ColorSet.lightGray, lineWidth: manager.contains(genre: genreText) ? 1 : 0)
                                            })
                                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))
                                            .onTapGesture {
                                                manager.appendGenre(genre: genreText)
                                            }
                                        
                                    }
                                })
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 20)
                            }
                        })
                        .padding(.top, 42)
                        
                        Rectangle()
                            .foregroundStyle(Color.clear)
                            .frame(width: 10, height: 200)
                    })
                }
                
            })
            
        }
        .onAppear(perform: {
            getGenreList()
        })
        
        
    }
    
    //문자열 가로길이 구하기
    private func getTextWidth(term: String) -> CGFloat {
        let fontAttribute = [NSAttributedString.Key.font: SharedFontFamily.Pretendard.bold.font(size: 16)]
        var width = (term as NSString).size(withAttributes: fontAttribute).width
        width += 39 //아이템 좌우 여백
        width += 7 //spacing
        return width
    }
    
    //기존 장르 배열을 2차원 배열로 가공하기
    //화면에 띄워질 모습 그대로를 2차원 배열로 저장. 한 행에 가능한 개수만큼만 나눠지도록 함
    //크기를 계산해서 첫번재 행에 3개, 두번째 행에 4개가 가능하다면 똑같은 형태로 저장
    private func gerRows(list: [String], screenWidth: CGFloat) ->[[String]] {
        var sumWidth: CGFloat = 0
        var returnValue:[[String]] = [[]]
        let screen = screenWidth - 40 //좌우 여백 20씩
        var index = 0
        for genre in list{
            let textWidth = getTextWidth(term: genre)
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
    
    private func getGenreList(){
        let db = FirebaseManager.shared.db
        db.collection("Admin").document("Data").getDocument { snapShot, error in
            if let error = error {
                print("firestore error: \(error)")
            }else if let snapshot = snapShot {
                if let data = snapshot.data(){
                    guard let genreList = data["genre_list"] as? [String] else {
                        print("no genreList")
                        return
                    }
                    self.genreList = genreList
                }
            }
        }
    }
}

//#Preview {
//    SelectGenreView()
//}


//                                        .foregroundStyle(customizationObject.isContained(term: genreText) ? Color.black : ColorSet.lightGray)
//                                        .background(customizationObject.isContained(term: genreText) ? ColorSet.mainPurpleColor : ColorSet.deepGray)

