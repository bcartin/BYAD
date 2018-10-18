//
//  LocationServices.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/24/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class LocationServices: NSObject, CLLocationManagerDelegate {

    static let shared = LocationServices()
    var manager: CLLocationManager?
    var lastSearchLocation: CLLocation?
    var currentLocation: CLLocation?
    
    private override init() {
        super.init()
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyHundredMeters 
    }
    
    func authorize() {
        manager?.requestAlwaysAuthorization()
    }
    
    func checkLocationAuthStatus() {
        if (CLLocationManager.authorizationStatus() == .authorizedAlways) || (CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            manager?.startUpdatingLocation()
        }
        else {
            manager?.requestAlwaysAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        guard let location = locations.last else {return}
        self.currentLocation = location
        let user: User = User(uid: userID)
        user.updateUserLocation(with: location)
    }
    
}
