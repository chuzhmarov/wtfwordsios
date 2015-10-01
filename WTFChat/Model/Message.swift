//
//  Message.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class Message : BaseEntity, JSQMessageData {
    let timestamp: NSDate
    let talkId: String
    
    var author: String
    var words: [Word]?
    var deciphered: Bool
    var cipherType: CipherType
    
    init(id: String, talkId: String, author: String) {
        
        self.timestamp = NSDate()
        self.talkId = talkId
        self.author = author
        self.deciphered = false
        cipherType = CipherType.FirstLetterCipher
        
        super.init(id: id)
    }
    
    init(id: String, talkId: String, author: String, words: [Word]?, cipherType: CipherType = CipherType.FirstLetterCipher) {
        
        self.timestamp = NSDate()
        self.talkId = talkId
        self.author = author
        self.deciphered = false
        self.cipherType = cipherType
        
        for word in words! {
            word.cipheredText = CipherFactory.getCipher(cipherType).getTextForDecipher(word)
        }
        
        self.words = words
        
        super.init(id: id)
    }
    
    init(id: String, talkId: String, author: String, words: [Word]?, deciphered: Bool) {
        
        self.timestamp = NSDate()
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
        self.words = words
        self.cipherType = CipherType.FirstLetterCipher
        
        super.init(id: id)
    }
    
    init(id: String, timestamp: NSDate, talkId: String, author: String, deciphered: Bool) {
        self.timestamp = timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
        self.cipherType = CipherType.FirstLetterCipher
            
        super.init(id: id)
    }
    
    init(id: String, talkId: String, author: String, words: [Word]?, deciphered: Bool, cipherType: CipherType = CipherType.FirstLetterCipher, timestamp: NSDate) {
        
        self.timestamp = timestamp
        self.talkId = talkId
        self.author = author
        self.deciphered = deciphered
        self.cipherType = cipherType
        
        for word in words! {
            word.cipheredText = CipherFactory.getCipher(cipherType).getTextForDecipher(word)
        }
        
        self.words = words
        
        super.init(id: id)
    }

    
    func getWordsWithoutDelimiters() -> [Word] {
        var result = [Word]()
        
        for word in words! {
            if (word.wordType != WordType.Delimiter) {
                result.append(word)
            }
        }
        
        return result
    }

    func countSuccess() -> Int {
        return countWordsByStatus(WordType.Success)
    }
    
    func countNew() -> Int {
        return countWordsByStatus(WordType.New)
    }
    
    func countFailed() -> Int {
        return countWordsByStatus(WordType.Failed)
    }
    
    func countWordsByStatus(wordType: WordType) -> Int {
        var result = 0
        
        for word in words! {
            if (word.wordType == wordType) {
                result++
            }
        }
        
        return result
    }
    
    // MARK: JSQMessageData realization
    
    func text() -> String! {
        if (userService.getCurrentUser().login == self.author) {
            return clearText()
        } else if (self.deciphered) {
            return clearText()
        } else {
            return "???"
        }
    }
    
    func clearText() -> String! {
        var result = ""
            
        if (words != nil) {
            for word in words! {
                result += word.getClearText()
            }
        }
            
        return result
    }
    
    func senderId() -> String! {
        return author
    }
    
    func senderDisplayName() -> String! {
        return author
    }
    
    func date() -> NSDate! {
        return timestamp
    }
    
    func isMediaMessage() -> Bool {
        return false;
    }
    
    func messageHash() -> UInt {
        return UInt(id.hash);
    }
    
    class func parseArrayFromJson(json: JSON) throws -> [Message] {
        var messages = [Message]()
        
        if let value = json.array {
            for messageJson in value {
                try messages.append(Message.parseFromJson(messageJson))
            }
        } else {
            throw json.error!
        }
        
        return messages
    }
    
    func getNewJson() -> JSON {
        var json: JSON = [
            "talk_id": self.talkId,
            "author": self.author,
            "deciphered": self.deciphered,
            "cipher_type": self.cipherType.rawValue,
            "timestamp": NSDate.parseStringJSONFromDate(self.timestamp)!,
        ]
        
        json["words"].arrayObject = getWordsJson()
        
        return json
    }
    
    func getDecipherJson() -> JSON {
        var json: JSON = [
            "id": self.id
        ]
        
        json["words"].arrayObject = getWordsJson()
        
        return json
    }
    
    func getWordsJson() -> [AnyObject] {
        var wordsJson = [AnyObject]()
        
        for i in 0..<self.words!.count {
            let wordJson = self.words![i].getJson()
            wordsJson.append(wordJson.rawValue)
        }
        
        return wordsJson
    }
    
    class func parseFromJson(json: JSON) throws -> Message {
        var id: String
        var talkId: String
        var author: String
        var words = [Word]()
        var deciphered: Bool
        var cipherType: CipherType
        var timestamp: NSDate
        
        if let value = json["id"].string {
            id = value
        } else {
            throw json["id"].error!
        }
        
        if let value = json["talk_id"].string {
            talkId = value
        } else {
            throw json["talk_id"].error!
        }
        
        if let value = json["author"].string {
            author = value
        } else {
            throw json["author"].error!
        }
        
        if let value = json["deciphered"].bool {
            deciphered = value
        } else {
            throw json["deciphered"].error!
        }
        
        if let value = json["cipher_type"].int {
            cipherType = CipherType(rawValue: value)!
        } else {
            throw json["cipher_type"].error!
        }
        
        if let value = json["timestamp"].string {
            if let parsedTimestamp = NSDate.parseDateFromStringJSON(value) {
                timestamp = parsedTimestamp
            } else {
                throw NSError(code: 1, message: "Could not parse date")
            }
        } else {
            throw json["timestamp"].error!
        }
        
        if let value = json["words"].array {
            for wordJson in value {
                try words.append(Word.parseFromJson(wordJson))
            }
        } else {
            throw json["words"].error!
        }

        return Message(
            id: id,
            talkId: talkId,
            author: author,
            words: words,
            deciphered: deciphered,
            cipherType: cipherType,
            timestamp: timestamp
        )
    }
}