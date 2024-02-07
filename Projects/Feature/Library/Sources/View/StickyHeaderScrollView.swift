//
//  ScrollWrapper.swift
//  Feature
//
//  Created by 제이콥 on 2/6/24.
//  Copyright © 2024 hollys. All rights reserved.
//

import Foundation
import SwiftUI

enum ScrollDirection{
    case up
    case down
    case stay
}

struct StickyHeaderScrollView<Content: View>: UIViewControllerRepresentable {
    @Binding var contentOffset: CGPoint
    @Binding var changeDetectValue: Bool
    @Binding var viewWidth: CGFloat
    @Binding var scrollDirection: ScrollDirection
    @Binding var topbarYoffset: CGFloat
    var content: () -> Content

    
    init(changeDetectValue: Binding<Bool>,contentOffset: Binding<CGPoint>,viewWidth: Binding<CGFloat>, scrollDirection: Binding<ScrollDirection>, topbarYoffset: Binding<CGFloat>, @ViewBuilder content: @escaping () -> Content) {
        self._changeDetectValue = changeDetectValue
        self._contentOffset = contentOffset
        self._viewWidth = viewWidth
        self._scrollDirection = scrollDirection
        self._topbarYoffset = topbarYoffset
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
        Coordinator(contentOffset: self._contentOffset, scrollDirection: self._scrollDirection, topbarYoffset: self._topbarYoffset)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {
        let contentOffset: Binding<CGPoint>
        let scrollDirection: Binding<ScrollDirection>
        let topbarYoffset: Binding<CGFloat>
        
        init(contentOffset: Binding<CGPoint>, scrollDirection: Binding<ScrollDirection>, topbarYoffset: Binding<CGFloat>) { // Modify this line
            self.contentOffset = contentOffset
            self.scrollDirection = scrollDirection
            self.topbarYoffset = topbarYoffset
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let diff = scrollView.contentOffset.y - contentOffset.wrappedValue.y
            
            if diff > 0{
                //down
                scrollDirection.wrappedValue = .down
                if scrollView.contentOffset.y <= 0 {
                    topbarYoffset.wrappedValue = 0
                }else{
                    topbarYoffset.wrappedValue -= diff
                }
            }else if diff < 0 {
                //up
                scrollDirection.wrappedValue = .up
                if scrollView.contentOffset.y <= 0 {
                    topbarYoffset.wrappedValue = 0
                }else {
                    if topbarYoffset.wrappedValue < 0 {
                        if topbarYoffset.wrappedValue - diff > 0 {
                            topbarYoffset.wrappedValue = 0
                        }else {
                            topbarYoffset.wrappedValue -= diff //diff가 음수이기 때문에 사실상 덧셈
                        }
                    }
                }
       
            }
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
//        
//        print("1content size: \(scrollView.contentSize)")
//        print("1hosting size: \(hostingController.view.frame.size)")
//        print("1scrollview size: \(scrollView.frame.size)")
//        print("1view size: \(view.frame.size)")
    }
}
