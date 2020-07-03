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
//  OZCircleProgressView.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/07.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

@IBDesignable
open class OZCircleProgressView: UIView {
    var duration: CFTimeInterval = 0
    @IBInspectable var width: CGFloat = 0
    @IBInspectable var color: UIColor = UIColor.blue
    @IBInspectable var bgColor: UIColor = UIColor.clear
    
    fileprivate var startAngle: CGFloat = 0
    fileprivate var endAngle: CGFloat = 0
    
    fileprivate var rect = CGRect.zero
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override open func draw(_ rect: CGRect) {
        // Drawing code
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let frame = self.frame
        initialize(frame)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize(frame)
    }
    
    internal func initialize(_ rect: CGRect) {
        startAngle = .pi * 1.5
        endAngle = startAngle + ( .pi * 2)
        self.rect = rect
        self.layer.cornerRadius = frame.size.width/2
    }
    
    func progress() {
        progress(from: 0, to: 1, duration: self.duration)
    }
    
    func progress(from: Any, to: Any, duration: TimeInterval) {
        
        var progressCircle = CAShapeLayer()
        let circleCenter = CGPoint(x: self.rect.size.width/2, y: self.rect.size.height/2)
        let circleRadius = self.rect.size.width/2-self.width/2
        let circlePath = UIBezierPath(arcCenter: circleCenter, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)// (ovalIn: self.bounds)
        
        progressCircle = CAShapeLayer ()
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = self.color.cgColor
        progressCircle.fillColor = self.bgColor.cgColor
        progressCircle.lineWidth = self.width
        
        self.layer.addSublayer(progressCircle)
        
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = true
        
        progressCircle.add(animation, forKey: "ani")
    }
    
    func stopAnimation(forced: Bool = false) {
        self.subviews.forEach {$0.layer.removeAllAnimations()}
        self.layer.removeAllAnimations()
        if forced {
            self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        }
        self.layoutIfNeeded()

        duration = 0
        startAngle = 0
        endAngle = 0
    }
}
