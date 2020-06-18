//
//  OZBubbleLabel.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/04.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

let kBubbleLabelTopInset: CGFloat = 5.0
let kBubbleLabelBottomInset: CGFloat = 5.0
let kBubbleLabelLeftInset: CGFloat = 10.0
let kBubbleLabelRightInset: CGFloat = 10.0

public enum OZBubbleLabelType {
    case basic, hasOwnDrawing, noDraw
}

open class OZBubbleLabel: UILabel {
    
    public var type: OZBubbleLabelType = .basic
    let radius: CGFloat = 13.0  // chat bubble corner radius

    @IBInspectable public var topInset: CGFloat = kBubbleLabelTopInset
    @IBInspectable public var bottomInset: CGFloat = kBubbleLabelBottomInset
    @IBInspectable public var leftInset: CGFloat = kBubbleLabelLeftInset
    @IBInspectable public var rightInset: CGFloat = kBubbleLabelRightInset
    @IBInspectable public var notchInsetXRatio: CGFloat = 0.67
    @IBInspectable public var heightRatio: CGFloat = 1
    let notchInsetX: CGFloat = 10.0

    public var isIncoming = false
    public var incomingColor = UIColor(white: 244.0 / 255.0, alpha: 1.0)
    public var outgoingColor = UIColor(red: 229.0 / 255.0, green: 21.0 / 255.0, blue: 0.0, alpha: 1.0)
    
    override open func draw(_ rect: CGRect) {
        
        if type == .basic {
            let width = bounds.width
            let height = bounds.height * heightRatio
            
            let cornerRatio: CGFloat = 6.27 / 14.0
            let cntlRadius: CGFloat = radius * cornerRatio
            
            let startX: CGFloat = 1 / 14 * radius

            let notchMaxY: CGFloat = (17.8 / 14) * radius
            let notchEndPoint = CGPoint(x: 6.49 / 14.0 * radius, y: 7.9 / 14.0 * radius)
            let notchControl1 = CGPoint(x: 10.59 / 14.0 * radius, y: 14.09 / 14.0 * radius)
            let notchControl2 = CGPoint(x: 9.11 / 14.0 * radius, y: 10.52 / 14.0 * radius)
            
            let srStartPoint = CGPoint(x: 0.29 / 14.0 * radius, y: 1.71 / 14.0 * radius)
            
            let sr1EndPoint = CGPoint(x: 0.29 / 14.0 * radius, y: 0.29 / 14.0 * radius)
            let sr1Control1 = CGPoint(x: -0.1 / 14.0 * radius, y: 1.32 / 14.0 * radius)
            let sr1Control2 = CGPoint(x: -0.1 / 14.0 * radius, y: 0.68 / 14.0 * radius)
            
            let sr2Control1 = CGPoint(x: 0.48 / 14.0 * radius, y: 0.11 / 14.0 * radius)
            let sr2Control2X = 0.73 / 14.0 * radius
            
            let bezierPath = UIBezierPath()
            
            if isIncoming {
                
                ///CW
                // left-top corner
                bezierPath.move(to: CGPoint(x: startX, y: 0))
                
                // top wall
                bezierPath.addLine(to: CGPoint(x: width - radius, y: 0))
                
                // right-top corner
                bezierPath.addCurve(to: CGPoint(x: width, y: radius),
                                    controlPoint1: CGPoint(x: width-cntlRadius, y: 0),
                                    controlPoint2: CGPoint(x: width, y: cntlRadius))
                
                // right wall
                bezierPath.addLine(to: CGPoint(x: width, y: height-radius))
                
                // right-bottom corner
                bezierPath.addCurve(to: CGPoint(x: width - radius, y: height),
                                    controlPoint1: CGPoint(x: width, y: height-cntlRadius),
                                    controlPoint2: CGPoint(x: width-cntlRadius, y: height))
                
                // bottom line
                bezierPath.addLine(to: CGPoint(x: notchInsetX+radius, y: height))
                
                // left-bottom corner
                bezierPath.addCurve(to: CGPoint(x: notchInsetX, y: height-radius),
                                    controlPoint1: CGPoint(x: notchInsetX+cntlRadius, y: height),
                                    controlPoint2: CGPoint(x: notchInsetX, y: height-cntlRadius))
                
                // left wall
                bezierPath.addLine(to: CGPoint(x: notchInsetX, y: notchMaxY))
                
                // bubble notch
                bezierPath.addCurve(to: notchEndPoint, controlPoint1: notchControl1, controlPoint2: notchControl2)
                bezierPath.addLine(to: srStartPoint)
                bezierPath.addCurve(to: sr1EndPoint, controlPoint1: sr1Control1, controlPoint2: sr1Control2)
                bezierPath.addCurve(to: CGPoint(x: startX, y: 0), controlPoint1: sr2Control1, controlPoint2: CGPoint(x: sr2Control2X, y: 0))
                
                incomingColor.setFill()
                
            } else {
                
                ///CCW
                // right-top corner
                bezierPath.move(to: CGPoint(x: width-startX, y: 0))
                
                // top wall
                bezierPath.addLine(to: CGPoint(x: radius, y: 0))
                
                // left-top corner
                bezierPath.addCurve(to: CGPoint(x: 0, y: radius), controlPoint1: CGPoint(x: cntlRadius, y: 0), controlPoint2: CGPoint(x: 0, y: cntlRadius))
                
                // left wall
                bezierPath.addLine(to: CGPoint(x: 0, y: height-radius))
                
                // left-bottom corner
                bezierPath.addCurve(to: CGPoint(x: radius, y: height), controlPoint1: CGPoint(x: 0, y: height-cntlRadius), controlPoint2: CGPoint(x: cntlRadius, y: height))
                
                // bottom line
                bezierPath.addLine(to: CGPoint(x: width-startX, y: height))
                
                // bubble notch
                bezierPath.addCurve(to: CGPoint(x: width-sr1EndPoint.x, y: height-sr1EndPoint.y),
                                    controlPoint1: CGPoint(x: width-sr2Control2X, y: height),
                                    controlPoint2: CGPoint(x: width-sr2Control1.x, y: height-sr2Control1.y))
                bezierPath.addCurve(to: CGPoint(x: width-srStartPoint.x, y: height-srStartPoint.y),
                                    controlPoint1: CGPoint(x: width+sr1Control2.x, y: height-sr1Control2.y),
                                    controlPoint2: CGPoint(x: width+sr1Control1.x, y: height-sr1Control1.y))
                bezierPath.addLine(to: CGPoint(x: width-notchEndPoint.x, y: height-notchEndPoint.y))
                bezierPath.addCurve(to: CGPoint(x: width-notchInsetX, y: notchMaxY),
                                    controlPoint1: CGPoint(x: width-notchControl2.x, y: height-notchControl2.y),
                                    controlPoint2: CGPoint(x: width-notchControl1.x, y: height-notchControl1.y))

                // right wall
                bezierPath.addLine(to: CGPoint(x: width-notchInsetX, y: radius))

                // right-top corner
                bezierPath.addCurve(to: CGPoint(x: width-notchInsetX-radius, y: 0),
                                    controlPoint1: CGPoint(x: width-notchInsetX, y: cntlRadius),
                                    controlPoint2: CGPoint(x: width-notchInsetX-cntlRadius, y: 0))

                outgoingColor.setFill()
            }
            
            bezierPath.close()
            bezierPath.fill()
        }
        super.draw(rect)
    }
    
    override open func drawText(in rect: CGRect) {
        if type == .basic {
            if isIncoming {
                let insets = UIEdgeInsets.init(top: topInset, left: leftInset + notchInsetX, bottom: bottomInset, right: rightInset - notchInsetX)
                super.drawText(in: rect.inset(by: insets))
            }
            else {
                let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
                super.drawText(in: rect.inset(by: insets))
            }
        }
    }
    
    
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    // MARK: - UIResponderStandardEditActions
    open override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
    
    // MARK: - Long-press Handler

    @objc func handleLongPress(_ recognizer: UIGestureRecognizer) {
        if recognizer.state == .began,
            let recognizerView = recognizer.view,
            let recognizerSuperview = recognizerView.superview {
            UIMenuController.shared.setTargetRect(recognizerView.frame, in: recognizerSuperview)
            UIMenuController.shared.setMenuVisible(true, animated:true)
            recognizerView.becomeFirstResponder()
        }
    }

}
