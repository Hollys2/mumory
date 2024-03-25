//
//  EditProfileView.swift
//  Feature
//
//  Created by 제이콥 on 3/2/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import PhotosUI
import FirebaseFirestore

//여기 내부에서만 사용하는 observable을 만들어서 사용할까??
//아이템 내부에 type, status, value 정의해서 사용
struct EditProfileView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State private var editProfileData: EditProfileData = EditProfileData()
    @State var isLoading: Bool = false
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background
            ScrollView(.vertical) {
                VStack(spacing: 33, content: {
                    UserProfile(profileData: $editProfileData)
                    NicknameStackView(profileData: $editProfileData)
                    IdStackView(profileData: $editProfileData)
                    BioStackView(profileData: $editProfileData)
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 500)
                })
            }
            
            LoadingAnimationView(isLoading: $isLoading)
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            editProfileData.nickname = currentUserData.user.nickname
            editProfileData.id = currentUserData.user.id
            editProfileData.bio = currentUserData.user.bio
            editProfileData.profileURL = currentUserData.user.profileImageURL
            editProfileData.backgroundURL = currentUserData.user.backgroundImageURL
        })
        
    }
}


public struct ImageBundle {
    public var item: PhotosPickerItem?
    public var image: Image?
    public var data: Data?
}
private struct UserProfile: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @Environment(\.dismiss) var dismiss
    @State var isPresentBackgroundBottomSheet: Bool = false
    @State var isPresentProfileBottomSheet: Bool = false

    let Firebase = FBManager.shared
    
    @Binding private var profileData: EditProfileData
    
    init(profileData: Binding<EditProfileData>) {
        self._profileData = profileData
    }
    
    @State var backgroundImageBundle: ImageBundle = ImageBundle()
    @State var profileImageBundle: ImageBundle = ImageBundle()
    
    var body: some View {
        ZStack(alignment: .top){
            
                
                //배경이미지
                VStack{
                    
                    if let image = backgroundImageBundle.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 165)
                            .clipped()
                    }else {
                        Rectangle()
                            .frame(maxWidth: .infinity)
                            .frame(height: 165)
                            .foregroundStyle(ColorSet.darkGray)
                    }
                }
                .overlay {
                    ColorSet.background.opacity(0.4)
                    
                    SharedAsset.camera.swiftUIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .padding(.bottom, 24)
                }
                .onTapGesture {
                    isPresentBackgroundBottomSheet = true
                }
                .fullScreenCover(isPresented: $isPresentBackgroundBottomSheet) {
                    ImageSelectBottomSheet(isPresent: $isPresentBackgroundBottomSheet, imageBundle: $backgroundImageBundle, photoType: .background)
                        .background(TransparentBackground())
                }
                .onChange(of: backgroundImageBundle.image) { value in
                    profileData.backgroundStatus = .valid
                }
                .overlay {
                    //프로필 이미지
                    VStack{
                        if let image = profileImageBundle.image {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(width: 90, height: 90)
                        }else {
                            Circle()
                                .fill(ColorSet.darkGray)
                                .frame(width: 90, height: 90)
                        }
                    }
                    .overlay(content: {
                        ColorSet.background.opacity(0.4)
                        
                        SharedAsset.camera.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                    })
                    .clipShape(Circle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                    .offset(y: 50)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        isPresentProfileBottomSheet = true
                    }
                    .fullScreenCover(isPresented: $isPresentProfileBottomSheet) {
                        ImageSelectBottomSheet(isPresent: $isPresentProfileBottomSheet, imageBundle: $profileImageBundle)
                            .background(TransparentBackground())
                    }
                    .onChange(of: profileImageBundle.image) { value in
                        profileData.profileStatus = .valid
                    }
                }
                
                
                
      
                
                
          
            //상단바
            HStack(alignment: .center){
                SharedAsset.xGradient.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .onTapGesture {
                        dismiss()
                    }
                
                Spacer()
                
                Text("프로필 편집")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(Color.white)
                
                Spacer()

                Text("완료")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 11)
                    .frame(height: 30)
                    .background(profileData.isValid() ? ColorSet.mainPurpleColor : ColorSet.subGray)
                    .clipShape(RoundedRectangle(cornerRadius: 31.5, style: .circular))
                    .onTapGesture {
                        Task {
                            await saveUserProfile(profileData: profileData)
                            dismiss()
                        }
                    }
//                    .disabled(!profileData.isValid())
                    
            }
            .padding(.horizontal, 20)
            .frame(height: 63)
            .padding(.top, currentUserData.topInset)
        }
        .onAppear {
            DispatchQueue.global().async {
                guard let url = profileData.backgroundURL else {
                    print("no url")
                    return
                }
                guard let data = try? Data(contentsOf: url) else {
                    print("no data")
                    return
                }
                guard let uiImage = UIImage(data: data) else {
                    print("no image")
                    return
                }
                backgroundImageBundle.data = uiImage.jpegData(compressionQuality: 0.1)
                DispatchQueue.main.async {
                    backgroundImageBundle.image = Image(uiImage: uiImage)
                    profileData.backgroundStatus = .normal
                }
            }                    
            

            
            DispatchQueue.global().async {
                guard let url = profileData.profileURL else {
                    print("no url")
                    return
                }
                guard let data = try? Data(contentsOf: url) else {
                    print("no data")
                    return
                }
                guard let uiImage = UIImage(data: data) else {
                    print("no image")
                    return
                }
                profileImageBundle.data = uiImage.jpegData(compressionQuality: 0.1)
                DispatchQueue.main.async {
                    profileImageBundle.image = Image(uiImage: uiImage)
                    profileData.profileStatus = .normal
                }
            }
            
            
        }
    }
    
    
    private func saveUserProfile(profileData: EditProfileData) async {
        let db = Firebase.db
        let storage = Firebase.storage
        let uid = currentUserData.uId
        let query = db.collection("User").document(uid)
        
        var data: [String: Any] = [
            "id": profileData.id,
            "nickname": profileData.nickname,
            "bio": profileData.bio
        ]
        
        data.merge(await uploadBackground(uid: uid))
        data.merge(await uploadProfile(uid: uid))

        guard let result = try? await query.setData(data, merge: true) else {
            print("update user profile error")
            return
        }
        
        currentUserData.user.nickname = profileData.nickname
        currentUserData.user.id = profileData.id
        currentUserData.user.bio = profileData.bio
    }
    
    private func uploadProfile(uid: String) async -> [String: Any] {
        let storage = Firebase.storage
        let db = Firebase.db
        
        if let profileData = profileImageBundle.data {
            let metaData = Firebase.storageMetadata()
            metaData.contentType = "image/jpeg"
            let path: String = "ProfileImage/\(uid).jpg"
            let reference = storage.reference(withPath: path)
            guard let result = try? await reference.putDataAsync(profileData, metadata: metaData) else {
                return [:]
            }
            guard let url = try? await reference.downloadURL() else {
                return [:]
            }
            currentUserData.user.profileImageURL = url
            return ["profileImageURL": url.absoluteString ]
        }else {
            guard let result = try? await storage.reference(withPath: "ProfileImage/\(uid).jpg").delete() else {
                print("3")
                return [:]
            }
            guard let deleteResult = try? await db.collection("User").document(uid).updateData(["profileImageURL": Firebase.deleteFieldValue()]) else {
                print("no delete")
                return [:]
            }
            currentUserData.user.profileImageURL = nil
            return [:]
        }
    }
    
    private func uploadBackground(uid: String) async -> [String: Any]{
        let storage = Firebase.storage
        let db = Firebase.db
        
        if let backgroundData = backgroundImageBundle.data {
            let metaData = Firebase.storageMetadata()
            metaData.contentType = "image/jpeg"
            let path: String = "BackgroundImage/\(uid).jpg"
            let reference = storage.reference(withPath: path)
            
            guard let result = try? await reference.putDataAsync(backgroundData, metadata: metaData) else {
                print("1")
                return [:]
            }
            guard let url = try? await reference.downloadURL() else {
                print("2")
                return [:]
            }
            currentUserData.user.backgroundImageURL = url
            return ["backgroundImageURL": url.absoluteString]
            
        }else {
            guard let result = try? await storage.reference(withPath: "BackgroundImage/\(uid).jpg").delete() else {
                print("3")
                return [:]
            }
            guard let deleteResult = try? await db.collection("User").document(uid).updateData(["backgroundImageURL": Firebase.deleteFieldValue()]) else {
                print("no delete")
                return [:]
            }
            currentUserData.user.backgroundImageURL = nil
            return [:]
        }
    }
}

private struct IdStackView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State private var isTappedInfo: Bool = false
    @State private var timer: Timer?
    let db = FBManager.shared.db
    
    @Binding private var profileData: EditProfileData
    init(profileData: Binding<EditProfileData>) {
        self._profileData = profileData
    }
    
    var body: some View {
        VStack(spacing: 12, content: {
            HStack(alignment: .bottom, spacing: 0, content: {
                Text("검색 ID")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundStyle(Color.white)
                Text(" *")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                SharedAsset.info.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 17)
                    .padding(.leading, 5)
                    .onTapGesture {
                        withAnimation {
                            isTappedInfo.toggle()
                        }
                    }
                    .overlay {
                        IdInfoView(isTappedInfo: $isTappedInfo)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 17 + 10)
                        //info아이콘 너비 + 아이콘과 해당 뷰 사이 너비
                        //overlay이기 때문에 아이콘 시작 위치에서 나타남.따라서 아이콘 너비만큼 옆으로 조금 밀어줘야함
                    }
                    
                Spacer()

                
                Text("\(profileData.id.count) ")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                Text("/ 15")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.subGray)
            })
            .frame(height: 17)
            
            
            AuthTextFieldSmall(text: $profileData.id, prompt: "ID를 입력해 주세요!")
                .onChange(of: profileData.id, perform: { value in
                    timer?.invalidate()
                    withAnimation {
                        profileData.idStatus = .loading
                    }
                    
                    if value.count > 15 {
                        profileData.id = String(value.prefix(15))
                    }
                    
                    if value == currentUserData.user.id {
                        withAnimation {
                            profileData.idStatus = .normal
                        }
                    }else {
                        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { timer in
                            checkID(id: profileData.id.lowercased())
                        })
                    }
                })
            
            VStack(spacing: 8, content: {
                Text("•  아이디는 3개월 동안 변경할 수 없습니다. ")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.D0Gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if !(profileData.idStatus == .normal || profileData.idStatus == .loading || profileData.id.isEmpty ) {
                    Text(profileData.idStatus == .valid ? "•  사용할 수 있는 ID 입니다."
                         : profileData.idStatus == .condition ? "•  영어, 숫자, _(언더바)만 사용할 수 있습니다."
                         : "•  이미 사용 중인 ID입니다.")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundStyle(profileData.idStatus == .valid ? ColorSet.validGreen
                                     : ColorSet.errorRed)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            })
            .padding(.top, 2)
        })
        .padding(.horizontal, 20)
    }
    
    private func checkID(id: String){
        let idRegex = "^[a-zA-Z0-9_]{5,15}$"
        let idPredicate = NSPredicate(format:"SELF MATCHES %@", idRegex)
        if idPredicate.evaluate(with: id) {
            Task {
                let result = await checkDuplication(id: id)
                withAnimation {
                    profileData.idStatus = result
                }
            }
        }else {
            withAnimation {
                profileData.idStatus = .condition
            }
        }
    }
    
    private func checkDuplication(id: String) async -> ErrorStatus{
        let query = db.collection("User").whereField("id", isEqualTo: id)
        guard let result = try? await query.getDocuments() else {
            return .duplicate
        }
        return result.isEmpty ? .valid : .duplicate
    }
}

private struct NicknameStackView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @State var timer: Timer?
    let db = FBManager.shared.db
    
    @Binding private var profileData: EditProfileData
    init(profileData: Binding<EditProfileData>) {
        self._profileData = profileData
    }
    
    var body: some View {
        VStack(spacing: 12, content: {
            HStack(alignment: .bottom, spacing: 0, content: {
                Text("닉네임")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundStyle(Color.white)
                Text(" *")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                Spacer()
                Text("\(profileData.nickname.count) ")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                Text("/ 7")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.subGray)
            })
            .frame(height: 17)

            
            AuthTextFieldSmall(text: $profileData.nickname, prompt: "닉네임을 입력해 주세요!")
                .onChange(of: profileData.nickname, perform: { value in
                    timer?.invalidate()
                    withAnimation {
                        profileData.nicknameStatus = .loading
                    }
                    
                    if profileData.nickname.count > 7 {
                        profileData.nickname =  String(value.prefix(7))
                    }
                    
                    if value == currentUserData.user.nickname {
                        withAnimation {
                            profileData.nicknameStatus = .normal
                        }
                    }else{
                        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { timer in
                            checkNickname(nickname: profileData.nickname.lowercased())
                        })
                    }
                })
            
            if !(profileData.nicknameStatus == .normal || profileData.nicknameStatus == .loading || profileData.nickname.isEmpty) {
                Text(profileData.nicknameStatus == .valid ? "•  사용할 수 있는 닉네임 입니다."
                     : profileData.nicknameStatus == .condition ? "•  3자 이상 입력해주세요."
                     : "•  이미 사용 중인 닉네임입니다.")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                .foregroundStyle(profileData.nicknameStatus == .valid ? ColorSet.validGreen : ColorSet.errorRed)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 10)
                .padding(.top, 2)
            }
        })
        .padding(.horizontal, 20)
        .padding(.top, 70)

    }
    
    private func checkNickname(nickname: String) {
        let nicknameRegex = "^[a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ]{3,7}$"
        let nicknamePredicate = NSPredicate(format:"SELF MATCHES %@", nicknameRegex)
        if nicknamePredicate.evaluate(with: nickname) {
            Task{
                let result = await checkDuplication(nickname: nickname)
                withAnimation {
                    profileData.nicknameStatus = result
                }
            }
        }else {
            DispatchQueue.main.async {
                withAnimation {
                    profileData.nicknameStatus = .condition
                }
            }
        }
    }
    
    private func checkDuplication(nickname: String) async -> ErrorStatus{
        let query = db.collection("User").whereField("nickname", isEqualTo: nickname)
        
        guard let result = try? await query.getDocuments() else {
            return .duplicate
        }
        
        return result.isEmpty ? .valid : .duplicate
    }
}



struct BioStackView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @Binding private var profileData: EditProfileData
    init(profileData: Binding<EditProfileData>) {
        self._profileData = profileData
    }
    
    var body: some View {
        VStack(spacing: 12, content: {
            HStack(alignment: .bottom, spacing: 0, content: {
                Text("소개")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundStyle(Color.white)
                Spacer()
                Text("\(profileData.bio.count) ")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                Text("/ 50")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.subGray)
            })
            .frame(height: 17)
            
            AuthTextFieldSmall(text: $profileData.bio, prompt: "회원님에 대해 소개해주세요!")
                .onChange(of: profileData.bio, perform: { value in
                    if profileData.bio.count > 50 {
                        profileData.bio = String(value.prefix(50))
                    }
                    profileData.bioStatus = (value == currentUserData.user.bio) ? .normal : .valid
                })

        })
        .padding(.horizontal, 20)
    }
}

private struct IdInfoView: View {
    @Binding var isTappedInfo: Bool
    init(isTappedInfo: Binding<Bool>) {
        self._isTappedInfo = isTappedInfo
    }
    var body: some View {
        HStack(spacing: 0) {
            Text("친구 찾기용 아이디 입니다.")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
            
            SharedAsset.xBlack.swiftUIImage
                .frame(width: 13, height: 13)
                .padding(.leading, 6)
                .onTapGesture {
                    withAnimation {
                        isTappedInfo = false
                    }
                }
            
        }
        .frame(height: 35)
        .padding(.trailing, 12)
        .padding(.leading, 16)
        .background(ColorSet.mainPurpleColor)
        .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20), style: .circular))
        .padding(.leading, 5)
        .opacity(isTappedInfo ? 1 : 0)
    }
}
enum ErrorStatus {
    case loading
    case normal
    case valid
    case duplicate
    case condition
}

struct EditProfileData {
    var id: String = ""
    var idStatus: ErrorStatus = .normal
    
    var nickname: String = ""
    var nicknameStatus: ErrorStatus = .normal
    
    var bio: String = ""
    var bioStatus: ErrorStatus = .normal
    
    var backgroundURL: URL?
    var backgroundStatus: ErrorStatus = .normal
    
    var profileURL: URL?
    var profileStatus: ErrorStatus = .normal
    
    func isValid() -> Bool {
        if idStatus == .normal && nicknameStatus == .normal && bioStatus == .normal && backgroundStatus == .normal && profileStatus == .normal {
            return false
        }else if isError(status: idStatus) || isError(status: nicknameStatus) || isError(status: bioStatus) || isError(status: backgroundStatus) || isError(status: profileStatus) {
            return false
        }
        return true
    }
    
    private func isError(status: ErrorStatus) -> Bool {
        if status == .loading || status == .condition || status == .duplicate {
            return true
        }
        return false
    }

}
