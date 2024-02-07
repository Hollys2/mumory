//
//  ScrollWrapper.swift
//  Feature
//
//  Created by 제이콥 on 2/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI


struct StickyHeaderScrollView<Content: View>: UIViewControllerRepresentable {
    @Binding var contentOffset: CGPoint
    @Binding var changeDetectValue: Bool
    @Binding var viewWidth: CGFloat
    var content: () -> Content

    
    init(changeDetectValue: Binding<Bool>,contentOffset: Binding<CGPoint>,viewWidth: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self._changeDetectValue = changeDetectValue
        self._contentOffset = contentOffset
        self._viewWidth = viewWidth
        self.content = content

    }

    func makeUIViewController(context: Context) -> UIStickyScrollViewController {
        print("make")
        let vc = UIStickyScrollViewController()
        vc.hostingController.rootView = AnyView(self.content())
        vc.scrollView.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ viewController: UIStickyScrollViewController, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())

        DispatchQueue.main.async {
            viewController.update()
            viewController.scrollView.contentOffset = self.contentOffset
            self.viewWidth = viewController.view.frame.width
            
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
            contentOffset.wrappedValue = scrollView.contentOffset
            
        }
    }
}

class UIStickyScrollViewController: UIViewController{
    lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.isPagingEnabled = false
        v.clipsToBounds = false
        return v
    }()
    
    var index = 0

    var hostingController: UIHostingController<AnyView> = UIHostingController(rootView: AnyView(EmptyView()))

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.decelerationRate = .fast
        scrollView.showsHorizontalScrollIndicator = false
        
        self.hostingController.view.backgroundColor = .clear
//        self.scrollView.backgroundColor = UIColor(red: 0, green: 1, blue: 0, alpha: 0.5)
//        self.view.backgroundColor = UIColor(red: 1, green: 0.5, blue: 0.5, alpha: 0.5)
        
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)
        
        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
//        
//        print("1content size: \(scrollView.contentSize)")
//        print("1hosting size: \(hostingController.view.frame.size)")
//        print("1scrollview size: \(scrollView.frame.size)")
//        print("1view size: \(view.frame.size)")

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
//        
//        print("1content size: \(scrollView.contentSize)")
//        print("1hosting size: \(hostingController.view.frame.size)")
//        print("1scrollview size: \(scrollView.frame.size)")
//        print("1view size: \(view.frame.size)")
    }
}
