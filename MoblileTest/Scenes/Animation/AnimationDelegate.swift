//
//  AnimationDelegate.swift
//  MoblileTest
//
//  Created by Giang Dong Trinh on 15/5/24.
//

import Foundation
import UIKit

class AnimationDelegate: NSObject, CAAnimationDelegate {
    var completion: (() -> Void)?

    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        completion?()
    }
}
