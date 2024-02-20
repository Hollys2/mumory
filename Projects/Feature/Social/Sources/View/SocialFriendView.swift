//
//  SocialFriendView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/08.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct FriendItemView: View {
    
    private let type: SearchFriendType
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    init(type: SearchFriendType) {
        self.type = type
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 84)
            
            HStack(spacing: 0) {
                SharedAsset.profileMumoryDetail.swiftUIImage
                    .resizable()
                    .frame(width: 50, height: 50)
                
                Spacer().frame(width: 15)
                
                VStack(spacing: 5) {
                    Text("이르음")
                      .font(
                        Font.custom("Pretendard", size: 20)
                          .weight(.semibold)
                      )
                      .foregroundColor(.white)
                      .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("@abcdefg")
                      .font(
                        Font.custom("Pretendard", size: 13)
                          .weight(.ultraLight)
                      )
                      .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                      .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                
                Spacer()
                
                switch type {
                case .addFriend:
                    Button(action: {
                        self.appCoordinator.isPopUpViewShown = true
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 96, height: 33)
                                .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                                .cornerRadius(16.5)
                            
                            
                            HStack(spacing: 0) {
                                SharedAsset.friendIconSocial.swiftUIImage
                                    .frame(width: 18, height: 18)
                                
                                Text("친구추가")
                                    .font(
                                        Font.custom("Pretendard", size: 13)
                                            .weight(.semibold)
                                    )
                                    .foregroundColor(.black)
                            }
                        }
                    }
                case .requestFriend:
                    Button(action: {
                        
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 81.92771, height: 33)
                                .background(Color(red: 0.64, green: 0.51, blue: 0.99))
                                .cornerRadius(16.5)
                            
                            Text("수락")
                                .font(
                                    Font.custom("Pretendard", size: 13)
                                        .weight(.semibold)
                                )
                                .foregroundColor(.black)
                        }
                    }
                    
                    Spacer().frame(width: 6.14)
                    
                    Button(action: {
                        
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 81.92771, height: 33)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .cornerRadius(16.5)
                            
                            Text("삭제")
                                .font(
                                    Font.custom("Pretendard", size: 13)
                                        .weight(.semibold)
                                )
                                .foregroundColor(.black)
                        }
                    }
                case .cancelRequestFriend:
                    Button(action: {
                        
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 77, height: 33)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .cornerRadius(16.5)
                            
                            Text("요청취소")
                                .font(
                                    Font.custom("Pretendard", size: 13)
                                        .weight(.semibold)
                                )
                                .foregroundColor(.black)
                        }
                    }
                case .unblockFriend:
                    Button(action: {
                        
                    }) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 77, height: 33)
                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                .cornerRadius(16.5)
                            
                            Text("차단해제")
                                .font(
                                    Font.custom("Pretendard", size: 13)
                                        .weight(.semibold)
                                )
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            
        }
        .padding(.horizontal, 20)
    }
}

enum SearchFriendType {
    case addFriend
    case requestFriend
    case cancelRequestFriend
    case unblockFriend
}

public struct SocialFriendView: View {
    
    @State private var searchText: String = ""
    @State private var searchFriendType: SearchFriendType = .addFriend
    @State private var isMenuSheetShown: Bool = false
    @State private var translation: CGSize = .zero
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    private var menuOptions: [BottemSheetMenuOption] {
        [
            BottemSheetMenuOption(iconImage: SharedAsset.requestFriendSocial.swiftUIImage, title: "내가 보낸 요청") {
                self.appCoordinator.rootPath.append(SearchFriendType.cancelRequestFriend)
            },
            
            BottemSheetMenuOption(iconImage: SharedAsset.blockFriendSocial.swiftUIImage, title: "차단친구 관리", action: {
                self.appCoordinator.rootPath.append(SearchFriendType.unblockFriend)
            })
        ]
    }
    
    public init() {}
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    DispatchQueue.main.async {
                        translation.height = value.translation.height
                    }
                }
            }
            .onEnded { value in
                
                withAnimation(Animation.easeInOut(duration: 0.2)) {
//                    if value.translation.height > 130 {
//                        appCoordinator.isCreateMumorySheetShown = false
//
//                        mumoryDataViewModel.choosedMusicModel = nil
//                        mumoryDataViewModel.choosedLocationModel = nil
//                    }
                        translation.height = 0
                }
            }
    }

    
    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer().frame(height: appCoordinator.safeAreaInsetsTop + 19)
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.appCoordinator.isAddFriendViewShown = false
                            }
                        }, label: {
                            SharedAsset.closeButtonSearchFriend.swiftUIImage
                                .frame(width: 30, height: 30)
                            
                        })
                        
                        Spacer()
                        
                        Text("친구 찾기")
                            .font(
                                Font.custom("Pretendard", size: 18)
                                    .weight(.semibold)
                            )
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                self.isMenuSheetShown = true
                            }
                        }, label: {
                            SharedAsset.menuButtonSearchFriend.swiftUIImage
                                .frame(width: 30, height: 30)
                        })
                    }
                    
                    Spacer().frame(height: 27)
                    
                    HStack(spacing: 6) {
                        HStack(alignment: .center, spacing: 10) {
                            Text("친구 추가")
                                .font(
                                    Font.custom("Pretendard", size: 13)
                                        .weight(.bold)
                                )
                                .foregroundColor(searchFriendType == .addFriend ? .black : Color(red: 0.82, green: 0.82, blue: 0.82))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(height: 33, alignment: .leading)
                        .background(searchFriendType == .addFriend ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.16, green: 0.16, blue: 0.16))
                        .cornerRadius(22)
                        .onTapGesture {
                            searchFriendType = .addFriend
                        }
                        
                        HStack(alignment: .center, spacing: 5) {
                            Text("친구 요청")
                                .font(
                                    Font.custom("Pretendard", size: 13)
                                        .weight(.medium)
                                )
                                .multilineTextAlignment(.center)
                                .foregroundColor(searchFriendType == .requestFriend ? .black : Color(red: 0.82, green: 0.82, blue: 0.82))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(height: 33, alignment: .leading)
                        .background(searchFriendType == .requestFriend ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.16, green: 0.16, blue: 0.16))
                        .cornerRadius(20)
                        .overlay(
                            Circle()
                                .foregroundColor(.red)
                                .frame(width: 4, height: 4)
                                .offset(x: 65, y: 8)
                            ,alignment: .topLeading
                        )
                        .onTapGesture {
                            searchFriendType = .requestFriend
                        }
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: 31)
                }
                .padding(.horizontal, 20)
                .overlay(
                    Rectangle()
                        .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
                        .frame(height: 0.5)
                    , alignment: .bottom
                )
                
                ScrollView {
                    VStack(spacing: 0) {
                        switch searchFriendType {
                        case .addFriend:
                            ZStack(alignment: .trailing) {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 82)
                                
                                TextField("", text: $searchText, prompt: Text("ID 검색")
                                    .font(Font.custom("Pretendard", size: 16))
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
                                .padding(.leading, 45)
                                .padding(.trailing, 37 + 23 + 10)
                                .background(
                                    Rectangle()
                                        .foregroundColor(.clear)
                                        .frame(width: UIScreen.main.bounds.width - 40)
                                        .frame(height: 45)
                                        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                                        .cornerRadius(35)
                                        .padding(.horizontal, 20)
                                )
                                .foregroundColor(.white)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        searchText = ""
                                    }, label: {
                                        SharedAsset.removeButtonSearch.swiftUIImage
                                            .frame(width: 23, height: 23)
                                    })
                                    .padding(.trailing, 37)
                                }
                            }
                            
                            FriendItemView(type: .addFriend)
                            
                        case .requestFriend:
                            FriendItemView(type: .requestFriend)
                        case .cancelRequestFriend:
                            EmptyView()
                        case .unblockFriend:
                            EmptyView()
                        }
                    }
                }
                
                Color.clear
            }
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .ignoresSafeArea()
            
            if self.appCoordinator.isPopUpViewShown {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                        .onTapGesture {
                            self.appCoordinator.isPopUpViewShown = false
                        }
                    
//                    PopUpView(isShown: self.$appCoordinator.isPopUpViewShown, type: .twoButton, title: "친구 요청을 보내시겠습니까?", buttonTitle: "친구 요청", buttonAction: )
                }
            }
            
            if self.isMenuSheetShown {
                Color.black.opacity(0.5).ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(Animation.easeInOut(duration: 0.2)) {
                            self.isMenuSheetShown = false
                        }
                    }
                
//                BottomSheetView(menuOptions: menuOptions) // 스크롤뷰만 제스처 추가해서 드래그 막음
//                    .offset(y: self.translation.height - appCoordinator.safeAreaInsetsBottom)
//                    .simultaneousGesture(dragGesture)
//                    .transition(.move(edge: .bottom))
//                    .zIndex(1)
            }
        }
    }
}

struct SocialFriendView_Previews: PreviewProvider {
    //    @EnvironmentObject var appCoordinator = AppCoordinator()
    static var previews: some View {
        //        SearchFriendMenuSheetView(translation: .constant(.zero))
        SocialFriendView()
            .environmentObject(AppCoordinator())
    }
}
