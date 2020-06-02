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
    
    // Optional from here
    func messageViewLoaded(isLoaded: Bool)
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage)
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage)
    func messageInputTextViewWillShow(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat)
    func messageInputTextViewWillHide(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat)
    func messageTextViewBeginEditing(textView: UITextView)
    func messageTextViewDidChanged(textView: UITextView)
    func messageTextViewEndEditing(textView: UITextView)
    
    /// This configurations will override previous configurations
    func messageConfiguration(viewController: OZMessagesViewController) -> OZMessagesConfigurations
    
    /// Mic button tapped, should return boolean for `internal` processing or not
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool

    /// Emotocon button tapped, should return boolean for `internal` processing or not
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool
    
    /// File button tapped, should return boolean for `internal` processing or not
    func messageFileButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool

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
    func messageConfiguration(viewController: OZMessagesViewController) -> OZMessagesConfigurations {
        return []
    }
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    func messageFileButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
}
