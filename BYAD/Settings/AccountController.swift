//
//  AccountController.swift
//  BYAD
//
//  Created by Bernie Cartin on 9/26/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class AccountController: UIViewController {
    
    var user: User?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Account"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    let userImage: CustomImageView = {
        let image = CustomImageView()
        image.layer.cornerRadius = 50
        image.clipsToBounds = true
        return image
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()

    
    let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account", for: .normal)
        button.backgroundColor = UIColor.red
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleDelete), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadInfo()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = .white
        navigationItem.titleView = titleLabel
        let safeArea = view.safeAreaLayoutGuide
        
        view.addSubview(userImage)
        userImage.anchor(top: safeArea.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        userImage.setSizeAnchors(height: 100, width: 100)
        userImage.centerHorizontaly(in: view)
        
        view.addSubview(nameLabel)
        nameLabel.anchor(top: userImage.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
        view.addSubview(phoneLabel)
        phoneLabel.anchor(top: nameLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
        view.addSubview(deleteAccountButton)
        deleteAccountButton.anchor(top: nil, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 50, paddingRight: 20)
        deleteAccountButton.setSizeAnchors(height: 50, width: nil)
        

    }
    
    fileprivate func formatPhoneNumber(number: String) -> String {
        var index = number.startIndex
        var formatedString = ""
        formatedString.append(number[index])
        index = number.index(after: index)
        formatedString.append(number[index])
        formatedString.append(" ")
        for _ in 1...3 {
            index = number.index(after: index)
            formatedString.append(number[index])
        }
        formatedString.append("-")
        for _ in 1...3 {
            index = number.index(after: index)
            formatedString.append(number[index])
        }
        formatedString.append("-")
        for _ in 1...4 {
            index = number.index(after: index)
            formatedString.append(number[index])
        }
        return formatedString
    }
    
    fileprivate func loadInfo() {
        guard let url = Auth.auth().currentUser?.photoURL?.absoluteString else {return}
        userImage.loadImage(from: url)
        
        nameLabel.text = Auth.auth().currentUser?.displayName
        guard let phoneNumber = Auth.auth().currentUser?.phoneNumber else {return}
        phoneLabel.text = formatPhoneNumber(number: phoneNumber)
    }
    
    @objc fileprivate func handleDelete() {
        let deleteAlert = UIAlertController(title: "Delete Account", message: "Are you sure?", preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .destructive, handler: { (action) in
            let delete2Alert = UIAlertController(title: nil, message: "You must re-authenticate your account to continue", preferredStyle: .alert)
            let Continue = UIAlertAction(title: "Continue", style: .default, handler: { (action) in
                let vc = PhoneController()
                vc.isDeleting = true
                self.navigationController?.pushViewController(vc, animated: true)
            })
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            delete2Alert.addAction(Continue)
            delete2Alert.addAction(cancel)
            self.present(delete2Alert, animated: true)
        })
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        deleteAlert.addAction(yes)
        deleteAlert.addAction(cancel)
        self.present(deleteAlert, animated: true)
    }
    
}

