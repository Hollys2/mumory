////
////  SocialFriendView.swift
////  Feature
////
////  Created by 다솔 on 2024/01/08.
////  Copyright © 2024 hollys. All rights reserved.
////
//
//
//import SwiftUI
//import Shared
//
//
//struct FriendItemView: View {
//    
//    private let type: SearchFriendType
//    
//    var friend: FriendSearch
//    
//    @Binding var isSendFriendRequestPopUpShown: Bool
//    @Binding var isAcceptFriendRequestPopUpShown: Bool
//    @Binding var isDeleteFriendRequestPopUpShown: Bool
//    @Binding var isCancelFriendRequestPopUpShown: Bool
//    @Binding var isUnblockFriendPopUpShown: Bool
//    
//    @EnvironmentObject var appCoordinator: AppCoordinator
//    
//    init(type: SearchFriendType,
//         friend: FriendSearch,
//         isSendFriendRequestPopUpShown: Binding<Bool>,
//         isAcceptFriendRequestPopUpShown: Binding<Bool>,
//         isDeleteFriendRequestPopUpShown: Binding<Bool>,
//         isCancelFriendRequestPopUpShown: Binding<Bool>,
//         isUnblockFriendPopUpShown: Binding<Bool>
//    ) {
//        self.type = type
//        self.friend = friend
//        _isSendFriendRequestPopUpShown = isSendFriendRequestPopUpShown
//        _isAcceptFriendRequestPopUpShown = isAcceptFriendRequestPopUpShown
//        _isDeleteFriendRequestPopUpShown = isDeleteFriendRequestPopUpShown
//        _isCancelFriendRequestPopUpShown = isCancelFriendRequestPopUpShown
//        _isUnblockFriendPopUpShown = isUnblockFriendPopUpShown
//    }
//    
//    var body: some View {
//        
//        ZStack {
//            
//            Rectangle()
//                .foregroundColor(.clear)
//                .frame(height: 84)
//            
//            HStack(spacing: 0) {
//                SharedAsset.profileMumoryDetail.swiftUIImage
//                    .resizable()
//                    .frame(width: 50, height: 50)
//                
//                Spacer().frame(width: 15)
//                
//                VStack(spacing: 5) {
//                    
//                    Text(friend.nickname)
//                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    (Text("@") + Text(friend.id))
//                        .font(SharedFontFamily.Pretendard.extraLight.swiftUIFont(size: 13))
//                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                }
//                
//                
//                Spacer()
//                
//                switch type {
//                case .addFriend:
//                    Button(action: {
//                        self.isSendFriendRequestPopUpShown = true
//                    }) {
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(width: 96, height: 33)
//                                .background(Color(red: 0.64, green: 0.51, blue: 0.99))
//                                .cornerRadius(16.5)
//                            
//                            
//                            HStack(spacing: 0) {
//                                SharedAsset.friendIconSocial.swiftUIImage
//                                    .resizable()
//                                    .frame(width: 18, height: 18)
//                                
//                                Text("친구추가")
//                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
//                                    .foregroundColor(.black)
//                            }
//                        }
//                    }
//                case .requestFriend:
//                    Button(action: {
//                        self.isAcceptFriendRequestPopUpShown = true
//                    }) {
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(width: 81.92771, height: 33)
//                                .background(Color(red: 0.64, green: 0.51, blue: 0.99))
//                                .cornerRadius(16.5)
//                            
//                            Text("수락")
//                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
//                                .foregroundColor(.black)
//                        }
//                    }
//                    
//                    Spacer().frame(width: 6.14)
//                    
//                    Button(action: {
//                        self.isDeleteFriendRequestPopUpShown = true
//                    }) {
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(width: 81.92771, height: 33)
//                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                .cornerRadius(16.5)
//                            
//                            Text("삭제")
//                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
//                                .foregroundColor(.black)
//                        }
//                    }
//                case .cancelRequestFriend:
//                    Button(action: {
//                        self.isCancelFriendRequestPopUpShown = true
//                    }) {
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(width: 77, height: 33)
//                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                .cornerRadius(16.5)
//                            
//                            Text("요청취소")
//                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
//                                .foregroundColor(.black)
//                        }
//                    }
//                case .unblockFriend:
//                    Button(action: {
//                        self.isUnblockFriendPopUpShown = true
//                    }) {
//                        ZStack {
//                            Rectangle()
//                                .foregroundColor(.clear)
//                                .frame(width: 77, height: 33)
//                                .background(Color(red: 0.47, green: 0.47, blue: 0.47))
//                                .cornerRadius(16.5)
//                            
//                            Text("차단해제")
//                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 13))
//                                .foregroundColor(.black)
//                        }
//                    }
//                }
//            }
//            
//        }
//        .padding(.horizontal, 20)
//    }
//}
//
//public struct SocialFriendView: View {
//    
//    @State private var mumory: Mumory = Mumory()
//    @State private var searchText: String = ""
//    @State private var searchFriendType: SearchFriendType = .addFriend
//    @State private var isMenuSheetShown: Bool = false
//    @State private var isFriendRequestReceived: Bool = false
//    
//    @State private var isSendFriendRequestPopUpShown: Bool = false
//    @State private var isAcceptFriendRequestPopUpShown: Bool = false
//    @State private var isDeleteFriendRequestPopUpShown: Bool = false
//    @State private var isCancelFriendRequestPopUpShown: Bool = false
//    @State private var isUnblockFriendPopUpShown: Bool = false
//    
//    @EnvironmentObject var appCoordinator: AppCoordinator
//    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
//    
//    @ObservedObject var firebaseManager = FirebaseManager.shared
//    
//    public init() {}
//    
//    public var body: some View {
//        
//        ZStack(alignment: .bottom) {
//            
//            VStack(spacing: 0) {
//                
//                VStack(spacing: 0) {
//                    
//                    Spacer().frame(height: appCoordinator.safeAreaInsetsTop + 19)
//                    
//                    HStack(spacing: 0) {
//                        
//                        Button(action: {
//                            withAnimation(.easeInOut(duration: 0.2)) {
//                                self.appCoordinator.isAddFriendViewShown = false
//                            }
//                        }, label: {
//                            SharedAsset.closeButtonSearchFriend.swiftUIImage
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                            
//                        })
//                        
//                        Spacer()
//                        
//                        Text("친구 찾기")
//                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
//                            .multilineTextAlignment(.center)
//                            .foregroundColor(.white)
//                        
//                        Spacer()
//                        
//                        Button(action: {
//                            withAnimation(.easeInOut(duration: 0.2)) {
//                                self.isMenuSheetShown = true
//                            }
//                        }, label: {
//                            SharedAsset.menuButtonSearchFriend.swiftUIImage
//                                .resizable()
//                                .frame(width: 30, height: 30)
//                        })
//                    }
//                    
//                    Spacer().frame(height: 27)
//                    
//                    HStack(spacing: 6) {
//                        HStack(alignment: .center, spacing: 10) {
//                            Text("친구 추가")
//                                .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
//                                .foregroundColor(searchFriendType == .addFriend ? .black : Color(red: 0.82, green: 0.82, blue: 0.82))
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .frame(height: 33, alignment: .leading)
//                        .background(searchFriendType == .addFriend ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.16, green: 0.16, blue: 0.16))
//                        .cornerRadius(22)
//                        .onTapGesture {
//                            searchFriendType = .addFriend
//                        }
//                        
//                        HStack(alignment: .center, spacing: 5) {
//                            Text("친구 요청")
//                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
//                                .multilineTextAlignment(.center)
//                                .foregroundColor(searchFriendType == .requestFriend ? .black : Color(red: 0.82, green: 0.82, blue: 0.82))
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 8)
//                        .frame(height: 33, alignment: .leading)
//                        .background(searchFriendType == .requestFriend ? Color(red: 0.64, green: 0.51, blue: 0.99) : Color(red: 0.16, green: 0.16, blue: 0.16))
//                        .cornerRadius(20)
//                        .overlay(
//                            firebaseManager.friendRequests != [] ?
//                            Circle()
//                                .foregroundColor(.red)
//                                .frame(width: 4, height: 4)
//                                .offset(x: 65, y: 8)
//                            : nil
//                            ,alignment: .topLeading
//                        )
//                        .onTapGesture {
//                            searchFriendType = .requestFriend
//                        }
//                        
//                        Spacer()
//                    }
//                    
//                    Spacer().frame(height: 31)
//                }
//                .padding(.horizontal, 20)
//                .overlay(
//                    Rectangle()
//                        .fill(Color(red: 0.65, green: 0.65, blue: 0.65))
//                        .frame(height: 0.5)
//                    , alignment: .bottom
//                )
//                
//                ScrollView {
//                    
//                    VStack(spacing: 0) {
//                        
//                        switch searchFriendType {
//                        case .addFriend:
//                            ZStack(alignment: .trailing) {
//                                Rectangle()
//                                    .foregroundColor(.clear)
//                                    .frame(height: 82)
//                                
//                                TextField("", text: $searchText, prompt: Text("ID 검색")
//                                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 16))
//                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47)))
//                                .onSubmit {
//                                    firebaseManager.searchFriend(Id: self.searchText)
//                                    //                                    self.searchText = ""
//                                }
//                                .padding(.leading, 45)
//                                .padding(.trailing, 37 + 23 + 10)
//                                .background(
//                                    Rectangle()
//                                        .foregroundColor(.clear)
//                                        .frame(width: UIScreen.main.bounds.width - 40)
//                                        .frame(height: 45)
//                                        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
//                                        .cornerRadius(35)
//                                        .padding(.horizontal, 20)
//                                )
//                                .foregroundColor(.white)
//                                
//                                if !searchText.isEmpty {
//                                    Button(action: {
//                                        searchText = ""
//                                    }, label: {
//                                        SharedAsset.removeButtonSearch.swiftUIImage
//                                            .resizable()
//                                            .frame(width: 23, height: 23)
//                                    })
//                                    .padding(.trailing, 37)
//                                }
//                            }
//                            
//                            if let friend = firebaseManager.searchedFriend {
//                                FriendItemView(type: .addFriend, friend: friend, isSendFriendRequestPopUpShown: self.$isSendFriendRequestPopUpShown, isAcceptFriendRequestPopUpShown: self.$isAcceptFriendRequestPopUpShown, isDeleteFriendRequestPopUpShown: self.$isDeleteFriendRequestPopUpShown, isCancelFriendRequestPopUpShown: self.$isCancelFriendRequestPopUpShown, isUnblockFriendPopUpShown: self.$isUnblockFriendPopUpShown)
//                            }
//                            
//                        case .requestFriend:
//                            ForEach(Array(firebaseManager.friendRequests.enumerated()), id: \.element) { index, value in
//                                FriendItemView(type: .requestFriend, friend: value, isSendFriendRequestPopUpShown: self.$isSendFriendRequestPopUpShown, isAcceptFriendRequestPopUpShown: self.$isAcceptFriendRequestPopUpShown, isDeleteFriendRequestPopUpShown: self.$isDeleteFriendRequestPopUpShown, isCancelFriendRequestPopUpShown: self.$isCancelFriendRequestPopUpShown, isUnblockFriendPopUpShown: self.$isUnblockFriendPopUpShown)
//                            }
//                            
//                        case .cancelRequestFriend:
//                            EmptyView()
//                        case .unblockFriend:
//                            EmptyView()
//                        }
//                    }
//                }
//                .scrollIndicators(.hidden)
//            }
//            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
//            .ignoresSafeArea()
//            .onDisappear {
//                firebaseManager.searchedFriend = nil
//            }
//            
//            //            if self.appCoordinator.isPopUpViewShown {
//            //                ZStack {
//            //                    Color.black.opacity(0.5).ignoresSafeArea()
//            //                        .onTapGesture {
//            //                            self.appCoordinator.isPopUpViewShown = false
//            //                        }
//            //
//            ////                    PopUpView(isShown: self.$appCoordinator.isPopUpViewShown, type: .twoButton, title: "친구 요청을 보내시겠습니까?", buttonTitle: "친구 요청", buttonAction: )
//            //                }
//            //            }
//        }
//        .bottomSheet(isShown: self.$isMenuSheetShown, mumoryBottomSheet: MumoryBottomSheet(appCoordinator: appCoordinator, mumoryDataViewModel: mumoryDataViewModel, type: .addFriend, mumoryAnnotation: self.$mumory))
//        .popup(show: self.$isSendFriendRequestPopUpShown, content: {
//            PopUpView(isShown: self.$isSendFriendRequestPopUpShown, type: .twoButton, title: "친구 요청을 보내시겠습니까?", buttonTitle: "친구 요청", buttonAction: {
//                FirebaseManager.shared.sendFriendRequest(receiverUserID: "tester")
//            })
//        })
//        .popup(show: self.$isAcceptFriendRequestPopUpShown, content: {
//            PopUpView(isShown: self.$isAcceptFriendRequestPopUpShown, type: .twoButton, title: "친구 요청을 수락하시겠습니까?", buttonTitle: "요청 수락", buttonAction: {
//                mumoryDataViewModel.acceptFriendReqeust(ID: "FUCKYOU3")  
//            })
//        })
//        .popup(show: self.$isDeleteFriendRequestPopUpShown, content: {
//            PopUpView(isShown: self.$isDeleteFriendRequestPopUpShown, type: .twoButton, title: "친구 요청을 삭제하시겠습니까?", buttonTitle: "요청 삭제", buttonAction: {
//                print(firebaseManager.friendRequests[0].nickname)
//                FirebaseManager.shared.deleteFriendRequest(receiverUserID: "tester")
//            })
//        })
//    }
//}
