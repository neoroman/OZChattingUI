//
//  OZMessagesViewProtocol.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/29.
//

import UIKit


// MARK: - OZMessageCellDelegate
protocol OZMessageCellDelegate {
    func messageCellDidSetMessage(cell: OZMessageCell)
    func messageCellLayoutSubviews(cell: OZMessageCell)
    
    /// Long message folding option need buttons to display, so they have own tag {Int}
    func messageCellLongMessageFoldingButtons(cell: OZMessageCell) -> [(UIButton, OZMessageFoldState)]
    
    /// Long message folding and unfolding button action
    func messageCellLongMessageButtonTapped(cell: OZMessageCell, view: UIView)
}

extension OZMessageCellDelegate {
    func messageCellLongMessageFoldingButtons(cell: OZMessageCell) -> [(UIButton, OZMessageFoldState)] { return [(UIButton(), .none)] }
    func messageCellLongMessageButtonTapped(cell: OZMessageCell, view: UIView) { }
}


// MARK: - OZMessagesViewControllerDelegate
public protocol OZMessagesViewControllerDelegate {
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage) -> Bool
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock)
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock)

    /// This configurations will override previous configurations
    func messageConfiguration(viewController: OZMessagesViewController) -> OZMessagesConfigurations

    
    // Optional from here
    func messageViewLoaded(isLoaded: Bool)
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage)
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage, nextMessage: OZMessage?)
    func messageInputTextViewWillShow(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat)
    func messageInputTextViewWillHide(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat)
    func messageTextViewBeginEditing(textView: UITextView)
    func messageTextViewDidChanged(textView: UITextView)
    func messageTextViewEndEditing(textView: UITextView)
    
    
    /// Mic button tapped, should return boolean for `internal` processing or not
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool
    func messageMicWillRequestRecordPermission(viewController: OZVoiceRecordViewController)

    /// Emotocon button tapped, should return boolean for `internal` processing or not
    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool
    
    /// File button tapped, should return boolean for `internal` processing or not
    func messageFileButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool

    /// Long message folding and unfolding button action
    func messageCellLongMessageButtonTapped(cell: OZMessageCell, view: UIView, isFolded: Bool) -> Bool
}
// MARK: - Optional OZMessagesViewControllerDelegate
public extension OZMessagesViewControllerDelegate {
    func messageViewLoaded(isLoaded: Bool) { }
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage) { }
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage, nextMessage: OZMessage?) { }
    func messageInputTextViewWillShow(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat) { }
    func messageInputTextViewWillHide(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat) { }
    func messageTextViewBeginEditing(textView: UITextView) { }
    func messageTextViewDidChanged(textView: UITextView) { }
    func messageTextViewEndEditing(textView: UITextView) { }
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    func messageMicWillRequestRecordPermission(viewController: OZVoiceRecordViewController) { }

    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    func messageFileButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    
    func messageCellLongMessageButtonTapped(cell: OZMessageCell, view: UIView, isFolded: Bool) -> Bool { return true }
}
