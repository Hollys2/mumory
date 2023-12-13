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
    
    let result: AnnotationItem
    
//    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
//        NavigationLink(destination: SearchLocationMapView(addressItem: <#T##AddressItem#>)) {
            HStack(alignment: .center, spacing: 13) {
                Image(uiImage: SharedAsset.addressSearchLocation.image)
                    .resizable()
                    .frame(width: 20, height: 23)
                
                VStack(spacing: 6) {
                    Text(result.title)
                        .lineLimit(1)
                        .font(Font.custom("Pretendard", size: 15).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Text(result.subTitle)
                        .lineLimit(1)
                        .font(Font.custom("Pretendard", size: 13))
                        .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } // HStack
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .padding(.horizontal, 5)
//        }
    }
    
//    func getRegion(title: String) {
//        let searchRequest = MKLocalSearch.Request()
//        searchRequest.naturalLanguageQuery = title
//
//        let localSearch = MKLocalSearch(request: searchRequest)
//        localSearch.start { response, error in
//            guard let response = response, error == nil else {
//                print("Error searching for places:", error?.localizedDescription ?? "Unknown error")
//                return
//            }
//
//            if let firstMapItem = response.mapItems.first {
//                let coordinate = firstMapItem.placemark.coordinate
//                let latitude = coordinate.latitude
//                let longitude = coordinate.longitude
//
//                locationManager.choosedLocation = AnnotationItem(title: result.title, subTitle: result.subtitle, latitude: latitude, longitude: longitude)
//            }
//        }
//    }
}

@available(iOS 16.0, *)
struct SearchLocationView: View {
    
    @State private var text = ""
    @State private var isActive = false
    @FocusState private var isFocusedTextField: Bool
    
    @StateObject var viewModel: ContentViewModel = .init()
    @StateObject var localSearchViewModel: LocalSearchViewModel = .init()
    
    @ObservedObject var mapViewModel: MapViewModel = .init()
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var locationManager: LocationManager
    
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
                    TextField("", text: $localSearchViewModel.queryFragment,
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
                    self.presentationMode.wrappedValue.dismiss()
                    appCoordinator.isSearchLocationViewShown = false
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
            
            if self.localSearchViewModel.results.isEmpty {
                ScrollView {
                    VStack(spacing: 15) {
                        VStack(spacing: 0) {
                            Button(action: {
                                if let userLocation = locationManager.userLocation {
                                    
                                    locationManager.convertLocationToAddress(location: userLocation)
                                    
                                    self.presentationMode.wrappedValue.dismiss()
                                    appCoordinator.isSearchLocationViewShown = false
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
                    VStack(spacing: 0) {
                        ForEach(self.localSearchViewModel.results, id: \.self) { result in
//                            AddressRow(result: AnnotationItem(title: result.title, subTitle: result.subtitle, latitude: <#T##Double#>, longitude: <#T##Double#>))
                                
                        }
                    } // VStack
                    .padding(.bottom, 66)
                } // ScrollView
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
