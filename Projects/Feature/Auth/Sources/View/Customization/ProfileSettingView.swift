//
//  ProfileSettingView.swift
//  Feature
//
//  Created by 제이콥 on 12/28/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import PhotosUI
import Shared
import Lottie
import Core

struct ProfileSettingView: View {
    // MARK: - Propoerties
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: CustomizationManageViewModel
    
    @State var nickname: String = ""
    @State var id: String = ""
    @State var isTouchInfo: Bool = false
    
    @State var nicknameErrorString: String = ""
    @State var idErrorString: String = ""
    
    @State var selectedItem: PhotosPickerItem?
    
    @State var nicknameTimer: Timer?
    @State var nicknameTime = 0.0
    @State var idTimer: Timer?
    @State var idTime = 0.0
    @State var isValidNicknameStyle: Bool = false
    @State var isValidIDStyle: Bool = false
    
    @State var isPresentBottomSheet: Bool = false
    
    // MARK: - View
    var body: some View {
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
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(ColorSet.subGray)
                            .padding(.top, 7)
                            .padding(.leading, 20)
                        
                        VStack(spacing: 0){
                            if let image = manager.profileImage{
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 105, height: 105)
                                    .clipShape(Circle())
                            }else{
                                manager.getSelectProfileImage()
                            }
                        }
                        .frame(width: 140, height: 140)
                        .padding(.top, 25)
                        .onTapGesture {
                            UIView.setAnimationsEnabled(false)
                            isPresentBottomSheet.toggle()
                        }
                        .onChange(of: selectedItem, perform: { value in
                            isPresentBottomSheet.toggle()
                            Task{
                                guard let loaded = try? await selectedItem?.loadTransferable(type: Data.self),
                                      let uiImage = UIImage(data: loaded) else {
                                    manager.removeProfileImage()
                                    return
                                }
                                DispatchQueue.main.async {
                                    manager.profileImage = Image(uiImage: uiImage)
                                    manager.profileImageData = uiImage.jpegData(compressionQuality: 0.1).unsafelyUnwrapped
                                }
                            
                            }
                        })
                        .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
                            PhotoSelectBottomSheet(isPresent: $isPresentBottomSheet, selectedItem: $selectedItem)
                                .background(TransparentBackground())
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
                        
                            
                        AuthTextField_16(text: $nickname, prompt: "닉네임을 입력해 주세요!")
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            .padding(.top, 15)
                            .onChange(of: nickname) { newValue in
                                nicknameTime = 0
                                nicknameErrorString = ""
                                manager.isValidNickname = false
                                if newValue.count > 7 {
                                    nickname = String(newValue.prefix(7))
                                }
                            }
                            .onChange(of: nicknameTime, perform: { value in
                                //1초 지났을 때만 실행
                                if nicknameTime == 0.8 {
                                    isValidNicknameStyle(nickname: nickname.lowercased())
                                }else if nicknameTime >= 1 && nicknameTime <= 1.2 {
                                    if isValidNicknameStyle {
                                        checkNickname(nickname: self.nickname.lowercased())
                                    }
                                }
                            })
                       

                        Text(manager.isValidNickname ? "•  사용할 수 있는 닉네임 입니다." : nicknameErrorString)
                            .foregroundStyle(manager.isValidNickname ? ColorSet.validGreen : ColorSet.errorRed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .padding(.leading, 30)
                            .padding(.top, 14)
                            .frame(height: nicknameErrorString.count > 0 ? nil : manager.isValidNickname ? nil : 0)
                        
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
                                    .foregroundStyle(Color.black)
                                
                                SharedAsset.xBlack.swiftUIImage
                                    .frame(width: 13, height: 13)
                                    .padding(.leading, 6)
                                    .onTapGesture {
                                        isTouchInfo = false
                                    }
                                
                            }
                            .padding(.vertical, 10)
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
                        
                        
                       AuthTextField_16(text: $id, prompt: "ID를 입력해 주세요!")
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.top, 10)
                        .onChange(of: id) { newValue in
                            idTime = 0
                            idErrorString = ""
                            manager.isValidID = false
                            if newValue.count > 15 {
                                id = String(newValue.prefix(15))
                            }
                        }
                        .onChange(of: idTime, perform: { value in
                            if idTime == 0.8 {
                                isValidIDStyle(id: id.lowercased())
                            }else if idTime >= 1 && idTime <= 1.2 {
                                if isValidIDStyle {
                                    checkID(id: self.id.lowercased())
                                }
                            }
                        })
                   
                        
                        Text(manager.isValidID ? "•  사용할 수 있는 ID 입니다." : idErrorString)
                            .foregroundStyle(manager.isValidID ? ColorSet.validGreen : ColorSet.errorRed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .padding(.leading, 30)
                            .padding(.top, 14)
                            .frame(height: idErrorString.count > 0 ? nil : manager.isValidID ? nil : 0)
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 150)
                    }
                }
                .scrollIndicators(.hidden)

                
            }
            .onAppear(perform: {
                self.nicknameTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                    nicknameTime += 0.2
                }
                self.idTimer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { timer in
                    idTime += 0.2
                }
            })
            .onDisappear(perform: {
                self.nicknameTimer?.invalidate()
                self.idTimer?.invalidate()
            })
            .onTapGesture {
                hideKeyboard()
            }
    }
    
    private func isValidIDStyle(id: String){
        manager.isValidID = false
        let idRegex = "^[a-zA-Z0-9_]{5,15}$"
        let idPredicate = NSPredicate(format:"SELF MATCHES %@", idRegex)
        isValidIDStyle = idPredicate.evaluate(with: id)
        idErrorString = id.count <= 0 ? "" : isValidIDStyle ? "" : "•  영어, 숫자, _(언더바)만 사용할 수 있습니다."
    }
    
    private func checkID(id: String){
        let db = FirebaseManager.shared.db
        let query = db.collection("User").whereField("id", isEqualTo: id)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("query error: \(error)")
            }else if let snapshot = snapshot{
                if snapshot.isEmpty {
                    idErrorString = ""
                    manager.id = id
                    manager.isValidID = true
                    print("nickname: \(manager.nickname), id: \(manager.id)")
               
                }else{
                    idErrorString = "•  이미 사용중인 ID 입니다."
                    manager.isValidID = false
                    
                }
            }else {
                print("snapshot error")
            }
        }
    }
    
    private func isValidNicknameStyle(nickname: String){
        manager.isValidNickname = false
        let nicknameRegex = "^[a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ]{3,7}$"
        let nicknamePredicate = NSPredicate(format:"SELF MATCHES %@", nicknameRegex)

        isValidNicknameStyle = nicknamePredicate.evaluate(with: nickname)
        nicknameErrorString = nickname.count <= 0 ? "" : isValidNicknameStyle ? "" : "•  3~7자 사이로 영어,한글만 사용할 수 있습니다."
    }
    
    private func checkNickname(nickname: String){
        let db = FirebaseManager.shared.db
        let query = db.collection("User").whereField("nickname", isEqualTo: nickname)
        
        query.getDocuments { snapshot, error in
            if let error = error {
                print("query error: \(error)")
            }else if let snapshot = snapshot{
                //동일한 문자열이 존재한다면
                if snapshot.isEmpty {
                    nicknameErrorString = ""
                    manager.isValidNickname = true
                    manager.nickname = nickname
                    print("nickname: \(manager.nickname), id: \(manager.id)")
                }else{
                    nicknameErrorString = "•  이미 사용중인 닉네임 입니다."
                    manager.isValidNickname = false
                }
            }else {
                print("snapshot error")
            }
        }
    }
    


}

