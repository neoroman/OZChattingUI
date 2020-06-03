//
//  OZBubbleLabel.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/04.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

open class OZBubbleLabel: UILabel {
    
    let radius: CGFloat = 13.0  // chat bubble corner radius

    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 13.0
    @IBInspectable var rightInset: CGFloat = 10.0
    @IBInspectable var notchInsetXRatio: CGFloat = 0.67

    public var isIncoming = false
    public var incomingColor = UIColor(white: 244.0 / 255.0, alpha: 1.0)
    public var outgoingColor = UIColor(red: 229.0 / 255.0, green: 21.0 / 255.0, blue: 0.0, alpha: 1.0)
    
    override open func draw(_ rect: CGRect) {
        
        let width = bounds.width
        let height = bounds.height
        
        let notchInsetX: CGFloat = 10.0
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
            bezierPath.move(to: CGPoint(x: width-radius, y: 0))
            
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
        
        
        super.draw(rect)
    }
    
    override open func drawText(in rect: CGRect) {
        if isIncoming {
            let insets = UIEdgeInsets.init(top: topInset, left: leftInset / notchInsetXRatio, bottom: bottomInset, right: rightInset * notchInsetXRatio)
            super.drawText(in: rect.inset(by: insets))
        }
        else {
            let insets = UIEdgeInsets.init(top: topInset, left: leftInset * notchInsetXRatio, bottom: bottomInset, right: rightInset / notchInsetXRatio)
            super.drawText(in: rect.inset(by: insets))
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




/* By Henry on 2020.05.03 for "LEFT" Chatting Bubble
 // This code was generated by Trial version of PaintCode, therefore cannot be used for commercial purposes.
 // http://www.paintcodeapp.com
 
 //// Color Declarations
 let fillColor = UIColor(red: 0.957, green: 0.957, blue: 0.957, alpha: 1.000)
 
 //// Bezier Drawing
 let bezierPath = UIBezierPath()
 bezierPath.move(to: CGPoint(x: 1, y: 0))
 bezierPath.addLine(to: CGPoint(x: 192.59, y: 0))
 bezierPath.addCurve(to: CGPoint(x: 206.59, y: 14), controlPoint1: CGPoint(x: 200.32, y: 0), controlPoint2: CGPoint(x: 206.59, y: 6.27))
 bezierPath.addLine(to: CGPoint(x: 206.59, y: 49))
 bezierPath.addCurve(to: CGPoint(x: 192.59, y: 63), controlPoint1: CGPoint(x: 206.59, y: 56.73), controlPoint2: CGPoint(x: 200.32, y: 63))
 bezierPath.addLine(to: CGPoint(x: 24.59, y: 63))
 bezierPath.addCurve(to: CGPoint(x: 10.59, y: 49), controlPoint1: CGPoint(x: 16.85, y: 63), controlPoint2: CGPoint(x: 10.59, y: 56.73))
 bezierPath.addLine(to: CGPoint(x: 10.59, y: 17.8))
 bezierPath.addCurve(to: CGPoint(x: 6.49, y: 7.9), controlPoint1: CGPoint(x: 10.59, y: 14.09), controlPoint2: CGPoint(x: 9.11, y: 10.52))
 bezierPath.addLine(to: CGPoint(x: 0.29, y: 1.71))
 bezierPath.addCurve(to: CGPoint(x: 0.29, y: 0.29), controlPoint1: CGPoint(x: -0.1, y: 1.32), controlPoint2: CGPoint(x: -0.1, y: 0.68))
 bezierPath.addCurve(to: CGPoint(x: 1, y: 0), controlPoint1: CGPoint(x: 0.48, y: 0.11), controlPoint2: CGPoint(x: 0.73, y: 0))
 bezierPath.close()
 bezierPath.usesEvenOddFillRule = true
 fillColor.setFill()
 bezierPath.fill()
 */


/* By Henry on 2020.05.03 for "RIGHT" Chatting Bubble
 // This code was generated by Trial version of PaintCode, therefore cannot be used for commercial purposes.
 // http://www.paintcodeapp.com
 
 //// Color Declarations
 let fillColor = UIColor(red: 0.898, green: 0.082, blue: 0.000, alpha: 1.000)
 
 //// Bezier Drawing
 let bezierPath = UIBezierPath()
 bezierPath.move(to: CGPoint(x: 245.59, y: 0))
 bezierPath.addLine(to: CGPoint(x: 14, y: 0))
 bezierPath.addCurve(to: CGPoint(x: 0, y: 14), controlPoint1: CGPoint(x: 6.27, y: 0), controlPoint2: CGPoint(x: 0, y: 6.27))
 bezierPath.addLine(to: CGPoint(x: 0, y: 31))
 bezierPath.addCurve(to: CGPoint(x: 14, y: 45), controlPoint1: CGPoint(x: 0, y: 38.73), controlPoint2: CGPoint(x: 6.27, y: 45))
 bezierPath.addLine(to: CGPoint(x: 222, y: 45))
 bezierPath.addCurve(to: CGPoint(x: 236, y: 31), controlPoint1: CGPoint(x: 229.73, y: 45), controlPoint2: CGPoint(x: 236, y: 38.73))
 bezierPath.addLine(to: CGPoint(x: 236, y: 17.8))
 bezierPath.addCurve(to: CGPoint(x: 240.1, y: 7.9), controlPoint1: CGPoint(x: 236, y: 14.09), controlPoint2: CGPoint(x: 237.47, y: 10.52))
 bezierPath.addLine(to: CGPoint(x: 246.29, y: 1.71))
 bezierPath.addCurve(to: CGPoint(x: 246.29, y: 0.29), controlPoint1: CGPoint(x: 246.68, y: 1.32), controlPoint2: CGPoint(x: 246.68, y: 0.68))
 bezierPath.addCurve(to: CGPoint(x: 245.59, y: 0), controlPoint1: CGPoint(x: 246.11, y: 0.11), controlPoint2: CGPoint(x: 245.85, y: 0))
 bezierPath.close()
 bezierPath.usesEvenOddFillRule = true
 fillColor.setFill()
 bezierPath.fill()
 
 */
