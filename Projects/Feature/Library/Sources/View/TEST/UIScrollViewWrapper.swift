//
//  UIScrollViewController.swift
//  Feature
//
//  Created by 제이콥 on 11/26/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import UIKit
import SwiftUI
import MusicKit

struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {
    var content: () -> Content
    @Binding var musicChart: MusicItemCollection<Song>
    
    init(musicChart: Binding<MusicItemCollection<Song>>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self._musicChart = musicChart

    }
    
    func makeUIViewController(context: Context) -> UIScrollViewController {
        let vc = UIScrollViewController()
        vc.hostingController.rootView = AnyView(self.content())
        vc.scrollView.contentSize = CGSize(width: 1000, height: 500) // contentSize 설정
        print("makeUIcontroller")
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        viewController.scrollView.contentSize = CGSize(width: 1000, height: 500)
        print("update view controller")
    }
}

class UIScrollViewController: UIViewController, UIScrollViewDelegate{

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    //UIHostingController: SwiftUI뷰 계층을 관리하는 UIKit 뷰 컨트롤러
    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
                
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
}
