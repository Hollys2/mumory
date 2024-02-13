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

struct SimpleScrollView<Content: View>: UIViewControllerRepresentable {
    @EnvironmentObject var userManager: UserViewModel
    @Binding var contentOffset: CGPoint

    var content: () -> Content

    
    init(contentOffset: Binding<CGPoint>, @ViewBuilder content: @escaping () -> Content) {
        self._contentOffset = contentOffset
        self.content = content
    }

    func makeUIViewController(context: Context) -> SimpleScrollViewController {
        let vc = SimpleScrollViewController()
        vc.hostingController.rootView = AnyView(self.content())
        vc.scrollView.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ viewController: SimpleScrollViewController, context: Context) {
        print("update")
        viewController.hostingController.rootView = AnyView(self.content())
        viewController.update()

        DispatchQueue.main.async {
            viewController.scrollView.contentOffset = self.contentOffset
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(contentOffset: self._contentOffset)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        let contentOffset: Binding<CGPoint>
        
        init(contentOffset: Binding<CGPoint>) { // Modify this line
            self.contentOffset = contentOffset
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.contentOffset.wrappedValue = scrollView.contentOffset
        }

    }
}

class SimpleScrollViewController: UIViewController{
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isPagingEnabled = false
        v.indexDisplayMode = .alwaysHidden
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
