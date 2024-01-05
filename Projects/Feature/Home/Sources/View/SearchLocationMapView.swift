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
struct SearchLocationMapView: View {
    
    @State var locationModel: LocationModel = .init(locationTitle: "", locationSubtitle: "", coordinate: CLLocationCoordinate2D())
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                SearchLocationMapViewRepresentable(locationModel: $locationModel)
                    .statusBarHidden(true)

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
                        .background(Color.red)
                }
                .padding(.top, 31)
                .padding(.leading, 20)
            }
            
            VStack(spacing: 0) {
                Text("\(locationModel.locationTitle)")
                    .font(
                        Font.custom("Pretendard", size: 20)
                            .weight(.bold)
                    )
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 35)
                
                Text("\(locationModel.locationSubtitle)")
                    .font(
                        Font.custom("Pretendard", size: 15)
                            .weight(.medium)
                    )
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 14)
                
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
                                .font(
                                    Font.custom("Pretendard", size: 18)
                                        .   weight(.bold)
                                )
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 38)
                }
            } // VStack
//            .frame(height: UIScreen.main.bounds.height * 0.94 * 0.28)
        } // VStack
        .navigationBarBackButtonHidden(true)
//        .padding(.horizontal, 21)
        .frame(width: UIScreen.main.bounds.width + 1)
//        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .background(.brown)
        .ignoresSafeArea()
    }
}

//@available(iOS 16.0, *)
//struct SearchLocationMapVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchLocationMapView()
//    }
//}

