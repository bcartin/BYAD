//
//  ChatController.swift
//  BYAD
//
//  Created by Bernie Cartin on 10/5/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class ChatController: UIViewController, Alertable {

    var connection: Connection?
    var user: User?
    var placeHolderText: Bool = true
    var messages: [Message] = []
    var myName = Auth.auth().currentUser?.displayName
    var userBlocked = false
    var reasonsArray: [String] = ["Offensive Language", "Rude/Obscene Photos", "Inappropriate Messages", "Other"]
    
    var bottomConstraint: NSLayoutConstraint?
    
    lazy var headerButton: UIButton = {
        var button = UIButton(type: .system)
        button.addTarget(self, action: #selector(viewProfile(button:)), for: .touchUpInside)
        return button
    }()
    
    let headerPhoto: CustomImageView = {
        let imageView = CustomImageView()
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    let chatTableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.allowsSelection = false
        tv.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        tv.register(SentMesssageCell.self, forCellReuseIdentifier: "sentMessageCell")
        tv.register(ReceivedMessageCell.self, forCellReuseIdentifier: "receivedMessageCell")
        return tv
    }()
    
    lazy var messageView: MessageInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let accessoryView = MessageInputAccessoryView(frame: frame)
        accessoryView.delegate = self
        return accessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return messageView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpDelegates()
        setupKeyboardWillShowNotifications()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.messages.removeAll()
        self.connection?.loadMessages(handler: { (message) in
            self.messages.append(message)
            self.messages.sort {$0.timeStamp > $1.timeStamp}
            self.chatTableView.reloadData()
            self.scrollToLast()
        })
        self.user?.observeIfBlocked(handler: { (userID) in
            if userID == self.connection?.personId {
                self.userBlocked = true
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if !userBlocked {
            self.connection?.updateStatus(isNewStatus: false)
        }
    }
    
    func setUpDelegates() {
        chatTableView.delegate = self
        chatTableView.dataSource = self
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
//        self.view.addGestureRecognizer(tap)
    }
    
    func setupUI() {
        chatTableView.keyboardDismissMode = .onDrag
        
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let actionsButton = UIBarButtonItem(image: UIImage(named: "actions.png"), style: .plain, target: self, action: #selector(showActions))
        self.navigationItem.rightBarButtonItem = actionsButton

        guard let name = self.connection?.connectionName else {return}
        headerLabel.text = name

        guard let photoUrl = connection?.connectionPhotoUrl else {return}
        headerPhoto.loadImage(from: photoUrl)
        headerPhoto.setSizeAnchors(height: 40, width: 40)
        
        let headerView = UIView()
        headerView.setSizeAnchors(height: 44, width: 270)
        headerView.addSubview(headerPhoto)
        headerPhoto.centerVertically(in: headerView)
        
        headerView.addSubview(headerLabel)
        headerLabel.anchor(top: nil, left: headerPhoto.rightAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 10, paddingBottom: 0, paddingRight: 0)
        headerLabel.centerVertically(in: headerView)
        
        headerView.addSubview(headerButton)
        headerButton.anchor(top: headerView.topAnchor, left: headerView.leftAnchor, bottom: headerView.bottomAnchor, right: headerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)

        self.navigationItem.titleView = headerView
        
        view.addSubview(chatTableView)
        chatTableView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        bottomConstraint = NSLayoutConstraint(item: chatTableView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view.safeAreaLayoutGuide, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: -50.0)
        bottomConstraint?.isActive = true

        chatTableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));

    }
    

    
    @objc fileprivate func viewProfile(button: UIButton) {
        
        guard let userId = connection?.personId else {return}
        let user = User(uid: userId)
        user.loadUserDetails(completion: { (error) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
            let vc = ProfileController()
            vc.displayActionsButton = true
            vc.user = user
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
    }
    
    @objc func sendMessage() {
        if !self.userBlocked {
            guard let chatId = self.connection?.chatID else {return}
            guard let senderId = Auth.auth().currentUser?.uid else {return}
            let messageText = messageView.messageTextField.text + " "
            guard let recipientId = connection?.personId else {return}
            guard let name = myName else {return}
            
            let message = Message(message: messageText, sentBy: senderId, timeStamp: Date(), sentTo: recipientId, senderName: name)
            message.saveMessage(chatId: chatId)
            self.view.endEditing(true)
            scrollToLast()
        }
        else {
            self.showAlert(title: C_ERROR, msg: "Failed to send message. User doesn't exist.")
        }
    }
    
    
    @objc func showActions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let blockAction = UIAlertAction(title: "Block User", style: .default) { (_) in
            self.blockUser()
        }
        let reportAction = UIAlertAction(title: "Report User", style: .default) { (_) in
            self.reportUser()

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(blockAction)
        alert.addAction(reportAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true)
    }
    
    fileprivate func blockUser() {
        let blockAlert = UIAlertController(title: "Block User", message: "Are you sure?", preferredStyle: .alert)
        let block = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            guard let myUserID = Auth.auth().currentUser?.uid else {return}
            guard let userID = self.connection?.personId else {return}
            let user = User(uid: userID)
            user.name = self.connection?.connectionName
            user.blockUser(by: myUserID, handler: { (error) in
                if let err = error {
                    self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                    return
                }
                self.userBlocked = true
                
                let confirmationAlert = UIAlertController(title: "User Blocked", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default
                    , handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                })
                confirmationAlert.addAction(action)
                self.present(confirmationAlert, animated: true)
            })
            
        })
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        blockAlert.addAction(block)
        blockAlert.addAction(cancel)
        self.present(blockAlert, animated: true)
    }
    
    fileprivate func reportUser() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: self.view.frame.width ,height: 80)
        let reasonPickerView = UIPickerView()
        reasonPickerView.delegate = self
        reasonPickerView.dataSource = self
        vc.view.addSubview(reasonPickerView)
        reasonPickerView.setSizeAnchors(height: 100, width: self.view.frame.width)
        reasonPickerView.centerVertically(in: vc.view)
        reasonPickerView.centerHorizontaly(in: vc.view)
        let reportAlert = UIAlertController(title: "Report User", message: "Select a reason to report this user.", preferredStyle: UIAlertController.Style.actionSheet)
        reportAlert.setValue(vc, forKey: "contentViewController")
        reportAlert.addAction(UIAlertAction(title: "Report", style: .default, handler: { (done) in
            //Report User
            guard let user = self.user else {return}
            guard let personId = self.connection?.personId else {return}
            let reason = self.reasonsArray[reasonPickerView.selectedRow(inComponent: 0)]
            user.reportUser(userID: personId, reason: reason)
            self.showAlert(title: "User has been reported", msg: "We will review the report and take action accordingly")
        }))
        reportAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(reportAlert, animated: true)
    }
    
}

extension ChatController: UITableViewDelegate, UITableViewDataSource {
    func getWidth(text: String) -> CGFloat
    {
        let txtField = UILabel(frame: .zero)
        txtField.text = text
        txtField.sizeToFit()
        return txtField.frame.size.width
    }
    
    func scrollToLast() {
        if messages.count > 0 {
            let IP = IndexPath(row: 0, section: 0)
            self.chatTableView.scrollToRow(at: IP, at: .bottom, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let messageWidth =  getWidth(text: messages[indexPath.row].message)
        let maxWidth = (self.chatTableView.frame.width / 3) * 2
        
        if messages[indexPath.row].sentBy == Auth.auth().currentUser?.uid {
            let sentMessageCell = chatTableView.dequeueReusableCell(withIdentifier: "sentMessageCell", for: indexPath) as! SentMesssageCell
            sentMessageCell.messageLabel.text = messages[indexPath.row].message
            sentMessageCell.messageLabelWidthConstraint?.constant = min(messageWidth, maxWidth)
            if let photoUrl = Auth.auth().currentUser?.photoURL?.absoluteString {
                sentMessageCell.senderImage.loadImage(from: photoUrl)
            }
            
            sentMessageCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            return sentMessageCell
        }
        else {
            let receivedMessageCell = chatTableView.dequeueReusableCell(withIdentifier: "receivedMessageCell", for: indexPath) as! ReceivedMessageCell
            receivedMessageCell.messageLabel.text = messages[indexPath.row].message
            if let photoUrl = connection?.connectionPhotoUrl {
                receivedMessageCell.senderImage.loadImage(from: photoUrl)
            }
            receivedMessageCell.messageLabelWidthConstraint?.constant = min(messageWidth, maxWidth)
            receivedMessageCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
            return receivedMessageCell
        }
        
    }
    
    
}

extension ChatController: MessageInputAccessoryViewDelegate {
    func didSend(for message: String) {
        self.sendMessage()
    }
    
    
}

extension ChatController {
    
    func setupKeyboardWillShowNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        bottomConstraint?.constant = -keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: Notification) {
                bottomConstraint?.constant = -50.0
    }
    
}

extension ChatController: UIPickerViewDataSource, UIPickerViewDelegate {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return reasonsArray[row]
    }
    
}
