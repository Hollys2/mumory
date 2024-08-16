//
//  MumoryCarouselUIViewRepresentable.swift
//  Feature
//
//  Created by 다솔 on 2024/03/07.
//  Copyright © 2024 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct MumoryCardView: View {
    
    @Binding var isAnnotationTapped: Bool
    
    @EnvironmentObject private var currentUserViewModel: CurrentUserViewModel
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .onTapGesture {
                    self.isAnnotationTapped = false
                }
            
            VStack(spacing: 16) {
                MumoryCarouselUIViewRepresentable(mumoryAnnotations: self.currentUserViewModel.mumoryViewModel.mumoryCarouselAnnotations)
                    .frame(height: 418)
                    .padding(.horizontal, (UIScreen.main.bounds.width - (getUIScreenBounds().width == 375 ? 296 : 310)) / 2 - 10)
                
                Button(action: {
                    self.isAnnotationTapped = false
                }, label: {
                    SharedAsset.closeButtonMumoryPopup.swiftUIImage
                        .resizable()
                        .frame(width: 26, height: 26)
                })
            }
            .offset(y: 10)
        }
    }
}

struct MumoryCarouselUIViewRepresentable: UIViewRepresentable {
    
    var mumoryAnnotations: [Mumory]
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        
        scrollView.delegate = context.coordinator
        
        let totalWidth = getUIScreenBounds().width == 375 ? (296 + 20) * CGFloat(mumoryAnnotations.count) : (310 + 20) * CGFloat(mumoryAnnotations.count)
        scrollView.contentSize = CGSize(width: totalWidth, height: 1)
        
        scrollView.isPagingEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.clipsToBounds = false
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        let hostingController = UIHostingController(rootView: MumoryList(mumoryAnnotations: mumoryAnnotations))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 418)
        
        scrollView.addSubview(hostingController.view)
        hostingController.view.backgroundColor = .clear
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryCarouselUIViewRepresentable {
    
    class Coordinator: NSObject {
        
        let parent: MumoryCarouselUIViewRepresentable
        
        init(parent: MumoryCarouselUIViewRepresentable) {
            self.parent = parent
            super.init()
        }
    }
}

extension MumoryCarouselUIViewRepresentable.Coordinator: UIScrollViewDelegate {}


struct MumoryList: View {
    
    let mumoryAnnotations: [Mumory]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(mumoryAnnotations.indices, id: \.self) { index in
                MumoryCard(mumory: mumoryAnnotations[index], selectedIndex: index)
                    .padding(.horizontal, 10)
            }
        }
    }
}


struct MumoryCard: View {
    
    let mumory: Mumory
    
    @EnvironmentObject var appCoordinator: AppCoordinator

    let selectedIndex: Int
    
    var body: some View {
        ZStack {
            
            VStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: getUIScreenBounds().width == 375 ? 296 : 310, height: getUIScreenBounds().width == 375 ? 296 : 310)
                    .background(
                        AsyncImage(url: mumory.song.artworkUrl) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: getUIScreenBounds().width == 375 ? 296 : 310, height: getUIScreenBounds().width == 375 ? 296 : 310)
                            default:
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(width: getUIScreenBounds().width == 375 ? 296 : 310, height: getUIScreenBounds().width == 375 ? 296 : 310)
                                    .background(Color(red: 0.25, green: 0.25, blue: 0.25))
                                    .overlay(
                                        Rectangle()
                                            .inset(by: 0.5)
                                            .stroke(.white, lineWidth: 1)
                                    )
                                    .overlay(
                                        SharedAsset.defaultArtwork.swiftUIImage
                                            .resizable()
                                            .frame(width: 103, height: 124)
                                            .background(Color(red: 0.47, green: 0.47, blue: 0.47))
                                    )
                            }
                        }
                    )
                    .cornerRadius(15)
                
                Spacer()
            }
            
            ZStack(alignment: .topLeading) {
                
                VStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: getUIScreenBounds().width == 375 ? 296 : 310, height: getUIScreenBounds().width == 375 ? 296 : 310)
                        .background(
                            LinearGradient(
                                stops: [
                                    Gradient.Stop(color: Color(red: 0.64, green: 0.52, blue: 0.98).opacity(0), location: 0.35),
                                    Gradient.Stop(color: Color(red: 0.64, green: 0.52, blue: 0.98), location: 0.85),
                                ],
                                startPoint: UnitPoint(x: 0.5, y: 0.74),
                                endPoint: UnitPoint(x: 0.5, y: 1)
                            )
                        )
                        .cornerRadius(15)
                    
                    Spacer()
                }
                
                if !self.mumory.isPublic {
                    SharedAsset.lockMumoryPopup.swiftUIImage
                        .resizable()
                        .frame(width: 34, height: 34)
                        .offset(x: 16, y: 16)
                }
            }
            
            VStack(spacing: 0) {
                
                Spacer()
                
                HStack(spacing: 5)  {
                    Text(DateManager.formattedDate(date: self.mumory.date, dateFormat: "yyyy.M.d"))
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundColor(.white)
                    
                    Spacer(minLength: 59)
                    
                    SharedAsset.locationMumoryPopup.swiftUIImage
                        .resizable()
                        .frame(width: 17, height: 17)
                    
                    Text("\(mumory.location.locationTitle)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                        .foregroundColor(.white)
                        .lineLimit(1)
                } // HStack
                .padding(.horizontal, 16)
                
                // MARK: - Underline
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 284, height: 0.5)
                    .background(.white.opacity(0.5))
                    .padding(.top, 11)
                
                HStack {
                    VStack(spacing: 8) {
                        Text("\(mumory.song.title)")
                            .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                            .foregroundColor(.white)
                            .frame(width: 199, height: 13, alignment: .topLeading)
                            .lineLimit(1)
                        
                        Text("\(mumory.song.artist)")
                            .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 15))
                            .foregroundColor(.white)
                            .frame(width: 199, height: 13, alignment: .topLeading)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        self.appCoordinator.rootPath.append(MumoryPage.mumoryDetailView(mumory: self.mumory))
                    }, label: {
                        SharedAsset.nextButtonMumoryPopup.swiftUIImage
                            .resizable()
                            .frame(width: 48, height: 48)
                    })
                } // HStack
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 18)
            } // VStack
        } // ZStack
        .frame(width: getUIScreenBounds().width == 375 ? 296 : 310, height: getUIScreenBounds().width == 375 ? 407 : 418)
        .background(Color(red: 0.64, green: 0.51, blue: 0.99))
        .cornerRadius(15)
    }
}
