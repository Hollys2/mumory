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
    
//    @Binding var mumoryAnnotations: [MumoryAnnotation]
//    @Binding var annotationSelected: Bool
    
//    @EnvironmentObject var mumoryDataViewModel: MumoryDataViewModel
    
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

        let hostingController = UIHostingController(rootView: MumoryDetailImageScrollContentView())
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: UIScreen.main.bounds.width - 40)

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

extension MumoryDetailImageScrollView {
    
    class Coordinator: NSObject {
        
        let parent: MumoryDetailImageScrollView
        
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

@available(iOS 16.0, *)
struct MumoryDetailImageScrollContentView: View {
    
//    @Binding var mumoryAnnotations: [MumoryAnnotation]
    
    var body: some View {
        HStack(spacing: 0) {
            MumoryDetailImageView()
                .padding(.horizontal, 5)
            MumoryDetailImageView()
                .padding(.horizontal, 5)
            MumoryDetailImageView()
                .padding(.horizontal, 5)
//            ForEach(0..<3, id: \.self) { _ in
//                MumoryDetailImageView()
//                    .padding(.horizontal, 10)
//            }
        }
    }
}

struct MumoryDetailImageView: View {
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                .background(
                    Color.gray
                    //                                    Image("PATH_TO_IMAGE")
                    //                                                        .resizable()
                    //                                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                    //                                        .clipped()
                )
            
            HStack(alignment: .center, spacing: 10) {
                Text("1 / 3")
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
            .offset(x: -13, y: 15)
        }
    }
}

struct MumoryDetailImageView_Previews: PreviewProvider {
    static var previews: some View {
        MumoryDetailImageScrollContentView()
    }
}
