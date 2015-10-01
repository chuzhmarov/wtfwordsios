//
//  MessageDao.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let messageService = MessageService()

class MessageService {
    func getMessagesByTalk(talk: Talk, completion:(messages: [Message]?, error: NSError?) -> Void) {
        networkService.get("messages/" + talk.id) { (json, error) -> Void in
            if let requestError = error {
                completion(messages: nil, error: requestError)
            } else {
                do {
                    let messages = try Message.parseArrayFromJson(json!)
                    completion(messages: messages, error: nil)
                } catch let error as NSError {
                    completion(messages: nil, error: error)
                }
                
            }
        }
    }
    
    func getUnreadMessagesByTalk(talk: Talk, completion:(messages: [Message]?, error: NSError?) -> Void) {
        networkService.get("messages/new/" + talk.id) { (json, error) -> Void in
            if let requestError = error {
                completion(messages: nil, error: requestError)
            } else {
                if let messagesJson = json {
                    do {
                        let messages = try Message.parseArrayFromJson(messagesJson)
                        completion(messages: messages, error: nil)
                    } catch let error as NSError {
                        completion(messages: nil, error: error)
                    }
                } else {
                    completion(messages: nil, error: nil)
                }
            }
        }
    }
    
    func saveMessage(message: Message, completion:(message: Message?, error: NSError?) -> Void) {
        let postJSON = message.getNewJson()
        
        networkService.post(postJSON, relativeUrl: "messages/add") {json, error -> Void in
            if let requestError = error {
                completion(message: nil, error: requestError)
            } else {
                if let messageJson = json {
                    do {
                        let message = try Message.parseFromJson(messageJson)
                        completion(message: message, error: nil)
                    } catch let error as NSError {
                        completion(message: nil, error: error)
                    }
                } else {
                    completion(message: nil, error: nil)
                }
            }
        }
    }
    
    func decipherMessage(message: Message, completion:(message: Message?, error: NSError?) -> Void) {
        let postJSON = message.getDecipherJson()
        
        networkService.post(postJSON, relativeUrl: "messages/decipher") {json, error -> Void in
            if let requestError = error {
                completion(message: nil, error: requestError)
            } else {
                if let messageJson = json {
                    do {
                        let message = try Message.parseFromJson(messageJson)
                        completion(message: message, error: nil)
                    } catch let error as NSError {
                        completion(message: nil, error: error)
                    }
                } else {
                    completion(message: nil, error: nil)
                }
            }
        }
    }

}