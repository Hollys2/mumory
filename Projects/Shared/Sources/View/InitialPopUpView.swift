//
//  InitialPopUpView.swift
//  Shared
//
//  Created by 다솔 on 2024/03/07.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI


public struct CreateMumoryPopUpView: View {
    
    public init() {}
    
    public var body: some View {
        Image(uiImage: SharedAsset.createMumoryInitialPopup.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 146, height: 35)
    }
    
    private func isPopUpShown() -> Bool {
        guard let lastViewedDate = UserDefaults.standard.object(forKey: "lastLogined") as? Date else {
            return true
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastViewedDate, to: currentDate)
        
        if let monthsPassed = components.month, monthsPassed >= 1 {
            return false
        }
        
        if let daysPassed = components.day, daysPassed >= 3 {
            return true
        } else {
            return false
        }
    }
}

public struct AppleMusicPopUpView: View {
    
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
                    self.isShown = false
                    
                    UserDefaults.standard.set(Date(), forKey: "lastPopUpClosedDate")
                }
        }
        .frame(width: getUIScreenBounds().width - 40, height: 67)
        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
        .cornerRadius(10)
        .opacity(self.isAppleMusicPopUpShown() ? 1 : 0)
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
                    let timeSinceLastPopUpClosed = calendar.dateComponents([.second], from: lastPopUpClosedDate, to: currentDate)
                    print("FUCK: \(timeSinceLastPopUpClosed.second)")
                    if let daysPassedSinceLastPopUpClosed = timeSinceLastPopUpClosed.second, daysPassedSinceLastPopUpClosed >= 1 {
                        return false
                    } else {
                        return true
                    }
                } else {
                    return true // 최초 실행 시에는 팝업을 표시합니다.
                }
            }
        }
        return false
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {

//    }
//}
