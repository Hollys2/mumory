//
//  SearchLocationView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/26.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI

struct SearchLocationView: View {
    @State private var text = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        if #available(iOS 16.0, *) {
            VStack {
                HStack {
                    ZStack(alignment: .leading) {
                        TextField("", text: $text)
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                            .padding(.leading, 15 + 23 + 7)
                            .padding(.trailing, 15 + 7)
                            .background(Color(red: 0.24, green: 0.24, blue: 0.24))
                            .foregroundColor(.white)
                            .cornerRadius(22)
                        
                        HStack(spacing: 7) {
                            Image(systemName: "magnifyingglass")
                                .frame(width: 23, height: 23)
                                .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            
                            if text.isEmpty {
                                Text("위치 검색")
                                    .font(Font.custom("Pretendard", size: 16))
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            } else {
//                                Spacer()
//                                Button(action: {
//                                }) {
//                                    Text("Tap me!")
//                                        .font(.title)
//                                        .padding()
//                                        .background(Color.blue)
//                                        .foregroundColor(.white)
//                                        .cornerRadius(10)
//                                }
//
                            }
                            
                        }
                        .padding(.leading, 15)
                    }
                    
                    
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("취소")
                            .font(
                                Font.custom("Pretendard", size: 16)
                                    .weight(.medium)
                            )
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .padding(.top, 28)
                
                VStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                    
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 0.3)
                        .foregroundColor(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7))
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                }
                .cornerRadius(15)
                .padding(.top, 15)
                .padding(.bottom, 15)
                
                HStack {
                    Text("최근 검색")
                    Spacer()
                    Text("전체 삭제")
                }
                
                ScrollView {
                    VStack {
                        ForEach(0..<100) { number in
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                                
                                Text("Row \(number)")
                                
                                Spacer()
                                
                                Image(systemName: "xmark")
                                    .foregroundColor(Color(red: 0.47, green: 0.47, blue: 0.47))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .cornerRadius(15)
                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
                
                Spacer()
                
            }
//            .presentationDetents([.fraction(0.985),
////                                              .height(800),
//            ])
            .padding(.horizontal, 20)
//            .frame(height: UIScreen.main.bounds.height)
            .cornerRadius(23)
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            .navigationBarHidden(true)
            .interactiveDismissDisabled()
//            .presentationDragIndicator(.visible)
            
        } else {
            // Fallback on earlier versions
        }
    }
}

struct SearchLocationView_Previews: PreviewProvider {
    static var previews: some View {
        SearchLocationView()
    }
}
