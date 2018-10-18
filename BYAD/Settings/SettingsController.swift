//
//  SettingsController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/28/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsController: UITableViewController, Alertable {
    
    let settings = [C_PERSONALINFO, C_PREFERENCES, C_PHOTOS, C_BLOCKEDUSERS, C_TERMSOFSERVICE, C_ABOUT, C_CLEARCACHE, C_LOGOUT, C_ACCOUNT]
    var user: User?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        navigationItem.titleView = titleLabel
        tableView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: C_CELLID)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: C_CELLID)
        cell.textLabel?.text = settings[indexPath.item]
        cell.textLabel?.textColor = .darkGray
        cell.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let user = self.user else {return}
        if tableView.cellForRow(at: indexPath)?.textLabel?.text == C_PERSONALINFO {
            let vc = PersonalInfoController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
        else if tableView.cellForRow(at: indexPath)?.textLabel?.text == C_PREFERENCES {
            let vc = PreferencesController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
        else if tableView.cellForRow(at: indexPath)?.textLabel?.text == C_PHOTOS {
            let vc = PhotosController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
        else if tableView.cellForRow(at: indexPath)?.textLabel?.text == C_TERMSOFSERVICE {
            let vc = TermsController()
            navigationController?.pushViewController(vc, animated: true)
        }
        else if tableView.cellForRow(at: indexPath)?.textLabel?.text == C_CLEARCACHE {
            let vc = CacheController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
        else if tableView.cellForRow(at: indexPath)?.textLabel?.text == C_LOGOUT {
            let logOutAlert = UIAlertController(title: "LOG OUT", message: "Are you sure?", preferredStyle: .alert)
            let logOut = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                do {
                    user.removeAllObservers()
                    user.updateUserDetails(with: [C_ISONLINE: false])
                    user.resetUserLocation()
                    try Auth.auth().signOut()
                    self.navigationController?.popToRootViewController(animated: true)
                }
                catch {
                    self.showAlert(title: C_ERROR, msg: "Error Logging Out")
                }
            })
            let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
            logOutAlert.addAction(logOut)
            logOutAlert.addAction(cancel)
            self.present(logOutAlert, animated: true)        }
        else if tableView.cellForRow(at: indexPath)?.textLabel?.text == C_ACCOUNT {
            let vc = AccountController()
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
        else if tableView.cellForRow(at: indexPath)?.textLabel?.text == C_ABOUT {
            let vc = AboutController()
            navigationController?.pushViewController(vc, animated: true)
        }
        

        
        
        
        
        
        
    }
    
}
