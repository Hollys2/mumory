//
//  TestView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/27.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI

public struct TestView: View {
    @State private var selectedDate = Date()
    
    public init(){}
    
    public var body: some View {
        VStack {
            DatePicker("Select a date", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(GraphicalDatePickerStyle())
                        .accentColor(.orange)
                        .frame(maxHeight: 400)
                }
//        TabView {
//            OnBoardingView(title: "Hello1", description: "It's me1.")
//            OnBoardingView(title: "Hello2", description: "It's me2.")
//            OnBoardingView(title: "Hello3", description: "It's me3.")
//        }
//        .tabViewStyle(.page)
    }
}

struct OnBoardingView: View {
    
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            
            Text(title)
                .font(.title).bold()
            
            Text(description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 50)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
