//
//  OZTextView.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/07.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

open class OZTextView: UITextView {

    public var inputTextViewFontColor = UIColor.black
    
    public enum VerticalAlignment: Int {
        case Top = 0, Middle, Bottom
    }

    public var verticalAlignment: VerticalAlignment = .Middle

    //override contentSize property and observe using didSet
    override open var contentSize: CGSize {
        didSet {
            let textView = self
            let height = textView.bounds.size.height
            let contentHeight:CGFloat = contentSize.height
            var topCorrect: CGFloat = 0.0
            switch(self.verticalAlignment){
            case .Top:
                textView.contentOffset = CGPoint.zero //set content offset to top
           case .Middle:
                topCorrect = (height - contentHeight * textView.zoomScale)/2.0
                topCorrect = topCorrect < 0 ? 0 : topCorrect
                textView.contentOffset = CGPoint(x: 0, y: -topCorrect)
           case .Bottom:
                topCorrect = textView.bounds.size.height - contentHeight
                topCorrect = topCorrect < 0 ? 0 : topCorrect
                textView.contentOffset = CGPoint(x: 0, y: -topCorrect)
            }
            if contentHeight >= height { //if the contentSize is greater than the height
                topCorrect = contentHeight - height //set the contentOffset to be the
                topCorrect = topCorrect < 0 ? 0 : topCorrect //contentHeight - height of textView
                textView.contentOffset = CGPoint(x: 0, y: topCorrect)
            }
        }
    }

    // MARK: - UIView

    override open func layoutSubviews() {
        super.layoutSubviews()
        let size = self.contentSize //forces didSet to be called
        self.contentSize = size
        
        self.textColor = inputTextViewFontColor
    }
}
