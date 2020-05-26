//
//  OZSwime.swift
//  OZChattingUI
//
//  Created by Henry Kim on 2020/05/09.
//  Copyright © 2020 ALTERANT. All rights reserved.
//  Thanks to https://github.com/sendyhalim/Swime
//

import Foundation

public struct OZSwime {
  /// File data
  let data: Data

  ///  A static method to get the `MimeType` that matches the given file data
  ///
  ///  - returns: Optional<MimeType>
  static public func mimeType(data: Data) -> OZMimeType? {
    return mimeType(swime: OZSwime(data: data))
  }

  ///  A static method to get the `MimeType` that matches the given bytes
  ///
  ///  - returns: Optional<MimeType>
  static public func mimeType(bytes: [UInt8]) -> OZMimeType? {
    return mimeType(swime: OZSwime(bytes: bytes))
  }

  ///  Get the `MimeType` that matches the given `OZSwime` instance
  ///
  ///  - returns: Optional<MimeType>
  static public func mimeType(swime: OZSwime) -> OZMimeType? {
    let bytes = swime.readBytes(count: min(swime.data.count, 262))

    for mime in OZMimeType.all {
      if mime.matches(bytes: bytes, swime: swime) {
        return mime
      }
    }

    return nil
  }

  public init(data: Data) {
    self.data = data
  }

  public init(bytes: [UInt8]) {
    self.init(data: Data(bytes))
  }

  ///  Read bytes from file data
  ///
  ///  - parameter count: Number of bytes to be read
  ///
  ///  - returns: Bytes represented with `[UInt8]`
  internal func readBytes(count: Int) -> [UInt8] {
    var bytes = [UInt8](repeating: 0, count: count)

    data.copyBytes(to: &bytes, count: count)

    return bytes
  }
}
