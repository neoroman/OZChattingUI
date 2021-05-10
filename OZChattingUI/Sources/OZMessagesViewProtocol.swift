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
//  OZMessagesViewProtocol.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/29.
//

import UIKit


////////////////////////////////////////////////////////////////////////////////
// MARK: - OZMessageDelegate
////////////////////////////////////////////////////////////////////////////////
protocol OZMessageDelegate {
    
    /// Optional from here
    
    /// Messages vertical padding between messages
    func verticalPaddingBetweenMessage(message: OZMessage, previousMessage: OZMessage) -> CGFloat
}
extension OZMessageDelegate {
    func verticalPaddingBetweenMessage(message: OZMessage, previousMessage: OZMessage) -> CGFloat { return 0 }
}


////////////////////////////////////////////////////////////////////////////////
// MARK: - OZMessageCellDelegate
////////////////////////////////////////////////////////////////////////////////
protocol OZMessageCellDelegate {
    func cellDidSetMessage(cell: OZMessageCell)
    func cellLayoutSubviews(cell: OZMessageCell)
    
    /// Optional from here
    ///
    /// Long message folding option need buttons to display, so they have own tag {Int}
    func cellLongMessageFoldingButtons(cell: OZMessageCell) -> [(UIButton, OZMessageFoldState)]
    
    /// Long message folding and unfolding button action
    func cellLongMessageButtonTapped(cell: OZMessageCell, view: UIView)
    
    /// Multiple image tapped
    func cellMultipleImageTapped(cell: OZMessageCell, view: UIImageView, index: Int)
}

extension OZMessageCellDelegate {
    func cellLongMessageFoldingButtons(cell: OZMessageCell) -> [(UIButton, OZMessageFoldState)] { return [(UIButton(), .none)] }
    func cellLongMessageButtonTapped(cell: OZMessageCell, view: UIView) { }
    func cellMultipleImageTapped(cell: OZMessageCell, view: UIImageView, index: Int) { }
}


////////////////////////////////////////////////////////////////////////////////
// MARK: - OZMessagesViewControllerDelegate
////////////////////////////////////////////////////////////////////////////////
public protocol OZMessagesViewControllerDelegate {
    func messageSending(identifier: String, type: OZMessageType, data: OZMessage) -> Bool
    func messageAppend(complete: @escaping OZChatFetchCompleteBlock)
    func messageCellTapped(cell: OZMessageCell, index: Int, complete: @escaping OZChatTapCompleteBlock)

    /// This configurations will override previous configurations
    func messageConfiguration(viewController: OZMessagesViewController) -> OZMessagesConfigurations

    
    /// Optional from here
    ///
    func messageViewLoaded(isLoaded: Bool)
    func messageCellDidSetMessage(cell: OZMessageCell, previousMessage: OZMessage)
    func messageCellLayoutSubviews(cell: OZMessageCell, previousMessage: OZMessage, nextMessage: OZMessage?)
    func messageInputTextViewWillShow(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat)
    func messageInputTextViewWillHide(insetMarget: UIEdgeInsets, keyboardHeight: CGFloat)
    func messageTextViewBeginEditing(textView: UITextView)
    func messageTextViewDidChanged(textView: UITextView)
    func messageTextViewDidEnterPressed(textView: UITextView)
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
    
    /// Multiple image tapped, should return boolean for `internal` processing or not
    func messageCellMultipleImageTapped(cell: OZMessageCell, image: UIImageView, indexOfImage: Int) -> Bool
    
    /// Messages vertical padding between messages
    func messageVerticalPaddingBetweenMessage(message: OZMessage, previousMessage: OZMessage) -> CGFloat
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
    func messageTextViewDidEnterPressed(textView: UITextView) {}
    func messageTextViewEndEditing(textView: UITextView) { }
    func messageMicButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    func messageMicWillRequestRecordPermission(viewController: OZVoiceRecordViewController) { }

    func messageEmoticonButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    func messageFileButtonTapped(viewController: OZMessagesViewController, sender: Any) -> Bool { return true }
    func messageCellLongMessageButtonTapped(cell: OZMessageCell, view: UIView, isFolded: Bool) -> Bool { return true }
    func messageCellMultipleImageTapped(cell: OZMessageCell, image: UIImageView, indexOfImage: Int) -> Bool { return true }
    func messageVerticalPaddingBetweenMessage(message: OZMessage, previousMessage: OZMessage) -> CGFloat { return 0 }
}
