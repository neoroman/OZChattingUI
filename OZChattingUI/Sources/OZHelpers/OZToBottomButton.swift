//
//  OZToBottomButton.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/06/07.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

@IBDesignable
class OZToBottomButton: UIButton {

    // MARK: - Public Properties
    
    public var strokeColor: UIColor {
        get {
            return _strokeColor
        }
        set(newValue) {
            _strokeColor = newValue
            setNeedsDisplay()
        }
    }
    
    public var strokeWidth: CGFloat {
        get {
            return _strokeWidth
        }
        set(newValue) {
            _strokeWidth = newValue
            setNeedsDisplay()
        }
    }

    public var fillColor: UIColor {
        get {
            return _fillColor
        }
        set(newValue) {
            _fillColor = newValue
            setNeedsDisplay()
        }
    }

    
    // MARK: - Private Properties
    
    private var _strokeColor: UIColor = .gray
    private var _strokeWidth: CGFloat = 1.0
    private var _fillColor: UIColor = .clear

    
    // MARK: - Drawing
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        drawRect(rect: bounds)
    }
    
    func drawRect(rect: CGRect) {
        let bounds = rect.insetBy(dx: rect.width * 0.2, dy: rect.height * 0.4)
        
        if _fillColor != .clear {
            let circleCenter = CGPoint(x: rect.midX, y: rect.midY)
            let circleRadius: CGFloat = rect.width / 2
            let circlePath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)// (ovalIn: self.bounds)
            
            let progressCircle = CAShapeLayer ()
            progressCircle.path = circlePath.cgPath
            progressCircle.strokeColor = _fillColor.cgColor
            progressCircle.fillColor = _fillColor.cgColor
            progressCircle.lineWidth = _strokeWidth
            
            self.layer.addSublayer(progressCircle)
        }
        
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
        bezierPath.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        bezierPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        bezierPath.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
        bezierPath.lineCapStyle = CGLineCap.round
        bezierPath.lineWidth = _strokeWidth
        bezierPath.stroke()
        bezierPath.close()
        
        let line = CAShapeLayer ()
        line.path = bezierPath.cgPath
        line.strokeColor = _strokeColor.cgColor
        line.lineWidth = _strokeWidth

        self.layer.addSublayer(line)
    }
}
