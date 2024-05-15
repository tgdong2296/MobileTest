//
//  AnimationViewController.swift
//  MoblileTest
//
//  Created by Giang Dong Trinh on 15/5/24.
//

import Foundation
import UIKit
import Reusable
import Then

class AnimationViewController: UIViewController {
    @IBOutlet var containerView: UIView!
    @IBOutlet var progressContainerView: UIView!
    @IBOutlet var bubbleImageview: UIImageView!
    @IBOutlet var departureIcons: [UIImageView]!
    @IBOutlet var destinationIcon: UIImageView!
    @IBOutlet var containerTopConstraint: NSLayoutConstraint!
    
    let animationDelegate = AnimationDelegate()
    let progressLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bubbleAnimation()
        appearAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    @IBAction func handleCloseButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func configViews() {
        containerView.alpha = 0
        animationDelegate.completion = { [weak self] in
            guard let self = self else { return }
            self.strokeAnimation()
        }
    }
    
    func appearAnimation() {
        UIView.animate(withDuration: 0.5, animations: {
            self.containerView.alpha = 1
            self.containerTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.heartAnimations()
        })
    }
    
    func strokeAnimation() {
        progressLayer.frame = self.progressLayer.bounds
        self.progressContainerView.layer.addSublayer(progressLayer)
        
        let path = UIBezierPath().then {
            $0.move(to: CGPoint(x: 0, y: 10))
            $0.addLine(to: CGPoint(x: 300, y: 10))
        }
        progressLayer.do {
            $0.path = path.cgPath
            $0.strokeColor = UIColor.systemPurple.cgColor
            $0.lineWidth = 5.0
            $0.fillColor = nil
            $0.strokeEnd = 0
        }
        let strokeAnimation = CABasicAnimation(keyPath: "strokeEnd").then {
            $0.fromValue = 0
            $0.toValue = 1
            $0.duration = 1
        }
        progressLayer.add(strokeAnimation, forKey: "strokeEndAnimation")
        progressLayer.strokeEnd = 1
    }
    
    func heartAnimations() {
        for (index, icon) in departureIcons.enumerated() {
            pathAnimation(from: icon, to: destinationIcon, delay: Double(index) * 0.2)
        }
    }
    
    func pathAnimation(from departureView: UIView, to destinationView: UIView, delay: TimeInterval) {
        let animatedIcon = UIImageView(frame: departureView.frame).with {
            $0.image = UIImage(named: "ic_heart")
        }
        self.containerView.addSubview(animatedIcon)
        
        let departurePoint = departureView.center
        let destinationPoint = destinationView.center
        
        let miniDelay: TimeInterval = 1
        let appearScaleDuration: TimeInterval = 0.2
        let appearShakeDuration: TimeInterval = 0.1
        let moveDuration: TimeInterval = 0.6
        
        let bezierPath = UIBezierPath().then {
            $0.move(to: departurePoint)
            $0.addLine(to: destinationPoint)
        }
        
        let appearScaleAnimation = CABasicAnimation(keyPath: "transform.scale").with {
            $0.fromValue = 0.0
            $0.toValue = 1.2
            $0.duration = appearScaleDuration
            $0.fillMode = CAMediaTimingFillMode.forwards
            $0.isRemovedOnCompletion = false
        }
        animatedIcon.layer.add(appearScaleAnimation, forKey: "scaleAnimation")
        
        let appearShakeAnimation = CABasicAnimation(keyPath: "transform.rotation.z").then {
            $0.fromValue = -0.2
            $0.toValue = 0.2
            $0.duration = appearShakeDuration
            $0.autoreverses = true
            $0.repeatCount = 2
            $0.beginTime = CACurrentMediaTime() + appearScaleDuration
        }
        animatedIcon.layer.add(appearShakeAnimation, forKey: "shakeAnimation")
        
        let movePositionAnimation = CAKeyframeAnimation(keyPath: "position").with {
            $0.path = bezierPath.cgPath
            $0.fillMode = CAMediaTimingFillMode.forwards
            $0.isRemovedOnCompletion = false
            $0.timingFunctions = [CAMediaTimingFunction.init(name: .easeInEaseOut)]
        }
        
        let moveScaleAnimation = CABasicAnimation(keyPath: "transform.scale").with {
            $0.fromValue = 1.0
            $0.toValue = 0.5
            $0.fillMode = CAMediaTimingFillMode.forwards
            $0.isRemovedOnCompletion = false
        }
        
        let moveAnimationGroup = CAAnimationGroup().with {
            $0.animations = [movePositionAnimation, moveScaleAnimation]
            $0.duration = moveDuration
            $0.fillMode = CAMediaTimingFillMode.forwards
            $0.isRemovedOnCompletion = false
            $0.beginTime = CACurrentMediaTime() + appearScaleDuration + appearShakeDuration + miniDelay
            $0.delegate = animationDelegate
        }
        animatedIcon.layer.add(moveAnimationGroup, forKey: "movingAndScalingAnimation")
        
        let disappearScaleAnimation = CABasicAnimation(keyPath: "transform.scale").with {
            $0.fromValue = 0.5
            $0.toValue = 0.7
            $0.autoreverses = true
            $0.duration = appearScaleDuration
            $0.fillMode = CAMediaTimingFillMode.forwards
            $0.isRemovedOnCompletion = false
        }
        let disappearShakeAnimation = CABasicAnimation(keyPath: "transform.rotation.z").then {
            $0.fromValue = -0.2
            $0.toValue = 0.2
            $0.duration = appearShakeDuration
            $0.autoreverses = true
            $0.repeatCount = 2
        }
        let disappearAnimationGroup = CAAnimationGroup().with {
            $0.animations = [disappearScaleAnimation, disappearShakeAnimation]
            $0.duration = moveDuration
            $0.fillMode = CAMediaTimingFillMode.forwards
            $0.isRemovedOnCompletion = false
            $0.beginTime = CACurrentMediaTime() + appearScaleDuration + appearShakeDuration + miniDelay + moveDuration
        }
        animatedIcon.layer.add(disappearAnimationGroup, forKey: nil)
    }
    
    func bubbleAnimation() {
        UIView.animate(withDuration: 1, delay: 0, options: [.curveLinear, .repeat,. autoreverse]) {
            self.bubbleImageview.transform = self.bubbleImageview.transform.translatedBy(x: 0, y: 20)
        }
    }
}

extension AnimationViewController: StoryboardSceneBased {
    static var sceneStoryboard: UIStoryboard = UIStoryboard(name: "Animation", bundle: nil)
}
