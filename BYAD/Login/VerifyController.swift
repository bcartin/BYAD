//
//  VerifyController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/22/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase


class VerifyController: UIViewController, Alertable {
    
    var verificationID: String?
    var phoneNumber: String?
    var isDeleting = false
    
    var vcToPop: UIViewController?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.text = "Verification"
        label.textColor = UIColor.mainBlue()
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.text = "Enter the code from the SMS we just sent you."
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    let codeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter code"
        textField.font = UIFont.systemFont(ofSize: 28)
        textField.textAlignment = .center
        textField.keyboardType = .phonePad
        textField.addTarget(self, action: #selector(handleTextChange(textField:)), for: .editingChanged)
        return textField
    }()
    
    let verifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Verify", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(handleVerify), for: .touchUpInside)
        return button
    }()
    
    let noCodeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = "Didn't get a code?"
        label.numberOfLines = 0
        return label
    }()
    
    let resendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("RESEND", for: .normal)
        button.backgroundColor = UIColor.mainBlue()
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleResend), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    fileprivate func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .white
        
        let codeUnderline = UIView()
        codeUnderline.backgroundColor = UIColor.lightGray
        codeUnderline.setSizeAnchors(height: 0.5, width: 120)
        let codeStackView = UIStackView(arrangedSubviews: [codeTextField, codeUnderline])
        codeStackView.axis = .vertical
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: safeArea.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 50, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        titleLabel.centerHorizontaly(in: view)
        
        view.addSubview(subTitleLabel)
        subTitleLabel.anchor(top: titleLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 20, paddingLeft: 5, paddingBottom: 0, paddingRight: 5)
        
        view.addSubview(codeStackView)
        codeStackView.anchor(top: subTitleLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 60, paddingLeft: 50, paddingBottom: 0, paddingRight: 50)
        
        view.addSubview(verifyButton)
        verifyButton.anchor(top: codeStackView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        verifyButton.centerHorizontaly(in: view)
        verifyButton.isEnabled = false
        
        view.addSubview(noCodeLabel)
        noCodeLabel.anchor(top: verifyButton.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 120, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        noCodeLabel.centerHorizontaly(in: view)
        
        view.addSubview(resendButton)
        resendButton.anchor(top: noCodeLabel.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        resendButton.setSizeAnchors(height: 30, width: 80)
        resendButton.centerHorizontaly(in: view)
        
    }
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == codeTextField {
            if textField.text?.count == 6 {
                textField.endEditing(false)
                verifyButton.isEnabled = true
            }
            else {
                verifyButton.isEnabled = false
            }
        }
    }
    
    @objc fileprivate func handleVerify() {
        self.shouldPresentLoadingView(true)
        guard let verificationCode = codeTextField.text else {return}
        guard let verificationID = self.verificationID else {return}
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        // DELETE USER
        if isDeleting {
            let user = Auth.auth().currentUser
            user?.reauthenticateAndRetrieveData(with: credential, completion: { (result, error) in
                if let err = error {
                    self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                    return
                }
                user?.delete(completion: { (error) in
                    if let err = error {
                        self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                        return
                    }
                    self.shouldPresentLoadingView(false)
                    self.navigationController?.popToRootViewController(animated: false)
                })
            })
            
        }
        // SIGN IN USER
        else {
            Auth.auth().signInAndRetrieveData(with: credential) { (result, error) in
                if let err = error {
                    self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                    return
                }
                guard let uid = result?.user.uid else {return}
                let user = User(uid: uid)
                user.checkIfUserExists(completion: { (exists) in
                    if exists {
                        self.shouldPresentLoadingView(false)
                        self.navigationController?.popToRootViewController(animated: false)
                    }
                    else {
                        let vc = NewUserController()
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                })
            }
        }
    }
    
    @objc fileprivate func handleResend() {
        guard let phoneNumber = self.phoneNumber else {return}
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let err = error {
                self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                print(err)
                return
            }
        }
    }
}
