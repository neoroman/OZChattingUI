//
//  ChattingViewController.swift
//  OZChattingUI_Example
//
//  Created by 이재은 on 2020/05/28.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import OZChattingUI

class ChattingViewController: OZMessagesViewController {

    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        if let fullText = inputTextView.text {
            self.send(msg: fullText)
            self.inputTextView.text = ""
//            self.adjustTextViewHeight(inputTextView)
            sendButton.isSelected = false
        }
    }
    
    func setUI() {
        inputTextView.textContainerInset = UIEdgeInsets(top:11, left: 14, bottom: 8, right: 40)
        inputTextView.layer.cornerRadius = 12
        inputTextView.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.tintColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
        
        fileButton.tintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        micButton.tintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
    }

}

extension ChattingViewController {
    
}
