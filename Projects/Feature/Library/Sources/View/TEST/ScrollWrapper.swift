//
//  ScrollWrapper.swift
//  Feature
//
//  Created by 제이콥 on 2/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI


struct ScrollWrapper<Content: View>: UIViewControllerRepresentable {
    
    @Binding var height: CGFloat
    var content: () -> Content

    
    init(height: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self._height = height
    }

    func makeUIViewController(context: Context) -> UIScrollViewViewControllerTest {
        print("make")
        let vc = UIScrollViewViewControllerTest()
        vc.hostingController.rootView = AnyView(self.content())
        vc.scrollView.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ viewController: UIScrollViewViewControllerTest, context: Context) {
        viewController.hostingController.rootView = AnyView(self.content())
        viewController.update()
        
//        DispatchQueue.main.async {
//            
//        }
//        viewController.update()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        
    }
}

class UIScrollViewViewControllerTest: UIViewController, UIScrollViewDelegate {
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
        scrollView.delegate = self
        scrollView.decelerationRate = .fast
        scrollView.showsHorizontalScrollIndicator = false
        
        self.hostingController.view.backgroundColor = .clear
        
//        print("1hosting view width: \(hostingController.view.frame.width) height: \(hostingController.view.frame.height)")
//        print("1content size width: \(scrollView.contentSize.width), height: \(scrollView.contentSize.height)")
        
        self.view.addSubview(self.scrollView)
        self.pinEdges(of: self.scrollView, to: self.view)
        
        self.hostingController.willMove(toParent: self)
        self.scrollView.addSubview(self.hostingController.view)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
        
//        print("2hosting view width: \(hostingController.view.frame.width) height: \(hostingController.view.frame.height)")
//        print("2content size width: \(scrollView.contentSize.width), height: \(scrollView.contentSize.height)")
        

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
        
        let height = hostingController.view.frame.height
//        print("3hosting view width: \(hostingController.view.frame.width) height: \(hostingController.view.frame.height)")
//        print("3content size width: \(scrollView.contentSize.width), height: \(scrollView.contentSize.height)")
        
        self.hostingController.willMove(toParent: self)
        self.pinEdges(of: self.hostingController.view, to: self.scrollView)
        self.hostingController.didMove(toParent: self)
        
//        print("4hosting view width: \(hostingController.view.frame.width) height: \(hostingController.view.frame.height)")
//        print("4content size width: \(scrollView.contentSize.width), height: \(scrollView.contentSize.height)")
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let cellWidth = scrollView.frame.size.width - 40
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
