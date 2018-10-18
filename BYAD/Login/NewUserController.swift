//
//  NewUserController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/22/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class NewUserController: UIViewController, Alertable {
    
//    var dob: Date?
    var age = 0
    var formIsValid = false
    let genders = ["Male", "Female"]
    let preferredGenders = ["Men", "Women"]
    var ages: [String] = []
    var userInterest = 0
    var userGender = 0
    var userMinAge = 18
    var userMaxAge = 99
    

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Tell us about yourself..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    let nameTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "Name"
        tf.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return tf
    }()
    
    let dobTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "Date of Birth"
        return tf
    }()
    
    let genderTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "Gender"
        return tf
    }()
    
    let favoriteDrinkTextField: CustomTextField = {
        let tf = CustomTextField()
        tf.placeholder = "Favorite Drink"
        tf.addTarget(self, action: #selector(validateForm), for: .editingChanged)
        return tf
    }()
    
    let dobButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleDOB), for: .touchUpInside)
        return button
    }()
    
    let genderButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(handleGender), for: .touchUpInside)
        return button
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
    
    let genderPicker = UIPickerView()
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
    
    
    lazy var continueButtonView: SubmitButtonAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let accessoryView = SubmitButtonAccessoryView(frame: frame)
        accessoryView.delegate = self
        accessoryView.submitButton.setTitle("CONTINUE", for: .normal)
        return accessoryView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return continueButtonView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    fileprivate func setupDelegates() {
        genderPicker.delegate = self
        genderPicker.dataSource = self
        interestedInPicker.delegate = self
        interestedInPicker.dataSource = self
        agesPicker.delegate = self
        agesPicker.dataSource = self
        
        nameTextField.delegate = self
        favoriteDrinkTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
        self.view.addGestureRecognizer(tap)
        setupViewResizerOnKeyboardShown()
    }
    
    fileprivate func setupUI() {
        continueButtonView.isHidden = true
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 20, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        titleLabel.centerHorizontaly(in: view)
        
        view.addSubview(nameTextField)
        nameTextField.anchor(top: titleLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        nameTextField.setSizeAnchors(height: 50, width: nil)
        
        view.addSubview(dobTextField)
        dobTextField.anchor(top: nameTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: -1, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        dobTextField.setSizeAnchors(height: 50, width: nil)
        
        view.addSubview(dobButton)
        dobButton.anchor(top: dobTextField.topAnchor, left: dobTextField.leftAnchor, bottom: dobTextField.bottomAnchor, right: dobTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(genderTextField)
        genderTextField.anchor(top: dobTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: -1, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        genderTextField.setSizeAnchors(height: 50, width: nil)
        
        view.addSubview(genderButton)
        genderButton.anchor(top: genderTextField.topAnchor, left: genderTextField.leftAnchor, bottom: genderTextField.bottomAnchor, right: genderTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(favoriteDrinkTextField)
        favoriteDrinkTextField.anchor(top: genderTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: -1, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        favoriteDrinkTextField.setSizeAnchors(height: 50, width: nil)
        
        view.addSubview(interestedInLabel)
        interestedInLabel.anchor(top: favoriteDrinkTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
        view.addSubview(interestedInTextField)
        interestedInTextField.anchor(top: interestedInLabel.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
        interestedInTextField.setSizeAnchors(height: 50, width: nil)
        
        view.addSubview(interestedInButton)
        interestedInButton.anchor(top: interestedInTextField.topAnchor, left: interestedInTextField.leftAnchor, bottom: interestedInTextField.bottomAnchor, right: interestedInTextField.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        
        view.addSubview(agesLabel)
        agesLabel.anchor(top: interestedInTextField.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
        
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
    
    
    @objc fileprivate func handleDOB() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: self.view.frame.width ,height: 200)
        let datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        if let dateText = dobTextField.text, dobTextField.text != "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            guard let selectedDate = dateFormatter.date(from: dateText) else {return}
            datePickerView.date = selectedDate
        }
        vc.view.addSubview(datePickerView)
        datePickerView.anchor(top: vc.view.safeAreaLayoutGuide.topAnchor, left: vc.view.safeAreaLayoutGuide.leftAnchor, bottom: vc.view.safeAreaLayoutGuide.bottomAnchor, right: vc.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        let dobAlert = UIAlertController(title: "Date of Birth", message: "You must be 18+ to use this app.", preferredStyle: UIAlertController.Style.actionSheet)
        dobAlert.setValue(vc, forKey: "contentViewController")
        dobAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (done) in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy"
            let age = Calendar.current.dateComponents([.year], from: datePickerView.date, to: Date()).year!
            if age < 18 {
                self.showAlert(title: C_ERROR, msg: "You must be over 18 to use this app")
            }
            else {
                self.dobTextField.text = dateFormatter.string(from: datePickerView.date)
                self.age = age
            }
            self.validateForm()
        }))
        self.present(dobAlert, animated: true)
    }
    
    @objc fileprivate func handleGender() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: self.view.frame.width ,height: 100)
        genderPicker.selectRow(userGender, inComponent: 0, animated: false)
        vc.view.addSubview(genderPicker)
        genderPicker.anchor(top: vc.view.safeAreaLayoutGuide.topAnchor, left: vc.view.safeAreaLayoutGuide.leftAnchor, bottom: vc.view.safeAreaLayoutGuide.bottomAnchor, right: vc.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        let genderAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        genderAlert.setValue(vc, forKey: "contentViewController")
        genderAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (done) in
            self.userGender = self.genderPicker.selectedRow(inComponent: 0)
            self.genderTextField.text = self.genders[self.userGender]
            self.validateForm()
        }))
        self.present(genderAlert, animated: true)
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
            self.interestedInTextField.text = self.preferredGenders[self.userInterest]
            self.validateForm()
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
            self.validateForm()
        }))
        self.present(genderAlert, animated: true)
    }
    
    @objc fileprivate func validateForm() {
        var isValid = true
        if nameTextField.text?.count ?? 0 == 0 || dobTextField.text?.count ?? 0 == 0 {
            isValid = false
        }
        if genderTextField.text?.count ?? 0 == 0 || interestedInTextField.text?.count ?? 0 == 0 || maxAgeTextField.text?.count ?? 0 == 0 {
            isValid = false
        }
        if minAgeTextField.text?.count ?? 0 == 0 || maxAgeTextField.text?.count ?? 0 == 0 {
            isValid = false
        }
        
        continueButtonView.isHidden = !isValid
        formIsValid = isValid
    }
    
    @objc fileprivate func handleContinue() {
        view.endEditing(true)
        if self.age < 18 {
            formIsValid = false
            showAlert(title: C_ERROR, msg: "You must be over 18 to use this app")
        }
        if userMinAge > userMaxAge {
            formIsValid = false
            showAlert(title: C_ERROR, msg: "Min age cannot be greater than max age")
        }
        if formIsValid {
            var userDictionary = [String: Any]()
            guard let uid = Auth.auth().currentUser?.uid else {return}
            userDictionary[C_UID] = uid
            userDictionary[C_NAME] = nameTextField.text
            userDictionary[C_GENDER] = userGender
            userDictionary[C_PREFEREDGENDER] = userInterest
            userDictionary[C_MINAGE] = userMinAge
            userDictionary[C_MAXAGE] = userMaxAge
            userDictionary[C_DOB] = dobTextField.text
            userDictionary[C_AGE] = self.age
            userDictionary[C_FAVORITEDRINK] = favoriteDrinkTextField.text ?? ""
            userDictionary[C_ISONLINE] = false
            userDictionary[C_BADGECOUNT] = 0
            let viewController = AddPhotosController()
            viewController.userDictionary = userDictionary
            navigationController?.pushViewController(viewController, animated: true)
        } 
    }
}

extension NewUserController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == interestedInPicker || pickerView == genderPicker {
            return 1
        }
        else {
            return 2
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == interestedInPicker || pickerView == genderPicker {
            return genders.count
        }
        else {
            return ages.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == genderPicker {
            return genders[row]
        }
        else if pickerView == interestedInPicker {
            return preferredGenders[row]
        }
        else {
            return ages[row]
        }
        
    }
    
    
}

extension NewUserController: SubmitButtonAccessoryViewDelegate {
    func didSubmit() {
        handleContinue()
    }
    
    
}
