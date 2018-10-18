//
//  BlockedUsersController.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/9/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class BlockedUsersController: UITableViewController, Alertable {
    
    var userIDS: [String] = []
    var userNames: [String] = []
    var userTimeStamps: [Date] = []
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Blocked Users"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadBlockedUsers()
        
    }
    
    fileprivate func setupUI() {
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.titleView = titleLabel
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: C_CELLID)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
    }
    
    fileprivate func loadBlockedUsers() {
        self.shouldPresentLoadingView(true)
        userIDS.removeAll()
        userNames.removeAll()
        userTimeStamps.removeAll()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: C_BLOCKED)
        request.returnsObjectsAsFaults = false
        do {
            let results = try managedContext.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let uid = result.value(forKey: C_UID) as? String {
                        self.userIDS.append(uid)
                    }
                    if let name = result.value(forKey: C_NAME) as? String {
                        self.userNames.append(name)
                    }
                    if let timeStamp = result.value(forKey: C_TIMESTAMP) as? Date {
                        self.userTimeStamps.append(timeStamp)
                    }
                } 
            }
            tableView.reloadData()
            self.shouldPresentLoadingView(false)
        } catch let error as NSError {
            self.shouldPresentLoadingView(false)
            self.showAlert(title: C_ERROR, msg: "Could not load blocked users. \(error.localizedDescription)")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIDS.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: C_CELLID)
        cell.textLabel?.text = userNames[indexPath.item]
        cell.textLabel?.textColor = .darkGray
        
        
        cell.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        cell.accessoryType = .disclosureIndicator
        
        let blockedDate = userTimeStamps[indexPath.item]
        if let days = Calendar.current.dateComponents([Calendar.Component.day], from: blockedDate, to: Date()).day {
            cell.detailTextLabel?.text = "\(days) days ago."
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = userIDS[indexPath.item]
        let user = User(uid: uid)
        user.loadUserDetails { (error) in
            if let err = error {
                self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                return
            }
            let vc = ProfileController()
            vc.user = user
            vc.displayActionsButton = true
            vc.userBlocked = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
}


