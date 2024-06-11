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


public struct CustomizationCenterView: View {
    public init(){}

    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @EnvironmentObject var currentUserData: CurrentUserViewModel
    @EnvironmentObject var authCoordinator: AuthCoordinator
    
    @State var isUploadImageCompleted = false
    @State var isUploadUserDataCompleted = false
    @State var isUploadPlaylistCompleted = false
    @State var isCustomizationDone = false
    @State var isTapBackButton: Bool = false
    
    let Firebase = FirebaseManager.shared
    
    // MARK: - View
    
    public var body: some View {
        ZStack(alignment: .top){
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0, content: {
               NavigationBar(leadingItem: BackButton)
                
                ProcessIndicator
                
                switch(signUpViewModel.step){
                case 4: SelectGenreView()
                case 5: SelectTimeView()
                case 6: ProfileSettingView()
                default: EmptyView()
                }
                
            })
            
            
            BackgroundGradient
            
            NextButton
            

        }
        .navigationBarBackButtonHidden()
        .onTapGesture {
            self.hideKeyboard()
        }
        
    }
    
    var NextButton: some View {
        VStack{
            Spacer()
            Button(action: {
                if signUpViewModel.step == 6 {
                    //final
                }else{
                    withAnimation {
                        signUpViewModel.step += 1
                    }
                }
            }, label: {
                MumoryLoadingButton(title: signUpViewModel.getButtonTitle(), isEnabled: signUpViewModel.isButtonEnabled(), isLoading: $signUpViewModel.isLoading)
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
            })
            .disabled(!signUpViewModel.isButtonEnabled())
        }
    }
    
    var ProcessIndicator: some View {
        ZStack(alignment: .leading){
            Rectangle()
                .fill(Color(white: 0.37))
                .frame(maxWidth: .infinity)
                .frame(height: 2)
            
            Rectangle()
                .fill(Color.white)
                .frame(height: 2)
                .frame(width: getStepIndicatorWidth())
                .animation(.default, value: signUpViewModel.step)
        }
    }
    
    var BackButton: some View {
        Button(action: {
            if signUpViewModel.step == 4 {
                authCoordinator.pop()
            }else{
                withAnimation {
                    signUpViewModel.step -= 1
                }
            }
        }, label: {
            SharedAsset.back.swiftUIImage
                .resizable()
                .frame(width: 30, height: 30)
        })
    }
    
    var BackgroundGradient: some View {
        VStack{
            Spacer()
            SharedAsset.underGradientLarge.swiftUIImage
                .resizable()
                .ignoresSafeArea()
                .scaledToFit()
        }
    }
    
    // MARK: - Methods
    
    private func getStepIndicatorWidth() -> CGFloat {
        // Start step of customization is 4
        let stepToNaturalNumber = signUpViewModel.step%4 + 1
        return getUIScreenBounds().width * (CGFloat(stepToNaturalNumber) / 3)
    }
    
//    private func uploadUserData() async{
//        customizationViewModel.isLoading = true
//        let db = Firebase.db
//        let auth = Firebase.auth
//        let messaging = Firebase.messaging
//        let storage = Firebase.storage
//        
//        guard let uid = auth.currentUser?.uid else {
//            return
//        }
//        
//        var userData: [String : Any] = [
//            "id": customizationViewModel.id,
//            "nickname": customizationViewModel.nickname,
//            "favoriteGenres": customizationViewModel.selectedGenres.map({$0.id}),
//            "notificationTime": customizationViewModel.selectedTime,
//            "fcmToken": messaging.fcmToken ?? "",
//            "profileIndex": customizationViewModel.randomProfileIndex
//        ]
//        
//        userData.merge(await uploadProfileImage(uid: uid))
//        userData.merge(await subscribeTOS(uid: uid))
//        //위에 두개 동시 실행
//        try? await db.collection("User").document(uid).setData(userData, merge: true)
//        
//        await uploadPlaylist(uid: uid)
//        
//        currentUserData.uId = uid
//        currentUserData.user = await MumoriUser(uId: uid)
//        currentUserData.favoriteGenres = customizationViewModel.selectedGenres.map({$0.id})
//        
//        customizationViewModel.isLoading = false
//        isCustomizationDone = true
//        appCoordinator.rootPath.append(MumoryPage.lastOfCustomization)
//    }
//
//    
//    private func subscribeTOS(uid: String) async -> [String: Any] {
//        let messaging = Firebase.messaging
//        
//        guard let isCheckedServiceNewsNotification = customizationViewModel.isCheckedServiceNewsNotification else {
//            return [:]
//        }
//        if isCheckedServiceNewsNotification {
//            try? await messaging.subscribe(toTopic: "Service")
//        }
//        try? await messaging.subscribe(toTopic: "Social")
//        
//        return [
//            "isSubscribedToService" : isCheckedServiceNewsNotification,
//            "isSubscribedToSocial": true
//        ]
//    }
//    
//    private func uploadPlaylist(uid: String) async{
//        let db = Firebase.db
//        let playlist: [String: Any] = [
//            "title": "즐겨찾기 목록",
//            "songIds": [],
//            "isPublic": false,
//            "date": Date()
//        ]
//        try? await db.collection("User").document(uid).collection("Playlist").document("favorite").setData(playlist)
//    }
//    
//    private func uploadProfileImage(uid: String) async -> [String: Any] {
//        let storage = Firebase.storage
//        
//        guard let data = customizationViewModel.profileImageData else {return ["profileImageURL": ""]}
//        let metaData = Firebase.storageMetadata()
//        metaData.contentType = "image/jpeg"
//        let path: String = "ProfileImage/\(uid).jpg"
//        let ref = storage.reference().child(path)
//        
//        guard let result = try? await ref.putDataAsync(data, metadata: metaData) else {
//            return ["profileImageURL": ""]
//        }
//        
//        guard let url = try? await ref.downloadURL() else {
//            return ["profileImageURL": ""]
//        }
//        
//        let userData: [String: Any] = [
//            "profileImageURL": url.absoluteString
//        ]
//        return userData
//        
//    }
}
