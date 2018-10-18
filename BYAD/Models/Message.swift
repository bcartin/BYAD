//
//  Message.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/5/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class Message {
    
    var message: String
    var sentBy: String
    var sentTo: String
    var timeStamp: Date
    var senderName: String
    
    init(message: String, sentBy: String, timeStamp: Date, sentTo: String, senderName: String) {
        self.message = message
        self.sentBy = sentBy
        self.timeStamp = timeStamp
        self.sentTo = sentTo
        self.senderName = senderName
    }
    
    func saveMessage(chatId: String) {
        Database.database().reference().child(C_CHATS).child(chatId).childByAutoId().updateChildValues([C_MESSAGE: self.message, C_SENDERID: self.sentBy, C_TIMESTAMP: String(describing: self.timeStamp), C_RECIPIENTID: self.sentTo, C_SENDERNAME: self.senderName])
    }
    
}
