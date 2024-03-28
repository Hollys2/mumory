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

//여기 내부에서만 사용하는 observable을 만들어서 사용할까?? - 이게좋을듯함
//아이템 내부에 type, status, value 정의해서 사용
struct EditProfileView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @StateObject private var editProfileViewModel: EditProfileViewModel = EditProfileViewModel()
    @State var isLoading: Bool = false
    
    var body: some View {
        ZStack(alignment: .top){
            ColorSet.background
            ScrollView(.vertical) {
                VStack(spacing: 33, content: {
                    UserProfile()
                        .environmentObject(editProfileViewModel)
                    
                    NicknameStackView()
                        .environmentObject(editProfileViewModel)
                    
                    IdStackView()
                        .environmentObject(editProfileViewModel)
                    
                    BioStackView()
                        .environmentObject(editProfileViewModel)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 500)
                })
            }
            LoadingAnimationView(isLoading: $editProfileViewModel.isLoading)
                .frame(maxHeight: .infinity, alignment: .center)
        }
        .ignoresSafeArea()
        .onAppear(perform: {
            DispatchQueue.main.async {
                editProfileViewModel.nickname = currentUserData.user.nickname
                editProfileViewModel.id = currentUserData.user.id
                editProfileViewModel.bio = currentUserData.user.bio
                editProfileViewModel.profileURL = currentUserData.user.profileImageURL
                editProfileViewModel.backgroundURL = currentUserData.user.backgroundImageURL
            }
        })
        .disabled(editProfileViewModel.isLoading)
        
    }
}


public struct ImageBundle {
    public var item: PhotosPickerItem?
    public var image: Image?
    public var data: Data?
}
private struct UserProfile: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var editProfileViewModel: EditProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State var isPresentBackgroundBottomSheet: Bool = false
    @State var isPresentProfileBottomSheet: Bool = false
    let Firebase = FBManager.shared
    
    var body: some View {
        ZStack(alignment: .top){
            //배경이미지
            VStack{
                if let image = editProfileViewModel.backgroundImageBundle.image {
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
                ImageSelectBottomSheet(isPresent: $isPresentBackgroundBottomSheet, imageBundle: $editProfileViewModel.backgroundImageBundle, photoType: .background)
                    .background(TransparentBackground())
            }
            .onChange(of: editProfileViewModel.backgroundImageBundle.image) { value in
                editProfileViewModel.backgroundStatus = .valid
            }
            .overlay {
                //프로필 이미지
                VStack{
                    if let image = editProfileViewModel.profileImageBundle.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                    }else {
                        currentUserData.user.defaultProfileImage
                            .resizable()
                            .scaledToFill()
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
                    ImageSelectBottomSheet(isPresent: $isPresentProfileBottomSheet, imageBundle: $editProfileViewModel.profileImageBundle)
                        .background(TransparentBackground())
                }
                .onChange(of: editProfileViewModel.profileImageBundle.image) { value in
                    editProfileViewModel.profileStatus = .valid
                }
            }
            
            //상단바
            HStack(alignment: .center){
                SharedAsset.xGradient.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onTapGesture {
                        dismiss()
                    }
                
                
                Text("프로필 편집")
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                
                Text("완료")
                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 13))
                    .foregroundStyle(Color.black)
                    .padding(.horizontal, 11)
                    .frame(height: 30)
                    .background(editProfileViewModel.isValid() ? ColorSet.mainPurpleColor : ColorSet.subGray)
                    .clipShape(RoundedRectangle(cornerRadius: 31.5, style: .circular))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .onTapGesture {
                        editProfileViewModel.isLoading = true
                        Task {
                            await editProfileViewModel.saveUserProfile(uid: currentUserData.uId)
                            DispatchQueue.main.async {
                                currentUserData.user.nickname = editProfileViewModel.nickname
                                currentUserData.user.id = editProfileViewModel.id
                                currentUserData.user.bio = editProfileViewModel.bio
                                currentUserData.user.profileImageURL = editProfileViewModel.profileURL
                                currentUserData.user.backgroundImageURL = editProfileViewModel.backgroundURL
                                editProfileViewModel.isLoading = false
                                dismiss()
                            }
                            
                        }
                    }
                    .disabled(!editProfileViewModel.isValid())
                
            }
            .padding(.horizontal, 20)
            .frame(height: 63)
            .padding(.top, currentUserData.topInset)
        }
    }
    
    
    
}

private struct IdStackView: View {
    @EnvironmentObject var currentUserData: CurrentUserData
    @EnvironmentObject var editProfileViewModel: EditProfileViewModel
    @State private var isTappedInfo: Bool = false
    @State private var timer: Timer?
    let db = FBManager.shared.db
    
    
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
                
                
                Text("\(editProfileViewModel.id.count) ")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                Text("/ 15")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.subGray)
            })
            .frame(height: 17)
            
            
            AuthTextFieldSmall(text: $editProfileViewModel.id, prompt: "ID를 입력해 주세요!")
                .onChange(of: editProfileViewModel.id, perform: { value in
                    timer?.invalidate()
                    withAnimation {
                        editProfileViewModel.idStatus = .loading
                    }
                    
                    if value.count > 15 {
                        editProfileViewModel.id = String(value.prefix(15))
                    }
                    
                    if value == currentUserData.user.id {
                        withAnimation {
                            editProfileViewModel.idStatus = .normal
                        }
                    }else {
                        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { timer in
                            checkID(id: editProfileViewModel.id.lowercased())
                        })
                    }
                })
            
            VStack(spacing: 8, content: {
                Text("•  아이디는 3개월 동안 변경할 수 없습니다. ")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.D0Gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !(editProfileViewModel.idStatus == .normal || editProfileViewModel.idStatus == .loading || editProfileViewModel.id.isEmpty ) {
                    Text(editProfileViewModel.idStatus == .valid ? "•  사용할 수 있는 ID 입니다."
                         : editProfileViewModel.idStatus == .condition ? "•  영어, 숫자, _(언더바)만 사용할 수 있습니다."
                         : "•  이미 사용 중인 ID입니다.")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                    .foregroundStyle(editProfileViewModel.idStatus == .valid ? ColorSet.validGreen
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
                    editProfileViewModel.idStatus = result
                }
            }
        }else {
            withAnimation {
                editProfileViewModel.idStatus = .condition
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
    @EnvironmentObject var editProfileViewModel: EditProfileViewModel
    @State var timer: Timer?
    let db = FBManager.shared.db
    
    
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
                Text("\(editProfileViewModel.nickname.count) ")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                Text("/ 7")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.subGray)
            })
            .frame(height: 17)
            
            
            AuthTextFieldSmall(text: $editProfileViewModel.nickname, prompt: "닉네임을 입력해 주세요!")
                .onChange(of: editProfileViewModel.nickname, perform: { value in
                    timer?.invalidate()
                    withAnimation {
                        editProfileViewModel.nicknameStatus = .loading
                    }
                    
                    if editProfileViewModel.nickname.count > 7 {
                        editProfileViewModel.nickname =  String(value.prefix(7))
                    }
                    
                    if value == currentUserData.user.nickname {
                        withAnimation {
                            editProfileViewModel.nicknameStatus = .normal
                        }
                    }else{
                        timer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { timer in
                            checkNickname(nickname: editProfileViewModel.nickname.lowercased())
                        })
                    }
                })
            
            if !(editProfileViewModel.nicknameStatus == .normal || editProfileViewModel.nicknameStatus == .loading || editProfileViewModel.nickname.isEmpty) {
                Text(editProfileViewModel.nicknameStatus == .valid ? "•  사용할 수 있는 닉네임 입니다."
                     : editProfileViewModel.nicknameStatus == .condition ? "•  3~7자 사이로 영어,한글만 사용할 수 있습니다."
                     : "•  이미 사용 중인 닉네임입니다.")
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                .foregroundStyle(editProfileViewModel.nicknameStatus == .valid ? ColorSet.validGreen : ColorSet.errorRed)
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
                    editProfileViewModel.nicknameStatus = result
                }
            }
        }else {
            DispatchQueue.main.async {
                withAnimation {
                    editProfileViewModel.nicknameStatus = .condition
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
    @EnvironmentObject var editProfileViewModel: EditProfileViewModel
    
    var body: some View {
        VStack(spacing: 12, content: {
            HStack(alignment: .bottom, spacing: 0, content: {
                Text("소개")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundStyle(Color.white)
                Spacer()
                Text("\(editProfileViewModel.bio.count) ")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.mainPurpleColor)
                
                Text("/ 50")
                    .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                    .foregroundStyle(ColorSet.subGray)
            })
            .frame(height: 17)
            
            AuthTextFieldSmall(text: $editProfileViewModel.bio, prompt: "회원님에 대해 소개해주세요!")
                .onChange(of: editProfileViewModel.bio, perform: { value in
                    if editProfileViewModel.bio.count > 50 {
                        editProfileViewModel.bio = String(value.prefix(50))
                    }
                    editProfileViewModel.bioStatus = (value == currentUserData.user.bio) ? .normal : .valid
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

class EditProfileViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var id: String = ""
    @Published var idStatus: ErrorStatus = .normal
    @Published var nickname: String = ""
    @Published var nicknameStatus: ErrorStatus = .normal
    @Published var bio: String = ""
    @Published var bioStatus: ErrorStatus = .normal
    @Published var backgroundStatus: ErrorStatus = .normal
    @Published var profileStatus: ErrorStatus = .normal
    @Published var backgroundImageBundle: ImageBundle = ImageBundle()
    @Published var profileImageBundle: ImageBundle = ImageBundle()
    @Published var backgroundURL: URL? {
        didSet {
            Task {
                guard let url = self.backgroundURL else {
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
                DispatchQueue.main.async {
                    self.backgroundImageBundle.data = uiImage.jpegData(compressionQuality: 0.1)
                    self.backgroundImageBundle.image = Image(uiImage: uiImage)
                    self.backgroundStatus = .normal
                }
   
            }
        }
    }
    @Published var profileURL: URL? {
        didSet {
            Task {
                guard let url = self.profileURL else {
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
                DispatchQueue.main.async {
                    self.profileImageBundle.data = uiImage.jpegData(compressionQuality: 0.1)
                    self.profileImageBundle.image = Image(uiImage: uiImage)
                    self.profileStatus = .normal
                }
    
            }
        }
    }
    
    let db = FBManager.shared.db
    let storage = FBManager.shared.storage
    
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
    
    func saveUserProfile(uid: String) async {
        let query = db.collection("User").document(uid)
        
        var data: [String: Any] = [
            "id": self.id,
            "nickname": self.nickname,
            "bio": self.bio
        ]
        
        let background = URL(string: await uploadBackground(uid: uid))
        let profile = URL(string: await uploadProfile(uid: uid))
        
        DispatchQueue.main.async {
            self.backgroundURL = background
            self.profileURL = profile
        }
        
        data.merge(["backgroundImageURL": background?.absoluteString ?? ""])
        data.merge(["profileImageURL" : profile?.absoluteString ?? ""])
        
        guard let result = try? await query.updateData(data) else {return}

    }
    
    private func uploadProfile(uid: String) async -> String {
        if let profileData = profileImageBundle.data {
            let metaData = FBManager.shared.storageMetadata()
            metaData.contentType = "image/jpeg"
            let path: String = "ProfileImage/\(uid).jpg"
            let reference = storage.reference(withPath: path)
            guard let result = try? await reference.putDataAsync(profileData, metadata: metaData) else {
                return ""
            }
            guard let url = try? await reference.downloadURL() else {
                return ""
            }
            return url.absoluteString
        }else {
            guard let result = try? await storage.reference(withPath: "ProfileImage/\(uid).jpg").delete() else {
                return ""
            }
            guard let updateResult = try? await db.collection("User").document(uid).updateData(["profileImageURL": FBManager.Fieldvalue.delete()]) else {
                return ""
            }
            return ""
        }
    }
    
    private func uploadBackground(uid: String) async -> String {
        if let backgroundData = backgroundImageBundle.data {
            let metaData = FBManager.shared.storageMetadata()
            metaData.contentType = "image/jpeg"
            let path: String = "BackgroundImage/\(uid).jpg"
            let reference = storage.reference(withPath: path)
            
            guard let result = try? await reference.putDataAsync(backgroundData, metadata: metaData) else {
                return ""
            }
            guard let url = try? await reference.downloadURL() else {
                return ""
            }
            return url.absoluteString
        }else {
            guard let result = try? await storage.reference(withPath: "BackgroundImage/\(uid).jpg").delete() else {
                return ""
            }
            guard let deleteResult = try? await db.collection("User").document(uid).updateData(["backgroundImageURL": FBManager.shared.deleteFieldValue()]) else {
                return ""
            }
            return ""
        }
    }
    
}

