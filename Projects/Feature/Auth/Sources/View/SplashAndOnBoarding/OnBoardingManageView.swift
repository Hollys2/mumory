//
//  OnBoardingManageView.swift
//  Feature
//
//  Created by 제이콥 on 1/29/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct OnBoardingManageView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var isPresentNextView = false
    
    var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            GeometryReader(content: { geometry in
                VStack{
                    //스크린사이즈에 따라 다른 뷰를 보여줌
                    if geometry.size.height > 700 {
                        OnBoardingManageView_big()
                            .onAppear(perform: {
                                print("big, \(geometry.size.height)")
                            })
                    }else {
                        OnBoardingManageView_small()
                            .onAppear(perform: {
                                print("small, \(geometry.size.height)")
                            })
                    }
                    
                }
                .onTapGesture {
                    print(geometry.size.height)
                }
            })
            
            VStack{
                Spacer()
                WhiteButton(title: "시작하기", isEnabled: true)
                    .padding(20)
                    .onTapGesture {
                        appCoordinator.rootPath.append(LoginPage.login)
                    }
            }
            
        }
        .navigationBarBackButtonHidden()
        
    }
    
}

struct EmpeyActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct OnBoardingManageView_small: View {
    @State var selection = 0
    
    var body: some View {
        VStack(spacing: 0, content: {
            //상단 인덱스
            HStack(spacing: 10, content: {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(selection == 0 ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
                
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(selection == 1 ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
                
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(selection == 2 ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
            }).padding(.top, 24)
            
            //페이징 기능이 있는 탭뷰
            TabView(selection: $selection,
                    content:  {
                OnBoarding1View_small().tag(0)
                
                OnBoarding2View_small().tag(1)
                
                OnBoarding3View_small().tag(2)
            })
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 26)
            
            Spacer()
            
        })
    }
}

struct OnBoardingManageView_big: View {
    @State var selection = 0
    
    var body: some View {
        VStack(spacing: 0, content: {
            //상단 인덱스
            HStack(spacing: 10, content: {
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(selection == 0 ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
                
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(selection == 1 ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
                
                Circle()
                    .frame(width: 6, height: 6)
                    .foregroundStyle(selection == 2 ? ColorSet.mainPurpleColor : ColorSet.skeleton02)
            })
            .padding(.top, 39)
            
            //페이징 기능이 있는 탭뷰
            TabView(selection: $selection,
                    content:  {
                OnBoarding1View_big().tag(0)
                
                OnBoarding2View_big().tag(1)
                
                OnBoarding3View_big().tag(2)
            })
            .tabViewStyle(.page(indexDisplayMode: .never))
            .padding(.top, 61)
            
            Spacer()
        })
    }
}


//#Preview {
//    OnBoardingManageView()
//}
