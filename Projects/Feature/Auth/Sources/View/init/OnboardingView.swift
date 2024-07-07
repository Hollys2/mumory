//
//  OnBoardingManageView.swift
//  Feature
//
//  Created by 제이콥 on 1/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Lottie

struct OnboardingView: View {
    
    // MARK: - Propoerties
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var isPresentNextView = false
    @State var selection: OnboardingType = .record

    // MARK: - View
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                IndexView
                
                TabView(selection: $selection, content:  {
                    OnboardingContentView(type: .record).tag(OnboardingType.record)
                    
                    OnboardingContentView(type: .share).tag(OnboardingType.record)
                    
                    OnboardingContentView(type: .recommendation).tag(OnboardingType.record)
                })
                .tabViewStyle(.page(indexDisplayMode: .never))
                
            })

            
            CommonButton(title: "시작하기", isEnabled: true)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(20)
                .onTapGesture {
                    appCoordinator.isOnboardingShown = false
                }
            
        }
        .navigationBarBackButtonHidden()
        .animation(.default, value: appCoordinator.isOnboardingShown)
        .transition(.opacity)
    }
    
    var IndexView: some View {
        HStack(spacing: 10, content: {
            Circle()
                .frame(width: 6, height: 6)
                .foregroundStyle(selection == .record ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
            
            Circle()
                .frame(width: 6, height: 6)
                .foregroundStyle(selection == .share ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
            
            Circle()
                .frame(width: 6, height: 6)
                .foregroundStyle(selection == .recommendation ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
        })
        .padding(.top, 24)
    }
    
}


public enum OnboardingType {
    case record
    case share
    case recommendation
}

/// 로티, 타이틀 등 온보딩 내부 컨텐츠를 담고 있는 뷰
struct OnboardingContentView: View {
    
    // MARK: - Object lifecycle
    init(type: OnboardingType) {
        switch type {
        case .record:
            self.lottieTitle = "onboardingRecord"
            self.title = "음악과 특별한 순간을 기록"
            self.subTitle = "지도에 언제 어디에서 어떤 음악을 들었는지 기록하고,\n리워드를 받아보세요"
        case .share:
            self.lottieTitle = "onboardingShare"
            self.title = "친구들과 음악과 나의 순간을 함께 공유"
            self.subTitle = "뮤모리로 친구들과 음악과 나의 순간을\n함께 공유하며 소통해보세요"
        case .recommendation:
            self.lottieTitle = "onboardingRecommendation"
            self.title = "뮤모리만의 음악 추천"
            self.subTitle = "뮤모리는 당신의 음악 취향을 이해하고,\n비슷한 취향을 가진 사람들의 음악을 추천 해드립니다"
        }
        
        setPaddingOfEachDevice()
    }
    
    // MARK: - Propoerties
    @State var topPaddingOfLottie: CGFloat = .zero
    @State var topPaddingOfTitle: CGFloat = .zero
    @State var topPaddingOfSubtitle: CGFloat = .zero
    @State var titleFontSize: CGFloat = .zero
    @State var subTitleFontSize: CGFloat = .zero
    let lottieTitle: String
    let title: String
    let subTitle: String
    
    // MARK: - View
    var body: some View {
        VStack(spacing: 0, content: {
            LottieView(animation: .named(lottieTitle, bundle: .module))
                .looping()
                .padding(.top, topPaddingOfLottie)
            
            Text(title)
                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: titleFontSize))
                .foregroundStyle(.white)
                .padding(.top, topPaddingOfTitle)
            
            
            Text(subTitle)
                .multilineTextAlignment(.center)
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: subTitleFontSize))
                .foregroundStyle(ColorSet.charSubGray)
                .padding(.top, topPaddingOfSubtitle)
                .lineSpacing(5)
            
            Spacer()
        })
        .onAppear {
            setPaddingOfEachDevice()
        }
    }
    
    // MARK: - Methods
    public func setPaddingOfEachDevice(){
        let isSmallDevice: Bool = getUIScreenBounds().height < 700
        self.topPaddingOfLottie = isSmallDevice ? 26 : 61
        self.topPaddingOfTitle = isSmallDevice ? 15 : 19
        self.topPaddingOfSubtitle = isSmallDevice ? 21 : 27
        self.titleFontSize = isSmallDevice ? 20 : 22
        self.subTitleFontSize = isSmallDevice ? 15 : 14
    }
}
