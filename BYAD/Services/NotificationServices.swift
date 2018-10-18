//
//  NotificationServices.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/21/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase

class NotificationService: NSObject, MessagingDelegate {
    
    private override init() {}
    static let shared = NotificationService()
    let unCenter = UNUserNotificationCenter.current()
    var window: UIWindow?
    
    func authorize() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        unCenter.requestAuthorization(options: options) { (granted, error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            guard granted else {return}
            DispatchQueue.main.async {
                self.configure()
            }
        }
    }
    
    func configure() {
        unCenter.delegate = self
        Messaging.messaging().delegate = self

        let application = UIApplication.shared
        application.registerForRemoteNotifications()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        if let uid = Auth.auth().currentUser?.uid {
            let user = User(uid: uid)
            user.updateUserDetails(with: [C_NOTIFICATIONSTOKEN: fcmToken])
        }
    }
    

}

extension NotificationService: UNUserNotificationCenterDelegate {
    
    
    func presentChatScreen(with senderDictionary: [String: Any]) {
        
        let connectionId = senderDictionary[C_UID] as! String
        let connectionName = senderDictionary[C_NAME] as! String
        let connectionPhotoUrl = senderDictionary[C_PHOTOURL] as! String
        let chatId = senderDictionary[C_CHATID] as! String
        
        let connection = Connection(id: connectionId, name: connectionName, photoURL: connectionPhotoUrl, chatID: chatId, timeStamp: Date(), message: nil, isNew: nil)
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let user = User(uid: uid)
        user.loadUserDetails { (error) in
            if let err = error {
                print(err)
                return
            }
            let navController = self.window?.rootViewController as! UINavigationController
            navController.popToRootViewController(animated: false)
            let connectionVC = ConnectionsController()
            connectionVC.user = user
            navController.pushViewController(connectionVC, animated: false)
            let chatVC = ChatController()
            chatVC.user = user
            chatVC.connection = connection
            connectionVC.navigationController?.pushViewController(chatVC, animated: false)
        }
       
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        if response.notification.request.content.categoryIdentifier == "message" {
            let notificationDictionary = response.notification.request.content.userInfo as! [String: Any]
            self.presentChatScreen(with: notificationDictionary)
        }
        completionHandler()
    }
    
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let requestType = notification.request.content.categoryIdentifier
        if requestType == "message" {
            let navController = self.window?.rootViewController as! UINavigationController
            let controller = navController.visibleViewController
            if !(controller is ChatController) {
                let options: UNNotificationPresentationOptions = [.alert, .sound]
                completionHandler(options)
            }
        }
    }
    
    
}


