//
//  
//  DrawableView.swift
//  MoblileTest
//
//  Created by Giang Dong Trinh on 14/5/24.
//
//

import Foundation
import UIKit
import Reusable
import Then

class DrawableView: UIView, NibOwnerLoadable {
    // MARK: - Data stucture
    struct DrawingStroke {
        let path: UIBezierPath
        let color: UIColor
    }
    
    enum DrawingMode {
        case draw
        case erase
    }
    
    // MARK: - Properties
    private var drawingLayer: CAShapeLayer?
    
    private var currentPath: UIBezierPath?
    
    private var temporaryPath: UIBezierPath?
    
    private var points = [CGPoint]()
    
    private let stack = Stack<DrawingStroke>()
    
    private var drawMode: DrawingMode = .draw
    
    var drawColor = UIColor.white
    
    var lineWidth: CGFloat = 4.0
    
    var opacity: CGFloat = 1
    
    var colors: [UIColor] = [
        .systemRed,
        .systemOrange,
        .systemTeal,
        .systemYellow,
        .systemPink,
        .systemPurple,
        .systemCyan,
        .systemMint,
        .systemBrown,
        .systemGreen
    ]
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadNibContent()
        self.configViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.loadNibContent()
        self.configViews()
    }
    
    private func configViews() {
        self.layer.removeAllAnimations()
        self.layer.masksToBounds = false
        self.backgroundColor = UIColor.white
        self.isMultipleTouchEnabled = false
    }
    
    // MARK: Drawing
    override func draw(_ rect: CGRect) {
        // TODO: This orveriding is still required.
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        handleDraw(layer, in: ctx)
    }
    
    // MARK: - Touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleTouchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        finishPath()
    }
    
    // MARK: - Functions
    func undo() {
        stack.pop()
        layer.setNeedsDisplay()
    }
    
    func set(mode: DrawingMode) {
        self.drawMode = mode
    }
}

// MARK: - Handle touch events
extension DrawableView {
    
    private func handleTouchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.preciseLocation(in: self) else {
            return
        }
        switch drawMode {
        case .draw:
            drawColor = colors.randomElement() ?? .systemBlue
        case .erase:
            drawColor = .white
        }
        
        points.removeAll()
        points.append(point)
    }
    
    private func handleTouchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.preciseLocation(in: self) else {
            return
        }
        points.append(point)
        updatePaths()
        layer.setNeedsDisplay()
    }
    
    private func handleTouchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // single touch support
        if points.count == 1 {
            currentPath = createPathStarting(at: points[0])
            currentPath?.lineWidth = self.lineWidth / 2.0
            currentPath?.addArc(withCenter: points[0],
                                radius: lineWidth / 4.0,
                                startAngle: 0,
                                endAngle: .pi * 2.0,
                                clockwise: true)
        }
        finishPath()
    }
}

// MARK: - Drawing logical
extension DrawableView {
    
    private func handleDraw(_ layer: CALayer, in ctx: CGContext) {
        self.layer.sublayers?.forEach {
            guard let caLayer = $0 as? CAShapeLayer else { return  }
            caLayer.removeFromSuperlayer()
        }
        
        self.drawingLayer = CAShapeLayer()
        let drawingLayer = self.drawingLayer!
        
        drawingLayer.do {
            $0.contentsScale = UIScreen.main.scale
            $0.lineWidth = lineWidth
            $0.opacity = Float(opacity)
            $0.lineJoin = .round
            $0.lineCap = .round
            $0.fillColor = UIColor.clear.cgColor
            $0.miterLimit = 0
            $0.strokeColor = drawColor.cgColor
        }
        
        for item in stack.items {
            let pathLayer = CAShapeLayer().with {
                $0.path = item.path.cgPath
                $0.strokeColor = item.color.cgColor
                $0.fillColor = UIColor.clear.cgColor
                $0.lineWidth = lineWidth
                $0.lineJoin = .round
                $0.lineCap = .round
                $0.miterLimit = 0
                $0.contentsScale = UIScreen.main.scale
            }
            self.layer.addSublayer(pathLayer)
        }
        
        let linePath = UIBezierPath()
        
        if let tempPath = temporaryPath, let currentPath = currentPath {
            linePath.append(tempPath)
            linePath.append(currentPath)
        }
        
        drawingLayer.path = linePath.cgPath
        
        self.drawingLayer = drawingLayer
        self.layer.addSublayer(drawingLayer)
    }
    
    private func updatePaths() {
        // update main path
        while points.count > 4 {
            
            points[3] = CGPoint(x: (points[2].x + points[4].x) / 2.0, y: (points[2].y + points[4].y) / 2.0)
            
            if currentPath == nil {
                currentPath = createPathStarting(at: points[0])
            }
            
            currentPath?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            points.removeFirst(3)
            temporaryPath = nil
        }
        
        // build temporary path up to last touch point
        switch points.count {
        case 2:
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addLine(to: points[1])
            break
        case 3:
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addQuadCurve(to: points[2], controlPoint: points[1])
            break
        case 4:
            temporaryPath = createPathStarting(at: points[0])
            temporaryPath?.addCurve(to: points[3], controlPoint1: points[1], controlPoint2: points[2])
            break
        default:
            break
        }
    }
    
    private func finishPath() {
        // add temp path to current path to reflect the changes in canvas
        if let tempPath = temporaryPath {
            currentPath?.append(tempPath)
        }
        
        if let currentPath = currentPath {
            let stroke = DrawingStroke(path: currentPath, color: drawColor)
            stack.push(stroke)
        }
        
        currentPath = nil
        drawColor = UIColor.clear
    }
    
    private func createPathStarting(at point: CGPoint) -> UIBezierPath {
        let localPath = UIBezierPath()
        localPath.move(to: point)
        return localPath
    }
}

// MARK: - Sticker
extension DrawableView {
    
    func addSticker() {
        guard let image = UIImage(named: "beer_sticker") else { return }
        let stickerView = StickerView(origin: center, image: image)
        self.addSubview(stickerView)
        stickerView.layer.zPosition = 9999
    }
}
