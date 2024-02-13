//
//  extension+UINavigationController.swift
//  Shared
//
//  Created by 다솔 on 2023/11/28.
//  Copyright © 2023 hollys. All rights reserved.
//


import UIKit

// 네비게이션바가 숨겨진 경우 스와이프 제스처로 팝이 되지 않는 현상 해결
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
//        print("UINavigationController")
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
//        interactivePopGestureRecognizer?.delegate = nil
    }

//    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        print("gestureRecognizerShouldBegin")
//        return viewControllers.count > 1
//    }
}
