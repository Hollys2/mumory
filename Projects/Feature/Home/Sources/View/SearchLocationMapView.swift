//
//  SearchLocationMapVIew.swift
//  Feature
//
//  Created by 다솔 on 2023/11/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared
import _MapKit_SwiftUI

@available(iOS 16.0, *)
struct SearchLocationMapView: View {
    
    @State var isShown: Bool = false
    @State var isActive: Bool = false
    @StateObject private var mapViewModel = MapViewModel()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var address: AddressResult
    //    @State private var path: [Int] = []
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                //                HomeMapView(tappedLocation: .constant(nil), isChanging: .constant(false))
                Map(
                    coordinateRegion: $mapViewModel.region,
                    annotationItems: mapViewModel.annotationItems,
                    annotationContent: { item in
                        MapMarker(coordinate: item.coordinate)
                    }
                )
                .onAppear {
                    self.mapViewModel.getPlace(from: address)
                }
                
                Button(action: {
                    withAnimation {
                        self.presentationMode.wrappedValue.dismiss()
                        appCoordinator.isSearchLocationMapViewShown = false
                    }
                    //                            appCoordinator.isCreateMumorySheetShown = true
                    //                            appCoordinator.isSearchLocationViewShown = true
                }) {
                    Image(uiImage: SharedAsset.backSearchLocation.image)
                        .resizable()
                        .frame(width: 30, height: 30)
                        .frame(width: 50, height: 50) // 버튼의 터치 영역 확장
                        .background(Color.red)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(height: UIScreen.main.bounds.height * 0.94 * 0.72)
            
            VStack(spacing: 0) {
                Text("\(address.title)")
                    .font(
                        Font.custom("Pretendard", size: 20)
                            .weight(.bold)
                    )
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 35)
                
                Text("\(address.subtitle)")
                    .font(
                        Font.custom("Pretendard", size: 15)
                            .weight(.medium)
                    )
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 30)
                    .padding(.top, 14)
                
                
                //                        NavigationLink(destination: MakeMumoryView(isShown: $isShown).environmentObject(appState)
                //                            .toolbar(.hidden), isActive: $isActive) {
                //                            EmptyView()
                //                        }
                //                        .hidden()
                
                
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                    //                        self.appCoordinator.isSearchLocationMapViewShown = false
                    //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    //                            self.appCoordinator.isCreateMumorySheetShown = true
                    //                            self.appCoordinator.isSearchLocationViewShown = false
                    //                        }
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
                Spacer()
            } // VStack
            .frame(height: UIScreen.main.bounds.height * 0.94 * 0.28)
            Spacer()
        } // VStack
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

@available(iOS 16.0, *)
struct SearchLocationMapVIew_Previews: PreviewProvider {
    static var previews: some View {
        let address: AddressResult = AddressResult(title: "타이틀", subtitle: "서브타이틀")
        SearchLocationMapView(address: address)
    }
}

