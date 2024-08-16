//
//  MumoryDetailImageScrollUIViewRepresentable.swift
//  Feature
//
//  Created by 다솔 on 2023/12/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared


@available(iOS 16.0, *)
struct MumoryDetailImageScrollUIViewRepresentable: UIViewRepresentable {

//    typealias UIViewType = UIScrollView

    var mumory: Mumory
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator

        let totalWidth = (UIScreen.main.bounds.width - 40 + 10) * CGFloat((self.mumory.imageURLs ?? []).count)

        scrollView.isPagingEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.clipsToBounds = false
        scrollView.bounces = true

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        let hostingController = UIHostingController(rootView: MumoryDetailImageScrollContentView(mumoryAnnotation: self.mumory))
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: UIScreen.main.bounds.width - 40)
        let contentHeight = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        scrollView.contentSize = CGSize(width: totalWidth, height: contentHeight)
        scrollView.addSubview(hostingController.view)
        
        scrollView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear

        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        let totalWidth = (UIScreen.main.bounds.width - 40 + 10) * CGFloat((self.mumory.imageURLs ?? []).count)
        
        let hostingController = UIHostingController(rootView: MumoryDetailImageScrollContentView(mumoryAnnotation: self.mumory))
        
        let contentHeight = hostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        hostingController.view.frame = CGRect(x: 0, y: 0, width: totalWidth, height: contentHeight)
        uiView.contentSize = CGSize(width: totalWidth, height: contentHeight)
        
        uiView.subviews.forEach { $0.removeFromSuperview() }
        uiView.addSubview(hostingController.view)
        
        uiView.backgroundColor = .clear
        hostingController.view.backgroundColor = .clear
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}

extension MumoryDetailImageScrollUIViewRepresentable {
    
    class Coordinator: NSObject {
        
        let parent: MumoryDetailImageScrollUIViewRepresentable
        
        init(parent: MumoryDetailImageScrollUIViewRepresentable) {
            self.parent = parent
            super.init()
        }
    }
}

extension MumoryDetailImageScrollUIViewRepresentable.Coordinator: UIScrollViewDelegate {}

struct MumoryDetailImageScrollContentView: View {
    
    var mumoryAnnotation: Mumory
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach((mumoryAnnotation.imageURLs ?? []).indices, id: \.self) { index in
                MumoryDetailImageView(url: (mumoryAnnotation.imageURLs ?? [])[index], count: (mumoryAnnotation.imageURLs ?? []).count, index: Int(index))
                    .padding(.horizontal, 5)
            }
        }
        .background(.clear)
        .onAppear {
//            print("MumoryDetailImageScrollContentView: \(mumoryAnnotation.imageURLs ?? [])")
        }
    }
}

struct MumoryDetailImageView: View {
    
    let url: String
    let count: Int
    let index: Int
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        
        ZStack(alignment: .topTrailing) {
            
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    Text("Failed to load image")
                @unknown default:
                    Text("Unknown state")
                }
            }
            .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
            .scaleEffect(scale)
            .gesture(MagnificationGesture()
                .onChanged { value in
                    print("onChanged")
                    scale = lastScale + (value.magnitude - 1) / 10.0
                }
                .onEnded { value in
                    print("onEnded")
                    scale = 1.0
                }
            )
            .clipped()
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
    }
}
