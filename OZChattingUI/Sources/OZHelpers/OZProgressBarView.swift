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
    
    @IBInspectable var imageTintColorDesired: UIColor = .black
    @IBInspectable var imageTintColorOriginal: UIColor = .white
    weak var tintColoredImageView: UIImageView?
    weak var tintColoredImage: UIImage?
    
    fileprivate let maxCount: TimeInterval = 10
    fileprivate var counter: TimeInterval = 0
    var progress: CGFloat = 0.0 {
        didSet {
            if oldValue < progress {
                Timer.scheduledTimer(withTimeInterval: TimeInterval(progress - oldValue)/maxCount, repeats: true) { (aTimer) in
                    self.setNeedsDisplay()
                    self.counter += 1
                    /* TODO: Do something here ... by Henry on 2020.05.06
                    if let anImgView = self.tintColoredImageView,
                        let anImg = anImgView.image,
                        let oImg = self.tintColoredImage,
                        anImg == oImg {
                        anImgView.image = anImg.withRenderingMode(.alwaysTemplate)
                        if self.bounds.width * self.progress < anImgView.frame.midX {
                            anImgView.tintColor = self.imageTintColorDesired
                        }
                        else {
                            anImgView.tintColor = self.imageTintColorOriginal
                        }
                    }
                    */
                    
                    if self.counter >= self.maxCount {
                        aTimer.invalidate()
                        self.counter = 0
                    }
                }
            }
            self.setNeedsDisplay()
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
