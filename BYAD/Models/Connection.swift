//
//  Connection.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/4/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import CoreData
import Firebase


class Connection {
    
    var personId: String
    var connectionName: String?
    var connectionPhotoUrl: String?
    var chatID: String?
    var timeStamp: Date
    var lastMessage: String?
    var isNew = false
    
    init(id: String) {
        self.personId = id
        self.timeStamp = Date()
    }
    
    init(id: String, name: String, photoURL: String, chatID: String, timeStamp: Date, message: String?, isNew: Bool?) {
        self.personId = id
        self.connectionName = name
        self.connectionPhotoUrl = photoURL
        self.chatID = chatID
        self.timeStamp = timeStamp
        self.lastMessage = message ?? ""
        self.isNew = isNew ?? false
    }
    
    func saveData(userID: String) {
        guard let name = self.connectionName else {return}
        guard let photoUrl = self.connectionPhotoUrl else {return}
        guard let chatId = self.chatID else {return}
        let message = self.lastMessage ?? ""
        let dataDict: [String:Any] = [C_UID: self.personId, C_NAME: name, C_PHOTOURL: photoUrl, C_CHATID: chatId, C_TIMESTAMP: String(describing: self.timeStamp), C_LASTMESSAGE: message, C_ISNEW: self.isNew]
        Database.database().reference().child(C_CONNECTIONS).child(userID).child(self.personId).updateChildValues(dataDict)
    }
    
    func connectionExists(userID: String, completion: @escaping(_ exists: Bool) -> ()) {
        Database.database().reference().child(C_CONNECTIONS).child(userID).child(self.personId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completion(true)
            }
            else {
                completion(false)
            }
        }
    }
    
    func loadMessages(handler: @escaping (_ message: Message) -> Void) {
        Database.database().reference().child(C_CHATS).removeAllObservers()
        guard let chatId = self.chatID else {return}
        Database.database().reference().child(C_CHATS).child(chatId).observe(.childAdded) { (snapshot) in
            if snapshot.exists() {
                let messageText = snapshot.childSnapshot(forPath: C_MESSAGE).value as! String
                let sentBy = snapshot.childSnapshot(forPath: C_SENDERID).value as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = C_DATETIMEFORMAT
                guard let time = dateFormatter.date(from: snapshot.childSnapshot(forPath: C_TIMESTAMP).value as! String) else {return}
                let sentTo = snapshot.childSnapshot(forPath: C_RECIPIENTID).value as! String
                let senderName = snapshot.childSnapshot(forPath: C_SENDERNAME).value as! String
                let message = Message(message: messageText, sentBy: sentBy, timeStamp: time, sentTo: sentTo, senderName: senderName)
                handler(message)
            }
        }
    }
    
    func observeChanges(handler: @escaping (_ result: Connection) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child(C_CONNECTIONS).child(userID).child(personId).observe(.value) { (snapshot) in
            if snapshot.exists() {
                self.lastMessage = snapshot.childSnapshot(forPath: C_LASTMESSAGE).value as? String ?? ""
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = C_DATETIMEFORMAT
                guard let time = dateFormatter.date(from: snapshot.childSnapshot(forPath: C_TIMESTAMP).value as! String) else {return}
                self.timeStamp = time
                self.isNew = snapshot.childSnapshot(forPath: C_ISNEW).value as? Bool ?? false
                handler(self)
            }
        }
    }
    
    func updateStatus(isNewStatus: Bool) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child(C_CONNECTIONS).child(userID).child(self.personId).updateChildValues([C_ISNEW: isNewStatus])
    }
    
//    func deleteConnection(with userID: String, handler: @escaping (_ error: Error?) -> Void) {
//        guard let chat = self.chatID else {return}
//        DataService.instance.CHATS.child(chat).removeValue()
//        DataService.instance.CONNECTIONS.child(userID).child(self.id).removeValue { (error, ref) in
//            if let err = error {
//                handler(err)
//            }
//            else {
//                DataService.instance.CONNECTIONS.child(self.id).child(userID).removeValue(completionBlock: { (error, ref) in
//                    if let err = error {
//                        handler(err)
//                    }
//                    else {
//                        handler(nil)
//                    }
//                })
//            }
//        }
//    }
    
    
    
    
    
    
    
}

