//
//  PreferencesController.swift
//  BYAD
//
//  Created by Bernie Cartin on 9/25/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class PreferencesController: UIViewController, Alertable {
    
    var user: User?
    let genders = ["Men", "Women"]
    var ages: [String] = []
    var userInterest = 0
    var userMinAge = 18
    var userMaxAge = 99
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Preferences"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    let interestedInLabel: UILabel = {
        let label = UILabel()
        label.text = "Interested In:"
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    let interestedInTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "Interested In"
        tf.textAlignment = .center
        return tf
    }()
    
    let interestedInPicker = UIPickerView()
    
    let interestedInButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleInterestedInTapped), for: .touchUpInside)
        return button
    }()
    
    
    let agesLabel: UILabel = {
        let label = UILabel()
        label.text = "Ages:"
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    let minAgeTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "Min"
        tf.textAlignment = .center
        return tf
    }()

    
    let maxAgeTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "Max"
        tf.textAlignment = .center
        return tf
    }()
    
    let agesPicker = UIPickerView()
    
    let agesButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleAgesTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var saveButtonView: SubmitButtonAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let accessoryView = SubmitButtonAccessoryView(frame: frame)
        accessoryView.delegate = self
        accessoryView.submitButton.setTitle("SAVE", for: .normal)
        return accessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return saveButtonView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupDelegates()
        loadUserData()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.titleView = titleLabel
        saveButtonView.isHidden = true
        
        view.addSubview(interestedInLabel)
        interestedInLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 25, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
        view.addSubview(interestedInTextField)
        interestedInTextField.anchor(top: interestedInLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        interestedInTextField.setSizeAnchors(height: 50, width: nil)
        
        view.addSubview(interestedInButton)
        interestedInButton.anchor(top: interestedInTextField.topAnchor, left: interestedInTextField.leftAnchor, bottom: interestedInTextField.bottomAnchor, right: interestedInTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(agesLabel)
        agesLabel.anchor(top: interestedInTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 25, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
   
        minAgeTextField.setSizeAnchors(height: 50, width: nil)
        maxAgeTextField.setSizeAnchors(height: 50, width: nil)
        let agesStackView = UIStackView(arrangedSubviews: [minAgeTextField,maxAgeTextField])
        agesStackView.axis = .horizontal
        agesStackView.distribution = .fillEqually
        agesStackView.spacing = 0
        view.addSubview(agesStackView)
        agesStackView.anchor(top: agesLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)

        view.addSubview(agesButton)
        agesButton.anchor(top: agesStackView.topAnchor, left: agesStackView.leftAnchor, bottom: agesStackView.bottomAnchor, right: agesStackView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        for number in 18...99 {
            ages.append(String(describing: number))
        }
        
        
        
    }
    
    fileprivate func setupDelegates() {
        agesPicker.delegate = self
        agesPicker.dataSource = self
        interestedInPicker.delegate = self
        interestedInPicker.dataSource = self
    }
    
    fileprivate func loadUserData() {
        guard let user = self.user else {return}
        userInterest = user.preferredGender ?? 0
        userMinAge = user.minAge ?? 18
        userMaxAge = user.maxAge ?? 99
        interestedInTextField.text = genders[userInterest]
        minAgeTextField.text = ages[userMinAge - 18]
        maxAgeTextField.text = ages[userMaxAge - 18]
    }
    
    
    
    @objc fileprivate func handleInterestedInTapped() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: self.view.frame.width ,height: 100)

        interestedInPicker.selectRow(userInterest, inComponent: 0, animated: false)
        vc.view.addSubview(interestedInPicker)
        interestedInPicker.anchor(top: vc.view.safeAreaLayoutGuide.topAnchor, left: vc.view.safeAreaLayoutGuide.leftAnchor, bottom: vc.view.safeAreaLayoutGuide.bottomAnchor, right: vc.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        let genderAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        genderAlert.setValue(vc, forKey: "contentViewController")
        genderAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (done) in
            self.userInterest = self.interestedInPicker.selectedRow(inComponent: 0)
            self.interestedInTextField.text = self.genders[self.userInterest]
            self.checkForChanges()
        }))
        self.present(genderAlert, animated: true)
    }
    
    @objc fileprivate func handleAgesTapped() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: self.view.frame.width ,height: 100)
        
        agesPicker.selectRow(userMinAge - 18, inComponent: 0, animated: false)
        agesPicker.selectRow(userMaxAge - 18, inComponent: 1, animated: false)
        vc.view.addSubview(agesPicker)
        agesPicker.anchor(top: vc.view.safeAreaLayoutGuide.topAnchor, left: vc.view.safeAreaLayoutGuide.leftAnchor, bottom: vc.view.safeAreaLayoutGuide.bottomAnchor, right: vc.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        let genderAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        genderAlert.setValue(vc, forKey: "contentViewController")
        genderAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (done) in
            if self.agesPicker.selectedRow(inComponent: 0) > self.agesPicker.selectedRow(inComponent: 1) {
                self.showAlert(title: C_ERROR, msg: "Max age cannot be less than min age")
            }
            else {
                self.userMinAge = self.agesPicker.selectedRow(inComponent: 0) + 18
                self.userMaxAge = self.agesPicker.selectedRow(inComponent: 1) + 18
                self.minAgeTextField.text = self.ages[self.userMinAge - 18]
                self.maxAgeTextField.text = self.ages[self.userMaxAge - 18]
            }
            self.checkForChanges()
        }))
        self.present(genderAlert, animated: true)
    }
    
    fileprivate func checkForChanges() {
        if userInterest != self.user?.preferredGender || userMinAge != self.user?.minAge || userMaxAge != self.user?.maxAge {
            saveButtonView.isHidden = false
        }
        else {
            saveButtonView.isHidden = true
        }
    }
    
    @objc fileprivate func handleSave() {
        var userDictionary = [String: Any]()
        guard let user = self.user else {return}
        userDictionary[C_PREFEREDGENDER] = userInterest
        userDictionary[C_MINAGE] = userMinAge
        userDictionary[C_MAXAGE] = userMaxAge
        user.updateUserDetails(with: userDictionary) { (error) in
            if let err = error {
                self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                return
            }
            //UPDATE USER CLASS
            self.user?.preferredGender = self.userInterest
            self.user?.minAge = self.userMinAge
            self.user?.maxAge = self.userMaxAge
            self.saveButtonView.isHidden = true
            // SHOW SAVED SUCCESFULL LABEL
            self.showMessage(message: "Saved Successfully", center: self.view.center)
        }
        
    }
    
}

extension PreferencesController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == interestedInPicker {
            return 1
        }
        else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == interestedInPicker {
            return genders.count
        }
        else {
            return ages.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == interestedInPicker {
            return genders[row]
        }
        else {
            return ages[row]
        }
        
    }
    
    
}

extension PreferencesController: SubmitButtonAccessoryViewDelegate {
    func didSubmit() {
        handleSave()
    }
    
    
}
