//
//  UIView+.swift
//  MoblileTest
//
//  Created by Giang Dong Trinh on 15/5/24.
//

import Foundation
import UIKit
import Then

extension UIView {
    
    func appearWithZoomEffect(duration: TimeInterval, delay: TimeInterval, completion: ((Bool) -> Void)? = nil) {
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        self.alpha = 0.0
        
        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            self.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: duration / 2, delay: 0, options: .curveEaseOut, animations: {
                self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: completion)
        })
    }
}
