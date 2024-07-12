//
//  AuthTextField.swift
//  Feature
//
//  Created by 제이콥 on 12/9/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import SwiftUI
import Shared

struct RoundedTextField: View {
    // MARK: - Object lifecycle
    init(text: Binding<String>, placeHolder: String, fontSize: CGFloat) {
        self._text = text
        self.placeHolder = placeHolder
        self.fontSize = fontSize
    }
    // MARK: - Propoerties
    @Binding var text: String
    let placeHolder: String
    let fontSize: CGFloat
    
    // MARK: - View
    var body: some View {
        HStack(spacing: 0){
            TextField("", text: $text, prompt: Text(placeHolder)
                .foregroundColor(ColorSet.subGray)
                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: fontSize)))
            
            .frame(maxWidth: .infinity)
            .padding(.leading, 25)
            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: fontSize))
            .foregroundColor(.white)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            
            
            SharedAsset.xWhiteCircle.swiftUIImage
                .frame(width: 23, height: 23)
                .padding(.trailing, 17)
                .padding(.leading, 5)
                .opacity(text.count > 0 ? 1 : 0)
                .onTapGesture {
                    text = ""
                }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 18)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
        
        //        var prompt: Text {
        //            Text(placeHolder)
        //                .foregroundColor(ColorSet.subGray)
        //                .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: fontSize))
        //        }
    }
}

struct RoundedTextField_18: View {
    @Binding var text: String
    var prompt: String = ""
    
    var body: some View {
        HStack(spacing: 0){
            TextField("", text: $text, prompt: getPrompt())
                .frame(maxWidth: .infinity)
                .padding(.leading, 25)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 18))
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            
            SharedAsset.xWhiteCircle.swiftUIImage
                .frame(width: 23, height: 23)
                .padding(.trailing, 17)
                .padding(.leading, 5)
                .opacity(text.count > 0 ? 1 : 0)
                .onTapGesture {
                    text = ""
                }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 18)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
        
    }
    
    func getPrompt() -> Text {
        return Text(prompt)
            .foregroundColor(ColorSet.subGray)
            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
    }
}

struct AuthTextField_16: View {
    @Binding var text: String
    var prompt: String = ""
    
    var body: some View {
        HStack(spacing: 0){
            TextField("", text: $text, prompt: getPrompt())
                .frame(maxWidth: .infinity)
                .padding(.leading, 25)
                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                .foregroundColor(.white)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
            
            
            SharedAsset.xWhiteCircle.swiftUIImage
                .frame(width: 23, height: 23)
                .padding(.trailing, 17)
                .padding(.leading, 5)
                .opacity(text.count > 0 ? 1 : 0)
                .onTapGesture {
                    text = ""
                }
                .onAppear {
                    Task {
                        await fetchDetailSong(songID: "")
                    }
                }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 18)
        .padding(.bottom, 18)
        .background(Color(red: 0.24, green: 0.24, blue: 0.24))
        .clipShape(RoundedRectangle(cornerRadius: 35, style: .circular))
    }
    
    func getPrompt() -> Text {
        return Text(prompt)
            .foregroundColor(ColorSet.subGray)
            .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 16))
    }
}
