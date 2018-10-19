//
//  ProfileController.swift
//  BYAD
//
//  Created by Bernie Cartin on 8/26/18.
//  Copyright © 2018 garsontech. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ProfileController: UIViewController, Alertable, UIScrollViewDelegate, GADBannerViewDelegate {
    
    var user: User?
    var userPhotos = [UIImage]()
    var displaySettingsButton = false
    var displayByadButton = false
    var displayDismissButton = false
    var displayActionsButton = false
    var userBlocked = false
    var reasonsArray: [String] = ["Offensive Language", "Rude/Obscene Photos", "Inappropriate Messages", "Other"]
    
    var bannerView: GADBannerView!
    
    var scrollView = UIScrollView()
    var pageControl : UIPageControl = UIPageControl(frame:CGRect(x: 50, y: 300, width: 200, height: 50))
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .white
        return label
    }()
    
    let detailsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 1, alpha: 0.8)
        view.layer.cornerRadius = 40
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgb(red: 85, green: 85, blue: 85)
        label.font = UIFont.systemFont(ofSize: 26)
        return label
    }()
    
    let drinkLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgb(red: 85, green: 85, blue: 85)
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let cocktailImage: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        iv.image = #imageLiteral(resourceName: "cocktail-dark").withRenderingMode(.alwaysOriginal)
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
        
    }()
    
    let byadView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.0)
        view.layer.cornerRadius = 40
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgb(red: 85, green: 85, blue: 85)
        return view
    }()
    
    let byadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("BYAD?", for: .normal)
        button.setTitle("", for: .disabled)
        button.setImage(UIImage(named: "cocktail.png")?.withRenderingMode(.alwaysOriginal), for: .disabled)
        button.titleLabel?.font = UIFont(name: "ChalkboardSE-Bold", size: 24)
        button.setTitleColor(UIColor.rgb(red: 85, green: 85, blue: 85), for: .normal)
        button.setTitleColor(UIColor(white: 1, alpha: 0.8), for: .disabled)
        button.addTarget(self, action: #selector(handleBYAD), for: .touchUpInside)
        button.clipsToBounds = true
        button.layer.cornerRadius = 40
        button.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return button
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "cancel.png"), for: .normal)
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        //Ad Banner Config
        bannerView.delegate = self
        bannerView.adSize = kGADAdSizeSmartBannerPortrait
//        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716" //Test
        bannerView.adUnitID = "ca-app-pub-4709796125234322/2019054959"  //Prod
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadImages()
        if displayByadButton {
            checkRequest()
        }
    }
    
    override func didReceiveMemoryWarning() {
        imageCache.removeAllObjects()
        userCache.removeAllObjects()
    }
    
    fileprivate func setupDelegates(){

    }
    
    fileprivate func setupUI() {
        view.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let safeArea = self.view.safeAreaLayoutGuide
        titleLabel.text = user?.name
        navigationItem.titleView = titleLabel
        if displaySettingsButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "settings").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(handleSettingsTapped))
        }
        else if displayActionsButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "actions.png"), style: .plain, target: self, action: #selector(showActions))
        }
        
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        view.addSubview(bannerView)
        bannerView.anchor(top: nil, left: safeArea.leftAnchor, bottom: safeArea.bottomAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        bannerView.setSizeAnchors(height: 50, width: nil)
        
    }
    
    fileprivate func loadImages() {
        self.userPhotos = []
        guard let photosUrl = self.user?.photosUrls else {return}
        let safeArea = self.view.safeAreaLayoutGuide
        self.scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width - 20, height: safeArea.layoutFrame.height - 70))
        self.configurePageControl(withMaxValue: photosUrl.count)
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
        self.scrollView.showSpinner(true)
        for (index, photoUrl) in photosUrl.enumerated() {
            
            var frame = CGRect.zero
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(index)
            frame.origin.y = 0
            frame.size = self.scrollView.frame.size
            self.scrollView.isPagingEnabled = true
            
            let myImageView: CustomImageView = CustomImageView()
            self.scrollView.addSubview(myImageView)
            myImageView.backgroundColor = UIColor(white: 0, alpha: 0.1)
            myImageView.loadImage(from: photoUrl)
            myImageView.frame = frame
            
            
        }
        user?.photos = userPhotos
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width * CGFloat(photosUrl.count), height: self.scrollView.frame.size.height)
        self.pageControl.layer.zPosition = 1
        
        self.scrollView.anchor(top: safeArea.topAnchor, left: safeArea.leftAnchor, bottom: bannerView.topAnchor, right: safeArea.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingBottom: 10, paddingRight: 10)
        self.scrollView.layer.cornerRadius = 40
        
        byadView.addSubview(dividerView)
        dividerView.anchor(top: byadView.topAnchor, left: byadView.leftAnchor, bottom: byadView.bottomAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        dividerView.setSizeAnchors(height: nil, width: 1)
        
        byadView.addSubview(byadButton)
        byadButton.anchor(top: byadView.topAnchor, left: byadView.leftAnchor, bottom: byadView.bottomAnchor, right: byadView.rightAnchor, paddingTop: 0, paddingLeft: 1, paddingBottom: 0, paddingRight: 0)
        
        if displayByadButton {
            detailsView.addSubview(byadView)
            byadView.anchor(top: detailsView.topAnchor, left: nil, bottom: detailsView.bottomAnchor, right: detailsView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
            byadView.setSizeAnchors(height: nil, width: 100)
        }
        
        self.view.addSubview(self.detailsView)
        self.detailsView.anchor(top: nil, left: safeArea.leftAnchor, bottom: bannerView.topAnchor, right: safeArea.rightAnchor, paddingTop: 0, paddingLeft: 20, paddingBottom: 20, paddingRight: 20)
        self.detailsView.setSizeAnchors(height: 100, width: nil)
        
        self.pageControl.anchor(top: nil, left: nil, bottom: self.detailsView.topAnchor, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        self.pageControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        
        guard let user = self.user else {return}
        guard let name = user.name else {return}
        guard let age = user.age else {return}
        let ageString = String(describing: age)
        nameLabel.text = name + ", " + ageString

        guard let drink = user.favoriteDrink else {return}
        drinkLabel.text = drink
        cocktailImage.setSizeAnchors(height: 12, width: 12)
        let drinkStackView = UIStackView(arrangedSubviews: [cocktailImage, drinkLabel])
        drinkStackView.axis = .horizontal
        drinkStackView.spacing = 5
        
        let detailsStackView = UIStackView(arrangedSubviews: [nameLabel, drinkStackView])
        detailsStackView.axis = .vertical
        detailsStackView.distribution = .fillEqually
        detailsStackView.spacing = 5
        
        detailsView.addSubview(detailsStackView)
        detailsStackView.anchor(top: detailsView.topAnchor, left: detailsView.leftAnchor, bottom: detailsView.bottomAnchor, right: detailsView.rightAnchor, paddingTop: 19, paddingLeft: 22, paddingBottom: 19, paddingRight: 100)
        
        if displayDismissButton {
            self.view.addSubview(dismissButton)
            dismissButton.anchor(top: scrollView.topAnchor, left: nil, bottom: nil, right: scrollView.rightAnchor, paddingTop: 15, paddingLeft: 0, paddingBottom: 0, paddingRight: 15)
            dismissButton.setSizeAnchors(height: 50, width: 50)
        }
        
    }
    
    @objc fileprivate func handleBYAD() {

        byadButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        byadButton.isEnabled = false
        sendRequest()
    }
    
    fileprivate func sendRequest() {
        guard let senderId = Auth.auth().currentUser?.uid else {return}
        guard let recipientId = user?.uid else {return}
        guard let senderName = Auth.auth().currentUser?.displayName else {return}
        guard let recipientName = user?.name else {return}
        let timeStamp = Date().timeIntervalSince1970
        var requestDict: [String:Any] = [:]
        requestDict[C_SENDERID] = senderId
        requestDict[C_SENDERNAME] = senderName
        requestDict[C_TIMESTAMP] = timeStamp
        requestDict[C_ISNEW] = true
        requestDict[C_RECIPIENTID] = recipientId
        requestDict[C_RECIPIENTNAME] = recipientName
        requestDict[C_ISACCEPTED] = false
        RequestServices.shared.createRequest(to: recipientId, data: requestDict)
        
    }
    
    fileprivate func checkRequest() {
        guard let userId = user?.uid else {return}
        let enableButton = RequestServices.shared.checkIfRequestSent(to: userId)
        if !enableButton {
            byadButton.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            byadButton.isEnabled = false
        }
    }
    
    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func showActions() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var title = "Block User"
        if userBlocked {
            title = "Unblock"
        }
        let blockAction = UIAlertAction(title: title, style: .default) { (_) in
            if self.userBlocked {
                self.unblockUser()
            }
            else {
                self.blockUser()
            }
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
            guard let userID = Auth.auth().currentUser?.uid else {return}
            self.user?.blockUser(by: userID, handler: { (error) in
                if let err = error {
                    self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                    return
                }
                self.userBlocked = true
                
                let confirmationAlert = UIAlertController(title: "User Blocked", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default
                    , handler: { (action) in
                        self.navigationController?.popToRootViewController(animated: true)
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
    
    fileprivate func unblockUser() {
        guard let userID = Auth.auth().currentUser?.uid else {return}
        user?.unblockUser(by: userID, handler: { (error) in
            if let err = error {
                self.showAlert(title: C_ERROR, msg: err.localizedDescription)
                return
            }
            self.userBlocked = false
            self.showAlert(title: "User Unblocked", msg: nil)
        })
        
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
            guard let personId = self.user?.uid else {return}
            guard let myUID = Auth.auth().currentUser?.uid else {return}
            let myUser = User(uid: myUID)
            let reason = self.reasonsArray[reasonPickerView.selectedRow(inComponent: 0)]
            myUser.reportUser(userID: personId, reason: reason)
            self.showAlert(title: "User has been reported", msg: "We will review the report and take action accordingly")
        }))
        reportAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(reportAlert, animated: true)
    }
    

    
    func configurePageControl(withMaxValue value: Int) {
        // The total number of pages that are available is based on how many available colors we have.
        self.pageControl.numberOfPages = value
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor.red
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.mainBlue()
        self.view.addSubview(pageControl)
        
    }

    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageControl.currentPage = Int(pageNumber)
    }
    
    @objc fileprivate func handleSettingsTapped() {
        let settingsControler = SettingsController()
        settingsControler.user = self.user
        navigationController?.pushViewController(settingsControler, animated: true)
    }
}

extension ProfileController: UIPickerViewDataSource, UIPickerViewDelegate {
    
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


