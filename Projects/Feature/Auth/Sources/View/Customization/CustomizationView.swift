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
import FirebaseStorage

public struct CustomizationView: View {
    let imageModel: UIImage = UIImage()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: CustomizationManageViewModel
    @EnvironmentObject var userManager: UserViewModel
    
    @State var isUploadImageCompleted = false
    @State var isUploadUserDataCompleted = false
    @State var isUploadPlaylistCompleted = false
    @State var isCustomizationDone = false
    
    @State var isLoading: Bool = false
    @State var isTapBackButton: Bool = false
    
    public init(){}
    
    public var body: some View {
        GeometryReader(content: { geometry in
            
            ZStack{
                ColorSet.background.ignoresSafeArea()
                
                //Step indicator
                VStack(spacing: 0, content: {
                    ZStack{
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(Color(red: 0.37, green: 0.37, blue: 0.37))
                        
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .foregroundColor(.white)
                            .padding(.trailing, setPadding(screen: geometry.size))
                    }
                    .padding(.top, 20)
                    
                    //Switch View
                    switch(manager.step){
                    case 0:
                        SelectGenreView()
                            .environmentObject(manager)
                            .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                            .onAppear(perform: {
                                isTapBackButton = false
                            })
                    
                    case 1:
                        SelectTimeView()
                            .environmentObject(manager)
                            .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                            .onAppear(perform: {
                                isTapBackButton = false
                            })
                    
                    case 2:
                        ProfileSettingView()
                            .environmentObject(manager)
                            .transition(.asymmetric(insertion: .move(edge: isTapBackButton ? .leading : .trailing), removal: .move(edge: isTapBackButton ? .trailing : .leading)))
                            .onAppear(perform: {
                                isTapBackButton = false
                            })
                    
                    default: EmptyView()
                    }
                    
                })
                
                
                VStack{
                    Spacer()
                    SharedAsset.underGradient.swiftUIImage
                        .resizable()
                        .ignoresSafeArea()
                        .scaledToFit()
                }
                
                //NextButton
                VStack{
                    Spacer()
                    Button(action: {
                        if manager.step == 2 {
                            uploadUserData()
                        }else{
                            withAnimation {
                                manager.step += 1
                            }
                        }
                    }, label: {
                        WhiteButton(title: manager.getButtonTitle(), isEnabled: manager.isButtonEnabled())
                            .padding(.bottom, 20)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    })
                    .disabled(!manager.isButtonEnabled())
                    
                }
                
                LottieView(animation: .named("loading", bundle: .module))
                    .looping()
                    .opacity(isLoading ? 1 : 0)
                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                
            }
            .navigationDestination(isPresented: $isCustomizationDone, destination: {
                LastOfCustomizationView()
                    .environmentObject(manager)
            })
            .navigationBarBackButtonHidden()
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        isTapBackButton = true
                        if manager.step == 0 {
                            dismiss()
                        }else{
                            withAnimation {
                                manager.step -= 1
                            }
                        }
                    }, label: {
                        SharedAsset.back.swiftUIImage
                    })
                    
                }
            })
            .gesture(DragGesture().onEnded({ gesture in
                if gesture.location.x - gesture.startLocation.x > 80 {
                    isTapBackButton = true
                    if manager.step == 0 {
                        dismiss()
                    }else{
                        withAnimation {
                            manager.step -= 1
                        }
                    }
                    
                }
            }))
            .onTapGesture {
                self.hideKeyboard()
            }
            
        })
        
    }
    private func setPadding(screen: CGSize) -> CGFloat {
        //width에 곱한 수 만큼 padding을 주어서 줄어들게 만듦
        //ex) 1번째 스탭이라면 3/4만큼 줄어들게 만들기
        if manager.step == 0{
            return screen.width * 3/4
        }else if manager.step == 1 {
            return screen.width * 2/4
        }else if manager.step == 2 {
            return screen.width * 1/4
        }
        return 0
    }
    
    private func uploadUserData(){
        isLoading = true
        let Firebase = FirebaseManager.shared
        let userDefault = UserDefaults.standard
        let db = Firebase.db
        let auth = Firebase.auth
        let messaging = Firebase.messaging

        guard let currentUser = auth.currentUser else {
            print("no current user. please sign in again")
            return
        }
                
        //유저데이터 업로드
        var userData: [String : Any] = [
            "id": manager.id,
            "nickname": manager.nickname,
            "favorite_genres": manager.selectedGenres.map({$0.id}),
            "selected_notification_time": manager.selectedTime
        ]
        
        let playlist: [String: Any] = [
            "title": "즐겨찾기 목록",
            "song_IDs": [],
            "is_private": true,
            "is_favorite": true
        ]
        
        //소셜 로그인했을 경우 이용약관 여부도 함께 저장(이메일 회원가입은 이전단계에서 이미 저장함)
        if let isCheckedServiceNewsNotification = manager.isCheckedServiceNewsNotification {
            if isCheckedServiceNewsNotification {
                messaging.subscribe(toTopic: "SERVICE")
            }
            messaging.subscribe(toTopic: "SOCIAL")
            
            //저장할 데이터에 이용약관 동의 여부도 추가
            userData.merge([
                "is_checked_service_news_notification" : isCheckedServiceNewsNotification,
                "is_checked_social_notification": true
            ])
        }
                        
        db.collection("User").document(currentUser.uid).setData(userData, merge: true) { error in
            if error == nil {
                //데이터 추가 성공
                isUploadUserDataCompleted = true
                isCustomizationDone = isUploadImageCompleted && isUploadUserDataCompleted
                isLoading = !(isUploadImageCompleted && isUploadUserDataCompleted)
            }else {
                print("error \(error!)")
            }
        }
        
        db.collection("User").document(currentUser.uid).collection("Playlist").document("favorite").setData(playlist) { error in
            if error == nil {
                isUploadPlaylistCompleted = true
                isCustomizationDone = isUploadImageCompleted && isUploadUserDataCompleted && isUploadPlaylistCompleted
                isLoading = !(isUploadImageCompleted && isUploadUserDataCompleted && isUploadPlaylistCompleted)
            }
        }
        
        //어플 전역에서 사용할 변수에 데이터 저장
        setUserManagerData()

        //프로필 이미지 업로드
        if let data = manager.profileImageData {
            guard let jpgImage = UIImage(data: data)?.jpegData(compressionQuality: 0.2) else {
                print("jpg conver error")
                return
            }
            
            //이미지 메타데이터 - 이미지 타입, 경로 및 이름 정의
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpeg"
            let imageName = "ProfileImage/\(currentUser.uid)"
            
            //업로드
            let storageRef = Storage.storage().reference().child("\(imageName)")
            storageRef.putData(jpgImage, metadata: metaData) { metaData, error in
                if let error = error {
                    print("storage error \(error)")
                    //에러시 어케 대처??
                }else if let metaData = metaData {
                    print("storage successful")
                    isUploadImageCompleted = true
                    isCustomizationDone = isUploadImageCompleted && isUploadUserDataCompleted
                    isLoading = !(isUploadImageCompleted && isUploadUserDataCompleted)
                    //실패했을 때 다시 시도할 수 있게 하기
                }
            }
            
        }else {
            //저징된 이미지가 없는 경우: 이미지 선택 안 했을 때
            //이미지 업로드 하지 않고 마무리함
            print("no profile image")
            isUploadImageCompleted = true
            isCustomizationDone = isUploadImageCompleted && isUploadUserDataCompleted
            isLoading = !(isUploadImageCompleted && isUploadUserDataCompleted)
        }
    }
    
    private func setUserManagerData(){
        userManager.id = manager.id
        userManager.nickname = manager.nickname
        userManager.favoriteGenres = manager.selectedGenres.map({$0.id})
        userManager.selectedNotificationTime = manager.selectedTime
        userManager.isCheckedServiceNewsNotification = manager.isCheckedServiceNewsNotification
        userManager.isCheckedSocialNotification = true
    }
}

//#Preview {
//    CustomizationView()
//}
