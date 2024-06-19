//
//  SearchLocationMapVIew.swift
//  Feature
//
//  Created by 다솔 on 2023/11/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Core
import Shared
import _MapKit_SwiftUI


public struct SearchLocationMapView: View {
    
    @State var locationModel: LocationModel = .init()
    
    @State private var locationTitleText: String = ""
    @State private var translation: CGSize = .zero
    @State private var isBottomSheetShown: Bool = false
    @State private var scrollViewOffset: CGFloat = .zero
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    
    public init() {}
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    //                    DispatchQueue.main.async {
                    self.translation.height = value.translation.height
                    //                    }
                }
            }
            .onEnded { value in
                withAnimation(Animation.easeInOut(duration: 0.01)) {
                    if value.translation.height > 50 {
                        self.isBottomSheetShown = false
                    }
                    self.translation.height = 0
                }
            }
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack(spacing: 0) {
                
                ZStack(alignment: .topLeading) {
                    
                    SearchLocationMapViewRepresentable(locationModel: $locationModel)
                    
                    Button(action: {
                        withAnimation {
                            appCoordinator.rootPath.removeLast()
                        }
                    }) {
                        Image(uiImage: SharedAsset.backSearchLocation.image)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .padding(20)
                    }
                    .padding(.top, appCoordinator.safeAreaInsetsTop)
                }
                
                VStack(spacing: 0) {
                    
                    Text("\(locationModel.locationTitle)")
                        .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .padding(.top, 30)
                    
                    Text("\(locationModel.locationSubtitle)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                        .foregroundColor(.white.opacity(0.7))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 30)
                        .padding(.top, 10)
                    
                    HStack(alignment: .center, spacing: 6) {

                        SharedAsset.pencilIconCreateMumory.swiftUIImage
                            .resizable()
                            .frame(width: 12, height: 12)
                            .offset(x: 13)
                        
                        Text("직접입력")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            .offset(x: 13)
                    }
                    .frame(width: 89, height: 33, alignment: .leading)
                    .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                    .cornerRadius(30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 30)
                            .inset(by: 0.5)
                            .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
                    )
                    .onTapGesture {
                        withAnimation(Animation.easeInOut(duration: 0.1)) {
                            self.isBottomSheetShown = true
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .padding(.top, 15)
                    
                    Spacer()
                    
                    Button(action: {
                        mumoryDataViewModel.choosedLocationModel = locationModel
                        appCoordinator.rootPath.removeLast(2)
                    }) {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(width: getUIScreenBounds().width - 40, height: 55)
                            .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                            .cornerRadius(35)
                            .overlay(
                                Text("선택하기")
                                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.black)
                            )
                            .padding(.horizontal, 20)
                            .padding(.bottom, getUIScreenBounds().width == 375 ? 39 : 51)
                        
                    }
                } // VStack
                .frame(height: 260)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            } // VStack
            .navigationBarBackButtonHidden(true)
            .frame(width: UIScreen.main.bounds.width + 1)
            
            if self.isBottomSheetShown {
                Color.black.opacity(0.5)
                    .onTapGesture {
                        withAnimation(Animation.easeInOut(duration: 0.1)) { // 사라질 때 애니메이션 적용
                            self.isBottomSheetShown = false
                        }}
                
                LocationInputBottomSheetView(isShown: self.$isBottomSheetShown, locationTitleText: $locationModel.locationTitle, searchText: locationModel.locationTitle)
                    .offset(y: self.translation.height)
                    .gesture(dragGesture)
                    .transition(.move(edge: .bottom))
                    .zIndex(1)
                    .padding(.bottom, appCoordinator.safeAreaInsetsBottom)
                    .offset(y: -scrollViewOffset)
                    .onAppear {
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
                            guard let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                            let keyboardHeight = keyboardSize.height
                            
                            withAnimation {
                                scrollViewOffset = keyboardHeight
                            }
                        }
                        
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (notification) in
                            withAnimation {
                                scrollViewOffset = 0
                            }
                        }
                    }
            }
            
        }
        .ignoresSafeArea()
        .statusBarHidden(true)
    }
}

