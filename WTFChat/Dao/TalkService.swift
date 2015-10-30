//
//  TalkService.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 27/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

let TALKS_UPDATE_TIMER_INTERVAL = 10.0

let talkService = TalkService()

protocol TalkListener {
    func updateTalks(talks: [Talk]?, error: NSError?)
}

class TalkService: NSObject {
    var updateTimer: NSTimer?
    
    var talks = [Talk]()
    
    var friendsTalkListener: TalkListener?
    
    func getTalkByLogin(friend: String) -> Talk? {
        for talk in talks {
            if (talk.getFriendLogin() == friend) {
                return talk
            }
        }
        
        return nil
    }
    
    func clearTalks() {
        self.talks = [Talk]()
        iosService.updatePushBadge(talks)
        updateTimer?.invalidate()
    }
    
    func setTalksByNewUser(user: User) {
        self.talks = user.talks
        
        //add singleModeTalk
        let singleModeTalk = Talk(id: "0")
        singleModeTalk.isSingleMode = true
        let singleModeUser = User(login: "Pass and Play", suggestions: 0)
        singleModeTalk.users.append(singleModeUser.login)
        singleModeTalk.users.append(user.login)
        
        talks.append(singleModeTalk)
        
        iosService.updatePushBadge(talks)
        
        //timer worked only on main
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTimer?.invalidate()

            self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(TALKS_UPDATE_TIMER_INTERVAL, target: self,
                selector: "getNewUnreadTalks", userInfo: nil, repeats: true)
        })

        fireUpdateTalksEvent()
    }
    
    func getNewUnreadTalks() {
        if (!userService.isLoggedIn()) {
            return
        }
        
        let lastUpdate = self.getTalksLastUpdate()
        
        let lastUpdateData = [
            "last_update": NSDate.parseStringJSONFromDate(lastUpdate)!
        ]
        
        let postJSON = JSON(lastUpdateData)
        
        networkService.post(postJSON, relativeUrl: "user/new_talks_by_time") { (json, error) -> Void in
            if let requestError = error {
                self.friendsTalkListener?.updateTalks(nil, error: requestError)
            } else {
                if let talksJson = json {
                    do {
                        let talks = try Talk.parseArrayFromJson(talksJson)
                        
                        for talk in talks {
                            self.updateOrCreateTalkInArray(talk)
                        }
                        
                        self.fireUpdateTalksEvent()
                    } catch let error as NSError {
                        self.friendsTalkListener?.updateTalks(nil, error: error)
                    }
                } else {
                    //no new talks - do nothing
                }
            }
        }
    }
    
    func addNewTalk(talk: Talk) {
        talks.append(talk)
        fireUpdateTalksEvent()
    }
    
    func updateTalkInArray(talk: Talk, withMessages: Bool = false) {
        updateOrCreateTalkInArray(talk, withMessages: withMessages)
        fireUpdateTalksEvent()
    }
    
    private func fireUpdateTalksEvent() {
        iosService.updatePushBadge(talks)
        self.friendsTalkListener?.updateTalks(talks, error: nil)
    }
    
    private func updateOrCreateTalkInArray(talk: Talk, withMessages: Bool = false) {
        for i in 0..<talks.count {
            if (talk.id == talks[i].id) {
                
                if (withMessages) {
                    //update with messages
                } else {
                    //save early downloaded messages before update
                    talk.messages = talks[i].messages
                }
                
                talks[i] = talk
                return
            }
        }
        
        talks.append(talk)
    }
    
    private func getTalksLastUpdate() -> NSDate {
        var lastUpdate: NSDate?
        
        for talk in talks {
            if (talk.isSingleMode) {
                continue
            }
            
            if (lastUpdate == nil || talk.lastUpdate.isGreater(lastUpdate!)) {
                lastUpdate = talk.lastUpdate
            }
        }
        
        if (lastUpdate != nil) {
            return lastUpdate!
        } else {
            return NSDate.defaultPast()
        }
    }
}