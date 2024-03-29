//
//  TermsOfServiceForSocialView.swift
//  Feature
//
//  Created by 제이콥 on 2/4/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import SwiftUI
import Shared
import Core
import Lottie

struct TermsOfServiceForSocialView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var manager: CustomizationManageViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    @State var isEntireChecked: Bool = false
    @State var isCheckedFirstItem: Bool = false
    @State var isCheckedSecondItem: Bool = false
    @State var isCheckedServiceNewsNotification: Bool = false
    @State var isTOSDone = false
    
    var body: some View {
        GeometryReader(content: { geometry in
            
            ZStack{
                
                LibraryColorSet.background.ignoresSafeArea()
                
                VStack(spacing: 0){
                    HStack{
                        SharedAsset.back.swiftUIImage
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .padding(.leading, 20)
                            .onTapGesture {
                                dismiss()
                            }
                        
                        Spacer()
                    }
                    .frame(height: 65)
                    
                    Text("서비스 이용약관에\n동의해주세요!")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 43)
                        .padding(.leading, 29)
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                        .lineSpacing(7)
                    
                    Spacer()
                    
                    HStack{
                        Text("전체 동의")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 20))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        //동의항목 선택 여부에 따라 전체동의 아이콘 변경 및 동작
                        if isCheckedFirstItem&&isCheckedSecondItem&&isCheckedServiceNewsNotification {
                            SharedAsset.checkCircleFill.swiftUIImage
                                .onTapGesture {
                                    isEntireChecked =
                                    !(isCheckedFirstItem&&isCheckedSecondItem&&isCheckedServiceNewsNotification)
                                    
                                    isCheckedFirstItem = isEntireChecked
                                    isCheckedSecondItem = isEntireChecked
                                    isCheckedServiceNewsNotification = isEntireChecked
                                }
                        }else {
                            SharedAsset.checkCircle.swiftUIImage
                                .onTapGesture {
                                    isEntireChecked =
                                    !(isCheckedFirstItem&&isCheckedSecondItem&&isCheckedServiceNewsNotification)
                                    
                                    isCheckedFirstItem = isEntireChecked
                                    isCheckedSecondItem = isEntireChecked
                                    isCheckedServiceNewsNotification = isEntireChecked
                                }
                        }
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    
                    SignUpConsentItem(type: .required, title: "이용약관 동의", isChecked: $isCheckedFirstItem)
                        .padding(.top, 48)
                    
                    SignUpConsentItem(type: .required, title: "개인정보 수집 및 이용 동의", isChecked: $isCheckedSecondItem)
                        .padding(.top, 35)
                    
                    
                    SignUpConsentItem(type: .select, title: "서비스 소식 수신 동의", isChecked: $isCheckedServiceNewsNotification)
                        .padding(.top, 35)
                        .padding(.bottom, 64)
                    
                    
                    Button(action: {
                        manager.isCheckedServiceNewsNotification = isCheckedServiceNewsNotification
                        isTOSDone = true
                        appCoordinator.rootPath.append(MumoryPage.startCustomization)
                    }, label: {
                        WhiteButton(title: "회원가입", isEnabled: isCheckedFirstItem && isCheckedSecondItem)
                            .padding(.bottom, 20)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                    })
                    .disabled(!(isCheckedFirstItem && isCheckedSecondItem))
                    
                }
            }
//            .navigationDestination(isPresented: $isTOSDone, destination: {
//                StartCostomizationView()
//                    .environmentObject(manager)
//            })
            .navigationBarBackButtonHidden()
 
        })
    }

}

//#Preview {
//    TermsOfServiceForSocialView()
//}
