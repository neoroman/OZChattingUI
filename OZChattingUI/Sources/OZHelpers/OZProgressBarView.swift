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
//  ProgressImageView.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/06.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

open class OZProgressBarView: UIView {

    @IBInspectable var radius: CGFloat = 7
    @IBInspectable var progressColor: UIColor = .red
    
    fileprivate let maxCount: TimeInterval = 10
    fileprivate var counter: TimeInterval = 0
    var progress: CGFloat = 0.0 {
        didSet {
            if progress == 0, oldValue == 1 {
                delay(0.05) {
                    self.setNeedsDisplay()
                }
            }
            else if progress == 0 || progress == 1 {
                self.setNeedsDisplay()
            }
            else if oldValue < progress {
                Timer.scheduledTimer(withTimeInterval: TimeInterval(progress - oldValue)/maxCount, repeats: true) { (aTimer) in
                    self.setNeedsDisplay()
                    self.counter += 1
                    if self.progress >= 1.0 || self.counter >= self.maxCount {
                        aTimer.invalidate()
                        self.counter = 0
                    }
                }
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        let width = rect.width
        let height = rect.height
        let cornerRatio: CGFloat = 6.27 / 14.0
        let cntlRadius: CGFloat = radius * cornerRatio
        let progressWidth: CGFloat = width * progress
        
        let bezierPath = UIBezierPath()
        ///CCW
        // right-top corner
        bezierPath.move(to: CGPoint(x: progressWidth, y: 0))
        
        // top wall
        bezierPath.addLine(to: CGPoint(x: radius, y: 0))
        
        // left-top corner
        bezierPath.addCurve(to: CGPoint(x: 0, y: radius), controlPoint1: CGPoint(x: cntlRadius, y: 0), controlPoint2: CGPoint(x: 0, y: cntlRadius))
        
        // left wall
        bezierPath.addLine(to: CGPoint(x: 0, y: height-radius))
        
        // left-bottom corner
        bezierPath.addCurve(to: CGPoint(x: radius, y: height), controlPoint1: CGPoint(x: 0, y: height-cntlRadius), controlPoint2: CGPoint(x: cntlRadius, y: height))
        

        if width - radius >= progressWidth {
            // bottom line
            bezierPath.addLine(to: CGPoint(x: progressWidth, y: height))
            
            bezierPath.addLine(to: CGPoint(x: progressWidth, y: 0))
        }
        else {
            // bottom line
            bezierPath.addLine(to: CGPoint(x: width-radius, y: height))
            
            // right-bottom corner
            bezierPath.addCurve(to: CGPoint(x: progressWidth, y: height-radius*progress),
                                controlPoint1: CGPoint(x: progressWidth-cntlRadius/progress, y: height),
                                controlPoint2: CGPoint(x: progressWidth, y: height-cntlRadius/progress))
            
            bezierPath.addLine(to: CGPoint(x: progressWidth, y: radius*progress))
            
            // right-top corner
            bezierPath.addCurve(to: CGPoint(x: progressWidth-radius, y: 0),
                                controlPoint1: CGPoint(x: progressWidth, y: cntlRadius/progress),
                                controlPoint2: CGPoint(x: progressWidth-cntlRadius/progress, y: 0))
        }
        progressColor.setFill()
        
        bezierPath.close()
        bezierPath.fill()
        
        
        super.draw(rect)
    }

}
