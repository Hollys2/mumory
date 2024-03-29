//
//  SearchLocationView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/26.
//  Copyright © 2023 hollys. All rights reserved.
//


import MapKit
import SwiftUI
import Core
import Shared


struct AddressRow: View {
    
    @State var result: MKLocalSearchCompletion
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var localSearchViewModel: LocalSearchViewModel
    
    var body: some View {
        Button(action: {
            localSearchViewModel.getRegion(localSearchCompletion: result) { region in
                if let region = region {
                    DispatchQueue.main.async {
                        let coordinate = CLLocationCoordinate2D(latitude: region.center.latitude, longitude: region.center.longitude)
                        mumoryDataViewModel.choosedLocationModel = LocationModel(locationTitle: result.title, locationSubtitle: result.subtitle, coordinate: coordinate)
                        
                        self.localSearchViewModel.addRecentSearch(RecentLocationSearch(locationTitle: result.title, locationSubTitle: result.subtitle, latitude: region.center.longitude, longitude: region.center.latitude))
                    }
                } else {
                    print("ERROR: 해당하는 주소가 없습니다.")
                }
            }
            
            appCoordinator.rootPath.removeLast()
        }) {
            HStack(spacing: 0) {
                SharedAsset.addressSearchLocation.swiftUIImage
                    .resizable()
                    .frame(width: 20, height: 23)
                
                Spacer().frame(width: 13)
                
                VStack(spacing: 6) {
                    Text(result.title)
                        .lineLimit(1)
                        .font(Font.custom("Pretendard", size: 15).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if !result.subtitle.isEmpty {
                        Text(result.subtitle)
                            .lineLimit(1)
                            .font(Font.custom("Pretendard", size: 13))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer().frame(width: 20)
                
                SharedAsset.addAddressButton.swiftUIImage
                    .resizable()
                    .frame(width: 30, height: 30)
            } // HStack
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .padding(.leading, 5)
        }
    }
}

struct SearchLocationView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var localSearchViewModel: LocalSearchViewModel
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            HStack {
                ZStack(alignment: .leading) {
                    TextField("", text: $localSearchViewModel.queryFragment,
                              prompt: Text("위치 검색").font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .padding(.horizontal, 15 + 23 + 7)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    )
                    .foregroundColor(.white)
                    
                    SharedAsset.searchIconCreateMumory.swiftUIImage
                        .resizable()
                        .frame(width: 23, height: 23)
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        .padding(.leading, 15)
                    
                    if !self.localSearchViewModel.queryFragment.isEmpty {
                        Button(action: {
                            self.localSearchViewModel.queryFragment = ""
                        }) {
                            HStack {
                                Spacer()
                                SharedAsset.removeButtonSearch.swiftUIImage
                                    .resizable()
                                    .frame(width: 23, height: 23)
                            }
                            .padding(.trailing, 17)
                        }
                    }
                }
                
                Button(action: {
                    appCoordinator.rootPath.removeLast()
                }) {
                    Text("취소")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.white)
                }
            } // HStack
            .frame(maxWidth: .infinity)
            .padding(.bottom, 15)
            
            if self.localSearchViewModel.results.isEmpty {
                ScrollView {
                    
                    VStack(spacing: 15) {
                        
                        VStack(spacing: 0) {
                            
                            Button(action: {
                                if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
                                     self.locationManager.promptForLocationSettings()
                                 }
                                
                                if let currentLocation = locationManager.currentLocation {
                                    mumoryDataViewModel.getChoosedeMumoryModelLocation(location: currentLocation) { model in
                                        mumoryDataViewModel.choosedLocationModel = model
                                    }
                                    appCoordinator.rootPath.removeLast()
                                } else {
                                    print("ERROR: locationManager.userLocation is nil")
                                }
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 55)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                    
                                    HStack(spacing: 10) {
                                        Image(uiImage: SharedAsset.userSearchLocation.image)
                                            .resizable()
                                            .frame(width: 29, height: 29)
                                        
                                        Text("현재 위치")
                                            .font(
                                                Font.custom("Apple SD Gothic Neo", size: 14)
                                                    .weight(.medium)
                                            )
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 20)
                                }
                            }
                            
                            Rectangle()
                                .frame(maxWidth: .infinity)
                                .frame(height: 0.3)
                                .foregroundColor(Color(red: 0.651, green: 0.651, blue: 0.651, opacity: 0.698).opacity(0.7))
                            
                            Button(action: {
                                appCoordinator.rootPath.append("map")
                            }) {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 55)
                                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                                    
                                    HStack(spacing: 12) {
                                        Image(uiImage: SharedAsset.mapSearchLocation.image)
                                            .resizable()
                                            .frame(width: 24, height: 22)
                                        
                                        Text("지도에서 직접 선택")
                                            .font(
                                                Font.custom("Apple SD Gothic Neo", size: 14)
                                                    .weight(.medium)
                                            )
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 23)
                                }
                            }
                        }
                        .background(SharedAsset.backgroundColor.swiftUIColor)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                        
                        VStack(spacing: 0) {
                            
                            HStack {
                                Text("최근 검색")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if !self.localSearchViewModel.recentSearches.isEmpty {
                                    Button(action: {
                                        self.localSearchViewModel.clearRecentSearches()
                                    }) {
                                        Text("전체삭제")
                                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                            .multilineTextAlignment(.trailing)
                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    }
                                }
                            }
                            .padding([.horizontal, .top], 20)
                            .padding(.bottom, 11)
                            
                            if !self.localSearchViewModel.recentSearches.isEmpty {
                                ForEach(self.localSearchViewModel.recentSearches, id: \.self) { value in
                                    RecentSearchItem(title: value.locationTitle) {
                                        self.localSearchViewModel.removeRecentSearch(value)
                                    }
                                    .onTapGesture {
                                        mumoryDataViewModel.choosedLocationModel = LocationModel(locationTitle: value.locationTitle, locationSubtitle: value.locationSubTitle, coordinate: CLLocationCoordinate2D(latitude: value.latitude, longitude: value.longitude))
                                        appCoordinator.rootPath.removeLast()
                                    }
                                }
                            } else {
                                Text("최근 검색내역이 없습니다.")
                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                    .foregroundColor(Color(red: 0.475, green: 0.475, blue: 0.475))
                                    .frame(height: 50)
                            }
                            
                            Spacer().frame(height: 15)
                        }
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .circular))
                        
                        if !self.localSearchViewModel.popularSearches.isEmpty {
                            
                            VStack(alignment: .leading, spacing: 0) {
                                
                                HStack {
                                    
                                    Text("뮤모리 인기 위치 검색어")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                }
                                .padding(20)
                                
                                HStack(spacing: 8) {
                                    
                                    ForEach(self.localSearchViewModel.popularSearches, id: \.self) { searchTerm in
                                        
                                        Text(searchTerm)
                                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                            .frame(height: 33)
                                            .padding(.horizontal, 16)
                                            .background(SharedAsset.mainColor.swiftUIColor)
                                            .cornerRadius(35)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .background(.pink)
                                
                                Spacer().frame(height: 12)
                            }
                            .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                            .cornerRadius(15)
                        }
                        
                    } // VStack
                    .padding(.bottom, 66)
                } // ScrollView
                .scrollIndicators(.hidden)
                .cornerRadius(15)
            } else {
                ScrollView {
                    
                    VStack(spacing: 0) {
                        
                        ForEach(self.localSearchViewModel.results, id: \.self) { result in
                            AddressRow(result: result)
                        }
                    } // VStack
                    .padding(.bottom, 66)
                } // ScrollView
                .scrollIndicators(.hidden)   
            }
        } // VStack
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 20)
        .frame(width: UIScreen.main.bounds.width + 1)
        .padding(.top, 60)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .loadingLottie(localSearchViewModel.isSearching)
        .onDisappear {
            appCoordinator.isSearchLocationViewShown = false
            localSearchViewModel.queryFragment = ""
        }
    }
}
