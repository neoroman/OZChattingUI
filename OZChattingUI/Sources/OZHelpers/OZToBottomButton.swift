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

    public var badgeCount: Int {
        get {
            return _badgeCount
        }
        set(newValue) {
            if newValue == 0, let aLabel = self.viewWithTag(tag4Label) {
                aLabel.removeFromSuperview()
            }
            else if _badgeCount != newValue {
                showBadge(count: newValue)
            }
            _badgeCount = newValue
            setNeedsDisplay()
        }
    }

    
    // MARK: - Private Properties
    
    private var _strokeColor: UIColor = .gray
    private var _strokeWidth: CGFloat = 1.0
    private var _fillColor: UIColor = .clear
    private var _badgeCount: Int = 0

    private var circle: CAShapeLayer?
    private var line: CAShapeLayer?
        
    
    // MARK: - Show count badge
    fileprivate let tag4Label = 1717017
    func showBadge(count: Int,
                   fontName: String = "AppleSDGothicNeo-Medium",
                   fontSize: CGFloat = 12,
                   height: CGFloat = 15,
                   textColor: UIColor = .white,
                   backgroundColor: UIColor = .green) {
        self.clipsToBounds = false
        self.layer.masksToBounds = false
        _badgeCount = count > 0 ? count : 1
        var size = OZMessageCell.sizeForText("\(_badgeCount)", fontName: fontName, fontSize: fontSize, maxWidth: 100, paddingX: 3, paddingY: 0)
        if size.height < height {
            size.height = height
        }
        if size.width < height {
            size.width = height
        }

        guard let aLabel = self.viewWithTag(tag4Label) as? UILabel else {
            let rect = CGRect(x: 0, y: 0, width: height, height: height)
            let label = UILabel(frame: rect)
            label.tag = tag4Label
            label.textAlignment = .center
            label.layer.cornerRadius = label.frame.height / 2
            label.layer.masksToBounds = true
            label.text = "\(_badgeCount)"
            label.textColor = textColor
            label.backgroundColor = backgroundColor
            label.center.y = bounds.minY
            label.center.x = bounds.midX
            label.frame.size = size
            self.addSubview(label)
            return
        }
        
        aLabel.text = "\(_badgeCount)"
        aLabel.textColor = textColor
        aLabel.backgroundColor = backgroundColor
        aLabel.center.y = bounds.minY
        aLabel.center.x = bounds.midX
        aLabel.frame.size = size
    }
    

    // MARK: - Drawing
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        drawRect(rect: bounds)
        
    }
    
    func drawRect(rect: CGRect) {
        
        if _fillColor != .clear {
            if circle == nil {
                let circleCenter = CGPoint(x: rect.midX, y: rect.midY)
                let circleRadius: CGFloat = rect.width / 2
                let circlePath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: 0, endAngle: .pi * 2, clockwise: false)// (ovalIn: self.bounds)
                
                circle = CAShapeLayer ()
                circle?.path = circlePath.cgPath
                self.layer.addSublayer(circle!)
            }
            circle?.strokeColor = _fillColor.cgColor
            circle?.fillColor = _fillColor.cgColor
            circle?.lineWidth = _strokeWidth
        }
        
        if line == nil {
            let bounds = rect.insetBy(dx: rect.width * 0.2, dy: rect.height * 0.4)

            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            bezierPath.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
            bezierPath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            bezierPath.addLine(to: CGPoint(x: bounds.midX, y: bounds.maxY))
            bezierPath.lineCapStyle = CGLineCap.round
            bezierPath.lineWidth = _strokeWidth
            bezierPath.stroke()
            bezierPath.close()
            
            line = CAShapeLayer ()
            line?.path = bezierPath.cgPath
            
            self.layer.addSublayer(line!)
        }
        line?.strokeColor = _strokeColor.cgColor
        line?.lineWidth = _strokeWidth
    }
}
