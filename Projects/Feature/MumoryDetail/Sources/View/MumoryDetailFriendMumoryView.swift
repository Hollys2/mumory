//
//  MumoryDetailFriendMumoryView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared

@available(iOS 16.0, *)
struct MumoryDetailFriendMumoryScrollView: UIViewRepresentable {

//    typealias UIViewType = UIScrollView
    
//    @Binding var mumoryAnnotations: [MumoryAnnotation]
//    @Binding var annotationSelected: Bool
//    @Binding var page: Int
    
//    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()

        scrollView.delegate = context.coordinator

        let totalWidth = (UIScreen.main.bounds.width - 40 + 10) * CGFloat(3)
        scrollView.contentSize = CGSize(width: totalWidth, height: 1)

        scrollView.isPagingEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.clipsToBounds = false
        scrollView.bounces = true

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        let hostingController = UIHostingController(rootView: MumoryDetailFriendMumoryScrollContentView())
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: 162)

        //        scrollView.backgroundColor = .red
        hostingController.view.backgroundColor = .clear

        scrollView.addSubview(hostingController.view)

        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
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

@available(iOS 16.0, *)
struct MumoryDetailFriendMumoryScrollContentView: View {
    
//    @Binding var mumoryAnnotations: [MumoryAnnotation]
    
    var body: some View {
        HStack(spacing: 0) {
            MumoryDetailFriendMumoryView()
                .padding(.horizontal, 5)
            MumoryDetailFriendMumoryView()
                .padding(.horizontal, 5)
            MumoryDetailFriendMumoryView()
                .padding(.horizontal, 5)
        }
    }
}

struct MumoryDetailFriendMumoryView: View {
    
    @State var date: String = ""

    @EnvironmentObject var appCoordinator: AppCoordinator
    
    var body: some View {
        ZStack(alignment: .top) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 40, height: 162)
                .background(Color(red: 0.16, green: 0.16, blue: 0.16))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .inset(by: 0.25)
                        .stroke(Color(red: 0.65, green: 0.65, blue: 0.65).opacity(0.7), lineWidth: 0.5)
                )
            
            VStack(spacing: 0) {
                Spacer().frame(height: 21)
                
                HStack(alignment: .center, spacing: 0) {
                    Spacer().frame(width: 17)
                    
                    Image(uiImage: SharedAsset.profileMumoryDetail.image)
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Spacer().frame(width: 7)
                    
                    Text("이르음음음음음")
                        .font(
                            Font.custom("Pretendard", size: 14)
                                .weight(.semibold)
                        )
                        .foregroundColor(.white)
                        .frame(width: 75, height: 10, alignment: .leading)
                    
                    Text(" ・ 10월 2일")
                        .font(Font.custom("Pretendard", size: 13))
                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                    
                    Spacer()
                    
                    Image(uiImage: SharedAsset.locationMumoryDatail.image)
                        .frame(width: 15, height: 15)
                    
                    Spacer().frame(width: 4)
                    
                    Text("반포한강공원반포한강공원")
                        .font(Font.custom("Pretendard", size: 13))
                        .lineLimit(1)
                        .foregroundColor(Color(red: 0.72, green: 0.72, blue: 0.72))
                        .frame(width: 99, height: 12, alignment: .leading)
                    
                    Spacer().frame(width: 17)
                } // HStack
                
                Spacer().frame(height: 16)
                
                HStack(spacing: 0) {
                    Spacer().frame(width: 17)
                    
                    VStack(spacing: 14) {
                        Text("내용내 용내 용내용옹내 용일 상일 상일상내용내용내용 내용옹내용일상 일상일상 내용내용내용 내용옹 내용 일상내용 내용옹내용 일상일상일상내용내용내용")
                            .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                        //                                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                            .foregroundColor(.white)
                            .frame(height: 48, alignment: .leading)
                        
                        HStack(spacing: 0) {
                            Image(uiImage: SharedAsset.musicIconMumoryDetail.image)
                                .frame(width: 14, height: 14)
                            
                            Spacer().frame(width: 5)
                            
                            Text("Super Shy")
                                .font(SharedFontFamily.Pretendard.semiBold.swiftUIFont(size: 14))
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            
                            Spacer().frame(width: 6)
                            
                            Text("NewJeans")
                                .font(SharedFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                                .foregroundColor(Color(red: 0.64, green: 0.51, blue: 0.99))
                            
                            Spacer()
                        }
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.56)
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 75, height: 75)
                        .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                        .cornerRadius(5)
                    
                    Spacer().frame(width: 17)
                } // HStack
                
                Spacer().frame(height: 27)
            } // VStack
            .frame(width: UIScreen.main.bounds.width - 40, height: 212)
        } // ZStack
    }
}

struct MumoryDetailFriendMumoryView_Previews: PreviewProvider {
    static var previews: some View {
        MumoryDetailFriendMumoryScrollContentView()
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
