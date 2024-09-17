//
//  UIScrollViewController.swift
//  Feature
//
//  Created by 제이콥 on 11/26/23.
//  Copyright © 2023 hollys. All rights reserved.
//

import UIKit
import SwiftUI

struct UIScrollViewWrapper<Content: View>: UIViewControllerRepresentable {

    var content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    func makeUIViewController(context: Context) -> UIScrollViewController {
        let vc = UIScrollViewController()
        vc.hostingController.rootView = AnyView(self.content())
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
    }
}

class UIScrollViewController: UIViewController, UIScrollViewDelegate{

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()
    
    //UIHostingController: SwiftUI뷰 계층을 관리하는 UIKit 뷰 컨트롤러
    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
//        print("view width: \(view.frame.width), height: \(view.frame.height)")
        
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)

        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)

        hostingController.view.backgroundColor = .purple
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
    
    //scroll view delegate
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if (scrollView.contentOffset.x.truncatingRemainder(dividingBy: 350)) > (350/2) {
////            scrollView.contentOffset.x = 0
//        }
//    }
//    
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("scrollview decelerating")
//    }
    
    
}

