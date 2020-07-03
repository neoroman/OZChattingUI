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
//  AudioExtension.swift
//  OZChattingUI_Example
//
//  Created by Henry Kim on 2020/05/25.
//  Copyright © 2020 ALTERANT. All rights reserved.
//

import Foundation

extension String {
    
    public static func audioFileSave(_ voiceString:String, _ messageId:String, _ ext: String = "amr") -> String {
        let tmpDirURL = FileManager.default.temporaryDirectory
        let filename = tmpDirURL.appendingPathComponent("\(messageId).\(ext)")
        let KEY = filename.relativePath
        if FileManager.default.isReadableFile(atPath: KEY) {
            return KEY
        }
        
        if let amrVoiceData  = Data(base64Encoded: voiceString, options: .ignoreUnknownCharacters) {
            try? amrVoiceData.write(to: filename)
            return KEY
        }
        return ""
    }
    public static func audioFileSave(_ data: Data, _ ext: String = "mp3") -> String {
        let tmpDirURL = FileManager.default.temporaryDirectory
        let filename = tmpDirURL.appendingPathComponent("\(String.randomFileName(length: 10)).\(ext)")
        let KEY = filename.relativePath
        if FileManager.default.isReadableFile(atPath: KEY) {
            return KEY
        }
        
        try? data.write(to: filename)
        return KEY
    }
    
    public static func randomFileName(length: Int) -> String {
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }

}
