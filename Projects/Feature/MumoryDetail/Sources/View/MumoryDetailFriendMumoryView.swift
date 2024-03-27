//
//  MumoryDetailFriendMumoryView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared


struct MumoryDetailFriendMumoryScrollView: UIViewRepresentable {

//    typealias UIViewType = UIScrollView
    
//    @Binding var mumoryAnnotations: [MumoryAnnotation]
//    @Binding var annotationSelected: Bool
//    @Binding var page: Int
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()

        scrollView.delegate = context.coordinator

        let totalWidth = (UIScreen.main.bounds.width - 40 + 10) * CGFloat(mumoryDataViewModel.myMumorys.count)
        scrollView.contentSize = CGSize(width: totalWidth, height: 212)

        scrollView.isPagingEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.clipsToBounds = false
        scrollView.bounces = true

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        let hostingController = UIHostingController(rootView: MumoryDetailFriendMumoryScrollContentView()
            .environmentObject(mumoryDataViewModel))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 212)

        scrollView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear

        scrollView.addSubview(hostingController.view)

        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
//        let totalWidth = (UIScreen.main.bounds.width - 40 + 10) * CGFloat(mumoryDataViewModel.myMumorys.count)
//        uiView.contentSize = CGSize(width: totalWidth, height: 212)
//
//        uiView.subviews.forEach { $0.removeFromSuperview() }
//
//        let hostingController = UIHostingController(rootView: MumoryDetailFriendMumoryScrollContentView())
//        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 212)
//        hostingController.view.bounds = uiView.bounds
//
//        uiView.backgroundColor = .clear
//        hostingController.view.backgroundColor = .clear
//
//        uiView.addSubview(hostingController.view)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryDetailFriendMumoryScrollView {
    
    class Coordinator: NSObject {
        
        let parent: MumoryDetailFriendMumoryScrollView
        
        init(parent: MumoryDetailFriendMumoryScrollView) {
            self.parent = parent
            super.init()
        }
    }
}

extension MumoryDetailFriendMumoryScrollView.Coordinator: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x / (UIScreen.main.bounds.width - 30))
//        self.parent.page = page
        self.parent.appCoordinator.page = page
    }
}

struct MumoryDetailFriendMumoryScrollContentView: View {
    
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(self.mumoryDataViewModel.myMumorys, id: \.self) { mumory in
                MumoryDetailFriendMumoryView(mumory: mumory)
                    .padding(.horizontal, 5)
            }
        }
    }
}

struct MumoryDetailFriendMumoryView: View {
    
    let mumory: Mumory

    @State private var user: MumoriUser = MumoriUser()
    @State var date: String = ""
    
    @EnvironmentObject var appCoordinator: AppCoordinator
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 40, height: 212)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
            
            VStack(spacing: 0) {
                
                Spacer().frame(height: 25)
                
                HStack(spacing: 0) {
                    
                    AsyncImage(url: self.user.profileImageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                        default:
                            Color(red: 0.184, green: 0.184, blue: 0.184)
                        }
                    }
                    .frame(width: 38, height: 38)
                    .mask {Circle()}
                    .onTapGesture {
                        Task {
                            let friend = await MumoriUser(uId: self.user.uId)
                            appCoordinator.rootPath.append(MumoryPage.friend(friend: friend))
                        }
                    }
                    
                    Spacer().frame(width: 8)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("\(self.user.nickname)")
                            .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14)))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: true, vertical: false)
                        
                        Spacer(minLength: 0)
                        
                        HStack(spacing: 0) {
                            
                            Text(DateManager.formattedDate(date: self.mumory.date, isPublic: self.mumory.isPublic))
                                .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14)))
                                .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                            
                            if !self.mumory.isPublic {
                                Image(uiImage: SharedAsset.lockMumoryDatail.image)
                                    .resizable()
                                    .frame(width: 18, height: 18)
                            }
                            
                            Spacer()
                            
                            Group {
                                Image(uiImage: SharedAsset.locationMumoryDatail.image)
                                    .resizable()
                                    .frame(width: 17, height: 17)
                                
                                Spacer().frame(width: 5)
                                
                                Text(self.mumory.locationModel.locationTitle)
                                    .font((SharedFontFamily.Pretendard.medium.swiftUIFont(size: 14)))
                                    .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                                    .frame(maxWidth: getUIScreenBounds().width * 0.2846153)
                                    .frame(height: 11, alignment: .leading)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .onTapGesture {
                                //                            self.isMapViewShown = true
                            }
                        } // HStack
                    } // VStack
                    .frame(height: 38)
                }
                
                Spacer().frame(height: 23)
                
                HStack(spacing: 0) {
                    
                    VStack(spacing: 0) {
                        
                        if !(mumory.tags ?? []).isEmpty {
                            HStack(spacing: 6) {
                                
                                ForEach(mumory.tags ?? [], id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(SharedFontFamily.Pretendard.medium.swiftUIFont(size: 13))
                                        .foregroundColor(SharedAsset.mainColor.swiftUIColor)
                                }
                                
                                Spacer(minLength: 0)
                            }
                            
                            Spacer().frame(height: 12)
                        } else {
                            Color.clear
                        }
                        
                        Text(self.mumory.content ?? "")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                            .foregroundColor(.white)
                            .lineSpacing(1)
                            .lineLimit(2)
                            .frame(minWidth: UIScreen.main.bounds.width * 0.62051, maxWidth: .infinity, alignment: .topLeading)
                            .frame(height: 33, alignment: .topLeading)
                        
                        Spacer(minLength: 0)
                    }
                    .frame(minWidth: UIScreen.main.bounds.width * 0.62051)
                    .frame(height: 58)
                    
                    Spacer(minLength: 14)
                    
                    if !(mumory.imageURLs ?? []).isEmpty {
                        AsyncImage(url: URL(string: mumory.imageURLs![0])) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                            case .empty:
                                ProgressView()
                            default:
                                Color(red: 0.247, green: 0.247, blue: 0.247)
                            }
                        }
                        .frame(width: 58, height: 58)
                        .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .cornerRadius(5)
                        .overlay(
                            (mumory.imageURLs ?? []).count > 1 ? ZStack {
                                Circle()
                                    .foregroundColor(Color(red: 0.16, green: 0.16, blue: 0.16).opacity(0.6))
                                    .frame(width: 19, height: 19)
                                
                                Text("\((mumory.imageURLs ?? []).count)")
                                    .font(SharedFontFamily.Pretendard.bold.swiftUIFont(size: 11))
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(.white)
                            }
                                .offset(x: -2, y: -2)
                            : nil
                            
                            , alignment: .bottomTrailing
                        )
                    }
                } // HStack
                .frame(height: 58)
                
                Rectangle()
                    .fill(Color(red: 0.651, green: 0.651, blue: 0.651, opacity: 0.502))
                    .frame(width: getUIScreenBounds().width * 0.815, height: 0.5)
                    .padding(.top, 16)
                    .padding(.bottom, 13)
                
                HStack(spacing: 0) {
                    
                    Image(uiImage: SharedAsset.musicIconMumoryDetail2.image)
                        .resizable()
                        .frame(width: 14, height: 14)
                    
                    Spacer().frame(width: 5)
                    
                    Text("\(self.mumory.musicModel.artist)")
                        .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                        .foregroundColor(Color(red: 0.761, green: 0.761, blue: 0.761))
                        .lineLimit(1)
                    
                    Spacer().frame(width: 6)
                    
                    Text("\(self.mumory.musicModel.title)")
                        .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundColor(Color(red: 0.761, green: 0.761, blue: 0.761))
                        .lineLimit(1)
                    
                    Spacer()
                }
                
                Spacer(minLength: 0)
            } // VStack
            .frame(width: UIScreen.main.bounds.width - 40 - 32, height: 212)
            
        } // ZStack
        .onAppear {
            Task {
                self.user = await MumoriUser(uId: mumory.uId)
            }
        }
    }
}


struct PageControl: UIViewRepresentable {
    
    typealias UIViewType = UIPageControl
    
    @Binding var page: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let view = UIPageControl()

        view.currentPageIndicatorTintColor = UIColor(red: 0.64, green: 0.51, blue: 0.99, alpha: 1)
        view.pageIndicatorTintColor = UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1)
        view.numberOfPages = 3

        return view
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        DispatchQueue.main.async {
            uiView.currentPage = self.page
        }
    }
}

//struct MumoryDetailMenuSheetView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        let appCoordinator = AppCoordinator() // 또는 실제 AppCoordinator 인스턴스 생성
//        ZStack {
//            Color.black
//            MumoryDetailFriendMumoryView()
//            .environmentObject(appCoordinator)
//
//        }
//    }
//}
