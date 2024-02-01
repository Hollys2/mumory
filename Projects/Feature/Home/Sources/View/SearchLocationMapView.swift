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

@available(iOS 16.0, *)
public struct SearchLocationMapView: View {
    
    @State var locationModel: LocationModel = .init(locationTitle: "", locationSubtitle: "", coordinate: CLLocationCoordinate2D())
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                SearchLocationMapViewRepresentable(locationModel: $locationModel)
//                    .statusBarHidden(true)

                Button(action: {
                    withAnimation {
                        appCoordinator.isSearchLocationMapViewShown = false
                        appCoordinator.rootPath.removeLast()
                    }
                }) {
                    Image(uiImage: SharedAsset.backSearchLocation.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                    //                        .frame(width: 50, height: 50) // 버튼의 터치 영역 확장
                }
                .padding(.top, appCoordinator.safeAreaInsetsTop + 19)
                .padding(.leading, 20)
            }
            
            VStack(spacing: 0) {
                
                Text("\(locationModel.locationTitle)")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 27)
                
                Text("\(locationModel.locationSubtitle)")
                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 8)
                    .padding(.bottom, 13)
                
                HStack(alignment: .center, spacing: 6) {
                    
                    SharedAsset.pencilIconCreateMumory.swiftUIImage
                        .resizable()
                        .frame(width: 12, height: 12)
                    
                    Text("직접 입력")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 10)
                .frame(height: 33, alignment: .leading)
                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                .cornerRadius(30)
                .overlay(
                  RoundedRectangle(cornerRadius: 30)
                    .inset(by: 0.5)
                    .stroke(Color(red: 0.47, green: 0.47, blue: 0.47), lineWidth: 1)
                )
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 30)
                
                Spacer()
                
                Button(action: {
                    mumoryDataViewModel.choosedLocationModel = locationModel
                    appCoordinator.rootPath.removeLast(appCoordinator.rootPath.count)
                }) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 309, height: 55)
                        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                        .cornerRadius(35)
                        .overlay(
                            Text("선택하기")
                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 39)
                        
                }
            } // VStack
            .frame(height: UIScreen.main.bounds.height * 0.349 + appCoordinator.safeAreaInsetsBottom)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        } // VStack
        .navigationBarBackButtonHidden(true)
//        .padding(.horizontal, 21)
        .frame(width: UIScreen.main.bounds.width + 1)
        .ignoresSafeArea()
    }
}

//@available(iOS 16.0, *)
//struct SearchLocationMapVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchLocationMapView()
//    }
//}

