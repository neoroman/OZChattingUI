//
//  OZEmoticonList.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/06.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import UIKit

open class OZEmoticonList: NSObject {
    var allEmoticons: [OZEmoticon] = []

    override init() {
        super.init()
        
        if self.allEmoticons.count == 0, let list = self.fetchAllEmoticonItems() {
            self.allEmoticons = list
        }

    }
    
    fileprivate func makeJsonFromPropertyList() -> NSDictionary? {
        func getPlist(path: String) -> NSDictionary? {
            do {
                let plistData = try Data.init(contentsOf: URL(fileURLWithPath: path))
                let plist = try PropertyListSerialization.propertyList(from: plistData, options: .mutableContainersAndLeaves, format: nil) as! NSDictionary
                
                return plist
            }
            catch {
                print("\(error.localizedDescription)")
            }
            return nil
        }
        
        guard let path = Bundle.main.path(forResource: "OZEmoticonList", ofType: "plist") else {
            if Bundle.isFramework(),
                let fBundle = Bundle(identifier: kOZChattingUIBuddleIdentifier),
                let path = fBundle.path(forResource: "OZEmoticonList", ofType: "plist") {
                return getPlist(path: path)
            }
            return nil
        }
                
        return getPlist(path: path)
    }
    
    fileprivate func fetchAllEmoticonItems() -> [OZEmoticon]? {
        let json = makeJsonFromPropertyList()
        
        if let dictionary = json as? [String: Any] {
            var returnItems: [OZEmoticon] = []
            if dictionary.count > 0 {
                for item in dictionary {
                    if let itemDict = item.value as? [String: Any],
                        let name = itemDict["name"] as? String {
                        if let title = itemDict["title"] as? String, let ext = itemDict["ext"] as? String {
                            returnItems.append(OZEmoticon(name, title: title, ext: ext))
                        }
                        else if let title = itemDict["title"] as? String {
                            returnItems.append(OZEmoticon(name, title: title, ext: "png"))
                        }
                    }
                }
                return returnItems
            }            
        }
        return nil
    }

}
