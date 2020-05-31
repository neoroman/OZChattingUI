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
    
    // MARK: - IBOutlet
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var keyboardButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var micMotionButton: UIButton!
    @IBOutlet weak var micCircleView: UIView?
    
    // MARK: - Property
    var isSuccessToSend: Bool = true
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Important !!!
        self.delegate = self
        setUI()
        setDefaultState()
    }
    
    // MARK: - Targets and Actions
    
    /// 메시지 전송
    @IBAction func pressedSendButton(_ sender: UIButton) {
        if let fullText = inputTextView.text {
            let trimmed = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 0 {
                send(msg: trimmed)
            }
            inputTextView.text.removeAll()
            adjustTextViewHeight(inputTextView)
            sendButton.isEnabled = false
        }
        //        setFailToSending()
    }
    
    /// 텍스트 입력 상태로 전환
    @IBAction func pressedKeyboardButton(_ sender: UIButton) {
        setDefaultState()
        inputTextView.becomeFirstResponder()
        //        expandInputView()
    }
    
    /// 음성 인식 상태로 전환
    @IBAction func pressedMicButton(_ sender: UIButton) {
        setDefaultState()
        keyboardButton.isHidden = false
        micButton.isHidden = true
        sendButton.isHidden = true
        setSuccessToMic()
        
        //        setFailToMic()
    }
    
    /// 입력한 텍스트 삭제
    @IBAction func pressedClearButton(_ sender: UIButton) {
        setDefaultState()
    }
    
    ///
    @IBAction func pressedMicMotionButton(_ sender: UIButton) {
        
    }
    
    // MARK: - Function
    /// 최초 UI 설정
    fileprivate func setUI() {
        self.view.backgroundColor = UIColor(red: 228/255, green: 232/255, blue: 232/255, alpha: 1.0)
        
        inputTextView.textContainerInset = UIEdgeInsets(top: 11, left: 14, bottom: 8, right: 40)
        inputTextView.layer.cornerRadius = 12
        inputTextView.layer.borderColor = UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1).cgColor
        inputTextView.layer.borderWidth = 1
        
        inputTextView.backgroundColor = .white
        messageTextViewBeginEditing(textView: inputTextView)
        //        timeLabel.text = "\(Date.formDateForChat(timestamp: message.timestamp))"
        fileButton.tintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1) // tint 안하고 이미지로 되도록
        micButton.tintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        keyboardButton.tintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        
        self.messagesConfigurations = addMessageConfiguration()
    }
    
    /// View, Button의 default 상태 설정
    fileprivate func setDefaultState() {
        inputTextView.textColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
        inputTextView.tintColor = UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1)
        inputTextView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 16)
        inputTextView.isEditable = true
        inputTextView.text.removeAll()
        adjustTextViewHeight(inputTextView)
        
        sendButton.setImage(UIImage(named: "btnCallEnterOn"), for: .normal)
        sendButton.isHidden = false
        sendButton.isEnabled = false
        
        clearButton.isHidden = true
        micMotionButton.isHidden = true
        micCircleView?.isHidden = true
        
        micButton.isHidden = false
        keyboardButton.isHidden = true
        
        isSuccessToSend = true
        //        sendButton.isEnabled = true // 임시
    }
    
    fileprivate func addMessageConfiguration() -> OZMessagesConfigurations {
        return [
            // OZMessageCell
            OZMessagesConfigurationItem.fontSize(18.0, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.roundedCorner(true, [.announcement]),
            OZMessagesConfigurationItem.cellBackgroundColor(UIColor(red:  204/255, green: 204/255, blue: 204/255, alpha: 1), [.announcement]),
            OZMessagesConfigurationItem.fontColor(UIColor(red: 119/255, green: 119/255, blue: 119/255, alpha: 1), [.announcement], .none),
            OZMessagesConfigurationItem.sepratorColor(.clear),
            OZMessagesConfigurationItem.timeFontSize(12.0), //? time포맷바꿔야됨
            OZMessagesConfigurationItem.timeFontColor(UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)),
            // OZTextView
            OZMessagesConfigurationItem.inputTextViewFontColor(.blue),
            OZMessagesConfigurationItem.inputTextUsingEnterToSend(false),
            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(12.0)
        ]
    }
    
    /// 긴 inputView에 대한 설정
    fileprivate func expandInputView() {
        micButton.isHidden = true
        inputTextView.trailingAnchor.constraint(equalTo: self.micButton.trailingAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: self.micButton.trailingAnchor).isActive = true
    }
    
    /// 메시지 전송 실패 뷰 설정
    fileprivate func setFailToSending() {
        if isSuccessToSend {
            inputTextView.text += "\n전달실패"
            let attr = NSMutableAttributedString(string: inputTextView.text)
            attr.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1),
                              range: NSMakeRange(0, inputTextView.text.count - 4))
            attr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),
                              value: UIFont(name:"AppleSDGothicNeo-Regular", size: 16),
                              range: NSMakeRange(0, inputTextView.text.count - 4))
            attr.addAttribute(NSAttributedString.Key.foregroundColor,
                              value: UIColor(red: 248/255, green: 72/255, blue: 94/255, alpha: 1),
                              range: (inputTextView.text as NSString).range(of: "전달실패"))
            attr.addAttribute(NSAttributedString.Key.init(kCTFontAttributeName as String),
                              value: UIFont(name:"AppleSDGothicNeo-Regular", size: 12),
                              range: (inputTextView.text as NSString).range(of: "전달실패"))
            
            inputTextView.attributedText = attr
            isSuccessToSend = false
        }
        
        sendButton.setImage(UIImage(named: "btnCallCancel"), for: .normal)
        clearButton.isHidden = false
        inputTextView.isEditable = false
        inputTextView.tintColor = .clear
        adjustTextViewHeight(inputTextView)
    }
    
    /// 음성 인식 가능한 상태 뷰 설정
    fileprivate func setSuccessToMic() {
        setMicGuideText("말씀하세요. 마이크가 켜져있습니다.")
        micMotionButton.isHidden = false
        
        micCircleView?.isHidden = false
        micCircleView?.layer.cornerRadius = 15
        micCircleView?.clipsToBounds = true
        
        inputTextView.isEditable = false
    }
    
    /// 음성 인식 불가한 상태 뷰 설정
    fileprivate func setFailToMic() {
        setMicGuideText("마이크를 사용할 수 없습니다.")
        micMotionButton.isHidden = false
        micMotionButton.isEnabled = false
        sendButton.isHidden = true
        
        inputTextView.resignFirstResponder()
        inputTextView.isEditable = false
    }
    
    /// 마이크 상태에 대한 안내 문구 설정
    /// - Parameter text: 안내 문구 텍스트
    fileprivate func setMicGuideText(_ text: String) {
        inputTextView.text.removeAll()
        adjustTextViewHeight(inputTextView)
        inputTextView.text = text
        inputTextView.font = UIFont(name:"AppleSDGothicNeo-Medium", size: 12)
        inputTextView.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1)
        inputTextView.centerVerticalText()
    }
    
}

// MARK: - OZMessagesViewControllerDelegate
extension ChattingViewController: OZMessagesViewControllerDelegate {
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) {
        if cell.message.type == .text {
            
            /* TODO: need more survey by Henry on 2020.05.31
            let shadowColor = UIColor.black
            cell.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.layer.shadowOpacity = 0.2
            cell.layer.shadowRadius = 8
            cell.layer.shadowColor = shadowColor.cgColor
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: 12).cgPath
             */
            
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
        sendButton.isEnabled = true
    }
    
    func messageTextViewEndEditing(textView: UITextView) {
        
    }
    
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return true
    }
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool {
        return true
    }
}

// MARK: - UITextView extension
extension UITextView {
    /// 텍스트뷰의 텍스트를 세로 가운데에 위치 설정
    func centerVerticalText() {
        let fitSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fitSize)
        let calculate = (bounds.size.height - size.height * zoomScale) / 2
        let offset = max(1, calculate)
        contentOffset.y = -offset
    }
}
