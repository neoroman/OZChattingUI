//
//  ImageCounterView.swift
//  Money
//
//  Created by Kristian Angyal on 07/03/2016.
//  Copyright © 2016 Mail Online. All rights reserved.
//

import UIKit

class CounterView: UIView {
    
    var count: Int
    let countLabel = UILabel()
    var currentIndex: Int {
        didSet {
            updateLabel()
        }
    }
    
    init(frame: CGRect, currentIndex: Int, count: Int) {
        
        self.currentIndex = currentIndex
        self.count = count
        
        super.init(frame: frame)
        
        configureLabel()
        updateLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel() {
        
        countLabel.textAlignment = .center
        self.addSubview(countLabel)
    }
    
    func updateLabel() {
        
        let stringTemplate = "%d of %d"
        let countString = String(format: stringTemplate, arguments: [currentIndex + 1, count])
        
        countLabel.attributedText = NSAttributedString(string: countString, attributes: [NSAttributedString.Key.font: UIFont(name: "AppleSDGothicNeo-Medium" , size: 16) as Any, NSAttributedString.Key.foregroundColor: UIColor(white: 153.0 / 255.0, alpha: 1.0)])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        countLabel.frame = self.bounds
    }
}
