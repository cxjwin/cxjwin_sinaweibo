//
//  NSMutableAttributeString+Weibo.swift
//  SinaWeibo
//
//  Created by cxjwin on 7/1/14.
//  Copyright (c) 2014 cxjwin. All rights reserved.
//

import Foundation

let CTAttachmentChar = "uFFFC"
let CTAttachmentCharacter = "\uFFFC"

var weiboEmojiDictionary: NSDictionary {
get {
    var emojiDictionary: NSDictionary! = nil
    var token: dispatch_once_t = 0
    dispatch_once(&token) {
        let emojiFilePath = NSBundle.mainBundle().pathForResource("emotionImage", ofType: "plist")
        emojiDictionary = NSDictionary(contentsOfFile: emojiFilePath)
    }
    return emojiDictionary
}
}