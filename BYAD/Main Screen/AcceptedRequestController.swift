//
//  AcceptedRequestController.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/5/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class AcceptedRequestController: UIViewController {
    
    var user: User?
    
    let matchImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 40
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let myImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 40
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    let matchUIView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.9)
        view.alpha = 0
        return view
    }()
    
    let greatLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 38)
        label.text = "GOOD NEWS!"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let subHeaderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let connectionMessageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let goChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("GO CHAT", for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 24)
        button.setTitleColor(UIColor(white: 1, alpha: 0.7), for: .normal)
        button.addTarget(self, action: #selector(handleGoChat(matchView:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    fileprivate func setupUI() {
        
        guard let photoUrl = user?.photosUrls[0] else {return}
        matchImageView.loadImage(from: photoUrl)
        guard let myPhotoUrl = Auth.auth().currentUser?.photoURL?.absoluteString else {return}
        myImageView.loadImage(from: myPhotoUrl)
        
        view.addSubview(matchUIView)
        matchUIView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        matchUIView.addSubview(myImageView)
        myImageView.anchor(top: matchUIView.topAnchor, left: nil, bottom: nil, right: matchUIView.rightAnchor, paddingTop: 200, paddingLeft: 0, paddingBottom: 0, paddingRight: 75)
        myImageView.setSizeAnchors(height: 200, width: 130)
        
        matchUIView.addSubview(matchImageView)
        matchImageView.anchor(top: matchUIView.topAnchor, left: matchUIView.leftAnchor, bottom: nil, right: nil, paddingTop: 200, paddingLeft: 75, paddingBottom: 0, paddingRight: 0)
        matchImageView.setSizeAnchors(height: 200, width: 130)
        
        var xFromCenter: CGFloat = -100.0
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 300)
        let scale = 1   //No Scaling
        var scaledAndRotated = rotation.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
        matchImageView.transform = scaledAndRotated
        
        xFromCenter = 100.0
        rotation = CGAffineTransform(rotationAngle: xFromCenter / 300)
        scaledAndRotated = rotation.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
        myImageView.transform = scaledAndRotated
        
        guard let user = user else {return}
        let name = user.name ?? ""
        
        subHeaderLabel.text = "\(name) has accepted your drink!"
        view.addSubview(subHeaderLabel)
        subHeaderLabel.anchor(top: nil, left: view.leftAnchor, bottom: myImageView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 50, paddingRight: 10)
        
        view.addSubview(greatLabel)
        greatLabel.anchor(top: nil, left: view.leftAnchor, bottom: subHeaderLabel.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        
        
        connectionMessageLabel.text = "You can now chat with \(name). \n Go set up a time and place to get that drink!"
        view.addSubview(connectionMessageLabel)
        connectionMessageLabel.anchor(top: myImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 50, paddingLeft: 10, paddingBottom: 0, paddingRight: 10)
        
        view.addSubview(goChatButton)
        goChatButton.anchor(top: connectionMessageLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 30, paddingLeft: 10, paddingBottom: 0, paddingRight: 10)
        
        matchUIView.fadeTo(alphaValue: 1, withDuration: 0.2)
        
    }
    
    @objc fileprivate func handleGoChat(matchView: UIView) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

