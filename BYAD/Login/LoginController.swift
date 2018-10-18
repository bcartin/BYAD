//
//  LoginController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/22/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginController: UIViewController {
    
    
    let titleImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "HeaderText"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let logoImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "mainLogo.png"))
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let termsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms & Conditions", for: .normal)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.addTarget(self, action: #selector(handleTermsTapped), for: .touchUpInside)
        return button
    }()
    
    let logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("GET STARTED", for: .normal)
        button.backgroundColor = UIColor.mainBlue()
//        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleLogIn), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
        
        if Auth.auth().currentUser != nil {
            DispatchQueue.main.async {
                let vc = MainController()
                let navController = UINavigationController(rootViewController: vc)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }

    }
    
    fileprivate func setupUI() {
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.barTintColor = UIColor.mainBlue()
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        view.addSubview(titleImage)
        titleImage.anchor(top: safeArea.topAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 80, paddingLeft: 50, paddingBottom: 0, paddingRight: 50)
        
        view.addSubview(logoImage)
//        logoImage.anchor(top: titleImage.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        logoImage.setSizeAnchors(height: 200, width: 200)
        logoImage.centerHorizontaly(in: view)
        logoImage.centerVertically(in: view)
        
        view.addSubview(logInButton)
        logInButton.anchor(top: nil, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 140, paddingRight: 0)
        logInButton.setSizeAnchors(height: 60, width: nil)
        
        view.addSubview(termsButton)
        termsButton.anchor(top: nil, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 30, paddingRight: 0)
        
        
    }
    
    @objc fileprivate func handleLogIn() {
        let phoneController = PhoneController()
        navigationController?.pushViewController(phoneController, animated: true)
    }
    
    @objc fileprivate func handleTermsTapped() {
        let vc = TermsController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
