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

        // Important !!!
        self.delegate = self
        setUI()
    }
    
    
    func setUI() {
        inputTextView.textContainerInset = UIEdgeInsets(top:11, left: 14, bottom: 8, right: 40)
        inputTextView.layer.cornerRadius = 12
        inputTextView.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1
        inputTextView.tintColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
        inputTextView.backgroundColor = .white
        
        fileButton.tintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        micButton.tintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        
        self.messagesConfigurations = addMessageConfiguration()
    }

    fileprivate func addMessageConfiguration() -> OZMessagesConfigurations {
        return [
            // OZMessageCell
            OZMessagesConfigurationItem.fontSize(18.0, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.bubbleBackgroundColor(.blue, .fromCurrent),
            OZMessagesConfigurationItem.bubbleBackgroundColor(.red, .fromOther),
            OZMessagesConfigurationItem.roundedCorner(true, [.announcement]),
            OZMessagesConfigurationItem.cellBackgroundColor(UIColor(red:  204/255, green: 204/255, blue: 204/255, alpha: 1), [.announcement]),
            OZMessagesConfigurationItem.fontColor(UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1), [.announcement], .none),
            OZMessagesConfigurationItem.sepratorColor(.clear),
            // OZTextView
            OZMessagesConfigurationItem.inputTextViewFontColor(.blue),
            OZMessagesConfigurationItem.inputTextUsingEnterToSend(false),
            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(12.0),
        ]
    }

    
    // MARK: - Targets and Actions
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        if let fullText = inputTextView.text {
            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 0 {
                send(msg: trimmed)
            }
            inputTextView.text = ""
            adjustTextViewHeight(inputTextView)
            sendButton.isSelected = false
        }
    }
}

extension ChattingViewController: OZMessagesViewControllerDelegate {
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) {
        let shadowColor = UIColor.black
        if cell.message.type == .text {
            
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowOpacity = 0.2
            cell.layer.shadowRadius = 8
            cell.layer.shadowColor = shadowColor.cgColor
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 12).cgPath

            if let incomingCell = cell as? IncomingTextMessageCell {
                
                if previousMessage.type == .text,
                    previousMessage.alignment == cell.message.alignment {
                    incomingCell.textLabel.type = .noDraw
                    incomingCell.textLabel.layer.cornerRadius = 12.0
                    incomingCell.textLabel.layer.masksToBounds = true
                    incomingCell.textLabel.backgroundColor = .white
                }
                else {
                    incomingCell.textLabel.type = .hasOwnDrawing
                }
            }
            else if let outgoingCell = cell as? OutgoingTextMessageCell {
                
                if previousMessage.type == .text,
                    previousMessage.alignment == cell.message.alignment {
                    outgoingCell.textLabel.type = .noDraw
                    outgoingCell.textLabel.layer.cornerRadius = 12.0
                    outgoingCell.textLabel.layer.masksToBounds = true
                    outgoingCell.textLabel.backgroundColor = UIColor(red: 0.000, green: 0.746, blue: 0.718, alpha: 1.000)
                }
                else {
                    outgoingCell.textLabel.type = .hasOwnDrawing
                }
            }
        }
        cell.setNeedsLayout()
    }
    
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage) {
        if cell.message.alignment == .left {
            switch cell.message.type {
            case .text:
                guard let incomingCell = cell as? IncomingTextMessageCell else { return }
                incomingCell.iconImage.isHidden = true
                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                incomingCell.textLabel.frame = incomingCell.bounds.inset(by: inset)
            case .image, .emoticon:
                guard let incomingCell = cell as? ImageMessageCell else { return }
                incomingCell.iconImage.isHidden = true
                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                incomingCell.imageView.frame = incomingCell.bounds.inset(by: inset)
            case .voice, .mp3:
                guard let incomingCell = cell as? AudioPlusIconMessageCell else { return }
                incomingCell.iconImage.isHidden = true
                let inset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                incomingCell.backView.frame = incomingCell.bounds.inset(by: inset)
            default:
                print(".....\(cell.message.type), prevMsg(\(String(describing: previousMessage))).....")
            }
        }
    }

    func messageSending(identifier: String, type: OZMessageType, data: OZMessage) {
        // code
    }
    
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock) {
        // code
    }
    
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock) {
        // code
    }
    
    func messageTextViewBeginEditing(textView: UITextView) {
    }
    func messageTextViewDidChanged(textView: UITextView) {
        sendButton.isSelected = true
    }
    func messageTextViewEndEditing(textView: UITextView) {
        sendButton.isSelected = false
    }
    
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return true
    }
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return true
    }
}
