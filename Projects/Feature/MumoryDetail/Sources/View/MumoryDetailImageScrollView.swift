//
//  MumoryDetailImageScrollView.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared


@available(iOS 16.0, *)
struct MumoryDetailImageScrollView: UIViewRepresentable {

//    typealias UIViewType = UIScrollView
    
//    @State var imageURLs: [String]
    @State var mumoryAnnotation: Mumory
    
    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
        
    func makeUIView(context: Context) -> UIScrollView {
        
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator

        let totalWidth = (UIScreen.main.bounds.width - 40 + 10) * CGFloat((mumoryAnnotation.imageURLs ?? []).count)
        scrollView.contentSize = CGSize(width: totalWidth, height: 1)

        scrollView.isPagingEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.clipsToBounds = false
        scrollView.bounces = true

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

//        let hostingController = UIHostingController(rootView: MumoryDetailImageScrollContentView(imageURLs: self.imageURLs))
        let hostingController = UIHostingController(rootView: MumoryDetailImageScrollContentView(mumoryAnnotation: self.mumoryAnnotation))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: UIScreen.main.bounds.width - 40)

        scrollView.addSubview(hostingController.view)
        
        scrollView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear

        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
//        print("업데이트뷰: \(imageURLs.count)")
        
        //        if context.coordinator.oldImageURLs != self.mumoryAnnotation.imageURLs {
        
        let totalWidth = (UIScreen.main.bounds.width - 40 + 10) * CGFloat((self.mumoryDataViewModel.selectedMumoryAnnotation.imageURLs ?? []).count)
        uiView.contentSize = CGSize(width: totalWidth, height: 1)
        
        //            let hostingController = UIHostingController(rootView: MumoryDetailImageScrollContentView(imageURLs: self.imageURLs))
        let hostingController = UIHostingController(rootView: MumoryDetailImageScrollContentView(mumoryAnnotation: self.mumoryDataViewModel.selectedMumoryAnnotation))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: UIScreen.main.bounds.width - 40)
        
        uiView.subviews.forEach { $0.removeFromSuperview() }
        uiView.addSubview(hostingController.view)
        
        uiView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
        
        //            context.coordinator.oldImageURLs = self.mumoryAnnotation.imageURLs ?? []
        //        }
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryDetailImageScrollView {
    
    class Coordinator: NSObject {
        
        let parent: MumoryDetailImageScrollView
        var oldImageURLs: [String] = []
        
        init(parent: MumoryDetailImageScrollView) {
            self.parent = parent
            super.init()
        }
    }
}

extension MumoryDetailImageScrollView.Coordinator: UIScrollViewDelegate {
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//           let pageWidth: CGFloat = 330.0 // 페이지의 너비
//
//           // 사용자가 놓은 스크롤의 최종 위치를 페이지 단위로 계산하여 목표 위치(targetContentOffset)를 조정
//           let targetX = targetContentOffset.pointee.x
//           let contentWidth = scrollView.contentSize.width
//           let newPage = round(targetX / pageWidth)
//           let xOffset = min(newPage * pageWidth, contentWidth - scrollView.bounds.width) // 너무 많이 이동하지 않도록 bounds 체크
//
//           targetContentOffset.pointee = CGPoint(x: xOffset, y: 0)
//       }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.x)
    }

}

struct MumoryDetailImageScrollContentView: View {
    
//    @State var imageURLs: [String]
    var mumoryAnnotation: Mumory
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach((mumoryAnnotation.imageURLs ?? []).indices, id: \.self) { index in
                MumoryDetailImageView(url: (mumoryAnnotation.imageURLs ?? [])[index], count: (mumoryAnnotation.imageURLs ?? []).count, index: Int(index))
                    .padding(.horizontal, 5)
            }
        }
        .background(.clear)
    }
}

struct MumoryDetailImageView: View {
    
    let url: String
    let count: Int
    let index: Int
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                .background(
                    AsyncImage(url: URL(string: url)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        case .failure:
                            Text("Failed to load image")
                        @unknown default:
                            Text("Unknown state")
                        }
                    }
                )
                .background(Color(red: 0.184, green: 0.184, blue: 0.184))
                
            
            if count != 1 {
                HStack(alignment: .center, spacing: 10) {
                    Text("\(index + 1) / \(count)")
                        .font(
                            Font.custom("Pretendard", size: 12)
                                .weight(.semibold)
                        )
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(.black.opacity(0.7))
                .cornerRadius(10.5)
                .cornerRadius(14)
                .offset(x: -13, y: 15)
            }
        }
        .background(.red)
    }
}
