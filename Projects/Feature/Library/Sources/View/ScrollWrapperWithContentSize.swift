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

struct ScrollWrapperWithContentSize<Content: View>: UIViewControllerRepresentable {
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel

    @Binding var contentOffset: CGPoint
    @Binding var contentSize: CGSize
    var content: () -> Content

    
    init(contentOffset: Binding<CGPoint>, contentSize: Binding<CGSize>, @ViewBuilder content: @escaping () -> Content) {
        self._contentOffset = contentOffset
        self._contentSize = contentSize
        self.content = content

    }

    func makeUIViewController(context: Context) -> ScrollWrapperContentSizeViewController {
        let vc = ScrollWrapperContentSizeViewController()
        vc.hostingController.rootView = AnyView(self.content())
        vc.scrollView.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ viewController: ScrollWrapperContentSizeViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        viewController.update()

        DispatchQueue.main.async {
            viewController.scrollView.contentOffset = self.contentOffset
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(contentOffset: self._contentOffset, contentSize: self._contentSize)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {

        let contentOffset: Binding<CGPoint>
        let contentSize: Binding<CGSize>
        
        init(contentOffset: Binding<CGPoint>, contentSize: Binding<CGSize>) { // Modify this line
            self.contentOffset = contentOffset
            self.contentSize = contentSize
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.contentOffset.wrappedValue = scrollView.contentOffset
            self.contentSize.wrappedValue = scrollView.contentSize
        }

    }
}

class ScrollWrapperContentSizeViewController: UIViewController{
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isPagingEnabled = false
        return v
    }()
    
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
        hostingController.view.translatesAutoresizingMaskIntoConstraints = true
        
        self.hostingController.willMove(toParent: self)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
    }
}
