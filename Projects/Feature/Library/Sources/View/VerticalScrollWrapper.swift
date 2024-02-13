//
//  ScrollWrapper.swift
//  Feature
//
//  Created by 제이콥 on 2/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import Shared
import SwiftUI
import MusicKit

struct VerticalScrollWrapper<Content: View>: UIViewControllerRepresentable {
    @EnvironmentObject var userManager: UserViewModel

    @Binding var contentOffset: CGPoint
    @Binding var songs: [Song]
    @Binding var scrollDirection: ScrollDirection
    @Binding var index: Int
//    @Binding var songs: [Song]
    var content: () -> Content

    
    init(songs: Binding<[Song]>,index: Binding<Int>, contentOffset: Binding<CGPoint>, scrollDirection: Binding<ScrollDirection>, @ViewBuilder content: @escaping () -> Content) {
        self._songs = songs
        self._contentOffset = contentOffset
        self._scrollDirection = scrollDirection
        self._index = index
        self.content = content

    }

    func makeUIViewController(context: Context) -> ScrollWrapperViewController {
        let vc = ScrollWrapperViewController()
        vc.hostingController.rootView = AnyView(self.content())
        vc.scrollView.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ viewController: ScrollWrapperViewController, context: Context) {
        print("update")
        viewController.hostingController.rootView = AnyView(self.content())
        viewController.update()

        DispatchQueue.main.async {
            viewController.scrollView.contentOffset = self.contentOffset
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(contentOffset: self._contentOffset, scrollDirection: self._scrollDirection, songs: self._songs, index: self._index)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {

        let contentOffset: Binding<CGPoint>
        let scrollDirection: Binding<ScrollDirection>
        let songs: Binding<[Song]>
        let index: Binding<Int>

        
        init(contentOffset: Binding<CGPoint>, scrollDirection: Binding<ScrollDirection>, songs: Binding<[Song]>, index: Binding<Int>) { // Modify this line
            self.contentOffset = contentOffset
            self.scrollDirection = scrollDirection
            self.songs = songs
            self.index = index
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.contentOffset.wrappedValue = scrollView.contentOffset
            print(scrollView.contentSize.height/CGFloat(songs.count))
            let cellHeight = 70.0
            //새로운 곡을 20개 단위로 불러옴
            //따라서 화면에 10위, 30위, 50위 .. 가 보일 때 다음 순위를 요청함(index를 늘림)
            if scrollView.contentOffset.y > (CGFloat(index.wrappedValue) * 1400 + (70 * 10)) {
                print("next page")
                index.wrappedValue += 1
            }
        }

    }
}

class ScrollWrapperViewController: UIViewController{
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isPagingEnabled = false
        v.clipsToBounds = true
        return v
    }()
    
    var index = 0

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hostingController.view.backgroundColor = .clear
    

        
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)
        
        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)


    }

    func pinEdges(of viewA: UIView, to viewB: UIView) {
        viewA.translatesAutoresizingMaskIntoConstraints = false
        viewB.addConstraints([
            viewA.leadingAnchor.constraint(equalTo: viewB.leadingAnchor),
            viewA.trailingAnchor.constraint(equalTo: viewB.trailingAnchor),
            viewA.topAnchor.constraint(equalTo: viewB.topAnchor),
            viewA.bottomAnchor.constraint(equalTo: viewB.bottomAnchor),
        ])
    }
    
    func update(){
        print("update again")
        hostingController.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.hostingController.willMove(toParent: self)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
    }
}
