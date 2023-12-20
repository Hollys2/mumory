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
    
    @State var result: MKLocalSearchCompletion = MKLocalSearchCompletion()
    @State var mumoryModel: MumoryModel = .init(coordinate: MapConstant.defaultCoordinate2D)

    @StateObject private var localSearchViewModel: LocalSearchViewModel = .init()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject private var locationViewModel: LocationViewModel

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                SearchLocationMapViewRepresentable(mumoryModel: $mumoryModel)
//                Map(
//                    coordinateRegion: $localSearchViewModel.region
////                    annotationItems: localSearchViewModel.annotationItems,
////                    annotationContent: { item in
////                        MapMarker(coordinate: item.coordinate)
////                    }
//                )
//                .onAppear {
//                    localSearchViewModel.getRegion(localSearchCompletion: result) { coordinate in
//                        if let coordinate = coordinate {
//                            print("장소의 위도: \(coordinate.latitude), 경도: \(coordinate.longitude)")
//                            // 여기에 가져온 좌표를 사용하는 로직을 추가할 수 있습니다.
//                        } else {
//                            print("장소의 좌표를 찾을 수 없습니다.")
//                        }
//                    }
//                }
                
                Button(action: {
                    withAnimation {
                        appCoordinator.isSearchLocationMapViewShown = false
                        appCoordinator.path.removeLast()
                    }
                }) {
                    Image(uiImage: SharedAsset.backSearchLocation.image)
                        .resizable()
                        .frame(width: 30, height: 30)
//                        .frame(width: 50, height: 50) // 버튼의 터치 영역 확장
                        .background(Color.red)
                        
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 31)
                .padding(.leading, 20)
                

            }
            .frame(height: UIScreen.main.bounds.height * 0.94 * 0.72)
            
            VStack(spacing: 0) {
                Text("\(mumoryModel.locationTitle ?? "locationTitle")")
                    .font(
                        Font.custom("Pretendard", size: 20)
                            .weight(.bold)
                    )
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 35)
                
                Text("\(mumoryModel.locationSubtitle ?? "locationSubtitle")")
                    .font(
                        Font.custom("Pretendard", size: 15)
                            .weight(.medium)
                    )
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 14)
                
                Button(action: {
                    locationViewModel.choosedMumoryModel = mumoryModel
                    appCoordinator.path.removeLast(appCoordinator.path.count)
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
            .frame(height: UIScreen.main.bounds.height * 0.94 * 0.28)
            Spacer()
        } // VStack
        .navigationBarBackButtonHidden(true)
//        .padding(.horizontal, 21)
        .frame(width: UIScreen.main.bounds.width + 1)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .ignoresSafeArea()
    }
}

//@available(iOS 16.0, *)
//struct SearchLocationMapVIew_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchLocationMapView()
//    }
//}

