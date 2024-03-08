//
//  MumoryDetailScrollContentView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/27.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Core
import Shared

struct TagView: View {
    var text: String

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(uiImage: SharedAsset.tagMumoryDatail.image)
                .frame(width: 14, height: 14)

            Text(text)
                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 12))
                .foregroundColor(.white)
        }
        .padding(.leading, 8)
        .padding(.trailing, 10)
        .padding(.vertical, 7)
        .background(.white.opacity(0.2))
        .cornerRadius(14)
    }
}

struct MumoryDetailScrollContentView: View {
    
    @Binding var mumoryAnnotation: MumoryAnnotation
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            ZStack(alignment: .bottomLeading) {
                
//                Rectangle()
//                    .foregroundColor(.clear)
//                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
//                    .background(Color(red: 0.17, green: 0.17, blue: 0.17).opacity(0.2))
                
                SharedAsset.albumFilterMumoryDetail.swiftUIImage
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: UIScreen.main.bounds.width, height: 64)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09), location: 0.38),
                                Gradient.Stop(color: Color(red: 0.09, green: 0.09, blue: 0.09).opacity(0), location: 0.59),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 1.28),
                            endPoint: UnitPoint(x: 0.5, y: 0.56)
                        )
                    )
                
                
                VStack(spacing: 23) {
                    
                    Text("\(mumoryAnnotation.musicModel.title)")
                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 24))
                        .lineLimit(2)
                        .foregroundColor(.white)
                        .frame(width: 301, alignment: .leading)
                    
                    Text("\(mumoryAnnotation.musicModel.artist)")
                        .font(SharedFontFamily.Pretendard.light.swiftUIFont(size: 20))
                        .lineLimit(1)
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 301, alignment: .leading)
                }
                .offset(y: -4)
                .padding(.leading, 20)
            }
            
            VStack(spacing: 0) {
                
                Group {
                    // MARK: Profile & Info
                    HStack(spacing: 8) {
                        Image(uiImage: SharedAsset.profileMumoryDetail.image)
                            .resizable()
                            .frame(width: 38, height: 38)
                        
                        VStack(spacing: 0) {
                            Text("이르음음음음음")
                                .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer(minLength: 0)
                            
                            HStack(spacing: 0) {

                                Text(DateManager.formattedDate(date: self.mumoryAnnotation.date, isPublic: self.mumoryAnnotation.isPublic))
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                                    .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .onAppear {
                                    }
                                    .onChange(of: mumoryAnnotation.isPublic) { newValue in
//                                        self.dateString = DateManager.formattedDate(date: mumoryAnnotation.date, isPublic: newValue)
                                    }

                                if !self.mumoryAnnotation.isPublic {
                                    Image(uiImage: SharedAsset.lockMumoryDatail.image)
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                }
                                
                                Spacer(minLength: 0)
                                
                                Image(uiImage: SharedAsset.locationMumoryDatail.image)
                                    .resizable()
                                    .frame(width: 17, height: 17)
                                
                                Spacer().frame(width: 4)
                                
                                Text("\(self.mumoryAnnotation.locationModel.locationTitle)")
                                    .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                                    .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
//                                    .lineLimit(1)
                                    .frame(maxWidth: getUIScreenBounds().width * 0.27)
                                    .frame(height: 11, alignment: .leading)
                                    .fixedSize(horizontal: true, vertical: false)
                            } // HStack
                        } // VStack
                    } // HStack
                    .frame(height: 38)
                    .padding(.vertical, 55)
                    
                    if let tags = self.mumoryAnnotation.tags {
                        // MARK: Tag
                        HStack(spacing: 0) {
                            
                            ForEach(tags.indices, id: \.self) { index in
                                
                                TagView(text: "\(tags[index])")
                                
                                if index != 2 {
                                    Spacer().frame(width: 6)
                                }
                            }
                            
                            Spacer(minLength: 0)
                        } // HStack
                        .padding(.bottom, 25)
                    }
                    
                    if let content = self.mumoryAnnotation.content, !content.isEmpty {
                        // MARK: Content
                        Text("\(content)")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 15))
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 25)
                    }

                    
//                    if let imageURLs = self.mumoryAnnotation.imageURLs, !imageURLs.isEmpty {
                        // MARK: Image
//                    if let selectedMumoryAnnotaion = mumoryDataViewModel.selectedMumoryAnnotation, !(selectedMumoryAnnotaion.imageURLs ?? []).isEmpty {
                    if !(self.mumoryAnnotation.imageURLs ?? []).isEmpty {
                        MumoryDetailImageScrollView(mumoryAnnotation: self.mumoryAnnotation)
                            .frame(width: UIScreen.main.bounds.width - 40 + 10, height: UIScreen.main.bounds.width - 40)
                            .padding(.bottom, 25)
                    }
                }
                
                Spacer().frame(height: 25)
                
                MumoryDetailReactionBarView(mumoryAnnotation: self.$mumoryAnnotation, isOn: false)
                    .background(GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.frame(in: .global).minY) { minY in
//                            print("minY: \(minY)")
                            let isReactionBarShown = minY + 85 > UIScreen.main.bounds.height
                            
                            if appCoordinator.isReactionBarShown != isReactionBarShown {
                                appCoordinator.isReactionBarShown = isReactionBarShown
                            }
                        }
                    })
                
                Spacer().frame(height: 92)
                
                Group {
                    Text("같은 음악을 들은 친구 뮤모리")
                        .font(
                            Font.custom("Apple SD Gothic Neo", size: 18)
                                .weight(.semibold)
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer().frame(height: 35)
                    
                    MumoryDetailFriendMumoryScrollView()
                        .frame(width: UIScreen.main.bounds.width - 40 + 10, height: 162)
                    
                    Spacer().frame(height: 17)
                    
                    PageControl(page: self.$appCoordinator.page)
                    
                    Spacer().frame(height: 80)
                }
                
                Group {
                    Text("동일한 지역에서 뮤모리된 음악")
                        .font(
                            Font.custom("Apple SD Gothic Neo", size: 18)
                                .weight(.semibold)
                        )
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Spacer().frame(height: 17)

                    ForEach(0..<3) { _ in
                        MumoryDetailSameLocationMusicView()
                    }

                    Spacer().frame(height: 25)

                    Button(action: {

                    }, label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 330, height: 49)
                                .background(Color(red: 0.09, green: 0.09, blue: 0.09))
                                .cornerRadius(24)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .inset(by: 0.25)
                                        .stroke(.white, lineWidth: 0.5)
                                )

                            Text("더보기")
                                .font(Font.custom("Pretendard", size: 15))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                        }
                    })
                    
                    Spacer().frame(height: 100)
                }
            } // VStack
            .frame(width: UIScreen.main.bounds.width - 40)
            .padding(.horizontal, 20) // 배경색을 채우기 위함
            .background(Color(red: 0.09, green: 0.09, blue: 0.09))
            
            Spacer()
        } // VStack
        .ignoresSafeArea()
    }
}
