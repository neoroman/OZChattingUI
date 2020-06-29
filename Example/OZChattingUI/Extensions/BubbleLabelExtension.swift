//
//  BubbleLabelExtension.swift
//  OZChattingUI_Example
//
//  Created by Henry Kim on 2020/05/27.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit
import OZChattingUI


let kBubbleRadius: CGFloat = 12.0
let kNotchInsetX: CGFloat = 4.0 / 12.0 * kBubbleRadius


extension OZBubbleLabel {
    
    override open func draw(_ rect: CGRect) {
        let radius: CGFloat = kBubbleRadius

        if type == .hasOwnDrawing {
            notchInsetX = kNotchInsetX
            
            let width = bounds.width
            let height = bounds.height
            
            let cornerRatio: CGFloat = 5.37 / 12.0
            let cntlRadius: CGFloat = radius * cornerRatio
            
            let startX: CGFloat = radius
            
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
        else if type == .basic {
            let width = bounds.width
            let height = bounds.height * heightRatio
            
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
//        var insetX = kNotchInsetX
//        if type == .basic {
//            insetX = 10
//        }
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
