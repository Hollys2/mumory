//
//  CustomizationView.swift
//  Feature
//
//  Created by 제이콥 on 12/26/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Core
import Shared
import Lottie


public struct CustomizationView: View {
    public init(){}

    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var customizationViewModel: CustomizationManageViewModel
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State var isUploadImageCompleted = false
    @State var isUploadUserDataCompleted = false
    @State var isUploadPlaylistCompleted = false
    @State var isCustomizationDone = false
    @State var isTapBackButton: Bool = false
    
    let Firebase = FBManager.shared
    
    // MARK: - View
    
    public var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
                HStack{
                    Button(action: {
                        isTapBackButton = true
                        if customizationViewModel.step == 0 {
                            dismiss()
                        }else{
                            withAnimation {
                                customizationViewModel.step -= 1
                            }
                        }
                    }, label: {
                        SharedAsset.back.swiftUIImage
                    })
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(height: 65)
                
                ZStack{
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(Color(red: 0.37, green: 0.37, blue: 0.37))
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .foregroundColor(.white)
                        .padding(.trailing, setPadding(screen: CGSize(width: getUIScreenBounds().width, height: getUIScreenBounds().height)))
                }
                
                //Switch View
                switch(customizationViewModel.step){
                case 0:
                    SelectGenreView()
                        .environmentObject(customizationViewModel)
                        .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), 
                                                removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                        .onAppear(perform: {
                            isTapBackButton = false
                        })
                    
                case 1:
                    SelectTimeView()
                        .environmentObject(customizationViewModel)
                        .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), 
                                                removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                        .onAppear(perform: {
                            isTapBackButton = false
                        })
                    
                case 2:
                    ProfileSettingView()
                        .environmentObject(customizationViewModel)
                        .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), 
                                                removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                        .onAppear(perform: {
                            isTapBackButton = false
                        })
                    
                default: EmptyView()
                }
                
            })
            
            
            VStack{
                Spacer()
                SharedAsset.underGradientLarge.swiftUIImage
                    .resizable()
                    .ignoresSafeArea()
                    .scaledToFit()
            }
            
            //NextButton
            VStack{
                Spacer()
                Button(action: {
                    if customizationViewModel.step == 2 {
                        Task{
                            await uploadUserData()
                        }
                    }else{
                        withAnimation {
                            customizationViewModel.step += 1
                        }
                    }
                }, label: {
                    MumoryLoadingButton(title: customizationViewModel.getButtonTitle(), isEnabled: customizationViewModel.isButtonEnabled(), isLoading: $customizationViewModel.isLoading)
                        .padding(.bottom, 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                })
                .disabled(!customizationViewModel.isButtonEnabled())
                
            }
            
            
        }
        .navigationBarBackButtonHidden()
        .gesture(DragGesture().onEnded({ gesture in
            if gesture.location.x - gesture.startLocation.x > 80 {
                isTapBackButton = true
                if customizationViewModel.step == 0 {
                    dismiss()
                }else{
                    withAnimation {
                        customizationViewModel.step -= 1
                    }
                }
                
            }
        }))
        .onTapGesture {
            self.hideKeyboard()
        }
        .disabled(customizationViewModel.isLoading)
        
    }
    
    var NavigationBar: some View {
        HStack{
            Button(action: {
                isTapBackButton = true
                if customizationViewModel.step == 0 {
                    dismiss()
                }else{
                    withAnimation {
                        customizationViewModel.step -= 1
                    }
                }
            }, label: {
                SharedAsset.back.swiftUIImage
            })
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 65)
    }
    
    // MARK: - Methods
    
    private func setPadding(screen: CGSize) -> CGFloat {
        //width에 곱한 수 만큼 padding을 주어서 줄어들게 만듦
        //ex) 1번째 스탭이라면 3/4만큼 줄어들게 만들기
        if customizationViewModel.step == 0{
            return screen.width * 3/4
        }else if customizationViewModel.step == 1 {
            return screen.width * 2/4
        }else if customizationViewModel.step == 2 {
            return screen.width * 1/4
        }
        return 0
    }
    
    private func uploadUserData() async{
        customizationViewModel.isLoading = true
        let db = Firebase.db
        let auth = Firebase.auth
        let messaging = Firebase.messaging
        let storage = Firebase.storage
        
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        var userData: [String : Any] = [
            "id": customizationViewModel.id,
            "nickname": customizationViewModel.nickname,
            "favoriteGenres": customizationViewModel.selectedGenres.map({$0.id}),
            "notificationTime": customizationViewModel.selectedTime,
            "fcmToken": messaging.fcmToken ?? "",
            "profileIndex": customizationViewModel.randomProfileIndex
        ]
        
        userData.merge(await uploadProfileImage(uid: uid))
        userData.merge(await subscribeTOS(uid: uid))
        //위에 두개 동시 실행
        try? await db.collection("User").document(uid).setData(userData, merge: true)
        
        await uploadPlaylist(uid: uid)
        
        currentUserData.uId = uid
        currentUserData.user = await MumoriUser(uId: uid)
        currentUserData.favoriteGenres = customizationViewModel.selectedGenres.map({$0.id})
        
        customizationViewModel.isLoading = false
        isCustomizationDone = true
        appCoordinator.rootPath.append(MumoryPage.lastOfCustomization)
    }

    
    private func subscribeTOS(uid: String) async -> [String: Any] {
        let messaging = Firebase.messaging
        
        guard let isCheckedServiceNewsNotification = customizationViewModel.isCheckedServiceNewsNotification else {
            return [:]
        }
        if isCheckedServiceNewsNotification {
            try? await messaging.subscribe(toTopic: "Service")
        }
        try? await messaging.subscribe(toTopic: "Social")
        
        return [
            "isSubscribedToService" : isCheckedServiceNewsNotification,
            "isSubscribedToSocial": true
        ]
    }
    
    private func uploadPlaylist(uid: String) async{
        let db = Firebase.db
        let playlist: [String: Any] = [
            "title": "즐겨찾기 목록",
            "songIds": [],
            "isPublic": false,
            "date": Date()
        ]
        try? await db.collection("User").document(uid).collection("Playlist").document("favorite").setData(playlist)
    }
    
    private func uploadProfileImage(uid: String) async -> [String: Any] {
        let storage = Firebase.storage
        
        guard let data = customizationViewModel.profileImageData else {return ["profileImageURL": ""]}
        let metaData = Firebase.storageMetadata()
        metaData.contentType = "image/jpeg"
        let path: String = "ProfileImage/\(uid).jpg"
        let ref = storage.reference().child(path)
        
        guard let result = try? await ref.putDataAsync(data, metadata: metaData) else {
            return ["profileImageURL": ""]
        }
        
        guard let url = try? await ref.downloadURL() else {
            return ["profileImageURL": ""]
        }
        
        let userData: [String: Any] = [
            "profileImageURL": url.absoluteString
        ]
        return userData
        
    }
}
