//
//  AudioExtension.swift
//  OZChatExample
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
