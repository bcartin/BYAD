//
//  PersonalInfoController.swift
//  BYAD
//
//  Created by Bernie Cartin on 9/24/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class PersonalInfoController: UIViewController, Alertable {
    
    var age = 0
    var formIsValid = false
    var user: User?
    var userGender = 0
    let genders = ["Male", "Female"]
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Personal Info"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
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
        setUpDelegates()
        loadUserData()
    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationItem.titleView = titleLabel
        saveButtonView.isHidden = true
        
        view.addSubview(nameTextField)
        nameTextField.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, bottom: nil, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 25, paddingLeft: -1, paddingBottom: 0, paddingRight: -1)
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
        
    }
    
    fileprivate func setUpDelegates() {
        nameTextField.delegate = self
        favoriteDrinkTextField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap(sender:)))
        self.view.addGestureRecognizer(tap)
        setupViewResizerOnKeyboardShown()
    }
    
    fileprivate func loadUserData() {
        guard let user = self.user else {return}
        nameTextField.text = user.name
        favoriteDrinkTextField.text = user.favoriteDrink
        dobTextField.text = user.dob
        userGender = user.gender ?? 0
        genderTextField.text = genders[userGender]
        guard let age = user.age else {return}
        self.age = age
        
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
                self.age = age
                self.dobTextField.text = dateFormatter.string(from: datePickerView.date)
            }
            self.validateForm()
        }))
        self.present(dobAlert, animated: true)
    }
    
    @objc fileprivate func handleGender() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: self.view.frame.width ,height: 100)
        let genderPicker = UIPickerView()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.selectRow(userGender, inComponent: 0, animated: false)
        vc.view.addSubview(genderPicker)
        genderPicker.anchor(top: vc.view.safeAreaLayoutGuide.topAnchor, left: vc.view.safeAreaLayoutGuide.leftAnchor, bottom: vc.view.safeAreaLayoutGuide.bottomAnchor, right: vc.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        let genderAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        genderAlert.setValue(vc, forKey: "contentViewController")
        genderAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { (done) in
            self.userGender = genderPicker.selectedRow(inComponent: 0)
            self.genderTextField.text = self.genders[self.userGender]
            self.validateForm()
        }))
        self.present(genderAlert, animated: true)
    }
    
    @objc fileprivate func validateForm() {
        var isValid = true
        if nameTextField.text?.count ?? 0 == 0 || dobTextField.text?.count ?? 0 == 0 {
            isValid = false
        }
        if userGender < 0 {
            isValid = false
        }
        saveButtonView.isHidden = !isValid
        formIsValid = isValid
    }
    
    @objc fileprivate func handleSave() {
        view.endEditing(true)
        if self.age < 18 {
            formIsValid = false
            showAlert(title: C_ERROR, msg: "You must be over 18 to use this app")
        }
        if formIsValid {
            var userDictionary = [String: Any]()
            guard let user = self.user else {return}
            userDictionary[C_NAME] = nameTextField.text
            userDictionary[C_GENDER] = userGender
            userDictionary[C_DOB] = dobTextField.text
            userDictionary[C_AGE] = self.age
            userDictionary[C_FAVORITEDRINK] = favoriteDrinkTextField.text ?? ""
            user.updateUserDetails(with: userDictionary) { (error) in
                if let err = error {
                    self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                    return
                }
                user.updateDisplayName(with: self.nameTextField.text ?? "")
                self.saveButtonView.isHidden = true
                //UPDATE USER CLASS
                self.user?.name = self.nameTextField.text
                self.user?.gender = self.userGender
                self.user?.dob = self.dobTextField.text
                self.user?.age = self.age
                self.user?.favoriteDrink = self.favoriteDrinkTextField.text ?? ""
                // SHOW SAVED SUCCESFULL LABEL
                self.showMessage(message: "Saved Successfully", center: self.view.center)
            }

        }
    }
    
    
    
}

extension PersonalInfoController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    
}

extension PersonalInfoController: SubmitButtonAccessoryViewDelegate {
    func didSubmit() {
        handleSave()
    }
    
    
}

