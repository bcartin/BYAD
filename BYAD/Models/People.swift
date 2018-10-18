//
//  People.swift
//  BYAD
//
//  Created by Bernie Cartin on 9/27/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase
import GeoFire
import CoreData

class People {
    
    var peopleArray: [User] = []
    var user: User?
    
    func loadPeople(handler: @escaping (_ error: Error?) -> Void) {
        Database.database().reference().child(C_USERS).observe(.childAdded) { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else {return}
            guard let uid = userDictionary[C_UID] as? String else {return}
            let user = User(uid: uid, dictionary: userDictionary)
            self.peopleArray.append(user)
            handler(nil)
        }
    }
    
    
    func loadPeopleGeo(handler: @escaping (_ error: Error?) -> Void) {
        guard let location = LocationServices.shared.currentLocation else {return}
        LocationServices.shared.lastSearchLocation = location
        let nodeRef = Database.database().reference().child(C_USERS)
        nodeRef.removeAllObservers()
        let geoRef = GeoFire(firebaseRef: nodeRef)
        let peopleQuery = geoRef.query(at: location, withRadius: 1.6)
        
        
        //To read blocked users from core data
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_BLOCKED)
        
        
        peopleQuery.observe(.keyEntered) { (userId, userLocation) in
            
            request.predicate = NSPredicate(format: "uid = %@", userId)
            request.returnsObjectsAsFaults = false
            do {
                let results = try managedContext.fetch(request)
                if results.count > 0 {
                    return
                }
            } catch let error as NSError {
                print("Could not Load. \(error), \(error.userInfo)")
            }
            Database.database().reference().child(C_USERS).child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let userDictionary = snapshot.value as? [String: Any] else {return}
                if self.isPersonAMatch(userDictionary) {
                    guard let uid = userDictionary[C_UID] as? String else {return}
                    let user = User(uid: uid, dictionary: userDictionary)
                    self.peopleArray.append(user)
                    handler(nil)
                }
            })
        }
    }
    
    func observePeopleExit(handler: @escaping (_ userID: String?) -> Void) {
        guard let location = self.user?.location else {return}
        let nodeRef = Database.database().reference().child(C_USERS)
        let geoRef = GeoFire(firebaseRef: nodeRef)
        let peopleQuery = geoRef.query(at: location, withRadius: 1.6)
        peopleQuery.observe(.keyExited) { (userId, userLocation) in
            handler(userId)
        }
    }
    
    func isPersonAMatch(_ personDictionary: [String: Any]) -> Bool {
        var isMatch = false
        let personGender = personDictionary[C_GENDER] as? Int
        guard let personAge = personDictionary[C_AGE] as? Int else {return false}
        guard let isOnline = personDictionary[C_ISONLINE] as? Bool else {return false}
        if  isOnline {
            if user?.uid != personDictionary[C_UID] as? String {
                if personGender == user?.preferredGender {
                    if personAge <= user?.maxAge ?? 99 && personAge >= user?.minAge ?? 18 {
                        isMatch = true
                    }
                }
            }
        }
        return isMatch
    }
    
    
    
}
