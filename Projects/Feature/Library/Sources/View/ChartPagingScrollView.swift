//
//  ScrollWrapper.swift
//  Feature
//
//  Created by 제이콥 on 2/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import MusicKit
import SwiftUI


struct ChartPagingScrollView<Content: View>: UIViewControllerRepresentable {
    @Binding var scrollViewHeight: CGFloat
    @Binding var musicChart: MusicItemCollection<Song>
    var content: () -> Content

    
    init(musicChart: Binding<MusicItemCollection<Song>>,scrollViewHeight: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self._musicChart = musicChart
        self._scrollViewHeight = scrollViewHeight
    }

    func makeUIViewController(context: Context) -> UIScrollPagingViewController {
        let vc = UIScrollPagingViewController()
        vc.hostingController.rootView = AnyView(self.content())
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollPagingViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        viewController.update()

        DispatchQueue.main.async {
            scrollViewHeight = viewController.scrollView.contentSize.height
        }
    }
}

class UIScrollPagingViewController: UIViewController, UIScrollViewDelegate {
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
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        scrollView.showsHorizontalScrollIndicator = false
        
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
        hostingController.view.translatesAutoresizingMaskIntoConstraints = true

        self.hostingController.willMove(toParent: self)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let cellWidth = UIScreen.main.bounds.width * 0.9
        let estimatedIndex = (scrollView.contentOffset.x) / cellWidth
        var index: Int
        
        if velocity.x > 0 {
            index = Int(ceil(estimatedIndex))
        } else if velocity.x < 0 {
            index = Int(floor(estimatedIndex))
        } else {
            index = Int(round(estimatedIndex))
        }
        
        index = max(min(5, index), 0)
        targetContentOffset.pointee = CGPoint(x: CGFloat(index) * cellWidth, y: 0)
        
    }
    

}
