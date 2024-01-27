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
    @EnvironmentObject var customizationObject: CustomizationViewModel
    //장르가 결정되면, 서버에서 받아오기
    @State var genreList: [String] = ["K-pop", "Rock", "J-POP", "POP", "WorldWide", "Indie Rock", "Dance", "Disney", "Anime", "R&B", "Soul", "Hip-Hop", "어쩌구저쩌구", "이렇게 저렇게", "하나추가", "두개", "냥", "야호 야호", "태그레이아웃성공", "나는 짱!!",
                               "K-pop", "Rock", "J-POP", "POP", "WorldWide", "Indie Rock", "Dance", "Disney", "Anime", "R&B", "Soul", "Hip-Hop", "어쩌구저쩌구", "이렇게 저렇게", "하나추가", "두개", "냥", "야호 야호", "태그레이아웃성공", "나는 짱!!"]
    var index = 0
    @State var itemBackgroundColorList = Array(repeating: ColorSet.mainPurpleColor, count: 100)
    let selectedColor = Color(red: 0.82, green: 0.82, blue: 0.82)
    public var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            GeometryReader(content: { geometry in
                
                ScrollView{
                    Text("관심있는 장르를\n선택해주세요")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                        .foregroundColor(.white)
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
                    .padding(.top, 55)
                    
                    Text("나에게 맞는 음악을 추천받을 수 있습니다!")
                        .foregroundColor(.white)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 3)
                    
                    Text("라이브러리 > 추천에서 수정할 수 있어요")
                        .foregroundColor(ColorSet.subGray)
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 20)
                        .padding(.top, 15)
                    
                    
                    //Tag Layout
                    //2차원배열이기 때문에 ForEach 2개 사용
                    VStack(content: {
                        ForEach(gerRows(list: genreList, screenWidth: geometry.size.width), id: \.self){ list in
                            
                            HStack(spacing: 7, content: {
                                ForEach(list, id: \.self){ genreText in
                                    Text(genreText)
                                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                                        .padding(.leading, 19)
                                        .padding(.trailing, 19)
                                        .padding(.top, 10)
                                        .padding(.bottom, 10)
                                        .foregroundStyle(customizationObject.isContained(term: genreText) ? Color.black : ColorSet.lightGray)
                                        .background(customizationObject.isContained(term: genreText) ? ColorSet.mainPurpleColor : ColorSet.deepGray)
                                        .overlay(content: {
                                            RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular)
                                                .stroke(Color.white, lineWidth: customizationObject.isContained(term: genreText) ? 0 : 1)
                                        })
                                        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 30, height: 30), style: .circular))

                                        .onTapGesture {
                                            print()
                                            if customizationObject.checkedCount < 5 {
                                                customizationObject.checkedCount += 1
                                                customizationObject.selectedGenreList.append(genreText)
                                            }
                                        }
                                        
                                }
                            })
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 20)
                        }
                    })
                    .padding(.top, 42)
                    
                }
            })
        }

        
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
}

//#Preview {
//    SelectGenreView()
//}


