/*
MIT License

Copyright (c) 2020 OZChattingUI, Henry Kim <neoroman@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
//
//  OZBubbleImageView.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/04.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

open class OZBubbleImageView: UIImageView {
    
    @IBInspectable var topInset: CGFloat = 5.0
    @IBInspectable var bottomInset: CGFloat = 5.0
    @IBInspectable var leftInset: CGFloat = 10.0
    @IBInspectable var rightInset: CGFloat = 10.0
    @IBInspectable var notchInsetXRatio: CGFloat = 0.65
    
    var isIncoming = true
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)

        let width = bounds.width
        let height = bounds.height
        
        let radius: CGFloat = 12.0
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
            //bezierPath.addCurve(to: CGPoint(x: 10.59, y: 49), controlPoint1: CGPoint(x: 16.85, y: 63), controlPoint2: CGPoint(x: 10.59, y: 56.73))

            // left wall
            bezierPath.addLine(to: CGPoint(x: notchInsetX, y: notchMaxY))
            
            // bubble notch
            bezierPath.addCurve(to: notchEndPoint, controlPoint1: notchControl1, controlPoint2: notchControl2)
            bezierPath.addLine(to: srStartPoint)
            bezierPath.addCurve(to: sr1EndPoint, controlPoint1: sr1Control1, controlPoint2: sr1Control2)
            bezierPath.addCurve(to: CGPoint(x: startX, y: 0), controlPoint1: sr2Control1, controlPoint2: CGPoint(x: sr2Control2X, y: 0))
                        
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
            bezierPath.addLine(to: CGPoint(x: width-notchInsetX-radius, y: height))
            
            // right-bottom corner
            bezierPath.addCurve(to: CGPoint(x: width-notchInsetX, y: height-radius),
                                controlPoint1: CGPoint(x: width-notchInsetX-cntlRadius, y: height),
                                controlPoint2: CGPoint(x: width-notchInsetX, y: height-cntlRadius))
            
            // right wall
            bezierPath.addLine(to: CGPoint(x: width-notchInsetX, y: notchMaxY))
            
            // bubble notch
            bezierPath.addCurve(to: CGPoint(x: width-notchEndPoint.x, y: notchEndPoint.y),
                                controlPoint1: CGPoint(x: width-notchControl1.x, y: notchControl1.y),
                                controlPoint2: CGPoint(x: width-notchControl2.x, y: notchControl2.y))
            bezierPath.addLine(to: CGPoint(x: width-srStartPoint.x, y: srStartPoint.y))
            bezierPath.addCurve(to: CGPoint(x: width-sr1EndPoint.x, y: sr1EndPoint.y),
                                controlPoint1: CGPoint(x: width+sr1Control1.x, y: sr1Control1.y),
                                controlPoint2: CGPoint(x: width+sr1Control2.x, y: sr1Control2.y))
            bezierPath.addCurve(to: CGPoint(x: width-startX, y: 0),
                                controlPoint1: CGPoint(x: width-sr2Control1.x, y: sr2Control1.y),
                                controlPoint2: CGPoint(x: width-sr2Control2X, y: 0))
            
        }
        
        UIColor.orange.setFill()
        
        bezierPath.close()
        bezierPath.fill()

        bezierPath.addClip()

        let mask            = CAShapeLayer()
        mask.path           = bezierPath.cgPath
        self.layer.mask     = mask
    }
        
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.masksToBounds = true
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
