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
