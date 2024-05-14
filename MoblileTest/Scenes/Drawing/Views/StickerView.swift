//
//  StickerView.swift
//  MoblileTest
//
//  Created by Giang Dong Trinh on 14/5/24.
//

import Foundation
import UIKit

class StickerView: UIView {

    var initialBounds = CGRect.zero
    var initialDistance: CGFloat = 0
    var initialAngle: CGFloat = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupGestures()
    }
    
    convenience init(origin: CGPoint, image: UIImage) {
        self.init(frame: .init(origin: origin, size: CGSize(width: 100, height: 100)))
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        self.addSubview(imageView)
    }
    
    private func setupGestures() {
        self.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        self.addGestureRecognizer(rotationGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.addGestureRecognizer(pinchGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        gesture.setTranslation(.zero, in: self.superview)
    }
    
    @objc private func handleRotation(_ gesture: UIRotationGestureRecognizer) {
        self.transform = self.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        self.transform = self.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
}
