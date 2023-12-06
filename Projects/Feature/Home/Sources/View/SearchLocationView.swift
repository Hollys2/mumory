//
//  SearchLocationView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/26.
//  Copyright © 2023 hollys. All rights reserved.
//


import MapKit
import SwiftUI
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
    
    //    @StateObject var viewModel: ContentViewModel = ContentViewModel()
    @StateObject var viewModel: ContentViewModel = .init()
    @FocusState private var isFocusedTextField: Bool
    
    @State private var text = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var isActive = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let address: AddressResult = AddressResult(title: "타이틀", subtitle: "서브타이틀")
    //    private var searchCompleter = MKLocalSearchCompleter()
    //    private var searchResults = [MKLocalSearchCompletion]()
    
    var body: some View {
            VStack {
                HStack {
                    ZStack(alignment: .leading) {
                        TextField("", text: $viewModel.searchableText,
                                  prompt: Text("위치 검색").font(Font.custom("Pretendard", size: 16))
                            .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .padding(.leading, 15 + 23 + 7)
                        .padding(.trailing, 15 + 23 + 7)
                        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                        .foregroundColor(.white)
                        .cornerRadius(22)
                        .onReceive(
                            viewModel.$searchableText.debounce(
                                for: .seconds(1),
                                scheduler: DispatchQueue.main
                            )
                        ) {
                            viewModel.searchAddress($0)
                            print(viewModel)
                            print(viewModel.searchAddress($0))
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
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("취소")
                            .font(
                                Font.custom("Pretendard", size: 16)
                                    .weight(.medium)
                            )
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .padding(.top, 28)
                
                
                if self.viewModel.results.isEmpty {
                    VStack(spacing: 0) {
                        Button(action: {
                            
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
                            appCoordinator.isCreateMumorySheetShown = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                appCoordinator.isSearchLocationMapViewShown = true
                            }
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
                        //                    .background(
                        //                        NavigationLink(
                        //                            destination: SearchLocationMapView(address: address),
                        //                            isActive: $appCoordinator.isSearchLocationMapViewShown
                        //                        ) {
                        //                            EmptyView()
                        //                        }
                        //                        .hidden()
                        //                    )
                    }
                    .cornerRadius(15)
                    .padding(.top, 15)
                    .padding(.bottom, 15)
                    
                    VStack {
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
                        
                        ScrollView {
                            VStack(spacing: 0) {
                                
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
                                }
                            }
                            .padding(.leading, 15)
                            .padding(.trailing, 20)
                        }
                        .frame(height: 200) // 스크롤 뷰의 높이를 설정 (이 높이를 초과하면 스크롤됨)
                    }
                    .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                    .cornerRadius(15)
                    
                    Spacer()
                    
                }
                else {
                    ScrollView {
                        VStack {
                            ForEach(self.viewModel.results, id: \.self) { address in
                                AddressRow(address: address)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .frame(height: 50) // 각 행의 높이를 설정하고자 할 때 추가
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationBarBackButtonHidden(true)
            .padding(.horizontal, 21)
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .cornerRadius(23)
            .onDisappear {
                appCoordinator.isSearchLocationViewShown = false
            }
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .frame(width: UIScreen.main.bounds.width + 1)
    }
}

@available(iOS 16.0, *)
struct SearchLocationView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleViewModel = ContentViewModel()
        SearchLocationView(viewModel: sampleViewModel)
    }
}
