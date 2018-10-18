//
//  RequestController.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/2/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class RequestController: UIViewController {
    
    var user: User?
    var requestId: String?
    var userImageCenter: CGPoint?
    
    let backgroundImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "back.jpg"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let blurEffectView: UIVisualEffectView = {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.alpha = 0.80
        return effectView
    }()
    
    let cheersLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 38)
        label.text = "CHEERS!"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let userUIView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 40
        return view
    }()
    
    let userImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 40
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        return imageView
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-DemiBold", size: 20)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let tutorialView = UIView()
    
    let tutorialImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "requestTutorial.png"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let gotItButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("GOT IT", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleDismissTutorial), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDelegates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userImageCenter = userUIView.center
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    fileprivate func setupUI() {
        view.addSubview(backgroundImage)
        backgroundImage.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(blurEffectView)
        blurEffectView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)

        let mainContentView = blurEffectView.contentView
        

        mainContentView.addSubview(userUIView)
        userUIView.setSizeAnchors(height: 250, width: 180)
        userUIView.centerHorizontaly(in: mainContentView)
        userUIView.centerVertically(in: mainContentView)

        guard let photoUrl = user?.photosUrls[0] else {return}
        userImageView.loadImage(from: photoUrl)
        userUIView.addSubview(userImageView)
        userImageView.anchor(top: userUIView.topAnchor, left: userUIView.leftAnchor, bottom: userUIView.bottomAnchor, right: userUIView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        mainContentView.addSubview(cheersLabel)
        cheersLabel.anchor(top: nil, left: mainContentView.leftAnchor, bottom: userUIView.topAnchor, right: mainContentView.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 25, paddingRight: 10)

        
        guard let user = user else {return}
        let name = user.name ?? ""
        messageLabel.text = name + " wants to buy you a drink!"
        mainContentView.addSubview(messageLabel)
        messageLabel.anchor(top: userUIView.bottomAnchor, left: mainContentView.leftAnchor, bottom: nil, right: mainContentView.rightAnchor, paddingTop: 30, paddingLeft: 10, paddingBottom: 0, paddingRight: 10)
        
        if !UserDefaults.standard.bool(forKey: C_HIDEREQUESTTUTORIAL) {
            view.addSubview(tutorialView)
            tutorialView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
            
            tutorialView.addSubview(tutorialImageView)
            tutorialImageView.anchor(top: tutorialView.topAnchor, left: tutorialView.leftAnchor, bottom: tutorialView.bottomAnchor, right: tutorialView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
            
            tutorialView.addSubview(gotItButton)
            gotItButton.anchor(top: nil, left: nil, bottom: tutorialView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 150, paddingRight: 0)
            gotItButton.centerHorizontaly(in: tutorialView)
        }

    }
    
    fileprivate func setupDelegates() {
        
        let drag = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        userUIView.addGestureRecognizer(drag)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(wasTapped(gestureRecognizer:)))
        userUIView.addGestureRecognizer(tap)
    }
    
    @objc fileprivate func wasTapped(gestureRecognizer : UITapGestureRecognizer) {
        let vc = ProfileController()
        vc.displayByadButton = false
        vc.displaySettingsButton = false
        vc.displayDismissButton = true
        vc.user = self.user
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc fileprivate func wasDragged(gestureRecognizer : UIPanGestureRecognizer) {
        guard let imageCenter = userImageCenter else {return}
        let labelPoint = gestureRecognizer.translation(in: view)
        userUIView.center = CGPoint(x: imageCenter.x + labelPoint.x, y: imageCenter.y)
        //animations - rotation
        let xFromCenter = view.bounds.width / 2 - userUIView.center.x
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 300)
        let scale = 1   //No Scaling
        var scaledAndRotated = rotation.scaledBy(x: CGFloat(scale), y: CGFloat(scale))
        userUIView.transform = scaledAndRotated
        
        if gestureRecognizer.state == .ended { //Have they stopped swiping?
            var accepted = false
            var acceptedOrRejected = ""
            
            if userUIView.center.x < (view.bounds.width / 2 - 150) { // if it's gone far enough left
                //NOT INTERESTED
                accepted = false
                acceptedOrRejected = "rejected"
            }
            if userUIView.center.x > (view.bounds.width / 2 + 150) { // if it's gone far enough right
                //INTERESTED
                accepted = true
                acceptedOrRejected = "accepted"
            }
            if acceptedOrRejected != "" {
                if accepted {
                    createConnections()
                    showConnection()
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
                updateRequest(isAccepted: accepted)
            }
            
            //Snap Back into place
            userUIView.center = imageCenter
            
            //Rotate back to initial position
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotated = rotation.scaledBy(x: 1, y: 1)
            userUIView.transform = scaledAndRotated
        }
    }
    
    @objc fileprivate func handleDismissTutorial() {
        UserDefaults.standard.set(true, forKey: C_HIDEREQUESTTUTORIAL)
        tutorialView.fadeTo(alphaValue: 0, withDuration: 0.5)
    }
    
    fileprivate func createConnections() {
        let chatId = NSUUID().uuidString
        guard let user = self.user else {return}
        guard let name = user.name else {return}
        guard let myUID = Auth.auth().currentUser?.uid else {return}
        guard let myName = Auth.auth().currentUser?.displayName else {return}
        guard let myPhotoUrl = Auth.auth().currentUser?.photoURL else {return}
        let myConnection = Connection(id: user.uid, name: name, photoURL: user.photosUrls[0], chatID: chatId, timeStamp: Date(), message: nil, isNew: true)
        myConnection.connectionExists(userID: myUID) { (exists) in
            if !exists {
                myConnection.saveData(userID: myUID)
            }
        }
        let matchConnection = Connection(id: myUID, name: myName, photoURL: myPhotoUrl.absoluteString, chatID: chatId, timeStamp: Date(), message: nil, isNew: true)
        matchConnection.connectionExists(userID: user.uid) { (exists) in
            if !exists {
                matchConnection.saveData(userID: user.uid)
            }
        }
    }
    
    fileprivate func showConnection() {
        guard let photoUrl = user?.photosUrls[0] else {return}
        let matchImageView: CustomImageView = {
            let imageView = CustomImageView()
            imageView.loadImage(from: photoUrl)
            imageView.layer.cornerRadius = 40
            imageView.layer.borderColor = UIColor.white.cgColor
            imageView.layer.borderWidth = 1
            return imageView
        }()
        guard let myPhotoUrl = Auth.auth().currentUser?.photoURL?.absoluteString else {return}
        let myImageView: CustomImageView = {
            let imageView = CustomImageView()
            imageView.loadImage(from: myPhotoUrl)
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
            label.text = "GREAT!"
            label.textColor = .white
            label.textAlignment = .center
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
        
        view.addSubview(greatLabel)
        greatLabel.anchor(top: nil, left: view.leftAnchor, bottom: myImageView.topAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 10, paddingBottom: 50, paddingRight: 10)
        
        guard let user = user else {return}
        let name = user.name ?? ""
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
    
    fileprivate func updateRequest(isAccepted: Bool) {
        guard let requestId = self.requestId else {return}
        var requestDict: [String:Any] = [:]
        requestDict[C_ISNEW] = false
        requestDict[C_ISACCEPTED] = isAccepted
        RequestServices.shared.updateRequest(withId: requestId, data: requestDict)
    }
}
