//
//  SocialView.swift
//  Feature
//
//  Created by 다솔 on 2024/01/03.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct SocialMenuSheetView: View {
    
    @Binding private var translation: CGSize
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @GestureState var dragAmount = CGSize.zero
    
    public init(translation: Binding<CGSize>) {
        self._translation =  translation
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 9)
            
            SharedAsset.dragIndicator.swiftUIImage
                .resizable()
                .frame(width: 47, height: 4)

            Spacer().frame(height: 9)

            VStack(spacing: 0) {
                ZStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 54)
                        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                    
                    HStack(spacing: 0) {
                        Spacer().frame(width: 20)
                        
                        SharedAsset.mumoryButtonSocial.swiftUIImage
                            .resizable()
                            .frame(width: 30, height: 30)
                        
                        Spacer().frame(width: 10)
                        
                        Text("뮤모리 보기")
                            .font(
                                Font.custom("Pretendard", size: 15)
                                    .weight(.medium)
                            )
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.appCoordinator.isSocialMenuSheetViewShown = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.appCoordinator.rootPath.append(0)
                    }
                }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame( height: 0.3)
                    .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.5))
                
                Button(action: {
                    
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 54)
                            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                        
                        HStack(spacing: 0) {
                            Spacer().frame(width: 20)
                            
                            SharedAsset.shareMumoryDetailMenu.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            Spacer().frame(width: 10)
                            
                            Text("공유하기")
                                .font(
                                    Font.custom("Pretendard", size: 15)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                }
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(height: 0.5)
                    .background(Color(red: 0.38, green: 0.38, blue: 0.38).opacity(0.5))
                
                Button(action: {
                    
                }) {
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .frame(height: 54)
                            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                        
                        HStack(spacing: 0) {
                            Spacer().frame(width: 20)
                            
                            SharedAsset.complainMumoryDetailMenu.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                            
                            Spacer().frame(width: 10)
                            
                            Text("신고")
                                .font(
                                    Font.custom("Pretendard", size: 15)
                                        .weight(.medium)
                                )
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                    }
                }
            } // VStack
            .cornerRadius(15)
            .padding(.horizontal, 9)
            
            Spacer().frame(height: 9)
        }
        .frame(width: UIScreen.main.bounds.width - 14, height: 190)
        .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        .cornerRadius(15)
    }
}

struct SocialItemView: View {
    
    @State private var isMenuShown: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        // MARK: Profile
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(uiImage: SharedAsset.profileMumoryDetail.image)
                    .resizable()
                    .frame(width: 38, height: 38)
                
                VStack(spacing: 5.25) {
                    Text("이르음음음음음")
                        .font(
                            Font.custom("Pretendard", size: 16)
                                .weight(.medium)
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 0) {
                        Text("10월 12일 ・ ")
                            .font(
                                Font.custom("Pretendard", size: 15)
                                    .weight(.medium)
                            )
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        
                        Image(uiImage: SharedAsset.lockMumoryDatail.image)
                            .resizable()
                            .frame(width: 18, height: 18)
                        
                        Spacer()
                        
                        Image(uiImage: SharedAsset.locationMumoryDatail.image)
                            .resizable()
                            .frame(width: 17, height: 17)
                        
                        Spacer().frame(width: 4)
                        
                        Text("반포한강공원반포한강공원")
                            .font(
                                Font.custom("Pretendard", size: 15)
                                    .weight(.medium)
                            )
                            .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            .frame(width: 106, height: 11, alignment: .leading)
                    } // HStack
                } // VStack
            } // HStack
            
            Spacer().frame(height: 13)
            
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .background(
                        SharedAsset.artworkSample.swiftUIImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                            .clipped()
                    )
                    .cornerRadius(15)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: .black.opacity(0.4), location: 0.00),
                                Gradient.Stop(color: .black.opacity(0), location: 0.26),
                                Gradient.Stop(color: .black.opacity(0), location: 0.63),
                                Gradient.Stop(color: .black.opacity(0.4), location: 0.96),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .cornerRadius(15)
                
                // MARK: Title & Menu
                HStack(spacing: 0) {
                    SharedAsset.musicIconSocial.swiftUIImage
                        .resizable()
                        .frame(width: 14, height: 14)
                    
                    Spacer().frame(width: 6)
                    
                    Text("Hollywood")
                        .font(
                            Font.custom("Pretendard", size: 14)
                                .weight(.bold)
                        )
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.white)
                    
                    Spacer().frame(width: 8)
                    
                    Text("검정치마")
                        .font(
                            Font.custom("Pretendard", size: 14)
                                .weight(.light)
                        )
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        self.isMenuShown = true
                        
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.appCoordinator.isSocialMenuSheetViewShown = true
                        }
                    }, label: {
                        SharedAsset.menuButtonSocial.swiftUIImage
                            .resizable()
                            .frame(width: 22, height: 22)
                    })
                } // HStack
                .padding(.top, 17)
                .padding(.leading, 20)
                .padding(.trailing, 17)
                
                VStack(spacing: 14) {
                    // MARK: Image Counter & Tag
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            HStack(spacing: 4) {
                                SharedAsset.imageCountSocial.swiftUIImage
                                    .frame(width: 18, height: 18)
                                Text("2")
                                    .font(
                                        Font.custom("Pretendard", size: 15)
                                            .weight(.medium)
                                    )
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 48, height: 28)
                            .background(
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: 48, height: 28)
                                    .background(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.6))
                                    .cornerRadius(15)
                            )
                            
                            HStack(alignment: .center, spacing: 5) {
                                SharedAsset.tagMumoryDatail.swiftUIImage
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                
                                Text("태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그")
                                    .font(
                                        Font.custom("Pretendard", size: 12)
                                            .weight(.semibold)
                                    )
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .padding(.leading, 8)
                            .padding(.trailing, 10)
                            .padding(.vertical, 7)
                            .background(.white.opacity(0.25))
                            .cornerRadius(14)
                            
                            HStack(alignment: .center, spacing: 5) {
                                SharedAsset.tagMumoryDatail.swiftUIImage
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                
                                Text("태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그")
                                    .font(
                                        Font.custom("Pretendard", size: 12)
                                            .weight(.semibold)
                                    )
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .padding(.leading, 8)
                            .padding(.trailing, 10)
                            .padding(.vertical, 7)
                            .background(.white.opacity(0.25))
                            .cornerRadius(14)
                            
                            HStack(alignment: .center, spacing: 5) {
                                SharedAsset.tagMumoryDatail.swiftUIImage
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                
                                Text("태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그태그")
                                    .font(
                                        Font.custom("Pretendard", size: 12)
                                            .weight(.semibold)
                                    )
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            .padding(.leading, 8)
                            .padding(.trailing, 10)
                            .padding(.vertical, 7)
                            .background(.white.opacity(0.25))
                            .cornerRadius(14)
                            
                            Spacer()
                        } // HStack
     
                    } // ScrollView
                  
              
//                    .frame(maxWidth: .infinity)
                    //                .background(
                    //                    Rectangle()
                    //                      .foregroundColor(.clear)
                    //                      .frame(height: 44)
                    //                      .background(.white)
                    //                      .blur(radius: 3)
                    //                )
                    
                    // MARK: Content
                    HStack(spacing: 0) {
                        Text("내용 내용내용 내용내용내용 내용내용내용내용내용 내용내용내용내용내용내용")
                            .font(
                                Font.custom("Pretendard", size: 13)
                                    .weight(.medium)
                            )
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .frame(width: (UIScreen.main.bounds.width - 20) * 0.66 * 0.87, alignment: .leading)
                        
                        Spacer()

                        // 컨텐트 너비에 따른 조건문 추가 예정
                        Text("더보기")
                            .font(
                                Font.custom("Pretendard", size: 11)
                                    .weight(.medium)
                            )
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                            .frame(width: (UIScreen.main.bounds.width - 20) * 0.66 * 0.13, alignment: .leading)
                    }
                } // VStack
                .frame(width: (UIScreen.main.bounds.width - 20) * 0.66)
                .padding(.leading, 22)
                //            .background(
                //                GeometryReader{ g in
                //                    Color.clear
                //                        .onAppear {
                //                            print("g.size.height: \(g.size.height)")
                //                        }
                //                }
                //            )
                .offset(y: UIScreen.main.bounds.width - 20 - 57 - 22)
                
                // MARK: Heart & Comment
                VStack(spacing: 12) {
                    Button(action: {
                        
                    }, label: {
                        SharedAsset.heartButtonSocial.swiftUIImage
                            .frame(width: 42, height: 42)
                            .background(.white.opacity(0.1))
                    })
                    
                    Text("10")
                        .font(
                            Font.custom("Pretendard", size: 15)
                                .weight(.medium)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        
                    }, label: {
                        SharedAsset.commentButtonSocial.swiftUIImage
                            .frame(width: 42, height: 42)
                    })
                    
                    //                Text("10")
                    //                  .font(
                    //                    Font.custom("Pretendard", size: 15)
                    //                      .weight(.medium)
                    //                  )
                    //                  .multilineTextAlignment(.center)
                    //                  .foregroundColor(.white)
                    
                }
                .offset(x: UIScreen.main.bounds.width - 20 - 42 - 17)
                .alignmentGuide(VerticalAlignment.top) { d in
                    d[.bottom] - (UIScreen.main.bounds.width - 20) + 27
                }
            } // ZStack
            Spacer().frame(height: 40)
        } // VStack
        .background(
            GeometryReader{ g in
                Color.clear
                    .onAppear {
                        print("g.size.height: \(g.size.height)")
                    }
            }
        )
        //        .sheet(isPresented: self.$isMenuShown, content: {
        //            SocialMenuSheetView()
        //                .padding(.horizontal, 9)
        //                .presentationDetents([.height(190)])
        //                .background(Color(red: 0.12, green: 0.12, blue: 0.12))
        //        })
        
    }
}

public struct SocialView: View {
    
    @State private var isAddFriendNotification: Bool = false
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    @State private var translation: CGSize = .zero
    
    public init() {}
    
    public var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack(alignment: .top, spacing: 0) {
                        Spacer().frame(width: 10)
                        
                        Text("소셜")
                            .font(
                                Font.custom("Pretendard", size: 24)
                                    .weight(.semibold)
                            )
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button(action: {
                            
                        }) {
                            SharedAsset.searchButtonSocial.swiftUIImage
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        
                        Spacer().frame(width: 12)
                        
                        Button(action: {
                            
                        }) {
                            (self.isAddFriendNotification ? SharedAsset.addFriendOnSocial.swiftUIImage : SharedAsset.addFriendOffSocial.swiftUIImage)
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        
                        Spacer().frame(width: 12)
                        
                        Button(action: {
                            
                        }) {
                            Image("UserProfile_BT")
                                .frame(width: 30, height: 30)
                                .background(
                                    Image("PATH_TO_IMAGE")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 30, height: 30)
                                        .clipped()
                                )
                                .overlay(
                                    Rectangle()
                                        .stroke(.white, lineWidth: 1)
                                )
                        }
                        
                        Spacer().frame(width: 10)
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    .padding(.top, 19 + appCoordinator.safeAreaInsetsTop)
                    
                    Spacer().frame(height: 51)
                    
                    LazyVStack(spacing: 0) {
                        ForEach(0..<1) { _ in
                            SocialItemView()
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width - 20)
                    
                } // VStack
            } // ScrollView
        }
        .padding(.horizontal, 10)
        .background(Color(red: 0.09, green: 0.09, blue: 0.09))
        .preferredColorScheme(.dark)
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
            .environmentObject(AppCoordinator())
    }
}
