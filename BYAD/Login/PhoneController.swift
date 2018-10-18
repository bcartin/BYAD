//
//  PhoneController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/22/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class PhoneController: UIViewController, Alertable {
    
    var verificationID: String?
    
    var vcToPop: UIViewController?
    var isDeleting = false
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to BYAD"
        label.font = UIFont.systemFont(ofSize: 28)
        return label
    }()
    
    let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sign In with your phone number and we'll send you a verification code"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    let areaCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "+1"
        label.font = UIFont.systemFont(ofSize: 24)
        return label
    }()
    
    let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Your Phone Number"
        textField.font = UIFont.systemFont(ofSize: 24)
        textField.keyboardType = .phonePad
        textField.textAlignment = .center
        textField.addTarget(self, action: #selector(handleTextChange(textField:)), for: .editingChanged)
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        let attributedText = NSMutableAttributedString(string: "By clicking continue you agree to the ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedText.append(NSAttributedString(string: " Terms & Conditions of Use. ", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.mainBlue()]))
        attributedText.append(NSAttributedString(string: "Message and data rates may apply.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        label.attributedText = attributedText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let infoButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleTermsTap), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpNavBar()
        setupDelegates()
    }
    
    fileprivate func setupDelegates() {
        phoneTextField.delegate = self
        
    }
    
    fileprivate func setupUI() {
        let safeArea = view.safeAreaLayoutGuide
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: safeArea.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 75, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        titleLabel.centerHorizontaly(in: view)
        
        view.addSubview(subTitleLabel)
        subTitleLabel.anchor(top: titleLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        subTitleLabel.centerHorizontaly(in: view)

        let areaCodeUnderline = UIView()
        areaCodeUnderline.backgroundColor = UIColor.lightGray
        areaCodeUnderline.setSizeAnchors(height: 0.5, width: 30)
        let areaCodeStackView = UIStackView(arrangedSubviews: [areaCodeLabel, areaCodeUnderline])
        areaCodeStackView.axis = .vertical
        
        let phoneUnderline = UIView()
        phoneUnderline.backgroundColor = UIColor.lightGray
        phoneUnderline.setSizeAnchors(height: 0.5, width: 200)
        let phoneStackView = UIStackView(arrangedSubviews: [phoneTextField, phoneUnderline])
        phoneStackView.axis = .vertical
        
        let combinedStackView = UIStackView(arrangedSubviews: [areaCodeStackView, phoneStackView])
        combinedStackView.axis = .horizontal
        combinedStackView.spacing = 20
        view.addSubview(combinedStackView)
        combinedStackView.anchor(top: subTitleLabel.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 50, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
        view.addSubview(continueButton)
        continueButton.anchor(top: combinedStackView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        continueButton.centerHorizontaly(in: view)
        continueButton.isEnabled = false
        
        view.addSubview(infoLabel)
        infoLabel.anchor(top: continueButton.bottomAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 40, paddingLeft: 30, paddingBottom: 0, paddingRight: 30)
        
        view.addSubview(infoButton)
        infoButton.anchor(top: infoLabel.topAnchor, left: infoLabel.leftAnchor, bottom: infoLabel.bottomAnchor, right: infoLabel.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
    }
    
    fileprivate func setUpNavBar() {
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    @objc fileprivate func handleTextChange(textField: UITextField) {
        if textField == phoneTextField {
            if textField.text?.count == 3 || textField.text?.count == 7 {
                textField.text = textField.text! + "-"
            }
            else if textField.text?.count == 12 {
                textField.endEditing(false)
                continueButton.isEnabled = true
            }
        }
    }
    
    @objc fileprivate func handleContinue() {
        guard let phoneNumber = phoneTextField.text else {return}
        let fullPhoneNumber = "+1 " + phoneNumber
        PhoneAuthProvider.provider().verifyPhoneNumber(fullPhoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let err = error {
                self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                print(err)
                return
            }
            let verifyController = VerifyController()
            verifyController.verificationID = verificationID
            verifyController.phoneNumber = fullPhoneNumber
            verifyController.isDeleting = self.isDeleting
            self.navigationController?.pushViewController(verifyController, animated: true)
        }
    }
    
    @objc fileprivate func handleCancel() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func handleTermsTap() {
        let viewController = TermsController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
