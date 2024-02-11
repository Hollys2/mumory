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
    @EnvironmentObject var userManager: UserViewModel

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
        Coordinator(contentOffset: self._contentOffset, scrollDirection: self._scrollDirection, topbarYoffset: self._topbarYoffset, topInset: userManager.topInset)
    }
    
    public class Coordinator: NSObject, UIScrollViewDelegate {

        let contentOffset: Binding<CGPoint>
        let scrollDirection: Binding<ScrollDirection>
        let topbarYoffset: Binding<CGFloat>
        let topInset: CGFloat
        
        init(contentOffset: Binding<CGPoint>, scrollDirection: Binding<ScrollDirection>, topbarYoffset: Binding<CGFloat>, topInset: CGFloat) { // Modify this line
            self.contentOffset = contentOffset
            self.scrollDirection = scrollDirection
            self.topbarYoffset = topbarYoffset
            self.topInset = topInset
        }

        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            var diff = scrollView.contentOffset.y - contentOffset.wrappedValue.y
//            print(scrollView.contentOffset.y)
//            print("offset.y :\(scrollView.contentOffset.y), diff: \(diff)")
            if diff > 0{
                //down
                scrollDirection.wrappedValue = .down
                if scrollView.contentOffset.y <= 0/*스크롤 시작 offset == safearea 높이*/{
                    //최상단에서 아래로 당겼다가 놓아서 줄어들 때도 최상단에 붙어있도록
                    topbarYoffset.wrappedValue = 0 /*상단뷰의 시작 offset*/
                }else{
                    //평범한 스크롤 상황에서 스크롤한 만큼 위로 사라지게함
                    topbarYoffset.wrappedValue -= diff
                }
            }else if diff < 0 {
                diff = -diff
                
                //up
                scrollDirection.wrappedValue = .up
                if scrollView.contentOffset.y <= 0 /*스크롤 시작 offset*/{
                    //최상단에서 아래로 당겼을 때도 최상단에 붙어있도록
                    topbarYoffset.wrappedValue = 0/*상단뷰의 시작 offset*/
                }else {
                    //평범한 스크롤 상황
                    
                    //미리 나오는 높이를 더해봤을 때 최상단보다 더 내려오면 최상단에 붙여놓기
                    if topbarYoffset.wrappedValue + diff >= 0 /*상단바의 시작 offset*/{
                        //최상단보다 더 밑으로 내려오는 것을 막기 위함
                        topbarYoffset.wrappedValue = 0/*상단바의 시작 offset위치*/
                    }else {
                        //아직 상단뷰가 다 안 나왔을 때는 그냥 계속 나오기. 스크롤 량 만큼 더하기
                        topbarYoffset.wrappedValue += diff
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
