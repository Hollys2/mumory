//
//  CreateMumoryBottomSheetView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/02.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

@available(iOS 16.0, *)
public struct CreateMumoryBottomSheetView: View {
    
    @State private var translation: CGSize = CGSize(width: 0, height: 16 + 20)
    @State private var offsetY: CGFloat = 0
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    let address: AddressResult = AddressResult(title: "타이틀2", subtitle: "서브타이틀2")
    
    public var body: some View {
        NavigationStack {
            ZStack {
                SharedAsset.backgroundColor.swiftUIColor
                
                VStack(spacing: 30) {
                    Button("Close Sheet") {
                        withAnimation(Animation.easeInOut(duration: 0.3)) {
                            appCoordinator.isCreateMumorySheetShown = false
                            //                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            //                                withAnimation(Animation.easeInOut(duration: 0.3)) {
                            //                                    appCoordinator.isCreateMumorySheetShown = true
                            //                                }
                            //                            }
                        }
                    }
                    
                    Button("SearchLocationView") {
                        //                        withAnimation(Animation.easeInOut(duration: 0.3)) {
                        appCoordinator.isNavigationStackShown = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            appCoordinator.isSearchLocationViewShown = true
                        }
                        //                        }
                    }
                    
                    Button("SearchLocationMapView") {
                        appCoordinator.isNavigationStackShown = true
                        withAnimation(Animation.easeInOut(duration: 3)) {
                            appCoordinator.isCreateMumorySheetShown = false
                            appCoordinator.isSearchLocationMapViewShown = true
                        }
                    }
                }
                
                //                                    NavigationLink(destination: SearchLocationMapView(address: address), isActive: $appCoordinator.isSearchLocationMapViewShown) {
                //                                        Circle()
                //                                            .frame(width: 100, height: 100)
                //                                            .onTapGesture {
                //                                                withAnimation(Animation.easeInOut(duration: 0.3)) {
                //                                                    appCoordinator.isCreateMumorySheetShown = false
                //                                                }
                //                                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                //                                                    withAnimation(Animation.easeInOut(duration: 0.3)) {
                //                                                        appCoordinator.isSearchLocationMapViewShown = true
                //                                                    }
                //                                                }
                //                                            }
                //                                    }
                NavigationLink(destination: SearchLocationView(), isActive: $appCoordinator.isSearchLocationViewShown) {
                    EmptyView()
                }
                
                NavigationLink(destination: SearchLocationMapView(address: address), isActive: $appCoordinator.isSearchLocationMapViewShown) {
                    EmptyView()
                }
                
                //                if appCoordinator.isSearchLocationViewShown {
                //                    SearchLocationView()
                //                        .transition(.move(edge: .trailing))
                //                        .zIndex(1) // 추가해서 사라질 때 에니메이션 적용됨
                //                }
                
            }
            .ignoresSafeArea()
        }
        //        .cornerRadius(appCoordinator.isSearchLocationMapViewShown ? 0 : 23, corners: appCoordinator.isSearchLocationMapViewShown ? [] : [.topLeft, .topRight])
        .cornerRadius(23, corners: [.topLeft, .topRight])
        //        .offset(y: appCoordinator.isSearchLocationMapViewShown ? 0 : 36)
        .offset(y: 36)
        //        .offset(y: appCoordinator.isCreateMumorySheetShown ? 16 + 20 : UIScreen.main.bounds.height) // withAnimation과 연관 있음
        
        .ignoresSafeArea()
        //                                .animation(.easeInOut(duration: 0.3), value: appCoordinator.isCreateMumorySheetShown)
        //            .gesture(
        //                DragGesture()
        //                    .onChanged { value in
        //                        print("onChanged: \(value.translation.height)")
        //                        if value.translation.height >= 0 {
        //                            translation = value.translation
        //                        }
        //                    }
        //                    .onEnded { value in
        //                        withAnimation() {
        //                            let snap = translation.height + offsetY
        //                            //                                let quarter = geometry.size.height / 4
        //
        //                            if snap > 160 {
        //                                appCoordinator.isCreateMumorySheetShown = false
        //                            } else {
        //                                translation.height = 16 + 20
        //                                offsetY = 0
        //                            }
        //                        }
        //                    }
        //            )
        //            }
        //            .ignoresSafeArea()
        //        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        
    }
}

//@available(iOS 16.0, *)
//struct CreateMumoryBottomSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appCoordinator = AppCoordinator()
//        CreateMumoryBottomSheetView(isShown: .constant(false))
//            .environmentObject(appCoordinator)
//    }
//}
