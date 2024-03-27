//
//  RegionMyMumoryView.swift
//  Feature
//
//  Created by 다솔 on 2024/03/27.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI

import Shared


public struct RegionMyMumoryView: View {
    
    let region: String
    let mumorys: [Mumory]
    
    @State private var selectedDate: Date = Date()
    @State private var currentTabSelection: Int = 0
    @State private var isDatePickerShown: Bool = false
    @State private var isMyMumorySearchViewShown: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @State private var offset: CGFloat = 0.0
    @State private var scrollViewOffsetY: CGFloat = 0.0
    @State private var dateViewOffsetY: CGFloat = 0.0
    
    public var body: some View {
        ZStack {
            
            VStack(spacing: 0) {
                
                VStack(spacing: 0) {
                    
                    Spacer().frame(height: self.appCoordinator.safeAreaInsetsTop + 19)
                    
                    HStack(spacing: 0) {
                        
                        Button(action: {
                            self.appCoordinator.rootPath.removeLast()
                        }, label: {
                            SharedAsset.backButtonTopBar.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                        })
                        
                        Spacer()
                        
                        TopBarTitleView(title: self.region)
                        
                        Spacer()
                        
                        Button(action: {
                            self.isMyMumorySearchViewShown = true
                        }, label: {
                            SharedAsset.searchButtonMypage.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                        })
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 13)
                    
                    VStack(spacing: 0) {
                        
                        ZStack(alignment: .top) {
                            
                            ScrollView(showsIndicators: false) {
                                
                                VStack(spacing: 0) {
                                    
                                    ForEach(Array(self.mumorys.enumerated()), id: \.element) { index, mumory in
                                        
                                        if index > 0 && !isSameMonth(mumory, with: self.mumorys[index - 1]) {
                                            ZStack(alignment: .topLeading) {
                                                Rectangle()
                                                    .foregroundColor(.clear)
                                                    .frame(height: 31)
                                                    .overlay(
                                                        Rectangle()
                                                            .foregroundColor(.clear)
                                                            .frame(width: getUIScreenBounds().width, height: 0.3)
                                                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.4)),
                                                        alignment: .top
                                                    )
                                                
                                                Text("\(DateManager.formattedDate(date: mumory.date, dateFormat: "YYYY년 M월"))")
                                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                                    .foregroundColor(.white)
                                                    .padding(.leading, 12)
                                                    .offset(y: 21)
                                            }
                                            .padding(.top, 30)
                                        }
                                        
                                        MumoryItemView(mumory: mumory, isRecent: index == 0 ? true : false)
                                    }
                                } // VStack
                                .padding(.top, 45)
                            } // ScrollView
                            
                            ZStack(alignment: .leading) {
                                
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: getUIScreenBounds().width, height: 55)
                                    .background(Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0.4).blur(radius: 5))
                                    .overlay(
                                        Rectangle()
                                            .foregroundColor(.clear)
                                            .frame(width: getUIScreenBounds().width, height: 0.3)
                                            .background(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.3))
                                        , alignment: .bottom
                                    )
                                
                                HStack(spacing: 6) {
                                    Text("\(Calendar.current.component(.month, from: self.selectedDate))월")
                                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                                        .foregroundColor(.white)
                                    
                                    SharedAsset.dateButtonMypage.swiftUIImage
                                        .resizable()
                                        .frame(width: 15, height: 15)
                                }
                                .padding(.leading, 12)
                                .onTapGesture {
                                    self.isDatePickerShown = true
                                }
                            }
                            
                        }
                    } // VStack
                }
            }
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            
            
            if self.isMyMumorySearchViewShown {
                MyMumorySearchView(isShown: self.$isMyMumorySearchViewShown)
            }
        }
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .sheet(isPresented: self.$isDatePickerShown, content: {
            MyMumoryDatePicker(selectedDate: self.$selectedDate)
                .presentationDetents([.height(309)])
        })
        .bottomSheet(isShown: $appCoordinator.isMyMumoryBottomSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .myMumory, mumoryAnnotation: .constant(Mumory())))
        .popup(show: $appCoordinator.isDeleteMumoryPopUpViewShown, content: {
            PopUpView(isShown: $appCoordinator.isDeleteMumoryPopUpViewShown, type: .twoButton, title: "해당 뮤모리를 삭제하시겠습니까?", buttonTitle: "뮤모리 삭제", buttonAction: {
                mumoryDataViewModel.deleteMumory(self.appCoordinator.choosedMumoryAnnotation) {
                    print("뮤모리 삭제 성공")
                    appCoordinator.isDeleteMumoryPopUpViewShown = false
                }
            })
        })
        .ignoresSafeArea()
    }
    
    func calculateSpacing(forIndex index: Int) -> CGFloat {
        guard index > 0 else {
            return 0
        }
        let previousDate = mumoryDataViewModel.filteredMumorys[index - 1].date
        let currentDate = mumoryDataViewModel.filteredMumorys[index].date
        
        print("previousDate: \(previousDate)")
        print("currentDate: \(currentDate)")
        print(Calendar.current.isDate(currentDate, equalTo: previousDate, toGranularity: .day))
        
        return !Calendar.current.isDate(currentDate, equalTo: previousDate, toGranularity: .day) ? 0 : 30
    }
    
    func isSameMonth(_ mumory1: Mumory, with mumory2: Mumory) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month], from: mumory1.date)
        let components2 = calendar.dateComponents([.year, .month], from: mumory2.date)
        return components1.year == components2.year && components1.month == components2.month
    }
}
