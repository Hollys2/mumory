//
//  InitialPopUpView.swift
//  Shared
//
//  Created by 다솔 on 2024/03/07.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import MusicKit


public struct CreateMumoryPopUpView: View {
    
    @AppStorage("isFirstTimeLaunch") var isFirstTimeLaunch: Bool = {
        let defaultValue = true
        UserDefaults.standard.register(defaults: ["isFirstTimeLaunch": defaultValue])
        return UserDefaults.standard.bool(forKey: "isFirstTimeLaunch")
    }()
    
    public init() {}
    
    public var body: some View {
        if self.isFirstTimeLaunch {
            Image(uiImage: SharedAsset.createMumoryInitialPopup.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 146, height: 35)
                .animation(.easeInOut(duration: 1), value: self.isFirstTimeLaunch)
                .offset(y: -41)
                .onAppear {
                    print("isFirstTimeLaunch: \(isFirstTimeLaunch)")
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                        UserDefaults.standard.set(false, forKey: "isFirstTimeLaunch")
                    }
                }
        }
    }
}

public struct AppleMusicPopUpView: View {
    
    @State var musicSubscription: MusicSubscription?
    @State var isShowingAppleMusicOffer = false
    @State var isShown = UserDefaults.standard.bool(forKey: "appleMusicPopUpShown")
    
    var offerOptions: MusicSubscriptionOffer.Options {
        var offerOptions = MusicSubscriptionOffer.Options()
//        offerOptions.itemID =
        return offerOptions
    }
    
    public init() {}
    
    public var body: some View {
        HStack {
            Group {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Apple Music 이용권이 없습니다.")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                        .foregroundColor(.black)
                    
                    Text("지금 바로 구독하고 뮤모리를 이용해보세요.")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundColor(.black)
                }
                .padding(.leading, 20)
                .padding(.vertical, 18)
                
                Spacer()
            }
            .onTapGesture {
                self.isShowingAppleMusicOffer = true
            }
            
            Image(uiImage: SharedAsset.closeButtonPopup.image)
                .resizable()
                .frame(width: 17, height: 17)
                .padding(.trailing, 11)
                .onTapGesture {
                    UserDefaults.standard.setValue(false, forKey: "appleMusicPopUpShown")
                    self.isShown = false
                }
        }
        .frame(width: getUIScreenBounds().width - 40, height: 67)
        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
        .cornerRadius(10)
        .opacity(!(self.musicSubscription?.canPlayCatalogContent ?? false) && self.isShown ? 1 : 0)
        .musicSubscriptionOffer(isPresented: $isShowingAppleMusicOffer, options: offerOptions)
    }
}

public struct MonthlyStatGenrePopUpView: View {
    
    @State private var isShown: Bool = true
    
    public init() {}
    
    public var body: some View {
        Image(uiImage: SharedAsset.monthlyStatPopup.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 242, height: 28)
            .opacity(self.isShown ? 1: 0)
            .animation(.easeInOut(duration: 1), value: self.isShown)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 8) {
                    self.isShown = false
                }
            }
    }
}
