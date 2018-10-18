//
//  AddPhotosController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/23/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase

class AddPhotosController: UIViewController, Alertable {
    
    var userDictionary: [String: Any]?
    var photosArray = [UIImage]()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Add some photos..."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()
    
    lazy var photosCollectionView: UICollectionView = {
        let cv = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 10), collectionViewLayout: UICollectionViewFlowLayout())
        cv.backgroundColor = .white
        cv.register(AddPhotoCell.self, forCellWithReuseIdentifier: C_CELLID)
        return cv
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
    
    fileprivate func setupUI() {
        view.backgroundColor = .white
        let safeArea = view.safeAreaLayoutGuide
        
        continueButtonView.isHidden = true
        
        view.addSubview(titleLabel)
        titleLabel.anchor(top: safeArea.topAnchor, left: safeArea.leftAnchor, bottom: nil, right: safeArea.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingBottom: 0, paddingRight: 20)
   
        view.addSubview(photosCollectionView)
        photosCollectionView.anchor(top: safeArea.topAnchor, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor, paddingTop: 40, paddingLeft: 20, paddingBottom: 100, paddingRight: 20)
        
    }
    
    
    
    fileprivate func setupDelegates() {
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
    }
    
    @objc fileprivate func handleContinue() {
        self.shouldPresentLoadingView(true)
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let dictionary = userDictionary else {return}
        let user = User(uid: uid, dictionary: dictionary)
        user.updateDisplayName(with: dictionary[C_NAME] as! String)
        user.updateUserDetails(with: dictionary) { (error) in
            if let err = error {
                self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                return
            }
            NotificationService.shared.configure()
            LocationServices.shared.checkLocationAuthStatus()
            user.savePhotos(using: self.photosArray) { (error) in
                if let err = error {
                    self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                    return
                }
                self.shouldPresentLoadingView(false)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
    
    fileprivate func formIsValid() {
        if photosArray.count > 0 {
            continueButtonView.isHidden = false
        }
        else {
            continueButtonView.isHidden = true
        }
    }
}

extension AddPhotosController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        formIsValid()
        let cell = photosCollectionView.dequeueReusableCell(withReuseIdentifier: C_CELLID, for: indexPath) as! AddPhotoCell
        cell.delegate = self
        cell.cellIndex = indexPath.row
        if indexPath.row <= photosArray.count - 1 {
            cell.photoImageView.image = photosArray[indexPath.item]
            cell.photoView.alpha = 1
        }
        else {
            cell.photoView.alpha = 0
        }
        return cell
            
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 2) - 2, height: (collectionView.frame.height / 2) - 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    
}

extension AddPhotosController: AddPhotoCellDelegate {
    func didTapDelete(for cell: AddPhotoCell) {
        cell.photoImageView.image = nil
        cell.photoView.alpha = 0
        guard let index = cell.cellIndex else {return}
        photosArray.remove(at: index)
        photosCollectionView.reloadData()
    }
    
    func didTapAddPhoto(for cell: AddPhotoCell) {
        pickImage()
    }
}

extension AddPhotosController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func pickImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        var image: UIImage?
        if let editedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {
            image = editedImage
        }
        else if let originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            image = originalImage
        }
        dismiss(animated: true, completion: nil)
        guard let photo = image else {return}
        photosArray.append(photo)
        photosCollectionView.reloadData()
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

extension AddPhotosController: SubmitButtonAccessoryViewDelegate {
    func didSubmit() {
        handleContinue()
    }
    
    
}
