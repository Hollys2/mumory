//
//  CustomizationView.swift
//  Feature
//
//  Created by 제이콥 on 12/26/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

public struct CustomizationView: View {
    public init(){}
    @Environment(\.dismiss) private var dismiss
    @StateObject var customizationObject: CustomizationViewModel = CustomizationViewModel()
    @State var isCustomizationDone = false
    public var body: some View {
        ZStack{
            ColorSet.background.ignoresSafeArea()
            
            GeometryReader(content: { geometry in
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
                    if customizationObject.nowStep == 0{
                        SelectGenreView()
                            .environmentObject(customizationObject)
                            .transition(AnyTransition.move(edge: .trailing))

                    }else if customizationObject.nowStep == 1 {
                        SelectTimeView()
                            .environmentObject(customizationObject)
                            .transition(AnyTransition.move(edge: .trailing))

                    }else if customizationObject.nowStep == 2 {
                        ProfileSettingView()
                            .environmentObject(customizationObject)
                            .transition(AnyTransition.move(edge: .trailing))

                    }
                })
                
            })
            
            //NextButton
            VStack{
                Spacer()
                WhiteButton(title: customizationObject.nowStep == 2 ? "완료" : "다음", isEnabled: customizationObject.getNextButtonEnabled())
                    .padding(.bottom, 20)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                    .onTapGesture {
                        if customizationObject.nowStep == 2 {
                            isCustomizationDone = true
                        }else{
                            withAnimation {
                                customizationObject.nowStep += 1
                            }
                        }
                    }
                    .disabled(!customizationObject.getNextButtonEnabled())
                    .shadow(color: .black, radius: 10, y: 8)
                    
            }
        }
        .navigationDestination(isPresented: $isCustomizationDone, destination: {
            LastOfCustomizationView()
                .environmentObject(customizationObject)
        })
        .navigationBarBackButtonHidden()
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading) {
                SharedAsset.back.swiftUIImage
                    .onTapGesture {
                        if customizationObject.nowStep == 0 {
                            dismiss()
                        }else{
                            withAnimation {
                                customizationObject.nowStep -= 1
                            }
                        }
                    }
            }
        })
    }
    private func setPadding(screen: CGSize) -> CGFloat {
        //width에 곱한 수 만큼 padding을 주어서 줄어들게 만듦
        //ex) 1번째 스탭이라면 3/4만큼 줄어들게 만들기
        if customizationObject.nowStep == 0{
            return screen.width * 3/4
        }else if customizationObject.nowStep == 1 {
            return screen.width * 2/4
        }else if customizationObject.nowStep == 2 {
            return screen.width * 1/4
        }
        return 0
    }
    
 
}

#Preview {
    CustomizationView()
}
