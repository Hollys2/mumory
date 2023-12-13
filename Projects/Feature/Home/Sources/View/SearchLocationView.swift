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

@available(iOS 16.0, *)
struct AddressRow: View {
    
    let address: AddressResult
    
    var body: some View {
        NavigationLink(destination: SearchLocationMapView(address: address)) {
            HStack(spacing: 11) {
                Image(uiImage: SharedAsset.addressSearchLocation.image)
                    .resizable()
                    .frame(width: 20, height: 23)
                    .padding(.leading, 15)
                
                Text(address.title)
                    .font(
                        Font.custom("Apple SD Gothic Neo", size: 15)
                            .weight(.medium)
                    )
                    .foregroundColor(.white)
                    .frame(alignment: .leading)
                
                Spacer()
            }
        }
        .isDetailLink(false)
        .frame(height: 50)
    }
}

@available(iOS 16.0, *)
struct SearchLocationView: View {
    
    @State private var text = ""
    @State private var isActive = false
    @FocusState private var isFocusedTextField: Bool
    
    @ObservedObject var mapViewModel: MapViewModel = .init()
    @StateObject var viewModel: ContentViewModel = .init()
    @EnvironmentObject var appCoordinator: AppCoordinator
    @StateObject var locationManager = LocationManager()
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let address: AddressResult = AddressResult(title: "타이틀", subtitle: "서브타이틀")
    //    private var searchCompleter = MKLocalSearchCompleter()
    //    private var searchResults = [MKLocalSearchCompletion]()
    
    @GestureState var dragAmount = CGSize.zero
    @Binding var translation: CGSize
    
    var body: some View {
        VStack(spacing: 0) {
            Image(uiImage: SharedAsset.dragIndicator.image)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
                .padding(.bottom, 14)
                .background(SharedAsset.backgroundColor.swiftUIColor) // 색이 존재해야 제스처 동작함
                .gesture(
                    DragGesture()
                        .updating($dragAmount) { value, state, _ in
                            if value.translation.height > 0 {
//                                                        state = value.translation
                                translation.height = value.translation.height
                            }
                        }
                        .onEnded { value in
                            withAnimation(Animation.easeInOut(duration: 0.1)) {
                                if value.translation.height > 130 {
                                    appCoordinator.isCreateMumorySheetShown = false
                                }
                                translation.height = 0
                            }
                        }
                )
            
            HStack {
                ZStack(alignment: .leading) {
                    TextField("", text: $viewModel.searchableText,
                              prompt: Text("위치 검색").font(Font.custom("Pretendard", size: 16))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .padding(.leading, 15 + 23 + 7)
                    .padding(.trailing, 15 + 23 + 7)
                    .background(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color(red: 0.24, green: 0.24, blue: 0.24))
                    )
                    .foregroundColor(.white)
                    .onReceive(
                        viewModel.$searchableText
                            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main
                                     )
                    ) {
                        viewModel.searchAddress($0)
                    }
                    
                    Image(systemName: "magnifyingglass")
                        .frame(width: 23, height: 23)
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        .padding(.leading, 15)
                    
                    if !self.viewModel.searchableText.isEmpty {
                        Button(action: {
                            self.viewModel.searchableText = ""
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                            .padding(.trailing, 17)
                        }
                    }
                }
                
                Button(action: {
                    print("FUCK: \(appCoordinator.isSearchLocationViewShown)")
                    appCoordinator.isSearchLocationViewShown = false
//                                            self.presentationMode.wrappedValue.dismiss()
                }) {
                    Text("취소")
                        .font(
                            Font.custom("Pretendard", size: 16)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.white)
                }
            } // HStack
            .frame(maxWidth: .infinity)
            .padding(.bottom, 15)
            
            if let places = self.locationManager.fetchedPlaces, !places.isEmpty {
                ScrollView {
                    VStack {
                        ForEach(places, id: \.self) { place in
                            NavigationLink(destination: SearchLocationMapView(address: address)) {
                                HStack(spacing: 11) {
                                    Image(uiImage: SharedAsset.addressSearchLocation.image)
                                        .resizable()
                                        .frame(width: 20, height: 23)
                                        .padding(.leading, 15)
                                    
                                    Text(place.name ?? "노 네임")
                                        .font(
                                            Font.custom("Apple SD Gothic Neo", size: 15)
                                                .weight(.medium)
                                        )
                                        .foregroundColor(.white)
                                        .frame(alignment: .leading)
                                    
                                    Text(place.locality ?? "")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            .frame(height: 50)
                        }
                    }
                }
                
            }
            
            if self.viewModel.results.isEmpty {
                ScrollView {
                    VStack(spacing: 15) {
                        VStack(spacing: 0) {
                            Button(action: {
                                if let userLocation = locationManager.userLocation {
                                    let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
                                    //                                    locationManager.convertLocationToAddress(location: location)
                                    
                                    locationManager.convertLocationToAddress(location: location)
                                    
                                    
                                    
                                    self.presentationMode.wrappedValue.dismiss()
                                    appCoordinator.isSearchLocationViewShown = false
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
                                .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                            
                            Button(action: {
                                appCoordinator.isSearchLocationMapViewShown = true
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
                        .cornerRadius(15)
                        .background(SharedAsset.backgroundColor.swiftUIColor)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Text("최근 검색")
                                    .font(
                                        Font.custom("Pretendard", size: 13)
                                            .weight(.medium)
                                    )
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                }) {
                                    Text("전체삭제")
                                        .font(
                                            Font.custom("Pretendard", size: 12)
                                                .weight(.medium)
                                        )
                                        .multilineTextAlignment(.trailing)
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                }
                            }
                            .padding([.horizontal, .top], 20)
                            .padding(.bottom, 11)
                            
                            ForEach(1...10, id: \.self) { index in
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .frame(width: 23, height: 23)
                                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    
                                    Text("검색검색 \(index)")
                                        .font(
                                            Font.custom("Pretendard", size: 14)
                                                .weight(.semibold)
                                        )
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Button(action: {}) {
                                        Image(systemName: "xmark")
                                            .frame(width: 19, height: 19)
                                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .padding(.leading, 15)
                                .padding(.trailing, 20)
                            }
                        }
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                        .cornerRadius(15)
                    } // VStack
                    .padding(.bottom, 66)
                } // ScrollView
                .scrollIndicators(.hidden)
                .cornerRadius(15)
            } else {
                ScrollView {
                    VStack {
                        ForEach(self.viewModel.results, id: \.self) { address in
                            AddressRow(address: address)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .frame(height: 50)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        } // VStack
        .navigationBarBackButtonHidden(true)
        .padding(.horizontal, 21)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .frame(width: UIScreen.main.bounds.width + 1)
        .onDisappear {
            appCoordinator.isSearchLocationViewShown = false
        }
    }
}

//@available(iOS 16.0, *)
//struct SearchLocationView_Previews: PreviewProvider {
//    static var previews: some View {
//        let sampleViewModel = ContentViewModel()
//        SearchLocationView(viewModel: sampleViewModel)
//    }
//}
