//
//  TestView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/27.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import PhotosUI
import Core
import Shared
import MapKit


@available(iOS 16.0, *)
public struct TestView: View {
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @GestureState var dragAmount = CGSize.zero
    @State private var translation: CGSize = CGSize(width: 0, height: 0)
    
    public init() {}
    
    var dragGesture: some Gesture {
        DragGesture()
            .updating($dragAmount) { value, state, _ in
                print("updating: \(value.translation.height)")
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        self.translation.height = value.translation.height
                    }
                }
                
            }
            .onEnded { value in
                print("onEnded: \(value.translation.height)")
                withAnimation(Animation.easeInOut(duration: 0.2)) {
                    if value.translation.height > 50 {
                        appCoordinator.isMumoryDetailMenuSheetShown = false
                    }
                    self.translation.height = 0
                }
            }
    }
    
    public var body: some View {
//        VStack(spacing: 0) {
        NavigationStack{
            VStack(spacing: 0) {
                Image(uiImage: SharedAsset.dragIndicator.image)
                    .frame(maxWidth: .infinity)
                    .frame(height: 22)
                    .background(.pink)
                    .gesture(dragGesture)
                
                Group {
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.editMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("뮤모리 수정")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.lockMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("나만 보기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.mapMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("지도에서 보기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                }
                
                //                Rectangle()
                //                    .foregroundColor(.clear)
                //                    .frame(height: 0.3)
                //                    .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                
                Group {
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.deleteMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("뮤모리 삭제")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(Color(red: 1, green: 0.25, blue: 0.25))
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.shareMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("공유하기")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 0.3)
                        .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.4))
                    
                    Button(action: {
                        
                    }, label: {
                        HStack(spacing: 0) {
                            Spacer().frame(width: 24)
                            SharedAsset.complainMumoryDetailMenu.swiftUIImage
                                .frame(width: 22, height: 22)
                            
                            Spacer().frame(width: 14)
                            
                            Text("신고")
                                .font(
                                    Font.custom("Pretendard", size: 16)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                                .frame(height: 55)
                            
                            Spacer()
                        }
                    })
                }
                
            }
            .frame(width: UIScreen.main.bounds.width - 14 - 18, height: 330)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .cornerRadius(15)
            
            Spacer().frame(height: 9)
        } // VStack
        .frame(width: UIScreen.main.bounds.width - 14)
        .background(.yellow)
        .cornerRadius(15)
        .offset(y: self.translation.height)
//        .ignoresSafeArea()
        //        .offset(y: self.translation.height + UIScreen.main.bounds.height - appCoordinator.safeAreaInsetsTop - appCoordinator.safeAreaInsetsBottom - 361)
        //        .offset(y: self.translation.height + appCoordinator.safeAreaInsetsTop + 16) // withAnimation과 연관 있음
        //        .offset(y: self.dragAmount + UIScreen.main.bounds.height - 361 - appCoordinator.safeAreaInsetsBottom) // withAnimation과 연관 있음
    }
}
//        .cornerRadius(23, corners: [.topLeft, .topRight])


//Button("SearchLocationView") {
//    appCoordinator.isNavigationStackShown = false
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//        appCoordinator.isSearchLocationViewShown = true
//    }
//}
//
//Button("SearchLocationMapView") {
//    appCoordinator.isNavigationStackShown = true
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//        withAnimation(Animation.easeInOut(duration: 0.2)) {
//            appCoordinator.isCreateMumorySheetShown = false
//        }
//    }
//
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//        appCoordinator.isSearchLocationMapViewShown = true
//    }
//}

//@available(iOS 16.0, *)
//struct CreateMumoryBottomSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        let appCoordinator = AppCoordinator()
//        CreateMumoryBottomSheetView(isShown: .constant(false))
//            .environmentObject(appCoordinator)
//    }
//}


class SwipeBackHostingController<Content: View>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        print("@@SwipeBackHostingController")
        
        // 백 스와이프를 처리하는 GestureRecognizer 추가
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        gesture.direction = .right
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleSwipeGesture() {
        // 백 스와이프가 감지되면 뷰를 닫음
        presentationController?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
