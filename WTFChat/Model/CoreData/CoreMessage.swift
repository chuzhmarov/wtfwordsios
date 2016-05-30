//
//  CoreMessage.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation
import CoreData

let CORE_WORD_CLASS_NAME = "CoreWord"
let CORE_MESSAGE_CLASS_NAME = "CoreMessage"

class CoreMessage: NSManagedObject {
    
    func updateFromMessage(message: Message) {
        self.id = message.id
        self.timestamp = message.timestamp
        self.lastUpdate = message.lastUpdate
        self.talkId = message.talkId
        self.author = message.author
        self.deciphered = message.deciphered
        self.cipherType = message.cipherType.rawValue
        self.exp = message.exp
        self.isLocal = message.isLocal
        self.extId = message.extId
        self.timerSecs = message.timerSecs
        self.hintsUsed = message.hintsUsed
        
        //clear old words if any
        if let words = self.words {
            for _ in 0..<words.count {
                if let coreWord = words[0] as? CoreWord {
                    self.removeWordsObject(coreWord)
                    coreDataService.deleteObject(coreWord)
                }
            }
        }
        
        //add new words
        for domainWord in message.words {
            let newCoreWord = coreDataService.createObject(CORE_WORD_CLASS_NAME) as! CoreWord
            newCoreWord.updateFromWord(domainWord)
            self.addWordsObject(newCoreWord)
        }
    }
    
    func getMessage() -> Message? {
        if (self.id == nil ||
            self.timestamp == nil ||
            self.lastUpdate == nil ||
            self.talkId == nil ||
            self.author == nil ||
            self.deciphered == nil ||
            self.cipherType == nil ||
            self.exp == nil ||
            self.isLocal == nil ||
            self.extId == nil ||
            self.timerSecs == nil ||
            self.hintsUsed == nil ||
            self.words == nil) {
                
                return nil
        }
        
        if let enumCipherType = CipherType(rawValue: Int(self.cipherType!)) {
            var domainWords = [Word]()
            
            for item in self.words! {
                if let coreWord = item as? CoreWord {
                    if let domainWord = coreWord.getWord() {
                        domainWords.append(domainWord)
                    }
                }
            }
            
            let message = Message(
                id: self.id!,
                talkId: self.talkId!,
                author: self.author!,
                words: domainWords,
                deciphered: Bool(self.deciphered!),
                cipherType: enumCipherType,
                timestamp: self.timestamp!,
                lastUpdate: self.lastUpdate!,
                exp: Int(self.exp!),
                extId: self.extId!,
                timerSecs: Int(self.timerSecs!),
                hintsUsed: Int(self.hintsUsed!)
            )
            
            message.isLocal = Bool(self.isLocal!)
            
            return message
        } else {
            return nil
        }
    }
    
    class func createOrUpdateMessage(message: Message) {
        if CoreMessage.getMessageByExtId(message) != nil {
            CoreMessage.updateMessage(message)
        } else {
            CoreMessage.createMessage(message)
        }
    }
    
    class func createMessage(message: Message) {
        let newCoreMessage = coreDataService.createObject(CORE_MESSAGE_CLASS_NAME) as! CoreMessage
        newCoreMessage.updateFromMessage(message)
        coreDataService.saveContext()
    }
    
    class func getAllWaiting() -> [Message] {
        let predicate = NSPredicate(format: "talkId != %@", "0")
        return getByPredicate(predicate)
    }
    
    class func getAllLocal() -> [Message] {
        let predicate = NSPredicate(format: "talkId == %@", "0")
        return getByPredicate(predicate)
    }
    
    class func getByTalkId(talkId: String) -> [Message] {
        let predicate = NSPredicate(format: "talkId == %@", talkId)
        return getByPredicate(predicate)
    }
    
    class func getMessageByExtId(message: Message) -> Message? {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)
        
        let predicate = NSPredicate(format: "extId == %@", message.extId)
        fetchRequest.predicate = predicate
        
        let results = coreDataService.executeFetch(fetchRequest)
        
        if (results.count > 0) {
            if let coreMessage = results[0] as? CoreMessage {
                return coreMessage.getMessage()
            }
        }
            
        return nil
    }
    
    private class func getByPredicate(predicate: NSPredicate) -> [Message] {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)
        
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.predicate = predicate
        
        let results = coreDataService.executeFetch(fetchRequest)
        
        var domainMessages = [Message]()
        
        for item in results {
            if let coreMessage = item as? CoreMessage {
                if let domainMessage = coreMessage.getMessage() {
                    domainMessages.append(domainMessage)
                }
            }
        }
        
        return domainMessages
    }
    
    class func updateMessage(message: Message) {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)
        
        let predicate = NSPredicate(format: "extId == %@", message.extId)
        fetchRequest.predicate = predicate
        
        let results = coreDataService.executeFetch(fetchRequest)

        if (results.count > 0) {
            if let coreMessage = results[0] as? CoreMessage {
                coreMessage.updateFromMessage(message)
                coreDataService.saveContext()
            }
        }
    }
    
    class func deleteMessageIfExists(message: Message) {
        if CoreMessage.getMessageByExtId(message) != nil {
            CoreMessage.deleteMessage(message)
        } else {
            //do nothing
        }
    }
    
    class func deleteMessage(message: Message) {
        let fetchRequest = coreDataService.createFetch(CORE_MESSAGE_CLASS_NAME)
        
        let predicate = NSPredicate(format: "extId == %@", message.extId)
        fetchRequest.predicate = predicate
        
        let results = coreDataService.executeFetch(fetchRequest)
        
        if (results.count > 0) {
            if let coreMessage = results[0] as? CoreMessage {
                coreDataService.deleteObject(coreMessage)
            }
        }
    }
}