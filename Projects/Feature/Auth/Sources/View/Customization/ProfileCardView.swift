//
//  LastOfCustomizationView.swift
//  Feature
//
//  Created by 제이콥 on 12/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct ProfileCardView: View {
    // MARK: - Propoerties
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    
    @State var isTitleShown: Bool = false
    @State var isCardShown: Bool = false
    @State var isSubTitleShown: Bool = false
    
    // MARK: - View
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            VStack(spacing: 0){
                Text("프로필 생성이 완료되었습니다!")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                    .foregroundStyle(.white)
                    .padding(.top, getUIScreenBounds().height > 815 ? 65 : 50)
                    .offset(y: isTitleShown ? -15 : 0)
                    .opacity(isTitleShown ? 1 : 0)
                
                CardView
                
                Text("지금부터 뮤모리를 통해\n많은 음악과 특별한 순간을 공유해보세요")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.subGray)
                    .multilineTextAlignment(.center)
                    .padding(.top, 37)
                    .tracking(0.3)
                    .lineSpacing(5)
                    .offset(y: isSubTitleShown ? -15 : 0)
                    .opacity(isSubTitleShown ? 1 : 0)
            }
            
            StartButton
      
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            setAnimationTimer()
        }
    }
    
    var StartButton: some View {
        VStack {
            Spacer()
            Button {
                appCoordinator.isHomeViewShown = true
            } label: {
                CommonButton(title: "시작하기", isEnabled: true)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    var CardView: some View {
        VStack(spacing: 0, content: {
            VStack(spacing: 0, content: {
                Group {
                    if let image = signUpViewModel.profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 105, height: 105)
                            .clipShape(Circle())
                        
                    } else {
                        signUpViewModel.getDefaultProfileImage()
                    }
                }
                .padding(.top, 33)
                
                Text(signUpViewModel.nickname)
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 20))
                    .foregroundStyle(.white)
                    .padding(.top, 18)
                
                Text("@\(signUpViewModel.id)")
                    .font(SharedFontFamily.Pretendard.extraLight.swiftUIFont(size: 15))
                    .foregroundStyle(Color(red: 0.72, green: 0.72, blue: 0.72))
                    .padding(.top, 8)
                    .padding(.bottom, 25)
            })
            
            VStack(spacing: 0, content: {
                Text("관심 음악 장르")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                    .foregroundStyle(Color(white: 0.96))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(white: 0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .circular))
                    .padding(.top, 18)
                
                
                Text(getGenreText(list: signUpViewModel.favoriteGenres, screen: getUIScreenBounds().size))
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                    .foregroundColor(ColorSet.mainPurpleColor)
                    .multilineTextAlignment(.center)
                    .padding(.top, 13)
                    .lineSpacing(5)
                    .lineLimit(5)
                
                Divider()
                    .background(Color(white: 0.2))
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 57)
                    .padding(.top, 20)
                
                Text("음악 감상 시간대")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 12))
                    .foregroundStyle(Color(white: 0.96))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(white: 0.16))
                    .clipShape(RoundedRectangle(cornerRadius: 40, style: .circular))
                    .padding(.top, 21)
                
                
                Text(getTimeZoneText(timeZone: signUpViewModel.notificationTime))
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                    .foregroundColor(ColorSet.mainPurpleColor)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
            })
            .frame(maxWidth: .infinity)
            .background(ColorSet.moreDeepGray)
            
            
        })
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 20, style: .circular)
                .stroke(ColorSet.subGray, lineWidth: 1)
        })
        .padding(.horizontal, 58)
        .padding(.top, 37)
        .offset(y: isCardShown ? -15 : 0)
        .opacity(isCardShown ? 1 : 0)
    }
    
    // MARK: - Methods
    private func setAnimationTimer() {
        var count: Int = 0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            withAnimation(.easeOut(duration: 0.3)) {
                if count == 1 {
                    print("첫번째")
                    isTitleShown = true
                } else if count == 2 {
                    isCardShown = true
                } else if count == 3 {
                    isSubTitleShown = true
                    timer.invalidate()
                }
                count += 1
            }
        }
    }
    
    private func getTextWidth(term: String) -> CGFloat {
        let fontAttribute = [NSAttributedString.Key.font: SharedFontFamily.Pretendard.medium.font(size: 13)]
        var width = (term as NSString).size(withAttributes: fontAttribute).width
        width += 2 //spacing
        return width
    }
    
    private func getGenreText(list: [MusicGenre], screen: CGSize) -> String {
        let screenWidth = screen.width - 114 - 116
        var result = ""
        var widthSum: CGFloat = 0
        var genreList = list
        
        //장르 이름 보여줄 때 가장 앞에 있는 장르에는 | 를 붙이면 안 되니까 따로 저장해줌.
        //0개를 선택할 일은 없지만 혹시 범위 오류 날까봐 조건문을 달아줌
        if list.count > 0 {
            result = "\(genreList[0].name) "
            widthSum = getTextWidth(term: genreList[0].name)
            genreList.remove(at: 0)
        }
        
        for genre in genreList{
            let textWidth = getTextWidth(term: genre.name)
            if (widthSum + textWidth) > screenWidth {
                result += "\n | \(genre.name) "
                widthSum = textWidth
            }else {
                result += "| \(genre.name) "
                widthSum += textWidth
            }
        }
        
        return result
    }
    
    private func getTimeZoneText(timeZone: TimeZone) -> String {
        switch timeZone {
        case .moring:
            return "아침 6:00AM ~ 11:00AM"
        case .afternoon:
            return "점심 11:00AM - 4:00PM"
        case .evening:
            return "저녁 4:00PM - 9:00PM"
        case .night:
            return "밤 9:00PM - 2:00AM"
        case .auto:
            return "이용 시간대를 분석해 자동으로 설정"
        case .none:
            return ""
        }
    }
}
