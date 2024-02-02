//
//  ProfileSettingView.swift
//  Feature
//
//  Created by 제이콥 on 12/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import _PhotosUI_SwiftUI
import Shared
import Lottie
import Core

struct ProfileSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: CustomizationManageViewModel
    
    @State var nickname: String = ""
    @State var id: String = ""
    @State var isTouchInfo: Bool = false
    @State var isValidNickname: Bool = false
    @State var isOver2Char: Bool = false
    @State var nicknameErrorString: String = ""
    @State var idErrorString: String = ""
    @State var selectedItem: PhotosPickerItem?
    @State var selectedImage: Image?
    
    var profileImageList: [Image] = [SharedAsset.profileSelectRed.swiftUIImage, SharedAsset.profileSelectGray.swiftUIImage, SharedAsset.profileSelectOrange.swiftUIImage, SharedAsset.profileSelectPurple.swiftUIImage, SharedAsset.profileSelectYellow.swiftUIImage]
        
    var body: some View {
        GeometryReader(content: { geometry in
            ZStack{
                ColorSet.background.ignoresSafeArea()
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Text("프로필을 설정해주세요")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .foregroundStyle(.white)
                            .padding(.leading, 20)
                            .padding(.top, 40)
                        
                        Text("마이페이지에서 수정할 수 있어요")
                            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.top, 7)
                            .padding(.leading, 20)
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let item = selectedItem{
                                if let imageData = manager.profileImageData{
                                    if let image = selectedImage{
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                            .frame(width: 105, height: 105)
                                    }
                                    

                                }
                                
                            }else{
                                manager.RandomSelectProfile()
                            }
                        }
                        .frame(width: 140, height: 140)
                        .padding(.top, 25)
                        .onChange(of: selectedItem, perform: { value in
                            Task{
                                if let loaded = try? await selectedItem?.loadTransferable(type: Data.self) {
                                    if let uiimage = UIImage(data: loaded){
                                        selectedImage = Image(uiImage: uiimage)
                                        manager.profileImage = selectedImage
                                        manager.profileImageData = loaded
                                    }
                                } else {
                                    print("Failed")
                                }
                            }
                        })
                        
                        
                        HStack(spacing: 0){
                            Text("닉네임")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundStyle(.white)
                            Text(" *")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundStyle(ColorSet.mainPurpleColor)
                            
                            Spacer()
                            
                            Text("\(nickname.count)")
                                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                                .foregroundColor(nickname.count > 0 ? ColorSet.mainPurpleColor : ColorSet.subGray)
                            
                            Text(" / 7")
                                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                                .foregroundColor(ColorSet.subGray)
                        }
                        .padding(.top, 25)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        
                            
                        AuthTextFieldSmall(text: $nickname, prompt: "닉네임을 입력해 주세요!")
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 15)
                            .onChange(of: nickname) { newValue in
                                getNicknameError(nickname: newValue.lowercased())
                            }

                        Text(nicknameErrorString)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .padding(.leading, 20)
                            .padding(.top, 14)
                        
                        HStack(spacing: 0){
                            Text("검색 ID")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundStyle(.white)
                            Text(" *")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                                .foregroundStyle(ColorSet.mainPurpleColor)
                            
                            SharedAsset.info.swiftUIImage
                                .frame(width: 15, height: 15)
                                .padding(.leading, 5)
                                .onTapGesture {
                                    isTouchInfo = true
                                }
                            
                            HStack(spacing: 0) {
                                Text("친구 찾기용 아이디 입니다.")
                                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                                
                                SharedAsset.xBlack.swiftUIImage
                                    .frame(width: 13, height: 13)
                                    .padding(.leading, 6)
                                    .onTapGesture {
                                        isTouchInfo = false
                                    }
                                
                            }
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .padding(.trailing, 12)
                            .padding(.leading, 16)
                            .background(ColorSet.mainPurpleColor)
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20), style: .circular))
                            .padding(.leading, 5)
                            .opacity(isTouchInfo ? 1 : 0)
                            
                            Spacer()
                            
                            Text("\(id.count)")
                                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                                .foregroundStyle(id.count > 0 ? ColorSet.mainPurpleColor : ColorSet.subGray)
                            
                            Text(" / 15")
                                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                                .foregroundStyle(ColorSet.subGray)
                        }
                        .padding(.top, 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        
                        
                       AuthTextFieldSmall(text: $id, prompt: "ID를 입력해 주세요!")
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                        .onChange(of: id, perform: { value in
                            getIdError(id: id.lowercased())
                        })
                        
                        Text(idErrorString)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .padding(.leading, 20)
                            .padding(.top, 14)
                        
                        
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 80)
                    }
                }
                
            }
            .onTapGesture {
                hideKeyboard()
            }
        })
    }
    

    
    private func getNicknameError(nickname: String){
        
        if nickname.count > 0 && nickname.count < 2 {
            nicknameErrorString = "2자 이상 입력해주세요"
            manager.nickname = ""
        }else{
            let db = FirebaseManager.shared.db
            let query = db.collection("User").whereField("nickname", isEqualTo: nickname)
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("query error: \(error)")
                }else if let snapshot = snapshot{
                    let dataCount = snapshot.count
                    
                    //동일한 문자열이 존재한다면
                    if dataCount > 0 {
                        nicknameErrorString = "이미 사용중인 닉네임 입니다."
                        manager.nickname = ""
                    }else{
                        nicknameErrorString = ""
                        manager.nickname = nickname
                        print("nickname: \(manager.nickname), id: \(manager.id)")
                        
                        
                    }
                }else {
                    print("snapshot error")
                }
            }
        }
    }
    
    private func getIdError(id: String) {
        print("nickname: \(manager.nickname), id: \(manager.id)")
        if isValidID(id: id){
            let db = FirebaseManager.shared.db
            let query = db.collection("User").whereField("id", isEqualTo: id)
            
            query.getDocuments { snapshot, error in
                if let error = error {
                    print("query error: \(error)")
                }else if let snapshot = snapshot{
                    let dataCount = snapshot.count
                    if dataCount > 0 {
                        idErrorString = "이미 사용중인 ID 입니다."
                        manager.id = ""
                    }else{
                        idErrorString = ""
                        manager.id = id
                        print("nickname: \(manager.nickname), id: \(manager.id)")
                        
                    }
                }else {
                    print("snapshot error")
                }
            }
        }else{
            idErrorString = "영어, 숫자만 사용할 수 있습니다."
            manager.id = ""
        }
    }
    
    private func isValidID(id: String) -> Bool {
        let idRegex = "^[a-zA-Z0-9_]+$"
        let idPredicate = NSPredicate(format:"SELF MATCHES %@", idRegex)
        return idPredicate.evaluate(with: id)
    }

}

//#Preview {
//    ProfileSettingView()
//}

