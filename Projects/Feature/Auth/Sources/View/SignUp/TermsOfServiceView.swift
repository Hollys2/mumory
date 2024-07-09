//
//  SignUpFinishView.swift
//  Feature
//
//  Created by 제이콥 on 12/10/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared
enum TOSChecklist {
    case tos
    case personalInformation
    case serviceNotification
}

struct TermsOfServiceView: View {
    // MARK: - Propoerties

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    @State var checkedList: [TOSChecklist] = []
    let nextButtonHeight: CGFloat = 78

    // MARK: - View
    var body: some View {
        ZStack{
            LibraryColorSet.background.ignoresSafeArea()
            VStack(spacing: 0){
                
                Text("서비스 이용약관에\n동의해주세요!")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 43)
                    .padding(.leading, 20)
                    .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                    .lineSpacing(7)
                
                Spacer()
                
                AllAgreeButton
                    .onChange(of: checkedList) { newValue in
                        signUpViewModel.isCheckedRequireItems = checkedList.contains(where: {$0 == .tos}) && checkedList.contains(where: {$0 == .personalInformation})
                        signUpViewModel.isSubscribedToService = checkedList.contains(where: {$0 == .serviceNotification})
                    }
                
                SignUpConsentItem(type: .tos, checkedList: $checkedList)
                    .padding(.top, 35)
                
                SignUpConsentItem(type: .personalInformation, checkedList: $checkedList)
                    .padding(.top, 30)
                
                SignUpConsentItem(type: .serviceNotification, checkedList: $checkedList)
                    .padding(.top, 30)
                    .padding(.bottom, 64 + nextButtonHeight)

            }
            
        }
    }
    
    var AllAgreeButton: some View {
        HStack{
            Text("전체 동의")
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let allAgreed: Bool = haveAllItem()
            Image(asset: allAgreed ? SharedAsset.checkCircleFill : SharedAsset.checkCircle)
                .resizable()
                .frame(width: 32, height: 32)
                .onTapGesture {
                    if allAgreed {
                        checkedList.removeAll()
                    } else {
                        checkedList = [.tos, .personalInformation, .serviceNotification]
                    }
                }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Methods
    
    private func haveAllItem() -> Bool {
        guard checkedList.contains(where: {$0 == .tos}) else {return false}
        guard checkedList.contains(where: {$0 == .personalInformation}) else {return false}
        guard checkedList.contains(where: {$0 == .serviceNotification}) else {return false}
        return true
    }
    
}

struct SignUpConsentItem: View {
    @State var isPresentDetail: Bool = false
    @Binding var checkedList: [TOSChecklist]
    var type: TOSChecklist
    var title: String
    
    init(type: TOSChecklist, checkedList: Binding<[TOSChecklist]>) {
        self._checkedList = checkedList
        self.type = type
        switch type {
        case .tos:
            self.title = "이용약관 동의"
        case .personalInformation:
            self.title = "개인정보 수집 및 이용 동의"
        case .serviceNotification:
            self.title = "서비스 소식 수신 동의"
        }
    }
    
    var body: some View {
        HStack(spacing: 5){
            
            switch(type){
            case .tos, .personalInformation:
                Text("(필수)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundColor(ColorSet.mainPurpleColor)
            case .serviceNotification:
                Text("(선택)")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                    .foregroundColor(Color(white: 0.6))
            }
            
            Text(title)
                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                .foregroundColor(Color(white: 0.6))
            
            if type == .tos || type == .personalInformation {
                Text("보기")
                    .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                    .foregroundColor(Color(white: 0.6))
                    .padding(.leading, 5)
                    .underline()
                    .onTapGesture {
                        isPresentDetail.toggle()
                    }
            }
            
            Spacer()
            
            CheckButton
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.leading, 20)
        .padding(.trailing, 24)
        .fullScreenCover(isPresented: $isPresentDetail, content: {
            switch type {
            case .tos:
                TOSDetailView()
            case .personalInformation:
                PersonalTOSDetailView()
            case .serviceNotification:
                EmptyView()
            }
        })
    }
    
    var CheckButton: some View {
        let contains = checkedList.contains(where: {$0 == type})
        return Image(asset: contains ? SharedAsset.checkFill : SharedAsset.check)
            .resizable()
            .frame(width: 23, height: 23)
            .onTapGesture {
                if contains {
                    checkedList.removeAll(where: {$0 == type})
                } else {
                    checkedList.append(type)
                }
            }
    }
        
}
