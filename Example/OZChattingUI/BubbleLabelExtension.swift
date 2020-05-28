//
//  BubbleLabelExtension.swift
//  OZChattingUI_Example
//
//  Created by Henry Kim on 2020/05/27.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import OZChattingUI


extension OZBubbleLabel {
    
    override open func draw(_ rect: CGRect) {
        
        if type == .hasOwnDrawing {
            let radius: CGFloat = 12.0
            
            var width = rect.width
            var height = rect.height
            if height < 60,
                let aText = self.attributedText?.string,
                aText.isHangul() {
                height = (height <= 44) ? height : height - 9
                width = width - 2
            }
            
            let cornerRatio: CGFloat = 5.37 / 12.0
            let cntlRadius: CGFloat = radius * cornerRatio
            
            let startX: CGFloat = radius
            
            let notchInsetX: CGFloat = 4.0 / 12.0 * radius
            let notchHeight: CGFloat = 8.0 / 12.0 * radius
            let notchRadius: CGFloat = 3.0 / 12.0 * radius
            let notchCircleStartPoint = CGPoint(x: width-notchInsetX + (3.6/12.0*radius),
                                                y: height-notchHeight + (4.8/12.0*radius))
            
            let notchCircle1stEndPoint = CGPoint(x: width - (0.8/12.0*radius),
                                                 y: height - (0.4/12.0*radius))
            let notchCircle1stCntlPoint1 = CGPoint(x: width + (0.27/12.0*radius),
                                                   y: height-notchRadius + (0.69/12.0*radius))
            let notchCircle1stCntlPoint2 = CGPoint(x: width + (0.09/12.0*radius),
                                                   y: height-notchRadius + (1.94/12.0*radius))
            
            let notchCircle2ndCntlPoint1 = CGPoint(x: width - (1.14/12.0*radius),
                                                   y: height - (0.14/12.0*radius))
            let notchCircle2ndCntlPoint2 = CGPoint(x: width - (1.56/12.0*radius),
                                                   y: height)
            let notchCircle2ndEndPoint = CGPoint(x: width-(2.0/12.0 * radius),
                                                 y: height)
            
            let bezierPath = UIBezierPath()
            
            if isIncoming {
                ///CCW
                // right-bottom corner
                bezierPath.move(to: CGPoint(x: width - radius, y: height))
                
                bezierPath.addCurve(to: CGPoint(x: width, y: height - radius),
                                    controlPoint1: CGPoint(x: width - cntlRadius, y: height),
                                    controlPoint2: CGPoint(x: width, y: height - cntlRadius))
                
                // right wall
                bezierPath.addLine(to: CGPoint(x: width, y: radius))
                
                // right-top corner
                bezierPath.addCurve(to: CGPoint(x: width - radius, y: 0),
                                    controlPoint1: CGPoint(x: width, y: cntlRadius),
                                    controlPoint2: CGPoint(x: width - cntlRadius, y: 0))
                
                // top wall
                bezierPath.addLine(to: CGPoint(x: radius + notchInsetX, y: 0))
                
                // left-top corner
                bezierPath.addCurve(to: CGPoint(x: notchInsetX, y: radius),
                                    controlPoint1: CGPoint(x: notchInsetX + cntlRadius, y: 0),
                                    controlPoint2: CGPoint(x: notchInsetX, y: cntlRadius))
                
                // left wall
                bezierPath.addLine(to: CGPoint(x: notchInsetX, y: height - notchHeight))
                
                // slope line of notch
                bezierPath.addLine(to: CGPoint(x: width - notchCircleStartPoint.x, y: notchCircleStartPoint.y))
                
                // bubble notch
                bezierPath.addCurve(to: CGPoint(x: width - notchCircle1stEndPoint.x, y: notchCircle1stEndPoint.y),
                                    controlPoint1: CGPoint(x: width - notchCircle1stCntlPoint1.x, y: notchCircle1stCntlPoint1.y),
                                    controlPoint2: CGPoint(x: width - notchCircle1stCntlPoint2.x, y: notchCircle1stCntlPoint2.y))
                bezierPath.addCurve(to: CGPoint(x: width - notchCircle2ndEndPoint.x, y: notchCircle2ndEndPoint.y),
                                    controlPoint1: CGPoint(x: width - notchCircle2ndCntlPoint1.x, y: notchCircle2ndCntlPoint1.y),
                                    controlPoint2: CGPoint(x: width - notchCircle2ndCntlPoint2.x, y: notchCircle2ndCntlPoint2.y))
                
                // bottom wall
                bezierPath.addLine(to: CGPoint(x: width - radius, y: height))
                
                UIColor.white.setFill()
                
            } else {
                
                //// Bezier Drawing - CW
                // left-bottom start
                bezierPath.move(to: CGPoint(x: startX, y: height))
                
                // left-bottom corner
                bezierPath.addCurve(to: CGPoint(x: 0, y: height-radius), controlPoint1: CGPoint(x: cntlRadius, y: height), controlPoint2: CGPoint(x: 0, y: height-cntlRadius))
                
                // left wall
                bezierPath.addLine(to: CGPoint(x: 0, y: radius))
                
                // left-top corner
                bezierPath.addCurve(to: CGPoint(x: radius, y: 0), controlPoint1: CGPoint(x: 0, y: cntlRadius), controlPoint2: CGPoint(x: cntlRadius, y: 0))
                
                // top wall
                bezierPath.addLine(to: CGPoint(x: width-notchInsetX-radius, y: 0))
                
                // right-top corner
                bezierPath.addCurve(to: CGPoint(x: width-notchInsetX, y: radius), controlPoint1: CGPoint(x: width-notchInsetX-cntlRadius, y: 0), controlPoint2: CGPoint(x: width-notchInsetX, y: cntlRadius))
                
                // right wall
                bezierPath.addLine(to: CGPoint(x: width-notchInsetX, y: height - notchHeight))
                
                // slope line of notch
                bezierPath.addLine(to: notchCircleStartPoint)
                
                // bubble notch
                bezierPath.addCurve(to: notchCircle1stEndPoint,
                                    controlPoint1: notchCircle1stCntlPoint1,
                                    controlPoint2: notchCircle1stCntlPoint2)
                bezierPath.addCurve(to: notchCircle2ndEndPoint,
                                    controlPoint1: notchCircle2ndCntlPoint1,
                                    controlPoint2: notchCircle2ndCntlPoint2)
                
                
                // bottom wall
                bezierPath.addLine(to: CGPoint(x: radius, y: height))
                
                //outgoingColor.setFill()
                UIColor(red: 0.000, green: 0.746, blue: 0.718, alpha: 1.000).setFill()
                
            }
            
            bezierPath.close()
            bezierPath.fill()
            
        }

        super.draw(rect)
    }
    
}
