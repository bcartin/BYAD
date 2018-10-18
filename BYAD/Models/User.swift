//
//  User.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/23/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import GeoFire
import CoreData

class User {
    
    var uid: String
    var name: String?
    var age: Int?
    var gender: Int?
    var dob: String?
    var preferredGender: Int?
    var minAge: Int?
    var maxAge: Int?
    var favoriteDrink: String?
    var photosUrls = [String]()
    var isOnline: Bool? {
        didSet {
            self.updateUserDetails(with: [C_ISONLINE: self.isOnline ?? false])
        }
    }
    var photos = [UIImage]()
    var badgeCount: Int?
    
    var location: CLLocation? {
        didSet {
            self.observeLastSearchLocation()
        }
    }
    
    init(uid: String) {
        self.uid = uid
    }
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.name = dictionary[C_NAME] as? String
        self.age = dictionary[C_AGE] as? Int
        self.gender = dictionary[C_GENDER] as? Int
        self.dob = dictionary[C_DOB] as? String
        self.preferredGender = dictionary[C_PREFEREDGENDER] as? Int
        self.minAge = dictionary[C_MINAGE] as? Int
        self.maxAge = dictionary[C_MAXAGE] as? Int
        self.favoriteDrink = dictionary[C_FAVORITEDRINK] as? String
        self.isOnline = dictionary[C_ISONLINE] as? Bool
        self.badgeCount = dictionary[C_BADGECOUNT] as? Int
        if let urlDictionary = dictionary[C_PHOTOURL] as? [String: Any] {
            for (_, value) in urlDictionary {
                self.photosUrls.append(value as! String)
            }
        }
    }
    
    func setUserDetails(with dictionary: [String: Any]) {
        self.name = dictionary[C_NAME] as? String
        self.age = dictionary[C_AGE] as? Int
        self.gender = dictionary[C_GENDER] as? Int
        self.dob = dictionary[C_DOB] as? String
        self.preferredGender = dictionary[C_PREFEREDGENDER] as? Int
        self.minAge = dictionary[C_MINAGE] as? Int
        self.maxAge = dictionary[C_MAXAGE] as? Int
        self.favoriteDrink = dictionary[C_FAVORITEDRINK] as? String
        self.isOnline = dictionary[C_ISONLINE] as? Bool
        self.badgeCount = dictionary[C_BADGECOUNT] as? Int
        if let urlDictionary = dictionary[C_PHOTOURL] as? [String: Any] {
            for (_, value) in urlDictionary {
                self.photosUrls.append(value as! String)
            }
        }
        let locationArray = dictionary[C_L] as! [CLLocationDegrees]
        let lat = locationArray[0]
        let long = locationArray[1]
        self.location = CLLocation(latitude: lat, longitude: long)
        userCache.setObject(self, forKey: self.uid as NSString)
    }
    
    func setUserDetails(with user: User) {
        self.name = user.name
        self.age = user.age
        self.gender = user.gender
        self.dob = user.dob
        self.preferredGender = user.preferredGender
        self.minAge = user.minAge
        self.maxAge = user.maxAge
        self.favoriteDrink = user.favoriteDrink
        self.isOnline = user.isOnline
        self.badgeCount = user.badgeCount
        self.photosUrls = user.photosUrls
        self.location = user.location

    }
    
    func updateUserDetails(with dictionary: [String:Any]) {
        Database.database().reference().child(C_USERS).child(self.uid).updateChildValues(dictionary)
        userCache.setObject(self, forKey: self.uid as NSString)
    }
    
    func updateUserDetails(with dictionary: [String:Any], completion: @escaping (_ error: Error?) -> ()) {
        Database.database().reference().child(C_USERS).child(self.uid).updateChildValues(dictionary) { (error, ref) in
            if let err = error {
                completion(err)
            }
            else {
                userCache.setObject(self, forKey: self.uid as NSString)
                completion(nil)
            }
        }
    }
    
    func checkIfUserExists(completion: @escaping (_ exists: Bool) -> ()) {
        Database.database().reference().child(C_USERS).child(self.uid).observeSingleEvent(of: .value) { (snapshot) in
            completion(snapshot.exists())
        }
    }
    
    func loadUserDetails(completion: @escaping (_ error: Error?) -> ()) {
        if let user = userCache.object(forKey: self.uid as NSString) {
            self.setUserDetails(with: user)
            completion(nil)
        }
        else {
            Database.database().reference().child(C_USERS).child(self.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let dataDictionary = snapshot.value as! [String: Any]
                self.setUserDetails(with: dataDictionary)
                completion(nil)
            }) { (error) in
                completion(error)
            }
        }
    }
    
    func deleteAllPhotos() {
            Database.database().reference().child(C_USERS).child(self.uid).child(C_PHOTOURL).removeValue()
    }
    
    func resetBadgeCount() {
        self.updateUserDetails(with: [C_BADGECOUNT: 0])
    }
    

    
    func savePhotos(using photos: [UIImage], handler: @escaping (_ error: Error?) -> Void) {
        self.photosUrls.removeAll()
        var photosUrlDictionary: [String: Any] = [:]
        for (index, image) in photos.enumerated() {
            let imageFileName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child(C_USERIMAGES).child(imageFileName)
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let newImage = resizeImage(image: image)
            if let uploadData = newImage.jpegData(compressionQuality: 1.0) {
                storageRef.putData(uploadData, metadata: metadata) { (meta, error) in
                    if let err = error {
                        handler(err)
                        return
                    }
                    storageRef.downloadURL(completion: { (url, error) in
                        if let err = error {
                            handler(err)
                            return
                        }
                        guard let newUrl = url?.absoluteString else {return}
                        imageCache.setObject(newImage, forKey: newUrl as NSString)
                        self.photosUrls.append(newUrl)
                        photosUrlDictionary[imageFileName] = newUrl
                        if index == 0 {
                            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                            changeRequest?.photoURL = url?.absoluteURL
                            changeRequest?.commitChanges(completion: nil)
                        }
                        if self.photosUrls.count == photos.count {
                            self.updateUserDetails(with: [C_PHOTOURL: photosUrlDictionary])
                            handler(nil)
                        }
                    })
                }
            }
        }
    }
    
    func updateDisplayName(with name: String) {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges(completion: nil)
    }
    
    func updateUserLocation(with location: CLLocation) {
        let nodeRef = Database.database().reference().child(C_USERS)
        let geoRef = GeoFire(firebaseRef: nodeRef)
        geoRef.setLocation(location, forKey: self.uid)
        self.location = location
    }
    
    func resetUserLocation() {
        let location = CLLocation(latitude: 0, longitude: 0)
        let nodeRef = Database.database().reference().child(C_USERS)
        let geoRef = GeoFire(firebaseRef: nodeRef)
        geoRef.setLocation(location, forKey: self.uid)
    }
    
    fileprivate func resizeImage(image: UIImage) -> UIImage {
        var returnImage : UIImage = UIImage()
        var actualHeight = image.size.height
        var actualWidth = image.size.width
        let maxWidth : CGFloat = 400.0
        let maxHeight : CGFloat = 700.0
        var imageRatio = actualWidth/actualHeight
        let maxRatio = maxWidth/maxHeight
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imageRatio < maxRatio {
                imageRatio = maxHeight / actualHeight
                actualWidth = imageRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imageRatio > maxRatio{
                imageRatio = maxWidth / actualWidth
                actualHeight = imageRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        if let img = UIGraphicsGetImageFromCurrentImageContext() {
            if let imageData = img.jpegData(compressionQuality: 1.0) {
                UIGraphicsEndImageContext()
                returnImage = UIImage(data: imageData)!
            }
        }
        return returnImage
    }
    
    func loadImages(completion: @escaping(_ finished: Bool) -> ()) {
        self.photos = []
        for url in self.photosUrls {
            let lastURLUsedToLoadImage = url
            if let cachedImage = imageCache.object(forKey: lastURLUsedToLoadImage as NSString) {
                self.photos.append(cachedImage)
                if self.photos.count == self.photosUrls.count {
                    completion(true)
                }
            }
            else {
                guard let url = URL(string: url) else {return}
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if url.absoluteString != lastURLUsedToLoadImage {
                        return
                    }
                    guard let imageData = data else {return}
                    if let photoImage = UIImage(data: imageData) {
                        imageCache.setObject(photoImage, forKey: url.absoluteString as NSString)
                        DispatchQueue.main.async {
                            self.photos.append(photoImage)
                        }
                    }
                    }.resume()
                if self.photos.count == self.photosUrls.count {
                    completion(true)
                }
            }
        }
        
    }
    
    
    func saveRequest(from uid: String, data: [String:Any]) {
        Database.database().reference().child(C_REQUESTS).child(self.uid).child(uid).updateChildValues(data) { (error, ref) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
            let entity = NSEntityDescription.entity(forEntityName: C_REQUESTS, in: managedContext)!
            let request = NSManagedObject(entity: entity, insertInto: managedContext)
            request.setValue(self.uid, forKey: "user")
            request.setValue(NSDate(), forKey: C_TIMESTAMP)
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func blockUser(by userID: String, handler: @escaping (_ error: Error?) -> Void) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.mergePolicy = NSMergePolicy(merge: NSMergePolicyType.mergeByPropertyObjectTrumpMergePolicyType)
        let entity = NSEntityDescription.entity(forEntityName: C_BLOCKED, in: managedContext)!
        let request = NSManagedObject(entity: entity, insertInto: managedContext)
        request.setValue(self.uid, forKey: C_UID)
        request.setValue(self.name, forKey: C_NAME)
        request.setValue(Date(), forKey: C_TIMESTAMP)
        do {
            try managedContext.save()
            Database.database().reference().child(C_BLOCKED).child(self.uid).child(userID).updateChildValues([C_UID: userID])
            self.resetUserLocation()
            handler(nil)
        } catch let error as NSError {
            handler(error)
        }
    }
    
    func unblockUser(by userID: String, handler: @escaping (_ error: Error?) -> Void)  {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_BLOCKED)
        request.predicate = NSPredicate(format: "uid = %@", self.uid)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    managedContext.delete(result)
                    do{
                        try managedContext.save()
                        Database.database().reference().child(C_BLOCKED).child(self.uid).child(userID).removeValue()
                        handler(nil)
                    }
                    catch let error as NSError{
                        handler(error)
                    }
                }
            }
        } catch let error as NSError {
            handler(error)
        }
    }
    
    func observeIfBlocked(handler: @escaping (_ userID: String?) -> Void) {
        
        Database.database().reference().child(C_BLOCKED).child(self.uid).observe(.childAdded) { (snapshot) in
            let id = snapshot.childSnapshot(forPath: C_UID).value as! String
            handler(id)
        }
    }
    
    func observeIfUnblocked(handler: @escaping (_ userID: String?) -> Void) {
        Database.database().reference().child(C_BLOCKED).child(self.uid).observe(.childRemoved) { (snapshot) in
            let id = snapshot.childSnapshot(forPath: C_UID).value as! String
            self.resetUserLocation()
            handler(id)
        }
    }
    
    
    
    func loadConnections(handler: @escaping (_ match: Connection?) -> Void) {
        Database.database().reference().child(C_CONNECTIONS).child(self.uid).queryOrdered(byChild: C_TIMESTAMP).observe(.childAdded) { (snapshot) in
            if snapshot.exists() {
                let id = snapshot.childSnapshot(forPath: C_UID).value as! String
                let name = snapshot.childSnapshot(forPath: C_NAME).value as! String
                let photoUrl = snapshot.childSnapshot(forPath: C_PHOTOURL).value as! String
                let chatId = snapshot.childSnapshot(forPath: C_CHATID).value as! String
                let lastMessage = snapshot.childSnapshot(forPath: C_LASTMESSAGE).value as! String
                let isNew = snapshot.childSnapshot(forPath: C_ISNEW).value as? Bool ?? false
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = C_DATETIMEFORMAT
                guard let time = dateFormatter.date(from: snapshot.childSnapshot(forPath: C_TIMESTAMP).value as! String) else {return}
                
                let match = Connection(id: id, name: name, photoURL: photoUrl, chatID: chatId, timeStamp: time, message: lastMessage, isNew: isNew)
                handler(match)
            }
            else {
                handler(nil)
            }
        }
        
    }
    
    func reportUser(userID: String, reason: String) {
        Database.database().reference().child(C_REPORTEDUSERS).child(self.uid).child(userID).updateChildValues([C_REASON: reason, C_TIMESTAMP: Date().description])
    }
    
    func removeAllObservers() {
        Database.database().reference().child(C_USERS).removeAllObservers()
        Database.database().reference().child(C_REQUESTS).removeAllObservers()
        Database.database().reference().child(C_BLOCKED).removeAllObservers()
        Database.database().reference().child(C_CONNECTIONS).removeAllObservers()
        Database.database().reference().child(C_CHATS).removeAllObservers()
    }
    
    func observeLastSearchLocation() {
        guard let lastLocation = LocationServices.shared.lastSearchLocation else {return}
        guard let location = self.location else {return}
        let distance = location.distance(from: lastLocation)
        if distance > 16 {
            NotificationCenter.default.post(name: .didCoverDistance, object: nil)
        }
    }
    
}
