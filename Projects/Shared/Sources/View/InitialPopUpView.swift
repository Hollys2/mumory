//
//  InitialPopUpView.swift
//  Shared
//
//  Created by 다솔 on 2024/03/07.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


public struct CreateMumoryPopUpView: View {
    
    @AppStorage("isFirstTimeLaunch") var isFirstTimeLaunch: Bool = {
        let defaultValue = true
        UserDefaults.standard.register(defaults: ["isFirstTimeLaunch": defaultValue])
        return UserDefaults.standard.bool(forKey: "isFirstTimeLaunch")
    }()
    
    public init() {}
    
    public var body: some View {
        Image(uiImage: SharedAsset.createMumoryInitialPopup.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 146, height: 35)
            .opacity(self.isFirstTimeLaunch ? 1: 0)
            .animation(.easeInOut(duration: 1), value: self.isFirstTimeLaunch)
            .onAppear {
                print("isFirstTimeLaunch: \(isFirstTimeLaunch)")
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
                    UserDefaults.standard.set(false, forKey: "isFirstTimeLaunch")
                }
            }
    }
}

public struct AppleMusicPopUpView: View {
    
//    @AppStorage("isFirstTimeLaunch") var isFirstTimeLaunch: Bool = true
    
    @Binding private var isShown: Bool
    
    public init(isShown: Binding<Bool>) {
        self._isShown = isShown
    }
    
    public var body: some View {
        HStack {
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
            
            Image(uiImage: SharedAsset.closeButtonPopup.image)
                .resizable()
                .frame(width: 17, height: 17)
                .padding(.trailing, 11)
                .onTapGesture {
                    UserDefaults.standard.set(Date(), forKey: "lastPopUpClosedDate")
                    self.isShown = false
                }
        }
        .frame(width: getUIScreenBounds().width - 40, height: 67)
        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
        .cornerRadius(10)
        .opacity(self.isShown ? 1 : 0)
    }
    
    func isAppleMusicPopUpShown() -> Bool {
        guard let firstLoginedDate = UserDefaults.standard.object(forKey: "firstLogined") as? Date else {
            return true
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month, .day, .second], from: firstLoginedDate, to: currentDate)
        
        if let monthsPassed = components.month, monthsPassed < 1 {
            if let daysPassed = components.day, daysPassed % 3 == 0 {
                if let lastPopUpClosedDate = UserDefaults.standard.object(forKey: "lastPopUpClosedDate") as? Date {
                    let timeSinceLastPopUpClosed = calendar.dateComponents([.day], from: lastPopUpClosedDate, to: currentDate)
                    if let daysPassedSinceLastPopUpClosed = timeSinceLastPopUpClosed.day, daysPassedSinceLastPopUpClosed >= 3 {
                        return true
                    } else {
                        return false
                    }
                } else {
                    return true // 최초 실행 시에는 팝업을 표시합니다.
                }
            }
        }
        return false
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

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        MonthlyStatPopUpView()
//    }
//}
