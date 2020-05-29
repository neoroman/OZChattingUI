//
//  OZMessageConfigurations.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/28.
//

import Foundation


public enum OZMessagesUserSideConfigType {
    case fromCurrent, fromOther, none
}


public typealias OZMessagesConfigurations = [OZMessagesConfigurationItem]

public enum OZMessagesConfigurationItem {
    
    ///  Bubble font name in OZMessageCell
    case fontName(String, [OZMessageType])
    
    /// Bubble font size in OZMessageCell
    case fontSize(CGFloat, [OZMessageType])

    /// Bubble font color in OZMessageCell
    case fontColor(UIColor, [OZMessageType], _ userType: OZMessagesUserSideConfigType)

    /// Time font size in OZMessageCell
    case timeFontSize(CGFloat)
    
    /// Time font size in OZMessageCell
    case timeFontColor(UIColor)

    /// Profile icon size in OZMessageCell
    case profileIconSize(CGFloat, [OZMessageType])

    /// Profile icon padding in OZMessageCell
    case profileIconPadding(CGFloat, [OZMessageType])

    /// Common cell padding(inset for bubble) in OZMessageCell
    case cellPadding(CGFloat, [OZMessageType])

    /// Left cell padding(inset for bubble and profile icon) in OZMessageCell
    case cellLeftPadding(CGFloat, [OZMessageType])

    /// Right cell padding(inset for bubble and profile icon) in OZMessageCell
    case cellRightPadding(CGFloat, [OZMessageType])

    /// Cell height in OZMessageCell
    case cellHeight(CGFloat, [OZMessageType])
    
    /// Row max width ratio in OZMessageCell, ex) 0.9
    case maxWidthRatio(CGFloat)
    
    /// Bubble background color in OZMessageCell
    case bubbleBackgroundColor(UIColor, _ userType: OZMessagesUserSideConfigType)
    
    /// Cell background color in OZMessageCell
    case cellBackgroundColor(UIColor, [OZMessageType])
    
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
    
    /// TODO: Vertical padding between messages in OZMessageCell
    //case verticalPaddingBetweenMessage(_ currentMessage: OZMessage, _ previousMessage: OZMessage)
    
    /// Input text view font color in OZTextView
    case inputTextViewFontColor(UIColor)

    /// Input text view using `Enter` for sending in OZTextView
    case inputTextUsingEnterToSend(Bool)

    /// Max duration of voice record in OZVoiceRecordViewController
    case voiceRecordMaxDuration(TimeInterval)
}

public class OZChattingDefaultConfiguration: NSObject {
    static func messageConfiguration() -> OZMessagesConfigurations {
        var items = [
            // OZMessageCell
            OZMessagesConfigurationItem.fontName("AppleSDGothicNeo-Medium", OZMessageType.allTypes()),
            OZMessagesConfigurationItem.fontSize(14.0, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.fontSize(16.0, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.fontColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1), OZMessageType.allTypes(), .none),
            OZMessagesConfigurationItem.fontColor(.black, [.deviceStatus, .mp3, .voice, .text], .fromOther),
            OZMessagesConfigurationItem.fontColor(.white, [.text], .fromCurrent),
            OZMessagesConfigurationItem.timeFontSize(12),
            OZMessagesConfigurationItem.timeFontColor(UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)),
            OZMessagesConfigurationItem.profileIconSize(32, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.profileIconSize(20, [.deviceStatus]),
            OZMessagesConfigurationItem.profileIconPadding(0, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellPadding(0, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellPadding(4, [.announcement]),
            OZMessagesConfigurationItem.cellPadding(12, [.text, .deviceStatus]),
            OZMessagesConfigurationItem.cellPadding(2, [.status]),
            OZMessagesConfigurationItem.cellRightPadding(0, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellHeight(60, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellHeight(40, [.mp3, .voice]),
            OZMessagesConfigurationItem.maxWidthRatio(0.9),
            OZMessagesConfigurationItem.bubbleBackgroundColor(UIColor(red: 229.0 / 255.0, green: 21.0 / 255.0, blue: 0.0, alpha: 1.0), .fromCurrent),
            OZMessagesConfigurationItem.bubbleBackgroundColor(UIColor(white: 244.0 / 255.0, alpha: 1.0), .fromOther),
            OZMessagesConfigurationItem.cellBackgroundColor(.clear, OZMessageType.allTypes()),
            OZMessagesConfigurationItem.cellBackgroundColor(.white, [.announcement]),
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
            // OZTextView
            OZMessagesConfigurationItem.inputTextViewFontColor(.black),
            OZMessagesConfigurationItem.inputTextUsingEnterToSend(true),
            // OZVoiceRecordViewController
            OZMessagesConfigurationItem.voiceRecordMaxDuration(10.0),
        ]
        
        for case .profileIconSize(let height, let types) in items {
            for x in types {
                items.append(OZMessagesConfigurationItem.cellLeftPadding(height, [x]))
            }
        }
        
        return items
    }
    
    // TODO: Implement item(case) exist?!?
}
