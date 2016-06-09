//
//  DecipherViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 07/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class DecipherViewController: BaseDecipherViewController {
    private let messageService: MessageService = serviceLocator.get(MessageService)
    
    override func sendMessageUpdate() {
        messageService.decipherMessage(message as! RemoteMessage) { (message, error) -> Void in
            if let requestError = error {
                print(requestError)
            }
        }
    }
    
    override func sendMessageDecipher() {
        messageService.decipherMessageInTalk(message as! RemoteMessage)

        messageService.decipherMessage(message as! RemoteMessage) { (message, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //TODO - show error to user
                    print(requestError)
                } else {
                    if (message!.exp > 0) {
                        self.expGainView.runProgress(message!.exp)
                    }
                }
            })
        }
    }
}