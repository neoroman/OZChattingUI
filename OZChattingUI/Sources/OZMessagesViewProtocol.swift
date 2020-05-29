//
//  OZMessagesViewProtocol.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/29.
//

import UIKit

// MARK: - OZMessagesViewControllerDelegate
public protocol OZMessagesViewControllerDelegate {
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage)
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock)
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock)
    func messageViewLoaded(isLoaded: Bool)
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage)
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage)
    func messageInputTextViewWillShow(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat)
    func messageInputTextViewWillHide(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat)
    func messageTextViewBeginEditing(textView: UITextView)
    func messageTextViewDidChanged(textView: UITextView)
    func messageTextViewEndEditing(textView: UITextView)
    
    /// TODO: not implemented yet 
    func messageConfiguration(configuration: Any)
    
    /// Mic button tapped, should return boolean for processing or not
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool

    /// Emotocon button tapped, should return boolean for processing or not
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool
}
// MARK: - Optional OZMessagesViewControllerDelegate
public extension OZMessagesViewControllerDelegate {
    func messageViewLoaded(isLoaded: Bool) { }
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) { }
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage) { }
    func messageInputTextViewWillShow(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat) { }
    func messageInputTextViewWillHide(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat) { }
    func messageTextViewBeginEditing(textView: UITextView) { }
    func messageTextViewDidChanged(textView: UITextView) { }
    func messageTextViewEndEditing(textView: UITextView) { }
    func messageConfiguration(configuration: Any) { }
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
}
