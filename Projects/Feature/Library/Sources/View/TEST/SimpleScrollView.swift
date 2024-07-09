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
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @Binding var contentOffset: CGPoint
    var refreshAction: () -> Void = {}
    var content: () -> Content

    
    init(contentOffset: Binding<CGPoint>, @ViewBuilder content: @escaping () -> Content) {
        self._contentOffset = contentOffset
        self.content = content
    }

    func makeUIViewController(context: Context) -> SimpleScrollViewController {
        let vc = SimpleScrollViewController(refreshAction: refreshAction)
        vc.hostingController.rootView = AnyView(self.content())
        vc.scrollView.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ viewController: SimpleScrollViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        viewController.refreshAction = refreshAction
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
extension SimpleScrollView {
    func refreshAction(action: @escaping () -> Void) -> SimpleScrollView {
        var view = self
        view.refreshAction = action
        return view
    }
}

class SimpleScrollViewController: UIViewController{
    
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isPagingEnabled = false
        v.showsVerticalScrollIndicator = false
        v.automaticallyAdjustsScrollIndicatorInsets = true
        return v
    }()
    
    var index = 0

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))
    
    var refreshAction: () -> Void
    var refreshControl: UIRefreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 100, width: 100, height: 100))

    init(refreshAction: @escaping () -> Void) {
        self.refreshAction = refreshAction
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hostingController.view.backgroundColor = .clear
        
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl.tintColor = UIColor(white: 0.47, alpha: 1)
        scrollView.refreshControl = refreshControl
            
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
    
    @objc func refresh(){
        self.refreshAction()
        refreshControl.endRefreshing()
    }
}
