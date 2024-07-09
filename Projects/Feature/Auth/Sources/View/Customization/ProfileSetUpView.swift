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

struct ProfileSetUpView: View {
    // MARK: - Propoerties
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @State var selectedItem: PhotosPickerItem?
    @State var isPresentBottomSheet: Bool = false
    @State var isPresentInfo: Bool = false
    
    @State var nicknameTimer: Timer?
    @State var idTimer: Timer?
    
    ///닉네임 입력 완료 여부 판단을 위한 이전 닉네임 저장 변수
    @State var previousNickname: String = ""
    
    ///아이디 입력 완료 여부 판단을 위한 이전 아이디 저장 변수
    @State var previousId: String = ""

    @State var nicknameState: ValidationState = .none
    @State var idState: ValidationState = .none

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
                        
                        Group {
                            if let image = signUpViewModel.profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 105, height: 105)
                                    .clipShape(Circle())
                            } else {
                                signUpViewModel.getDefaultProfileImage()
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
                                let data = try? await selectedItem?.loadTransferable(type: Data.self)
                                signUpViewModel.setProfileImage(data: data)
                            }
                        })
                        .fullScreenCover(isPresented: $isPresentBottomSheet, content: {
                            PhotoSelectBottomSheet(isPresent: $isPresentBottomSheet, selectedItem: $selectedItem)
                                .background(TransparentBackground())
                        })
                        
                        
                        NicknameStack
                        
                        RoundedTextField(text: $signUpViewModel.nickname, placeHolder: "닉네임을 입력해 주세요!", fontSize: 16)
                            .padding(.horizontal, 20)
                            .padding(.top, 15)
                        
                            .onChange(of: signUpViewModel.nickname) { newValue in
                                nicknameState = .none
                                signUpViewModel.isValidNickname = false
                                let isTimerInvalid = !(nicknameTimer?.isValid ?? false)
                                if isTimerInvalid {
                                    setNicknameTimerForCheckingValidation()
                                }
                            }

                       

                        Text(getNicknameFeedbackMsg())
                            .foregroundStyle(signUpViewModel.isValidNickname ? ColorSet.validGreen : ColorSet.errorRed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .padding(.leading, 30)
                            .padding(.top, 14)
                            .frame(height: nicknameState == .none ? 0 : nil)

                        HStack(spacing: 0){
                            IdTitle
                            
                            Button {
                                isPresentInfo.toggle()
                            } label: {
                                SharedAsset.info.swiftUIImage
                                    .resizable()
                                    .frame(width: 15, height: 15)
                                    .padding(.leading, 5)
                            }
                            
                            IdInformationView
                                .transition(.scale)

                            Spacer()
                            
                            CountTextOfId
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)
                        
                        
                        RoundedTextField(text: $signUpViewModel.id, placeHolder: "ID를 입력해 주세요!", fontSize: 16)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .onChange(of: signUpViewModel.id) { newValue in
                            idState = .none
                            signUpViewModel.isValidId = false
                            let isTimerInvalid = !(idTimer?.isValid ?? false)
                            if isTimerInvalid {
                                setIdTimerForCheckingValidation()
                            }
                        }

                        Text(getIdFeedbackMsg())
                            .foregroundStyle(signUpViewModel.isValidId ? ColorSet.validGreen : ColorSet.errorRed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 12))
                            .padding(.leading, 30)
                            .padding(.top, 14)
                            .frame(height: idState == .none ? 0 : nil)
                        
                        Rectangle()
                            .fill(.clear)
                            .frame(height: 150)
                    }
                }
                .scrollIndicators(.hidden)

                
            }
            .onAppear(perform: {
                setNicknameTimerForCheckingValidation()
                setIdTimerForCheckingValidation()
            })
            .onDisappear(perform: {
                self.nicknameTimer?.invalidate()
                self.idTimer?.invalidate()
            })
            .onTapGesture {
                hideKeyboard()
            }
    }
    
    var NicknameStack: some View {
        HStack(spacing: 0){
            Text("닉네임")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                .foregroundStyle(.white)
            Text(" *")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                .foregroundStyle(ColorSet.mainPurpleColor)
            
            Spacer()
            
            Text("\(signUpViewModel.nickname.count)")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                .foregroundColor(signUpViewModel.nickname.count > 0 ? ColorSet.mainPurpleColor : ColorSet.subGray)
            
            Text(" / 7")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                .foregroundColor(ColorSet.subGray)
        }
        .padding(.top, 25)
        .padding(.horizontal, 20)
    }
    
    var IdInformationView: some View {
        HStack(spacing: 0) {
            Text("친구 찾기용 아이디 입니다.")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundStyle(Color.black)
            Button {
                isPresentInfo.toggle()
            } label: {
                SharedAsset.xBlack.swiftUIImage
                    .resizable()
                    .frame(width: 13, height: 13)
                    .padding(.leading, 6)
            }
        }
        .padding(.vertical, 10)
        .padding(.trailing, 12)
        .padding(.leading, 16)
        .background(ColorSet.mainPurpleColor)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
        .padding(.leading, 5)
        .animation(.default, value: isPresentInfo)
        .opacity(isPresentInfo ? 1 : 0)
    }
    
    var IdTitle: some View {
        HStack(spacing: 0) {
            Text("검색 ID")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                .foregroundStyle(.white)
            Text(" *")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                .foregroundStyle(ColorSet.mainPurpleColor)
        }

    }
    
    var CountTextOfId: some View {
        HStack(spacing: 0) {
            Text("\(signUpViewModel.id.count)")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                .foregroundStyle(signUpViewModel.id.count > 0 ? ColorSet.mainPurpleColor : ColorSet.subGray)
            
            Text(" / 15")
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 12))
                .foregroundStyle(ColorSet.subGray)
        }

    }
    
    // MARK: - Methods
    
    ///닉네임의 형식, 중복 실시간 체크 기능을 하는 타이머 설정
    private func setNicknameTimerForCheckingValidation() {
        previousNickname = signUpViewModel.nickname
        self.nicknameTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true, block: { _ in
            guard !signUpViewModel.nickname.isEmpty else {
                setValidation(target: .nickname, state: .none)
                return
            }
            
            let isEndEditing = (previousNickname == signUpViewModel.nickname)
            guard isEndEditing else {
                previousNickname = signUpViewModel.nickname
                return
            }
            
            signUpViewModel.isLoading = true

            guard isCorrectNicknameFormat() else {
                setValidation(target: .nickname, state: .formatError)
                return
            }
            

            Task {
                guard await isValidNickname() else {
                    setValidation(target: .nickname, state: .duplicationError)
                    return
                }
                setValidation(target: .nickname, state: .valid)
            }
        })
  
    }
    
    ///아이디의 형식, 중복 실시간 체크 기능을 하는 타이머 설정
    private func setIdTimerForCheckingValidation() {
        previousId = signUpViewModel.id
        self.idTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true, block: { _ in
            guard !signUpViewModel.id.isEmpty else {
                setValidation(target: .id, state: .none)
                return
            }
            
            let isEndEditing = (previousId == signUpViewModel.id)
            guard isEndEditing else {
                previousId = signUpViewModel.id
                return
            }
            
            signUpViewModel.isLoading = true

            guard isCorrectIdFormat() else {
                setValidation(target: .id, state: .formatError)
                return
            }
            

            Task {
                guard await isValidId() else {
                    setValidation(target: .id, state: .duplicationError)
                    return
                }
                setValidation(target: .id, state: .valid)
            }
        })
  
    }
    
    ///아이디 형식 확인
    private func isCorrectIdFormat() -> Bool {
        let idRegex = "^[a-zA-Z0-9_]{5,15}$"
        let idPredicate = NSPredicate(format:"SELF MATCHES %@", idRegex)
        return idPredicate.evaluate(with: signUpViewModel.id)
    }
    
    ///닉네임 형식 확인
    private func isCorrectNicknameFormat() -> Bool {
        let nicknameRegex = "^[a-zA-Z가-힣ㄱ-ㅎㅏ-ㅣ]{3,7}$"
        let nicknamePredicate = NSPredicate(format:"SELF MATCHES %@", nicknameRegex)
        return nicknamePredicate.evaluate(with: signUpViewModel.nickname)
    }
    
    ///아이디 중복 확인
    private func isValidId() async -> Bool {
        let db = FirebaseManager.shared.db
        let query = db.collection("User").whereField("id", isEqualTo: signUpViewModel.id)
        
        guard let snapshot = try? await query.getDocuments() else {return false}
        return snapshot.isEmpty
    }
    
    ///닉네임 오류 메세지
    private func getNicknameFeedbackMsg() -> String {
        switch nicknameState {
        case .none: return ""
        case .valid: return "•  사용할 수 있는 닉네임 입니다."
        case .formatError: return "•  3~7자 사이로 영어,한글만 사용할 수 있습니다."
        case .duplicationError: return "•  이미 사용 중인 닉네임입니다."
        }
    }
    
    ///아이디 오류 메세지
    private func getIdFeedbackMsg() -> String {
        switch idState {
        case .none: return ""
        case .valid: return "•  사용할 수 있는 ID 입니다."
        case .formatError: return "•  영어, 숫자, _(언더바)만 사용할 수 있습니다."
        case .duplicationError: return "•  이미 사용 중인 ID입니다."
        }
    }
    
    ///닉네임 중복 확인
    private func isValidNickname() async -> Bool {
        let db = FirebaseManager.shared.db
        let query = db.collection("User").whereField("nickname", isEqualTo: signUpViewModel.nickname)
        
        guard let snapshot = try? await query.getDocuments() else {return false}
        return snapshot.isEmpty
    }

    private enum ProfileSetUpType {
        case nickname
        case id
    }
    
    ///닉네임과 아이디의 유효성 변수 설정
    private func setValidation(target: ProfileSetUpType, state: ValidationState) {
        let isValid: Bool = (state == .valid)
        switch target {
        case .nickname:
            self.nicknameState = state
            signUpViewModel.isValidNickname = isValid
            if isValid {
                self.nicknameTimer?.invalidate()
            }
            
        case .id:
            self.idState = state
            signUpViewModel.isValidId = isValid
            if isValid {
                self.idTimer?.invalidate()
            }
            
        }
        
        signUpViewModel.isLoading = false
    }
    
}

