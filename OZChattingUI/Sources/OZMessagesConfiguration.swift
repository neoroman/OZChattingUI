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
//  OZMessageConfigurations.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/28.
//

import Foundation
import UIKit


public enum OZMessagesUserSideConfigType {
    case fromCurrent, fromOther, none
}


public typealias OZMessagesConfigurations = [OZMessagesConfigurationItem]

public enum OZMessagesConfigurationItem {
    func title() -> String {
        let text = String(describing: self).trimmingCharacters(in: CharacterSet(charactersIn: "."))
        if let aFirst = text.components(separatedBy: "(").first {
            return aFirst
        }
        return text
    }

    // ============ OZMessageCell ==================
    ///  Bubble font name in OZMessageCell
    case fontName(String, [OZMessageType])
    
    /// Bubble font size in OZMessageCell
    case fontSize(CGFloat, [OZMessageType])

    /// Bubble font color in OZMessageCell
    case fontColor(UIColor, [OZMessageType], _ userType: OZMessagesUserSideConfigType)

    /// Time font size in OZMessageCell
    case timeFontSize(CGFloat)

    /// Time font format in OZMessageCell
    case timeFontFormat(String)

    /// Time font size in OZMessageCell
    case timeFontColor(UIColor)
    
    /// Profile icon name in OZMessageCell
    case profileIconName(String, [OZMessageType], _ userType: OZMessagesUserSideConfigType)

    /// Profile icon size in OZMessageCell
    case profileIconSize(CGFloat, [OZMessageType], _ paddingX: CGFloat)

    /// Profile icon padding in OZMessageCell
    case profileIconPadding(CGFloat, [OZMessageType])

    /// Default image size of messages in OZMessagesCell
    /// Display image height won't be greater than cellHeight
    case chatImageSize(CGSize, _ cornerRadius: CGFloat, _ forSeding: CGSize)

    /// Default image max bytes in OZMessagesCell
    case chatImageMaxNumberOfBytes(Int)
    
    /// Multiple image related in OZMessageCell,
    /// maxHeight = 0 means default, i.e. chatImageSize.height x 3
    case multipleImages(_ spacing: CGFloat, _ borderWidth: CGFloat, _ backgroundColor: UIColor)
    
    /// Default emoticon size of messages in OZMessageCell
    case chatEmoticonSize(CGSize)
    
    /// Common cell padding(inset for bubble) in OZMessageCell
    case cellPadding(CGFloat, [OZMessageType])

    /// Cell height in OZMessageCell
    case cellHeight(CGFloat, [OZMessageType])
    
    /// Cell content opacity in OZMessageCell, eg. 0.5 means 50%,
    /// Default is 1.0 means 100%
    case cellOpacity(CGFloat, [OZMessageType])
    
    /// Row max width ratio in OZMessageCell, eg. 0.9 means 90% of screen width
    case maxWidthRatio(CGFloat)
    
    /// Bubble background color in OZMessageCell
    case bubbleBackgroundColor(UIColor, _ userType: OZMessagesUserSideConfigType)
    
    /// Cell background color in OZMessageCell
    case cellBackgroundColor(UIColor, [OZMessageType])
    
    /// Audio background color in OZMessageCell
    case audioProgressColor(UIColor, _ userType: OZMessagesUserSideConfigType)
    
    /// Audio play, pause button image name in OZMessageCell
    case audioButtonsName(_ playButton: String, _ pauseButton: String)

    /// Rounded corner for content in OZMessageCell
    case roundedCorner(Bool, [OZMessageType])
        
    /// Show shadow in OZMessageCell
    case showShadow(Bool, [OZMessageType])
    
    /// Shadow color in OZMessageCell
    case shadowColor(UIColor, [OZMessageType], _ userType: OZMessagesUserSideConfigType)
    
    /// Seperator of status message(type == .announcement) in OZMessageCell
    case sepratorColor(UIColor)
    
    /// Alignment of content in OZMessageCell
    case alignment(OZMessageAlignment, [OZMessageType], _ userType: OZMessagesUserSideConfigType)
    
    /// Using packed images, default `YES` in OZMessageCell,
    /// isStrictSizeAsChatImage, default ``NO`` in OZMessageCell
    case usingPackedImages(Bool, _ isStrictSizeAsChatImage: Bool)
    
    /// Show time label for image, default `NO` in OZMessageCell
    case showTimeLabelForImage(Bool)
    
    /// Using long message folding option, default `NO` in OZMessageCell,
    /// eg) .usingLongMessageFolding(false, 200, CGSize(width: 100, height: 25), .center, .center)
    case usingLongMessageFolding(Bool, _ maxHeight: CGFloat, _ buttonSize: CGSize, _ foldButtonAlignment: OZMessageAlignment, _ unfoldButonAlignment: OZMessageAlignment)
    /// eg) .usingLongMessageFoldingButtons(UIButton(type: .infoLight), UIButton(type: .detailDisclosure))
    case usingLongMessageFoldingButtons(_ foldButton: UIButton, _ unfoldButon: UIButton)
    
    /// Can message selectable by long press gesture, default `NO` in OZMessageCell
    case canMessageSelectableByLongPressGesture(Bool)

    // ============ OZMessagesViewController ==================
    /// Auto scroll to bottom after begin text editting in OZMessagesViewController
    case autoScrollToBottomBeginTextInput(Bool, _ isShowScrollToBottomButton: Bool)
    
    /// Auto scroll to bottom while new message arrived in OZMessagesViewController,
    /// Default is ``YES``, isShowNewBadgeCount = ``NO``
    case autoScrollToBottomNewMessageArrived(Bool)
            
    /// CollectionView contentInset in OZMessagesViewController
    case collectionViewEdgeInsets(UIEdgeInsets)
    
    /// CollectionView frame in OZMessagesViewController, default `NO`,
    /// ``visibleRow = 0`` means show all message with scroll,
    /// ``visibleRow > 0`` means only show given row of messages without scroll
    case customCollectionViewFrame(Bool, _ customRect: CGRect, _ visibleRow: Int)
    
    /// Input box `emoticon` button tint color in OZMessagesViewController
    case inputBoxEmoticonButtonTintColor(UIColor, _ selectedColor: UIColor)
    
    /// Input box `file` button tint color in OZMessagesViewController
    case inputBoxFileButtonTintColor(UIColor, _ selectedColor: UIColor)

    /// Input box `mic` button tint color in OZMessagesViewController
    case inputBoxMicButtonTintColor(UIColor, _ selectedColor: UIColor)

    /// Input text view minimum height, default `56`, in OZMessagesViewController
    case inputContainerMinimumHeight(CGFloat)

    /// Input text view minimum height, default `56 * 3`, in OZMessagesViewController
    case inputContainerMaximumHeight(CGFloat)

    /// Input text vertical alignemnt in OZTextView
    case inputTextVerticalAlignment(OZTextView.VerticalAlignment)

    /// Input text view font color in OZTextView
    case inputTextViewFont(UIFont)

    /// Input text view font color in OZTextView
    case inputTextViewFontColor(UIColor)

    /// Input text view using `Enter` for sending in OZTextView, Default is ``NO``
    case inputTextUsingEnterToSend(Bool)
    
    /// Button for scroll to bottom in OZMessagesViewController,
    /// Origin .zero, set default origin from 5 pixel from InputContainerView
    case scrollToBottomButton(CGPoint, CGSize, _ strokeWidth: CGFloat, _ strokeColor: UIColor, _ fillColor: UIColor, _ buttonAlpha: CGFloat)
        
    /// Badge shape for auto scroll to bottom while new message arrived in OZMessagesViewController,
    /// Default is ``NO``,
    /// font is ``AppleSDGothicNeo-Medium``, ``12pt``,
    /// height is ``15``, textColor is ``white``, backgroundColor is ``green``
    case scrollToBottomNewMessageBadge(Bool, _ fontName: String, _ fontSize: CGFloat,
        _ height: CGFloat, _ textColor: UIColor, _ backgroundColor: UIColor)
    
    /// Show typing indicator in left-side in OZMessagesViewController,
    /// Default is ``NO``, isTyping only work this value is ``YES``
    case showTypingIndicator(Bool, CGFloat, UIColor)
    

    // ============ OZVoiceRecordViewController ==================
    /// Max duration of voice record in OZVoiceRecordViewController
    case voiceRecordMaxDuration(TimeInterval, _ displayMaxDuration: Int)
    
    /// Using AMR format for voice recording in OZVoiceRecodeViewController
    case voiceRecordAMRFormat(OZAMREncodeMode)
    

    // ============ OZEmoticonViewController ==================
    /// Page control tint color in OZEmoticonViewController
    case emoticonPageIndicatorTintColor(UIColor)

    /// Current page control tint color in OZEmoticonViewController
    case emoticonCurrentPageIndicatorTintColor(UIColor)
}

public class OZChattingDefaultConfiguration: NSObject {
    static func refineMessegeConfiguration(from: OZMessagesConfigurations) -> OZMessagesConfigurations {
        let reference = OZChattingDefaultConfiguration.defaulMessageConfiguration()
        var result: [OZMessagesConfigurationItem] = []
        let titleOfFrom = from.map({$0.title()})
        for i in 0..<reference.count {
            if titleOfFrom.contains(reference[i].title()) {
                continue
            }
            result.append(reference[i])
        }
        result.append(contentsOf: from)
        return result
    }
    
    static func defaulMessageConfiguration() -> OZMessagesConfigurations {
        var items = [
            // OZMessageCell
            OZMessagesConfigurationItem.fontName("AppleSDGothicNeo-Medium", OZMessageType.allTypes()),
            OZMessagesConfigurationItem.fontSize(14.0, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.fontSize(16.0, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.fontColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), OZMessageType.allTypes(), .none),
            OZMessagesConfigurationItem.fontColor(.black, [.deviceStatus, .mp3, .voice, .text], .fromOther),
            OZMessagesConfigurationItem.fontColor(.white, [.text], .fromCurrent),
            OZMessagesConfigurationItem.timeFontSize(12),
            OZMessagesConfigurationItem.timeFontFormat("h:mm a"),
            OZMessagesConfigurationItem.timeFontColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)),
            OZMessagesConfigurationItem.profileIconName("", OZMessageType.allTypes(), .none),
            OZMessagesConfigurationItem.profileIconSize(32, OZMessageType.allTypes(), 8),
            OZMessagesConfigurationItem.profileIconSize(20, [.deviceStatus], 8),
            OZMessagesConfigurationItem.profileIconPadding(0, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellPadding(0, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellPadding(4, [.announcement]),
            OZMessagesConfigurationItem.cellPadding(12, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.cellPadding(2, [.status]),
            OZMessagesConfigurationItem.cellHeight(60, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellHeight(40, [.mp3, .voice]),
            OZMessagesConfigurationItem.cellHeight(120, [.image]),
            OZMessagesConfigurationItem.cellOpacity(1.0, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.maxWidthRatio(0.9),
            OZMessagesConfigurationItem.bubbleBackgroundColor(#colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1), .fromCurrent),
            OZMessagesConfigurationItem.bubbleBackgroundColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), .fromOther),
            OZMessagesConfigurationItem.chatImageSize(CGSize(width: 100, height: 100), 7, CGSize(width: 400, height: 400)),
            OZMessagesConfigurationItem.chatImageMaxNumberOfBytes(16384),
            OZMessagesConfigurationItem.multipleImages(4, 1, .clear),
            OZMessagesConfigurationItem.chatEmoticonSize(CGSize(width: 50, height: 50)),
            OZMessagesConfigurationItem.cellBackgroundColor(.clear, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellBackgroundColor(.white, [.announcement]),
            OZMessagesConfigurationItem.audioProgressColor(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1), .none),
            OZMessagesConfigurationItem.roundedCorner(true, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.roundedCorner(false, [.announcement]),
            OZMessagesConfigurationItem.showShadow(false, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.showShadow(false, [.text, .image]),
            OZMessagesConfigurationItem.shadowColor(.clear, OZMessageType.allTypes(), .none),
            OZMessagesConfigurationItem.shadowColor(UIColor(white: 0.4, alpha: 1.0), [.image, .text], .fromOther),
            OZMessagesConfigurationItem.shadowColor(UIColor(red: 140/255, green: 0.1, blue: 0.1, alpha: 1.0), [.text], .fromCurrent),
            OZMessagesConfigurationItem.sepratorColor(UIColor(white: 238.0 / 255.0, alpha: 1.0)),
            OZMessagesConfigurationItem.alignment(.right, OZMessageType.allTypes(), .fromCurrent),
            OZMessagesConfigurationItem.alignment(.left, OZMessageType.allTypes(), .fromOther),
            OZMessagesConfigurationItem.alignment(.center, [.announcement, .deviceStatus], .none),
            OZMessagesConfigurationItem.usingPackedImages(true, false),
            OZMessagesConfigurationItem.showTimeLabelForImage(false),
            OZMessagesConfigurationItem.canMessageSelectableByLongPressGesture(false),
            OZMessagesConfigurationItem.audioButtonsName("play.fill", "pause.fill"),

            // OZMessagesViewController
            OZMessagesConfigurationItem.autoScrollToBottomBeginTextInput(true, false),
            OZMessagesConfigurationItem.autoScrollToBottomNewMessageArrived(true),
            OZMessagesConfigurationItem.collectionViewEdgeInsets(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)),
            OZMessagesConfigurationItem.inputBoxEmoticonButtonTintColor(.black, .systemTeal),
            OZMessagesConfigurationItem.inputBoxFileButtonTintColor(.black, .systemTeal),
            OZMessagesConfigurationItem.inputBoxMicButtonTintColor(.black, .systemTeal),
            OZMessagesConfigurationItem.inputContainerMinimumHeight(56),
            OZMessagesConfigurationItem.inputContainerMaximumHeight(56*3),
            OZMessagesConfigurationItem.scrollToBottomButton(.zero, CGSize(width: 30, height: 30), 5, .clear, .gray, 0.4),

            // OZTextView
            OZMessagesConfigurationItem.inputTextVerticalAlignment(.Middle),
            OZMessagesConfigurationItem.inputTextViewFont(UIFont.boldSystemFont(ofSize: 18)),
            OZMessagesConfigurationItem.inputTextViewFontColor(.black),
            OZMessagesConfigurationItem.inputTextUsingEnterToSend(false),

            // OZEmoticonViewController
            OZMessagesConfigurationItem.emoticonPageIndicatorTintColor(UIColor.magenta.withAlphaComponent(0.3)),
            OZMessagesConfigurationItem.emoticonCurrentPageIndicatorTintColor(UIColor.magenta),

            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(10.0, 0),
            OZMessagesConfigurationItem.voiceRecordAMRFormat(.OZAMR_05_15),
        ]
        
        for case .inputContainerMinimumHeight(let minHeight) in items {
            for case .collectionViewEdgeInsets(var inset) in items {
                inset.bottom = minHeight
                items.append(OZMessagesConfigurationItem.collectionViewEdgeInsets(inset))
            }
        }
        
        return items
    }
}
