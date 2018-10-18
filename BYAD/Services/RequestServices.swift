//
//  RequestServices.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/1/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase
import CoreData
import AVFoundation

class RequestServices {
    
    private init() {}
    
    static let shared = RequestServices()
    
    func observeRequests() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child(C_REQUESTS).queryOrdered(byChild: C_RECIPIENTID).queryEqual(toValue: uid).observe(.childAdded) { (snapshot) in
            if snapshot.exists() {
                if snapshot.childSnapshot(forPath: C_ISNEW).value as! Bool == true {
                    let requestId = snapshot.key
                    let userID = snapshot.childSnapshot(forPath: C_SENDERID).value as! String
                    let user = User(uid: userID)
                    user.loadUserDetails(completion: { (error) in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        let vc = RequestController()
                        vc.user = user
                        vc.requestId = requestId
                        
                        //Play Notification Sound
                        let systemSoundID: SystemSoundID = 1015
                        AudioServicesPlayAlertSound(systemSoundID)
                        
                        let rootVC = UIApplication.shared.keyWindow?.rootViewController
                        rootVC?.present(vc, animated: true, completion: nil)
                    })
                }
            }
        }
        Database.database().reference().child(C_REQUESTS).queryOrdered(byChild: C_RECIPIENTID).queryEqual(toValue: uid).observe(.childChanged) { (snapshot) in
            if snapshot.exists() {
                if snapshot.childSnapshot(forPath: C_ISNEW).value as! Bool == true {
                    let requestId = snapshot.key
                    let userID = snapshot.childSnapshot(forPath: C_SENDERID).value as! String
                    let user = User(uid: userID)
                    user.loadUserDetails(completion: { (error) in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        let vc = RequestController()
                        vc.user = user
                        vc.requestId = requestId
                        
                        //Play Notification Sound
                        let systemSoundID: SystemSoundID = 1015
                        AudioServicesPlayAlertSound(systemSoundID)
                        
                        let rootVC = UIApplication.shared.keyWindow?.rootViewController
                        rootVC?.present(vc, animated: true, completion: nil)
                    })
                }
            }
        }
    }
        
    
    func observeSentRequest() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Database.database().reference().child(C_REQUESTS).queryOrdered(byChild: C_SENDERID).queryEqual(toValue: uid).observe(.childChanged) { (snapshot) in
            if snapshot.exists() {
                if snapshot.childSnapshot(forPath: C_ISACCEPTED).value as! Bool == true {
                    let userID = snapshot.childSnapshot(forPath: C_RECIPIENTID).value as! String
                    let user = User(uid: userID)
                    user.loadUserDetails(completion: { (error) in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        let vc = AcceptedRequestController()
                        vc.user = user
                        
                        //Play Notification Sound
                        let systemSoundID: SystemSoundID = 1015
                        AudioServicesPlaySystemSound(systemSoundID)
                        
                        let rootVC = UIApplication.shared.keyWindow?.rootViewController
                        rootVC?.present(vc, animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    
    func createRequest(to recipientUID: String, data: [String:Any]) {
        Database.database().reference().child(C_REQUESTS).childByAutoId().updateChildValues(data) { (error, ref) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            let entity = NSEntityDescription.entity(forEntityName: C_REQUESTS, in: managedContext)!
            let request = NSManagedObject(entity: entity, insertInto: managedContext)
            request.setValue(recipientUID, forKey: "user")
            request.setValue(NSDate(), forKey: C_TIMESTAMP)
            do {
                try managedContext.save()
                print("Saved")
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func updateRequest(withId requestId: String, data: [String:Any]) {
        Database.database().reference().child(C_REQUESTS).child(requestId).updateChildValues(data) { (error, ref) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
        }
    }
    
    func checkIfRequestSent(to userId: String) -> Bool {
        var enableButton: Bool = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_REQUESTS)
        request.predicate = NSPredicate(format: "user = %@", userId)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    guard let lastRequestDate = result.value(forKey: C_TIMESTAMP) as? Date else {return true}
                    let currentDate = Date()
                    let hoursElapsed = Calendar.current.dateComponents([.hour], from: lastRequestDate, to: currentDate).hour
                    if hoursElapsed ?? 48 >= 48 {
                        enableButton = true
                    }
                    else {
                        enableButton = false
                    }
                    
                }
            }
            else {
                enableButton = true
            }
        } catch let error as NSError {
            print("Could not Load. \(error), \(error.userInfo)")
        }
        return enableButton
    }
    
}
