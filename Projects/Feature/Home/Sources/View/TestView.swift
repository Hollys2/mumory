//
//  TestView.swift
//  Feature
//
//  Created by 다솔 on 2023/11/27.
//  Copyright © 2023 hollys. All rights reserved.
//


import SwiftUI
import Shared
import _MapKit_SwiftUI

class SwipeBackHostingController<Content: View>: UIHostingController<Content> {
    override init(rootView: Content) {
        super.init(rootView: rootView)
        print("@@SwipeBackHostingController")
        
        // 백 스와이프를 처리하는 GestureRecognizer 추가
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        gesture.direction = .right
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleSwipeGesture() {
        // 백 스와이프가 감지되면 뷰를 닫음
        presentationController?.presentedViewController.dismiss(animated: true, completion: nil)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
