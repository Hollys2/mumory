//
//  LastOfCustomizationView.swift
//  Feature
//
//  Created by 제이콥 on 12/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct LastOfCustomizationView: View {
    @EnvironmentObject var manager: CustomizationManageViewModel
    
    @State var firstYOffset: CGFloat = 0
    @State var firstOpacity: CGFloat = 0
    @State var secondYOffset: CGFloat = 0
    @State var secondOpacity: CGFloat = 0
    @State var thirdYOffset: CGFloat = 0
    @State var thirdOpacity: CGFloat = 0
    var selectedGenreList = ["K-POP", "J-POP", "라이브음악", "인디", "HIP/HOP"]
    
    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            GeometryReader(content: { geometry in
                
                
                VStack(spacing: 0){
                    Text("프로필 생성이 완료되었습니다!")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                        .foregroundStyle(.white)
                        .padding(.top, geometry.size.height > 700 ? 75 : 50)
                        .offset(y: firstYOffset)
                        .opacity(firstOpacity)
                    
                    VStack(spacing: 0, content: {
                        VStack(spacing: 0, content: {
                            
                            if let image = manager.profileImage {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 105, height: 105)
                                    .clipShape(Circle())
                                    .padding(.top, 30)
                            }else{
                                SharedAsset.profile.swiftUIImage
                                    .frame(width: 105, height: 105)
                                    .clipShape(Circle())
                                    .padding(.top, 30)
                            }
                                
                            
                            Text(manager.nickname)
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                                .foregroundStyle(.white)
                                .padding(.top, 15)
                            
                            Text("@\(manager.id)")
                                .font(SharedFontFamily.Pretendard.extraLight.swiftUIFont(size: 15))
                                .foregroundStyle(Color(red: 0.72, green: 0.72, blue: 0.72))
                                .padding(.top, 2)
                                .padding(.bottom, 23)
                        })
                        
                        VStack(spacing: 0, content: {
                            Text("관심 음악 장르")
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                                .foregroundStyle(Color(red: 0.96, green: 0.96, blue: 0.96))
                                .padding(.top, 4)
                                .padding(.bottom, 4)
                                .padding(.leading, 12)
                                .padding(.trailing, 12)
                                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 40, height: 40), style: .circular))
                                .padding(.top, 18)
                            

                        Text(getGenreText(list: manager.genreList,screen: geometry.size))
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundColor(ColorSet.mainPurpleColor)
                                .multilineTextAlignment(.center)
                                .padding(.top, 13)
                                .lineSpacing(5)
                            
                            Rectangle()
                                .frame(height: 1)
                                .padding(.leading, 57)
                                .padding(.trailing, 57)
                                .padding(.top, 21)
                                .foregroundStyle(Color(red: 0.2, green: 0.2, blue: 0.2))
                            
                            Text("음악 감상 시간대")
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                                .foregroundStyle(Color(red: 0.96, green: 0.96, blue: 0.96))
                                .padding(.top, 4)
                                .padding(.bottom, 4)
                                .padding(.leading, 12)
                                .padding(.trailing, 12)
                                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 40, height: 40), style: .circular))
                                .padding(.top, 21)
                            

                            Text(getTimeZoneComment(timeZone: manager.selectedTime))
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                .foregroundColor(ColorSet.mainPurpleColor)
                                .multilineTextAlignment(.center)
                                .lineSpacing(5)
                                .padding(.top, 13)
                                .padding(.bottom, 23)

                        })
                        .frame(maxWidth: .infinity)
                        .background(ColorSet.moreDeepGray)
                        .clipShape(RoundedCorner(radius: 20, corners: [.bottomLeft, .bottomRight]))

                        
                    })
                    .frame(maxWidth: .infinity)
                    .overlay(content: {
                        RoundedRectangle(cornerSize: CGSize(width: 20, height: 20), style: .continuous)
                            .stroke(ColorSet.subGray, lineWidth: 0.5)
                    })
                    .padding(.leading, 58)
                    .padding(.trailing, 58)
                    .padding(.top, geometry.size.height > 700 ? 43 : 23)
                    .offset(y: secondYOffset)
                    .opacity(secondOpacity)
                    
                    Text("지금부터 뮤모리를 통해\n많은 음악과 특별한 순간을 공유해보세요")
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                        .foregroundStyle(ColorSet.subGray)
                        .multilineTextAlignment(.center)
                        .padding(.top, 37)
                        .tracking(0.5)
                        .offset(y: thirdYOffset)
                        .opacity(geometry.size.height > 700 ? thirdOpacity : 0)
                    
                    
                    Spacer()
         

                }
                
                VStack{
                    Spacer()
                    NavigationLink {
                        HomeView()
                    } label: {
                        WhiteButton(title: "시작하기", isEnabled: true)
                            .padding(.bottom, 20)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    }
                }
            })
        }
        .navigationBarBackButtonHidden()
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    firstYOffset -= 15
                    firstOpacity = 1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                withAnimation(.easeOut(duration: 0.3)) {
                    secondYOffset -= 15
                    secondOpacity = 1
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                withAnimation(.easeOut(duration: 0.3)) {
                    thirdYOffset -= 15
                    thirdOpacity = 1
                }
            }
        })
    }
    private func getTextWidth(term: String) -> CGFloat {
        let fontAttribute = [NSAttributedString.Key.font: SharedFontFamily.Pretendard.medium.font(size: 13)]
        var width = (term as NSString).size(withAttributes: fontAttribute).width
        width += 2 //spacing
        return width
    }
    
    private func getGenreText(list: [String], screen: CGSize) -> String {
        let screenWidth = screen.width - 114 - 116
        var result = ""
        var widthSum: CGFloat = 0
        var genreList = list
        
        if list.count > 0 {
            result = "\(genreList[0]) "
            widthSum = getTextWidth(term: genreList[0])
            genreList.remove(at: 0)
        }
        
        for genre in genreList{
            let textWidth = getTextWidth(term: genre)
            if (widthSum + textWidth) > screenWidth {
                result += "\n | \(genre) "
                widthSum = textWidth
            }else {
                result += "| \(genre) "
                widthSum += textWidth
            }
        }
        
        return result
    }
    
    private func getTimeZoneComment(timeZone: Int) -> String {
        if timeZone == 1 {
            return "아침 6:00AM ~ 11:00AM"
        }else if timeZone == 2 {
            return "점심 11:00AM - 4:00PM"
        }else if timeZone == 3 {
            return "저녁 4:00PM - 9:00PM"
        }else if timeZone == 4 {
            return "밤 9:00PM - 2:00AM"
        }else if timeZone == 5 {
            return "이용 시간대를 분석해 자동으로 설정"
        }
        
        return ""
    }
}

//#Preview {
//    LastOfCustomizationView()
//}
