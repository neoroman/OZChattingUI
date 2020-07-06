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
//  OZTextView.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/07.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

open class OZTextView: UITextView {

    public var inputTextViewFontColor = UIColor.black {
        didSet {
            if textColor != inputTextViewFontColor {
                textColor = inputTextViewFontColor
            }
        }
    }
    
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
    }
}
