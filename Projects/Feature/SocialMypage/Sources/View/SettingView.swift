//
//  SettingView.swift
//  Feature
//
//  Created by 제이콥 on 2/3/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import FirebaseAuth
import Firebase
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser
import Lottie

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var withdrawManager: WithdrawViewModel
    @EnvironmentObject var settingViewModel: SettingViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    @State var isShowingWithdrawPopup = false
    @State var isLoading: Bool = false
    
    var body: some View {        
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            VStack(spacing: 0){
                //상단바
                HStack {
                    SharedAsset.back.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.rootPath.removeLast()
                        }
                    Spacer()
                    Text("설정")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                        .foregroundStyle(Color.white)
                    Spacer()
                    SharedAsset.home.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .onTapGesture {
                            appCoordinator.bottomAnimationViewStatus = .remove
                            appCoordinator.selectedTab = .home
                            appCoordinator.isSocialCommentSheetViewShown = false
                            appCoordinator.isMumoryDetailCommentSheetViewShown = false
                            appCoordinator.rootPath = NavigationPath()
                        }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .frame(height: 65)
                .padding(.bottom, 7)
                
                
                SettingItem(title: "계정 정보 / 보안")
                    .onTapGesture {
                        appCoordinator.rootPath.append(MyPage.account)
                    }
                
                SettingItem(title: "알림")
                    .onTapGesture {
                        appCoordinator.rootPath.append(MyPage.notification(iconHidden: false))
                    }
                
                SettingItem(title: "1:1 문의")
                    .onTapGesture {
                        appCoordinator.rootPath.append(MyPage.question)
                    }
                
                SettingItem(title: "앱 리뷰 남기기")
                    .onTapGesture {
                        if let appstoreUrl = URL(string: "https://apps.apple.com/app/idD8W49RM7XB") {
                            var urlComp = URLComponents(url: appstoreUrl, resolvingAgainstBaseURL: false)
                            urlComp?.queryItems = [
                                URLQueryItem(name: "action", value: "write-review")
                            ]
                            guard let reviewUrl = urlComp?.url else {
                                return
                            }
                            UIApplication.shared.open(reviewUrl, options: [:], completionHandler: nil)
                        }
                    }
                
                
                Spacer()
                
                
                LogoutButton()
                    .onTapGesture {
                        let Firebase = FBManager.shared
                        do {
                            try Firebase.auth.signOut()
                            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                                UserDefaults.standard.removeObject(forKey: key.description)
                            }
                            Firebase.db.collection("User").document(currentUserData.uId).updateData(["fcmToken": ""])
                            appCoordinator.bottomAnimationViewStatus = .remove
                            appCoordinator.initPage = .onBoarding
                            currentUserData.removeAllData()
                            appCoordinator.rootPath = NavigationPath()
                        }catch {
                            print("signout error: \(error)")
                        }
                    }
                
            
                WithdrawButton()
                    .onChange(of: withdrawManager.isAppleUserAuthenticated, perform: { value in
                        if value{
                            //계정 탈퇴를 위한 애플 로그인 성공시
                            deleteAppleUser()
                        }
                    })
                    .onTapGesture {
                        UIView.setAnimationsEnabled(false)
                        isShowingWithdrawPopup.toggle()
                    }
                    .fullScreenCover(isPresented: $isShowingWithdrawPopup) {
                        TwoButtonPopupView(title: "계정을 탈퇴하시겠습니까?", subTitle: "탈퇴하신 계정은 복구가 불가능합니다.", positiveButtonTitle: "탈퇴하기") {
                            //탈퇴(확인)버튼 클릭 action - 회원가입 방식에 따라 재 로그인 진행
                            withdraw(method: settingViewModel.signinMethod)
                        }
                        .background(TransparentBackground())
                    }
                
            }
            .onDisappear(perform: {
                isLoading = false
            })
            
            LoadingAnimationView(isLoading: $isLoading)
            
        }
        .disabled(isLoading)
        
    }
    
    func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
      guard let viewController = viewController else {
        return nil
      }
   
      if let navigationController = viewController as? UINavigationController {
        return navigationController
      }
   
      for childViewController in viewController.children {
        return findNavigationController(viewController: childViewController)
      }
   
      return nil
    }
    private func deleteAppleUser(){
        print("in delete apple user")
        let Firebase = FBManager.shared
        let db = Firebase.db
        let auth = Firebase.auth
        
        guard let currentUser = auth.currentUser else {
            print("no current user")
            return
        }
        
        currentUser.delete { error in
            if let error = error{
                print("delete user error: \(error)")
                //에러처리
            }else {
                print("delete user successful")
                db.collection("User").document(currentUser.uid).delete { error in
                    if let error = error {
                        print("delete document error: \(error)")
                    }else {
                        print("delete docs successful")
                        appCoordinator.bottomAnimationViewStatus = .remove
                        appCoordinator.rootPath = NavigationPath()
                    }
                }
            }
            
        }
    }
    private func withdraw(method: String){
        isLoading = true
        if method == "Apple" {
            withdrawManager.AppleLogin()
        }else if method == "Google" {
            withdrawManager.GoogleLogin(originalEmail: settingViewModel.email) { isSuccessful in
                deleteUser(isSuccessful: isSuccessful)
            }
        }else if method == "Kakao" {
            withdrawManager.KakaoLogin(originalEmail: settingViewModel.email) { isSuccessful in
                deleteUser(isSuccessful: isSuccessful)
            }
        }else if method == "Email" {
            appCoordinator.rootPath.append(MyPage.emailVerification)
        }
    }
    
    private func deleteUser(isSuccessful: Bool){
        if isSuccessful {
            let Firebase = FBManager.shared
            let db = Firebase.db
            let auth = Firebase.auth
            
            guard let currentUser = auth.currentUser else {
                print("no current user")
                return
            }
            
            currentUser.delete { error in
                if let error = error{
                    print("delete user error: \(error)")
                }else {
                    db.collection("User").document(currentUser.uid).delete { error in
                        if let error = error {
                            print("delete document error: \(error)")
                        }else {
                            for key in UserDefaults.standard.dictionaryRepresentation().keys {
                                UserDefaults.standard.removeObject(forKey: key.description)
                            }
                            currentUserData.removeAllData()
                            appCoordinator.bottomAnimationViewStatus = .remove
                            appCoordinator.initPage = .home
                            appCoordinator.rootPath = NavigationPath()
                        }
                    }
                }
            }
            
        }
    }
}

//#Preview {
//    SettingView()
//}

struct SettingItem: View {
    @State var title: String
    var body: some View {
        HStack{
            Text(title)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundStyle(.white)
            
            Spacer()
            
            SharedAsset.nextSetting.swiftUIImage
                .frame(width: 25, height: 25)
        }
        .padding(20)
    }
}

private struct WithdrawButton: View {
    var body: some View {
        Text("계정 탈퇴")
            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
            .foregroundStyle(ColorSet.subGray)
            .underline()
            .padding(.bottom, 70)
            .padding(.top, 67)
    }
}

private struct LogoutButton: View {
    var body: some View {
        Text("로그아웃")
            .foregroundColor(.white)
            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
            .padding(.top, 15)
            .padding(.bottom, 15)
            .padding(.trailing, 62)
            .padding(.leading, 62)
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .circular)
                    .stroke(Color(red: 0.65, green: 0.65, blue: 0.65), lineWidth: 1)
            )
    }
}

private func removeMyData(uid: String) async {
    let Firebase = FBManager.shared
    let db = Firebase.db
    let storage = Firebase.storage
    
    //내가 요청했거나, 나에게 요청했던 기록 삭제
    let deleteFriendCollectionQuery = db.collectionGroup("Friend").whereField("uId", isEqualTo: uid)
    guard let snapshot = try? await deleteFriendCollectionQuery.getDocuments() else {return}
    snapshot.documents.forEach { document in
        document.reference.delete()
    }
    
    //나랑 친구였던 사람들의 친구목록에서 나 삭제
    let deleteFriendQuery = db.collection("User").whereField("friend", arrayContains: uid)
    guard let deleteFriendSnapshot = try? await deleteFriendQuery.getDocuments() else {return}
    deleteFriendSnapshot.documents.forEach { document in
        document.reference.updateData(["friends": FBManager.Fieldvalue.arrayRemove([uid])])
    }
    
    //나를 블락했던 사람들의 목록에서 나 삭제
    let deleteBlockQuery = db.collection("User").whereField("blockFriend", arrayContains: uid)
    guard let deleteBlockSnapshot = try? await deleteBlockQuery.getDocuments() else {return}
    deleteBlockSnapshot.documents.forEach { document in
        document.reference.updateData(["blockFriends": FBManager.Fieldvalue.arrayRemove([uid])])
    }
    
    guard let result = try? await storage.reference(withPath: "ProfileImage/\(uid).jpg").delete() else {
        return
    }
    guard let result = try? await storage.reference(withPath: "BackgroundImage/\(uid).jpg").delete() else {
        return
    }
}
